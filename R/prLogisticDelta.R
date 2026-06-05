# =============================================================================
# prLogisticDelta.R
#
# Main user-facing function: delta-method confidence intervals for PR.
# Supports glm, glmerMod (lme4), geeglm (geepack), svyglm (survey).
# =============================================================================

#' Estimate Prevalence Ratios via Logistic Regression -- Delta Method
#'
#' Estimates adjusted prevalence ratios (PR) and confidence intervals using
#' the delta method, from a fitted logistic regression model. Supports four
#' model types covering independent, clustered, longitudinal and complex-survey
#' data.
#'
#' @param fit A fitted model object of class `glm` (binomial family),
#'   `glmerMod` (from [lme4::glmer()]), `geeglm` (from [geepack::geeglm()]),
#'   or `svyglm` (from [survey::svyglm()]). Must use the logit link.
#' @param standardisation Character string: `"conditional"` (default) or
#'   `"marginal"`. See *Details*.
#' @param conf Numeric scalar in (0, 1): confidence level. Default `0.95`.
#' @param ref_values Named list of reference values for specific predictors,
#'   e.g. `list(age = 40, bmi = 25)`. Overrides automatic reference-value
#'   selection. For factor/dummy predictors the value should be `0` (the
#'   default) or `1`.
#' @param ref_continuous Character string: how to compute the reference value
#'   for continuous predictors when not supplied in `ref_values`. Either
#'   `"median"` (default) or `"mean"`.
#'
#' @details
#' ## Standardisation procedures
#'
#' **Conditional standardisation** fixes all covariates at their reference
#' values (median/mean for continuous, 0 for binary/dummy) and computes the
#' PR for each predictor by contrasting *exposed* (predictor = 1) vs
#' *unexposed* (predictor = 0) profiles:
#' \deqn{
#'   \widehat{PR}_j =
#'   \frac{\mathrm{expit}(\hat\beta_0 + \hat\beta_j + \sum_{k \neq j} \hat\beta_k r_k)}
#'        {\mathrm{expit}(\hat\beta_0 + \sum_{k \neq j} \hat\beta_k r_k)}
#' }
#' where \eqn{r_k} are the reference values of the remaining covariates.
#'
#' **Marginal standardisation** computes counterfactual prevalences using
#' the observed covariate distribution of the entire sample:
#' \deqn{
#'   \widehat{PR}_j =
#'   \frac{n^{-1}\sum_i \mathrm{expit}(\hat\eta_i^{(1)})}
#'        {n^{-1}\sum_i \mathrm{expit}(\hat\eta_i^{(0)})}
#' }
#' where \eqn{\hat\eta_i^{(1)}} and \eqn{\hat\eta_i^{(0)}} are the linear
#' predictors with predictor \eqn{j} set to 1 and 0, respectively.
#'
#' Variance estimates use the delta method (first-order Taylor expansion) as
#' described in Oliveira et al. (1997) and Amorim & Ospina (2021).
#'
#' ## Baseline / reference category
#'
#' By default, the reference level of each factor predictor is determined by
#' the contrasts of the fitted model (typically the first level of the
#' `factor()`). You can override this using `ref_values` for any predictor
#' column present in the model matrix.
#'
#' ## Supported model types
#'
#' | Class        | Package  | Use case                        |
#' |--------------|----------|---------------------------------|
#' | `glm`        | stats    | Independent observations        |
#' | `glmerMod`   | lme4     | Clustered / multilevel data     |
#' | `geeglm`     | geepack  | Longitudinal / GEE              |
#' | `svyglm`     | survey   | Complex survey designs          |
#'
#' @return An object of class `"prLogistic"` with components:
#' \describe{
#'   \item{`table`}{Numeric matrix with columns `Estimate`, lower and upper CI.}
#'   \item{`conf`}{Confidence level used.}
#'   \item{`method`}{`"delta"`.}
#'   \item{`standardisation`}{`"conditional"` or `"marginal"`.}
#'   \item{`model_type`}{Class of the fitted model.}
#'   \item{`call`}{The matched call.}
#' }
#'
#' @references
#' Amorim, L. D. & Ospina, R. (2021). Prevalence ratio estimation using R.
#' *Anais da Academia Brasileira de Ciencias*, **93**(4), e20190316.
#' \doi{10.1590/0001-3765202120190316}
#'
#' Oliveira, N. F., Santana, V. S. & Lopes, A. A. (1997). Razoes de
#' proporcoes e uso da regressao log?stica em estudos transversais.
#' *Revista de Sa?de P?blica*, **31**, 90-99.
#'
#' Wilcosky, T. C. & Chambless, L. E. (1985). A comparison of direct
#' adjustment and regression adjustment of epidemiologic measures.
#' *Journal of Chronic Diseases*, **38**, 849-856.
#'
#' @seealso [prLogistic::prLogisticBootCond()], [prLogistic::prLogisticBootMarg()],
#'   [prLogistic::prLogisticGEE()], [prLogistic::prLogisticSurvey()]
#'
#' @examples
#' # --- Independent observations (glm) --- infert is a built-in dataset ----
#' # outcome: case (spontaneous abortion), prevalence ~33%
#' fit_glm <- glm(case ~ induced + spontaneous + parity,
#'                family = binomial, data = infert)
#'
#' # Conditional PR (continuous covariates at median)
#' prLogisticDelta(fit_glm, standardisation = "conditional")
#'
#' # Marginal PR
#' prLogisticDelta(fit_glm, standardisation = "marginal")
#'
#' # Custom reference values
#' prLogisticDelta(fit_glm,
#'                 standardisation = "conditional",
#'                 ref_values = list(parity = 2))
#'
#' \dontrun{
#' # --- Clustered data (glmer) ---------------------------------------------
#' library(lme4)
#' fit_glmer <- glmer(case ~ induced + spontaneous + (1 | stratum),
#'                    family = binomial, data = infert)
#' prLogisticDelta(fit_glmer, standardisation = "marginal")
#'
#' # --- Longitudinal / GEE -------------------------------------------------
#' library(geepack)
#' data(ohio, package = "geepack")
#' fit_gee <- geeglm(resp ~ smoke + age,
#'                   family  = binomial,
#'                   id      = id,
#'                   corstr  = "exchangeable",
#'                   data    = ohio)
#' prLogisticDelta(fit_gee, standardisation = "marginal")
#'
#' # --- Complex survey design ----------------------------------------------
#' library(survey)
#' data(api, package = "survey")
#' dclus2 <- svydesign(id = ~dnum + snum, fpc = ~fpc1 + fpc2, data = apiclus2)
#' fit_svy <- svyglm(sch.wide ~ meals + stype,
#'                   design = dclus2, family = quasibinomial)
#' prLogisticDelta(fit_svy, standardisation = "conditional")
#' }
#'
#' @export
prLogisticDelta <- function(fit,
                             standardisation = c("conditional", "marginal"),
                             conf            = 0.95,
                             ref_values      = NULL,
                             ref_continuous  = c("median", "mean")) {

  cl              <- match.call()
  standardisation <- match.arg(standardisation)
  ref_continuous  <- match.arg(ref_continuous)

  # ---- Validate inputs ---------------------------------------------------
  .check_model(fit)

  if (!is.numeric(conf) || length(conf) != 1L || conf <= 0 || conf >= 1) {
    stop("`conf` must be a single number in (0, 1).")
  }

  # ---- Extract design matrix (no intercept) ------------------------------
  X_full   <- .get_model_matrix(fit)           # n x (p+1), with intercept
  X_no_int <- X_full[, -1L, drop = FALSE]      # n x p

  if (ncol(X_no_int) == 0L) {
    stop("Model has no predictors other than the intercept.")
  }

  # ---- Resolve reference values ------------------------------------------
  ref <- .resolve_ref(X_no_int, ref_values, ref_continuous)

  # ---- Compute PR --------------------------------------------------------
  tbl <- if (standardisation == "conditional") {
    pr_conditional(fit, ref, conf)
  } else {
    pr_marginal(fit, X_full, ref, conf)
  }

  # ---- Return prLogistic object ------------------------------------------
  .new_prLogistic(
    table           = tbl,
    conf            = conf,
    method          = "delta",
    standardisation = standardisation,
    model_type      = .model_label(fit),
    call            = cl
  )
}
