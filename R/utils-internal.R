# =============================================================================
# utils-internal.R
# Internal helper functions -- not exported.
# =============================================================================

# --------------------------------------------------------------------------- #
#  Model-type checkers                                                         #
# --------------------------------------------------------------------------- #

.is_glm    <- function(x) inherits(x, "glm") && !inherits(x, "glmerMod") && !inherits(x, "geeglm") && !inherits(x, "svyglm")
.is_glmer  <- function(x) inherits(x, "glmerMod")
.is_gee    <- function(x) inherits(x, "geeglm")
.is_svyglm <- function(x) inherits(x, "svyglm") && !inherits(x, "geeglm")

.supported_model <- function(x) {
  .is_glm(x) || .is_glmer(x) || .is_gee(x) || .is_svyglm(x)
}

.model_label <- function(x) {
  if (.is_glm(x))    return("glm")
  if (.is_glmer(x))  return("glmer")
  if (.is_gee(x))    return("geeglm")
  if (.is_svyglm(x)) return("svyglm")
  "unknown"
}

# --------------------------------------------------------------------------- #
#  Coefficient / covariance extraction (unified across model types)           #
# --------------------------------------------------------------------------- #

.get_coef <- function(fit) {
  if (.is_glmer(fit)) return(lme4::fixef(fit))
  stats::coef(fit)
}

.get_vcov <- function(fit) {
  # geepack::geeglm stores the robust sandwich variance in $geese$vbeta.
  # vcov.geeglm() in older geepack versions has a bug (calls residuals()
  # with an unsupported type argument), so we extract directly from the
  # internal slot when available.
  if (.is_gee(fit)) {
    vc <- tryCatch(
      {
        v <- fit$geese$vbeta
        rn <- names(stats::coef(fit))
        dimnames(v) <- list(rn, rn)
        v
      },
      error = function(e) as.matrix(stats::vcov(fit))
    )
    return(as.matrix(vc))
  }
  as.matrix(stats::vcov(fit))
}

# --------------------------------------------------------------------------- #
#  Model matrix extraction                                                     #
# --------------------------------------------------------------------------- #

.get_model_matrix <- function(fit) {
  if (.is_glmer(fit)) {
    # lme4 stores the fixed-effect design matrix directly
    mm <- lme4::getME(fit, "X")
    return(as.matrix(mm))
  }
  if (.is_gee(fit)) {
    # Use the design matrix stored in the internal geese slot to avoid
    # triggering summary.glm (which calls residuals.geeglm with a bad arg
    # in older geepack versions)
    mm <- fit$geese$X
    if (is.null(mm)) mm <- stats::model.matrix(fit)
    colnames(mm) <- fit$geese$xnames
    return(as.matrix(mm))
  }
  # glm, svyglm: standard model.matrix
  as.matrix(stats::model.matrix(fit))
}

# --------------------------------------------------------------------------- #
#  Resolve reference values for each predictor                                 #
#                                                                              #
#  Returns a named numeric vector of length p (intercept excluded) with the   #
#  reference value for each column of the design matrix (excluding intercept). #
#                                                                              #
#  Logic:                                                                      #
#   1. Binary/dummy columns  -> 0 (the reference / non-exposed level).        #
#   2. Continuous columns    -> median of observed values (default) or the    #
#      value supplied in `ref_values`.                                         #
#   3. `ref_values` overrides everything: user always wins.                   #
# --------------------------------------------------------------------------- #

.resolve_ref <- function(X_no_int, ref_values, ref_continuous) {
  # X_no_int : design matrix WITHOUT the intercept column
  # ref_values      : named list supplied by user (NULL = none)
  # ref_continuous  : "median" | "mean"

  p   <- ncol(X_no_int)
  nms <- colnames(X_no_int)
  ref <- numeric(p)
  names(ref) <- nms

  for (j in seq_len(p)) {
    col <- X_no_int[, j]

    # Is this column binary (0/1 dummy)?
    is_binary <- all(col %in% c(0, 1))

    if (is_binary) {
      ref[j] <- 0L
    } else {
      # Continuous: use median or mean
      ref[j] <- if (ref_continuous == "median") stats::median(col, na.rm = TRUE)
                 else                            mean(col, na.rm = TRUE)
    }
  }

  # Apply user overrides
  if (!is.null(ref_values)) {
    bad <- setdiff(names(ref_values), nms)
    if (length(bad) > 0) {
      warning(
        "ref_values names not found in model matrix columns and will be ignored: ",
        paste(bad, collapse = ", ")
      )
    }
    for (nm in intersect(names(ref_values), nms)) {
      ref[nm] <- as.numeric(ref_values[[nm]])
    }
  }

  ref
}

# --------------------------------------------------------------------------- #
#  Build the "exposed" and "reference" design row for predictor j             #
#                                                                              #
#  For predictor j (column index in X_no_int):                                #
#    x1_j : reference row with column j set to 1 (exposed)                   #
#    x0_j : reference row with column j set to 0 (reference/baseline)        #
#  All other columns are fixed at their reference values (`ref`).             #
#                                                                              #
#  The intercept is prepended ? length = p+1.                                 #
# --------------------------------------------------------------------------- #

.build_contrast_rows <- function(j, ref) {
  p  <- length(ref)
  x1 <- c(1, ref)          # intercept + all covariates at reference
  x0 <- c(1, ref)
  x1[j + 1L] <- 1          # exposed
  x0[j + 1L] <- 0          # unexposed / reference
  list(x1 = x1, x0 = x0)
}

# --------------------------------------------------------------------------- #
#  Logistic mean: p = expit(x'beta)                                           #
# --------------------------------------------------------------------------- #

.expit <- function(eta) {
  # Numerically stable version
  ifelse(eta >= 0,
         1 / (1 + exp(-eta)),
         exp(eta) / (1 + exp(eta)))
}

# --------------------------------------------------------------------------- #
#  Delta-method variance for log(PR_conditional)                              #
#                                                                              #
#  Gradient of log(PR) w.r.t. beta (Oliveira et al. 1997):                   #
#    x* = (1-p1)*x1 - (1-p0)*x0                                              #
#  Var(log PR) ? x*' Sigma x*                                                 #
# --------------------------------------------------------------------------- #

.delta_var_logPR <- function(p1, p0, x1, x0, Sigma) {
  xstar <- (1 - p1) * x1 - (1 - p0) * x0
  as.numeric(crossprod(xstar, Sigma %*% xstar))
}

# --------------------------------------------------------------------------- #
#  Build CI columns from log(PR) +/- z * se                                     #
# --------------------------------------------------------------------------- #

.make_ci <- function(logPR, se, conf) {
  z    <- abs(stats::qnorm((1 - conf) / 2))
  lo   <- exp(logPR - z * se)
  hi   <- exp(logPR + z * se)
  list(lo = lo, hi = hi)
}

# --------------------------------------------------------------------------- #
#  Assemble final matrix with row/col names                                   #
# --------------------------------------------------------------------------- #

.assemble_table <- function(PR, lo, hi, conf, nms) {
  pct <- paste0(as.character(c((1 - conf) / 2, 1 - (1 - conf) / 2) * 100), "%")
  out <- cbind(PR, lo, hi)
  colnames(out) <- c("Estimate", pct)
  rownames(out) <- nms
  out
}

# --------------------------------------------------------------------------- #
#  Validate model object                                                       #
# --------------------------------------------------------------------------- #

.check_model <- function(fit) {
  if (!.supported_model(fit)) {
    stop(
      "Object must be one of: glm (binomial), glmerMod (lme4), ",
      "geeglm (geepack), or svyglm (survey). Got: ",
      paste(class(fit), collapse = "/")
    )
  }

  # Check binomial family (only for model types where $family is safe to access)
  if (.is_glm(fit) || .is_svyglm(fit)) {
    fam <- tryCatch(fit$family$family, error = function(e) "unknown")
    lnk <- tryCatch(fit$family$link,   error = function(e) "unknown")
    if (!grepl("binomial|quasibinomial", fam)) {
      warning("Expected a binomial family; got '", fam, "'. Proceed with caution.")
    }
    if (lnk != "logit") {
      warning(
        "prLogistic is designed for the logit link; got '", lnk, "'. ",
        "Results may not be meaningful."
      )
    }
  }
  # geeglm: access family safely via the family slot
  if (.is_gee(fit)) {
    fam <- tryCatch(fit$family$family, error = function(e) "unknown")
    lnk <- tryCatch(fit$family$link,   error = function(e) "unknown")
    if (!grepl("binomial|quasibinomial", fam)) {
      warning("Expected a binomial family for GEE; got '", fam, "'. Proceed with caution.")
    }
  }

  invisible(TRUE)
}

# --------------------------------------------------------------------------- #
#  Warn if any PR estimate is outside (0, 10) -- likely a numerical issue      #
# --------------------------------------------------------------------------- #

.check_pr_range <- function(PR, nms) {
  bad <- which(PR < 0 | PR > 10 | !is.finite(PR))
  if (length(bad) > 0) {
    warning(
      "Unusual PR estimate(s) detected for: ",
      paste(nms[bad], collapse = ", "),
      ". Check model convergence and predictor coding."
    )
  }
  invisible(NULL)
}
