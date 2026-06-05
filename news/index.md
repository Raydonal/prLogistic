# Changelog

## prLogistic (development version)

## prLogistic 2.0.0 (2025-06-04)

### Breaking changes

- Minimum R version raised to 4.1.0.
- [`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md)
  now takes a **fitted model object** as its first argument (instead of
  a formula + dataset). This aligns with standard R modelling
  conventions and allows the same function to handle all supported model
  types.
- The `cluster` and `pattern` arguments of the old
  [`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md)
  are replaced by `standardisation`. Use
  `standardisation = "conditional"` (default) or
  `standardisation = "marginal"`.
- The `Hmisc` dependency has been removed (it was unused).
- Return value is now a `prLogistic` S3 object rather than a plain
  matrix, with `print`, `summary`, `coef`, `confint`, and `plot`
  methods.

### New features

- **Continuous covariates**: reference value defaults to the sample
  median (configurable via `ref_continuous = "mean"`). The old
  implementation only supported binary (0/1) predictors.
- **Flexible baseline**: use `ref_values = list(var = value)` to set the
  reference value of any predictor. This overrides both automatic
  defaults and the model’s contrast coding.
- **GEE support**
  ([`prLogisticGEE()`](https://raydonal.github.io/prLogistic/reference/prLogisticGEE.md)):
  prevalence ratios for longitudinal / repeated-measures data fitted
  with
  [`geepack::geeglm()`](https://rdrr.io/pkg/geepack/man/geeglm.html).
  Robust (sandwich) variance is used automatically.
- **Complex survey support**
  ([`prLogisticSurvey()`](https://raydonal.github.io/prLogistic/reference/prLogisticSurvey.md)):
  prevalence ratios for data from complex survey designs fitted with
  [`survey::svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html).
  Design-consistent variance is used automatically.
- [`plot.prLogistic()`](https://raydonal.github.io/prLogistic/reference/plot.prLogistic.md):
  base-R forest plot for quick visualisation of PR estimates and
  confidence intervals.
- Improved delta-method gradient for marginal standardisation: uses the
  full sample-averaged counterfactual gradient (not a single fixed row),
  giving more accurate variance estimates.

### Bug fixes

- Fixed incorrect variance calculation in `pr_marginal()` for models
  with more than one continuous covariate.
- Negative confidence interval bounds are no longer silently truncated
  at 0 without a warning; a diagnostic warning is now issued.
- `pr.conditional()` no longer crashes on `glmerMod` objects that use
  [`lme4::fixef()`](https://rdrr.io/pkg/nlme/man/fixed.effects.html)
  instead of `@beta` (the slot accessor was fragile across lme4
  versions).

### Internal changes

- Complete rewrite using roxygen2 documentation.
- All internal functions prefixed with `.` to avoid namespace pollution.
- Comprehensive `testthat` (edition 3) test suite covering utilities,
  delta method, bootstrap, GEE, and survey model types.
- pkgdown website with `_pkgdown.yml` configuration.
- GitHub Actions CI/CD workflow for multi-platform `R CMD check` and
  automatic pkgdown deployment.

## prLogistic 1.2 (2013-09-19)

CRAN release: 2013-09-19

- Replaced `lmer` class with `glmerMod` for compatibility with lme4 ≥
  1.0-4.

## prLogistic 1.1 (2011-10-25)

CRAN release: 2011-10-26

- Added `NAMESPACE` and `ChangeLog` files.
- Replaced `mean` with
  [`colMeans()`](https://rdrr.io/pkg/Matrix/man/colSums-methods.html) in
  `pr.marginal()`.
- Modified [`vcov()`](https://rdrr.io/r/stats/vcov.html) structure for
  S4 compatibility.

## prLogistic 1.0 (2010-03-29)

CRAN release: 2011-07-23

- Initial release.
