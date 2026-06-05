# =============================================================================
# prLogisticGEE.R
#
# Convenience wrapper for longitudinal / repeated-measures data fitted with
# Generalised Estimating Equations (GEE) via geepack::geeglm().
#
# GEE models yield population-averaged (marginal) parameter estimates,
# so marginal standardisation is the natural and recommended choice.
# Conditional standardisation is also supported for completeness.
# =============================================================================

#' Prevalence Ratios for Longitudinal Data -- GEE Models
#'
#' A convenience wrapper around [prLogistic::prLogisticDelta()] for models fitted with
#' [geepack::geeglm()]. GEE provides population-averaged (marginal) estimates
#' suitable for longitudinal or clustered binary outcomes.
#'
#' @param fit A `geeglm` object fitted with `family = binomial` and
#'   `link = "logit"` (or `family = binomial(link = "logit")`).
#' @param standardisation Character: `"marginal"` (default, recommended for
#'   GEE) or `"conditional"`.
#' @param conf Confidence level. Default `0.95`.
#' @param method Inference method: `"delta"` (default) or `"bootstrap"`.
#' @param data Data frame (required when `method = "bootstrap"`).
#' @param R Number of bootstrap replicates (only used when
#'   `method = "bootstrap"`). Default `999L`.
#' @param ref_values Named list of reference values. See [prLogistic::prLogisticDelta()].
#' @param ref_continuous `"median"` (default) or `"mean"`.
#'
#' @details
#' GEE accounts for within-subject correlation through a working correlation
#' structure (`corstr` argument of `geeglm()`). Common choices:
#' \describe{
#'   \item{`"independence"`}{No correlation assumed (equivalent to GLM).}
#'   \item{`"exchangeable"`}{Constant correlation across time points.}
#'   \item{`"ar1"`}{First-order autoregressive; suitable for ordered time.}
#'   \item{`"unstructured"`}{Estimates all pairwise correlations freely.}
#' }
#'
#' The robust (sandwich) variance-covariance matrix returned by `vcov()` on
#' a `geeglm` object is used automatically, giving valid inference even when
#' the working correlation structure is misspecified.
#'
#' @return A `"prLogistic"` object. See [prLogistic::prLogisticDelta()].
#'
#' @references
#' Zeger, S. L. & Liang, K.-Y. (1986). Longitudinal data analysis for
#' discrete and continuous outcomes. *Biometrics*, **42**, 121-130.
#'
#' H?jsgaard, S., Halekoh, U. & Yan, J. (2006). The R package geepack for
#' generalised estimating equations. *Journal of Statistical Software*,
#' **15**(2), 1-11.
#'
#' Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
#' \doi{10.1590/0001-3765202120190316}
#'
#' @seealso [prLogistic::prLogisticDelta()], [geepack::geeglm()]
#'
#' @examplesIf requireNamespace("geepack", quietly = TRUE)
#' library(geepack)
#' data(ohio, package = "geepack")
#'
#' # Model respiratory symptoms over time with exchangeable correlation
#' fit_gee <- geeglm(
#'   resp  ~ smoke + age,
#'   family = binomial,
#'   id     = id,
#'   corstr = "exchangeable",
#'   data   = ohio
#' )
#'
#' # Marginal PR (recommended for GEE)
#' prLogisticGEE(fit_gee)
#'
#' # With bootstrap CIs (small R for a fast example; use R >= 999 in practice)
#' prLogisticGEE(fit_gee, method = "bootstrap", data = ohio, R = 25)
#'
#' @export
prLogisticGEE <- function(fit,
                           standardisation = c("marginal", "conditional"),
                           conf            = 0.95,
                           method          = c("delta", "bootstrap"),
                           data            = NULL,
                           R               = 999L,
                           ref_values      = NULL,
                           ref_continuous  = c("median", "mean")) {

  standardisation <- match.arg(standardisation)
  method          <- match.arg(method)
  ref_continuous  <- match.arg(ref_continuous)

  if (!.is_gee(fit)) {
    stop(
      "`fit` must be a `geeglm` object from geepack. ",
      "For glm models use prLogisticDelta() directly."
    )
  }

  if (method == "bootstrap") {
    if (is.null(data)) {
      stop("`data` must be supplied when method = 'bootstrap'.")
    }
    if (standardisation == "marginal") {
      return(prLogisticBootMarg(fit, data = data, conf = conf, R = R,
                                ref_values = ref_values,
                                ref_continuous = ref_continuous))
    } else {
      return(prLogisticBootCond(fit, data = data, conf = conf, R = R,
                                ref_values = ref_values,
                                ref_continuous = ref_continuous))
    }
  }

  prLogisticDelta(
    fit             = fit,
    standardisation = standardisation,
    conf            = conf,
    ref_values      = ref_values,
    ref_continuous  = ref_continuous
  )
}
