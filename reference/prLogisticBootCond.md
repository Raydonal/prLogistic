# Bootstrap CI for Prevalence Ratios – Conditional Standardisation

Estimates adjusted prevalence ratios (PR) using conditional
standardisation and obtains confidence intervals via bootstrap
resampling (normal- approximation and percentile methods).

## Usage

``` r
prLogisticBootCond(
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

At each bootstrap replicate the model is refitted on a resampled dataset
and conditional PRs are computed. Two CI types are returned:

- Normal:

  Bootstrap normal-approximation interval.

- Percentile:

  Empirical quantiles of the bootstrap distribution.

Use
[`confint.prLogistic()`](https://raydonal.github.io/prLogistic/reference/confint.prLogistic.md)
with `type = "normal"` or `type = "percentile"` to extract a single CI
type.

## References

Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)

Davison, A. C. & Hinkley, D. V. (1997). *Bootstrap Methods and their
Application*. Cambridge University Press.

## See also

[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md),
[`prLogisticBootMarg()`](https://raydonal.github.io/prLogistic/reference/prLogisticBootMarg.md)

## Examples

``` r
fit_glm <- glm(case ~ induced + spontaneous + parity,
               family = binomial, data = infert)

set.seed(42)
res <- prLogisticBootCond(fit_glm, data = infert, R = 199)
#> Warning: Unusual PR estimate(s) detected for: spontaneous. Check model convergence and predictor coding.
#> Warning: Unusual PR estimate(s) detected for: spontaneous. Check model convergence and predictor coding.
#> Warning: Unusual PR estimate(s) detected for: spontaneous. Check model convergence and predictor coding.
#> Warning: Unusual PR estimate(s) detected for: spontaneous. Check model convergence and predictor coding.
#> Warning: Unusual PR estimate(s) detected for: spontaneous. Check model convergence and predictor coding.
print(res)
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glm 
#>   Method       : bootstrap 
#>   Standardis.  : conditional 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>                   Estimate    Normal CI    Percentile CI 
#>             Estimate Normal.2.5% Normal.97.5% Pct.2.5% Pct.97.5%
#> induced       2.5500      0.1918       4.1912   1.5021    5.5680
#> spontaneous   4.3606      0.1780       7.1674   2.5657   10.5113
#> parity        0.5941      0.4021       0.8071   0.3869    0.7931
#> 
plot(res)

```
