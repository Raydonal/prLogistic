# Bootstrap CI for Prevalence Ratios – Marginal Standardisation

Estimates adjusted prevalence ratios (PR) using marginal standardisation
(population-averaged) and obtains confidence intervals via bootstrap
resampling.

## Usage

``` r
prLogisticBootMarg(
  fit,
  data,
  conf = 0.95,
  R = 999L,
  ref_values = NULL,
  ref_continuous = c("median", "mean")
)
```

## Arguments

- fit:

  A fitted model object of class `glm` (binomial family), `glmerMod`
  (from [`lme4::glmer()`](https://rdrr.io/pkg/lme4/man/glmer.html)),
  `geeglm` (from
  [`geepack::geeglm()`](https://rdrr.io/pkg/geepack/man/geeglm.html)),
  or `svyglm` (from
  [`survey::svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html)).
  Must use the logit link.

- data:

  Data frame used to fit `fit`. Required for bootstrapping.

- conf:

  Numeric scalar in (0, 1): confidence level. Default `0.95`.

- R:

  Integer: number of bootstrap replicates. Default `999`.

- ref_values:

  Named list of reference values for specific predictors, e.g.
  `list(age = 40, bmi = 25)`. Overrides automatic reference-value
  selection. For factor/dummy predictors the value should be `0` (the
  default) or `1`.

- ref_continuous:

  Character string: how to compute the reference value for continuous
  predictors when not supplied in `ref_values`. Either `"median"`
  (default) or `"mean"`.

## Value

An object of class `"prLogistic"` with components:

- `table`:

  Numeric matrix with columns `Estimate`, lower and upper CI.

- `conf`:

  Confidence level used.

- `method`:

  `"delta"`.

- `standardisation`:

  `"conditional"` or `"marginal"`.

- `model_type`:

  Class of the fitted model.

- `call`:

  The matched call.

## Details

Marginal standardisation averages counterfactual predicted probabilities
over the empirical covariate distribution, giving a population-averaged
PR. At each bootstrap replicate the model is refitted and marginal PRs
are recomputed.

## See also

[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md),
[`prLogisticBootCond()`](https://raydonal.github.io/prLogistic/reference/prLogisticBootCond.md)

## Examples

``` r
fit_glm <- glm(case ~ induced + spontaneous + parity,
               family = binomial, data = infert)

set.seed(42)
res <- prLogisticBootMarg(fit_glm, data = infert, R = 199)
print(res)
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glm 
#>   Method       : bootstrap 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>                   Estimate    Normal CI    Percentile CI 
#>             Estimate Normal.2.5% Normal.97.5% Pct.2.5% Pct.97.5%
#> induced       1.7024      1.1774       2.1367   1.3081    2.3990
#> spontaneous   3.0923      1.7405       4.1577   2.2437    4.7643
#> parity        0.8005      0.7306       0.8634   0.7422    0.8754
#> 
```
