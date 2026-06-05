# =============================================================================
# prLogisticSurvey.R
#
# Convenience wrapper for complex survey designs fitted with
# survey::svyglm().
#
# The survey package automatically provides design-consistent (sandwich)
# standard errors via vcov(), which .get_vcov() extracts correctly.
# =============================================================================

#' Prevalence Ratios for Complex Survey Data
#'
#' A convenience wrapper around [prLogistic::prLogisticDelta()] for logistic regression
#' models fitted on complex survey data using [survey::svyglm()].
#'
#' @param fit A `svyglm` object fitted with `family = quasibinomial` (or
#'   `binomial`) and the logit link.
#' @param standardisation Character: `"conditional"` (default) or
#'   `"marginal"`.
#' @param conf Confidence level. Default `0.95`.
#' @param ref_values Named list of reference values. See [prLogistic::prLogisticDelta()].
#' @param ref_continuous `"median"` (default) or `"mean"`.
#'
#' @details
#' `svyglm()` incorporates sampling weights and complex design features
#' (stratification, clustering, finite-population corrections) into parameter
#' estimation. The design-consistent variance-covariance matrix is extracted
#' automatically via `vcov()` and used in the delta-method calculations.
#'
#' **Note:** bootstrap resampling for survey data requires design-aware
#' resampling (e.g., survey bootstrap, balanced repeated replication).
#' This is currently not automated; use [prLogistic::prLogisticDelta()] with a
#' bootstrap-replicate survey design if needed.
#'
#' @return A `"prLogistic"` object. See [prLogistic::prLogisticDelta()].
#'
#' @references
#' Lumley, T. (2004). Analysis of complex survey samples.
#' *Journal of Statistical Software*, **9**(1), 1-19.
#'
#' Lumley, T. (2010). *Complex Surveys: A Guide to Analysis Using R*.
#' Wiley, New Jersey.
#'
#' Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
#' \doi{10.1590/0001-3765202120190316}
#'
#' @seealso [prLogistic::prLogisticDelta()], [survey::svyglm()]
#'
#' @examplesIf requireNamespace("survey", quietly = TRUE)
#' library(survey)
#' data(api, package = "survey")
#'
#' # Create binary outcome
#' apiclus2$target_met <- as.numeric(apiclus2$sch.wide == "Yes")
#'
#' # Stratified two-stage cluster sample
#' dclus2 <- svydesign(
#'   id   = ~dnum + snum,
#'   fpc  = ~fpc1 + fpc2,
#'   data = apiclus2
#' )
#'
#' fit_svy <- svyglm(
#'   target_met ~ meals + stype,
#'   design = dclus2,
#'   family = quasibinomial
#' )
#'
#' prLogisticSurvey(fit_svy, standardisation = "conditional")
#' prLogisticSurvey(fit_svy, standardisation = "marginal")
#'
#' @export
prLogisticSurvey <- function(fit,
                              standardisation = c("conditional", "marginal"),
                              conf            = 0.95,
                              ref_values      = NULL,
                              ref_continuous  = c("median", "mean")) {

  standardisation <- match.arg(standardisation)
  ref_continuous  <- match.arg(ref_continuous)

  if (!.is_svyglm(fit)) {
    stop(
      "`fit` must be a `svyglm` object from the survey package. ",
      "For standard glm models use prLogisticDelta() directly."
    )
  }

  prLogisticDelta(
    fit             = fit,
    standardisation = standardisation,
    conf            = conf,
    ref_values      = ref_values,
    ref_continuous  = ref_continuous
  )
}
