# =============================================================================
# prLogisticBoot.R
#
# Bootstrap confidence intervals for prevalence ratios.
# Two exported functions:
#   prLogisticBootCond() -- conditional standardisation
#   prLogisticBootMarg() -- marginal standardisation
# =============================================================================


# --------------------------------------------------------------------------- #
#  Internal bootstrap statistic functions                                      #
# --------------------------------------------------------------------------- #

.boot_stat_cond <- function(data, indices, fit, ref, conf) {
  fit_b <- tryCatch(
    stats::update(fit, data = data[indices, , drop = FALSE]),
    error = function(e) NULL
  )
  if (is.null(fit_b)) return(rep(NA_real_, length(.get_coef(fit)) - 1L))
  tbl <- pr_conditional(fit_b, ref, conf)
  as.numeric(tbl[, "Estimate"])
}

.boot_stat_marg <- function(data, indices, fit, ref, conf) {
  data_b <- data[indices, , drop = FALSE]
  fit_b  <- tryCatch(
    stats::update(fit, data = data_b),
    error = function(e) NULL
  )
  if (is.null(fit_b)) return(rep(NA_real_, length(.get_coef(fit)) - 1L))
  X_b   <- .get_model_matrix(fit_b)
  tbl   <- pr_marginal(fit_b, X_b, ref, conf)
  as.numeric(tbl[, "Estimate"])
}


# --------------------------------------------------------------------------- #
#  .run_bootstrap() -- shared machinery                                         #
# --------------------------------------------------------------------------- #

.run_bootstrap <- function(fit, data, conf, R, ref, ref_continuous,
                            ref_values, stat_fn, standardisation, cl) {

  .check_model(fit)

  X_full   <- .get_model_matrix(fit)
  X_no_int <- X_full[, -1L, drop = FALSE]
  ref      <- .resolve_ref(X_no_int, ref_values, ref_continuous)

  nms <- names(.get_coef(fit))[-1L]
  p   <- length(nms)

  # Point estimates from full data
  tbl_pt <- if (standardisation == "conditional") {
    pr_conditional(fit, ref, conf)
  } else {
    pr_marginal(fit, X_full, ref, conf)
  }

  # Bootstrap
  boot_out <- boot::boot(
    data      = data,
    statistic = stat_fn,
    R         = R,
    fit       = fit,
    ref       = ref,
    conf      = conf
  )

  # Confidence intervals for each PR
  pct_lo  <- (1 - conf) / 2
  pct_hi  <- 1 - pct_lo
  pct_lbl <- paste0(as.character(c(pct_lo, pct_hi) * 100), "%")

  ci_mat <- matrix(NA_real_, nrow = p, ncol = 4L,
                   dimnames = list(
                     nms,
                     c(paste0("Normal.", pct_lbl),
                       paste0("Pct.", pct_lbl))
                   ))

  for (i in seq_len(p)) {
    bci <- tryCatch(
      boot::boot.ci(boot_out, type = c("norm", "perc"), index = i),
      error = function(e) NULL
    )
    if (!is.null(bci)) {
      ci_mat[i, 1:2] <- bci$normal[2:3]
      ci_mat[i, 3:4] <- bci$percent[4:5]
    }
  }

  # Truncate negative CIs at 0
  ci_mat <- pmax(ci_mat, 0)

  # Full table: Estimate | Normal lo | Normal hi | Pct lo | Pct hi
  out_tbl <- cbind(tbl_pt[, "Estimate", drop = FALSE], ci_mat)

  .new_prLogistic(
    table           = out_tbl,
    conf            = conf,
    method          = "bootstrap",
    standardisation = standardisation,
    model_type      = .model_label(fit),
    call            = cl
  )
}


# --------------------------------------------------------------------------- #
#  prLogisticBootCond()                                                        #
# --------------------------------------------------------------------------- #

#' Bootstrap CI for Prevalence Ratios -- Conditional Standardisation
#'
#' Estimates adjusted prevalence ratios (PR) using conditional standardisation
#' and obtains confidence intervals via bootstrap resampling (normal-
#' approximation and percentile methods).
#'
#' @inheritParams prLogisticDelta
#' @param data Data frame used to fit `fit`. Required for bootstrapping.
#' @param R Integer: number of bootstrap replicates. Default `999`.
#'
#' @details
#' At each bootstrap replicate the model is refitted on a resampled dataset
#' and conditional PRs are computed. Two CI types are returned:
#' \describe{
#'   \item{Normal}{Bootstrap normal-approximation interval.}
#'   \item{Percentile}{Empirical quantiles of the bootstrap distribution.}
#' }
#' Use [prLogistic::confint.prLogistic()] with `type = "normal"` or `type = "percentile"`
#' to extract a single CI type.
#'
#' @inherit prLogisticDelta return
#' @seealso [prLogistic::prLogisticDelta()], [prLogistic::prLogisticBootMarg()]
#'
#' @references
#' Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
#' \doi{10.1590/0001-3765202120190316}
#'
#' Davison, A. C. & Hinkley, D. V. (1997). *Bootstrap Methods and their
#' Application*. Cambridge University Press.
#'
#' @examples
#' fit_glm <- glm(case ~ induced + spontaneous + parity,
#'                family = binomial, data = infert)
#'
#' set.seed(42)
#' res <- prLogisticBootCond(fit_glm, data = infert, R = 199)
#' print(res)
#' plot(res)
#'
#' @export
prLogisticBootCond <- function(fit,
                                data,
                                conf           = 0.95,
                                R              = 999L,
                                ref_values     = NULL,
                                ref_continuous = c("median", "mean")) {

  cl             <- match.call()
  ref_continuous <- match.arg(ref_continuous)

  .run_bootstrap(
    fit             = fit,
    data            = data,
    conf            = conf,
    R               = R,
    ref             = NULL,
    ref_continuous  = ref_continuous,
    ref_values      = ref_values,
    stat_fn         = .boot_stat_cond,
    standardisation = "conditional",
    cl              = cl
  )
}


# --------------------------------------------------------------------------- #
#  prLogisticBootMarg()                                                        #
# --------------------------------------------------------------------------- #

#' Bootstrap CI for Prevalence Ratios -- Marginal Standardisation
#'
#' Estimates adjusted prevalence ratios (PR) using marginal standardisation
#' (population-averaged) and obtains confidence intervals via bootstrap resampling.
#'
#' @inheritParams prLogisticBootCond
#'
#' @details
#' Marginal standardisation averages counterfactual predicted probabilities
#' over the empirical covariate distribution, giving a population-averaged PR.
#' At each bootstrap replicate the model is refitted and marginal PRs are
#' recomputed.
#'
#' @inherit prLogisticDelta return
#' @seealso [prLogistic::prLogisticDelta()], [prLogistic::prLogisticBootCond()]
#'
#' @examples
#' fit_glm <- glm(case ~ induced + spontaneous + parity,
#'                family = binomial, data = infert)
#'
#' set.seed(42)
#' res <- prLogisticBootMarg(fit_glm, data = infert, R = 199)
#' print(res)
#'
#' @export
prLogisticBootMarg <- function(fit,
                                data,
                                conf           = 0.95,
                                R              = 999L,
                                ref_values     = NULL,
                                ref_continuous = c("median", "mean")) {

  cl             <- match.call()
  ref_continuous <- match.arg(ref_continuous)

  .run_bootstrap(
    fit             = fit,
    data            = data,
    conf            = conf,
    R               = R,
    ref             = NULL,
    ref_continuous  = ref_continuous,
    ref_values      = ref_values,
    stat_fn         = .boot_stat_marg,
    standardisation = "marginal",
    cl              = cl
  )
}
