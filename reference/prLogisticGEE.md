# Prevalence Ratios for Longitudinal Data – GEE Models

A convenience wrapper around
[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md)
for models fitted with
[`geepack::geeglm()`](https://rdrr.io/pkg/geepack/man/geeglm.html). GEE
provides population-averaged (marginal) estimates suitable for
longitudinal or clustered binary outcomes.

## Usage

``` r
prLogisticGEE(
  fit,
  standardisation = c("marginal", "conditional"),
  conf = 0.95,
  method = c("delta", "bootstrap"),
  data = NULL,
  R = 999L,
  ref_values = NULL,
  ref_continuous = c("median", "mean")
)
```

## Arguments

- fit:

  A `geeglm` object fitted with `family = binomial` and `link = "logit"`
  (or `family = binomial(link = "logit")`).

- standardisation:

  Character: `"marginal"` (default, recommended for GEE) or
  `"conditional"`.

- conf:

  Confidence level. Default `0.95`.

- method:

  Inference method: `"delta"` (default) or `"bootstrap"`.

- data:

  Data frame (required when `method = "bootstrap"`).

- R:

  Number of bootstrap replicates (only used when
  `method = "bootstrap"`). Default `999L`.

- ref_values:

  Named list of reference values. See
  [`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md).

- ref_continuous:

  `"median"` (default) or `"mean"`.

## Value

A `"prLogistic"` object. See
[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md).

## Details

GEE accounts for within-subject correlation through a working
correlation structure (`corstr` argument of
[`geeglm()`](https://rdrr.io/pkg/geepack/man/geeglm.html)). Common
choices:

- `"independence"`:

  No correlation assumed (equivalent to GLM).

- `"exchangeable"`:

  Constant correlation across time points.

- `"ar1"`:

  First-order autoregressive; suitable for ordered time.

- `"unstructured"`:

  Estimates all pairwise correlations freely.

The robust (sandwich) variance-covariance matrix returned by
[`vcov()`](https://rdrr.io/r/stats/vcov.html) on a `geeglm` object is
used automatically, giving valid inference even when the working
correlation structure is misspecified.

## References

Zeger, S. L. & Liang, K.-Y. (1986). Longitudinal data analysis for
discrete and continuous outcomes. *Biometrics*, **42**, 121-130.

H?jsgaard, S., Halekoh, U. & Yan, J. (2006). The R package geepack for
generalised estimating equations. *Journal of Statistical Software*,
**15**(2), 1-11.

Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)

## See also

[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md),
[`geepack::geeglm()`](https://rdrr.io/pkg/geepack/man/geeglm.html)

## Examples

``` r
library(geepack)
data(ohio, package = "geepack")

# Model respiratory symptoms over time with exchangeable correlation
fit_gee <- geeglm(
  resp  ~ smoke + age,
  family = binomial,
  id     = id,
  corstr = "exchangeable",
  data   = ohio
)

# Marginal PR (recommended for GEE)
prLogisticGEE(fit_gee)
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : geeglm 
#>   Method       : delta 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>       Estimate   2.5%  97.5%
#> smoke   1.2499 0.9332 1.6742
#> age     0.9070 0.8410 0.9782
#> 

# With bootstrap CIs (small R for a fast example; use R >= 999 in practice)
prLogisticGEE(fit_gee, method = "bootstrap", data = ohio, R = 25)
#> Warning: extreme order statistics used as endpoints
#> Warning: extreme order statistics used as endpoints
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : geeglm 
#>   Method       : bootstrap 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>                   Estimate    Normal CI    Percentile CI 
#>       Estimate Normal.2.5% Normal.97.5% Pct.2.5% Pct.97.5%
#> smoke   1.2499      0.9657       1.4458   1.0794    1.5240
#> age     0.9070      0.8043       1.0188   0.8258    1.0302
#> 
```
