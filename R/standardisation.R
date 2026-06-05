# =============================================================================
# standardisation.R
#
# Core estimation engine.
#
# pr_conditional() and pr_marginal() are the internal workhorses.
# They accept any fitted model whose coefficients/vcov can be extracted
# and return a numeric matrix [p x 3]: Estimate | lower CI | upper CI.
#
# Mathematical reference:
#   Amorim & Ospina (2021) An Acad Bras Cienc 93(4): e20190316
#   Oliveira et al. (1997) Rev Saude Publica 31:90-99
# =============================================================================


# --------------------------------------------------------------------------- #
#  pr_conditional()                                                            #
#                                                                              #
#  For each predictor j (j = 1, ..., p):                                      #
#    - Fix all other predictors at their reference values (ref).              #
#    - Set predictor j to 1 (exposed) or 0 (unexposed).                      #
#    - Compute p1 = expit(x1'beta),  p0 = expit(x0'beta).                          #
#    - PR_j = p1 / p0.                                                        #
#    - Var(log PR_j) via delta method: x*'Sigmax*, x* = (1-p1)x1 - (1-p0)x0.   #
#                                                                              #
#  `ref`  : named numeric vector (length p, NO intercept) of reference vals. #
#  `conf` : confidence level, e.g. 0.95.                                      #
# --------------------------------------------------------------------------- #

pr_conditional <- function(fit, ref, conf) {

  beta  <- .get_coef(fit)        # named, length p+1 (includes intercept)
  Sigma <- .get_vcov(fit)        # (p+1) x (p+1)
  p     <- length(beta) - 1L    # number of predictors (excl. intercept)
  nms   <- names(beta)[-1L]

  PR  <- numeric(p)
  lo  <- numeric(p)
  hi  <- numeric(p)

  for (j in seq_len(p)) {
    rows  <- .build_contrast_rows(j, ref)
    x1    <- rows$x1
    x0    <- rows$x0

    eta1  <- sum(x1 * beta)
    eta0  <- sum(x0 * beta)
    p1    <- .expit(eta1)
    p0    <- .expit(eta0)

    if (p0 < .Machine$double.eps) {
      warning("Reference prevalence for '", nms[j],
              "' is near zero; PR is undefined. Check baseline specification.")
      PR[j] <- NA_real_; lo[j] <- NA_real_; hi[j] <- NA_real_
      next
    }

    PR[j]      <- p1 / p0
    logPR      <- log(PR[j])
    var_logPR  <- .delta_var_logPR(p1, p0, x1, x0, Sigma)

    if (var_logPR < 0) var_logPR <- 0   # numerical noise guard

    se    <- sqrt(var_logPR)
    ci    <- .make_ci(logPR, se, conf)
    lo[j] <- ci$lo
    hi[j] <- ci$hi
  }

  .check_pr_range(PR, nms)
  .assemble_table(PR, lo, hi, conf, nms)
}


# --------------------------------------------------------------------------- #
#  pr_marginal()                                                               #
#                                                                              #
#  For each predictor j:                                                       #
#    - Fix predictor j to 1 across ALL n observations ? p1_i = expit(eta1_i).  #
#    - Fix predictor j to 0 across ALL n observations ? p0_i = expit(eta0_i).  #
#    - PR_j = mean(p1_i) / mean(p0_i)  -- population-averaged.                #
#                                                                              #
#  Gradient (delta method):                                                    #
#    ?log(PR)/?beta ? (1-p?1) * x?1 - (1-p?0) * x?0                             #
#    where x?1 = n^{-1} Sigma_i x1_i (mean design row under exposure = 1)        #
#          x?0 = n^{-1} Sigma_i x0_i (mean design row under exposure = 0)        #
#                                                                              #
#  `X` : full design matrix INCLUDING intercept (n x p+1).                   #
# --------------------------------------------------------------------------- #

pr_marginal <- function(fit, X, ref, conf) {

  beta  <- .get_coef(fit)
  Sigma <- .get_vcov(fit)
  p     <- length(beta) - 1L
  nms   <- names(beta)[-1L]
  n     <- nrow(X)

  PR  <- numeric(p)
  lo  <- numeric(p)
  hi  <- numeric(p)

  for (j in seq_len(p)) {

    # Build counterfactual matrices: set column j+1 (j-th predictor) to 1/0
    X1 <- X;  X1[, j + 1L] <- 1
    X0 <- X;  X0[, j + 1L] <- 0

    p1_vec <- .expit(as.numeric(X1 %*% beta))
    p0_vec <- .expit(as.numeric(X0 %*% beta))

    p1_bar <- mean(p1_vec)
    p0_bar <- mean(p0_vec)

    if (p0_bar < .Machine$double.eps) {
      warning("Mean reference prevalence for '", nms[j],
              "' is near zero; PR is undefined.")
      PR[j] <- NA_real_; lo[j] <- NA_real_; hi[j] <- NA_real_
      next
    }

    PR[j]  <- p1_bar / p0_bar
    logPR  <- log(PR[j])

    # Gradient: average counterfactual design rows weighted by (1 - p)
    # This is the marginal delta-method gradient from Oliveira et al. (1997)
    # extended to population-average standardisation
    xbar1 <- colMeans((1 - p1_vec) * X1)   # E[(1-p1_i) * x1_i]
    xbar0 <- colMeans((1 - p0_vec) * X0)   # E[(1-p0_i) * x0_i]
    xstar <- xbar1 - xbar0

    var_logPR <- as.numeric(crossprod(xstar, Sigma %*% xstar))
    if (var_logPR < 0) var_logPR <- 0

    se    <- sqrt(var_logPR)
    ci    <- .make_ci(logPR, se, conf)
    lo[j] <- ci$lo
    hi[j] <- ci$hi
  }

  .check_pr_range(PR, nms)
  .assemble_table(PR, lo, hi, conf, nms)
}
