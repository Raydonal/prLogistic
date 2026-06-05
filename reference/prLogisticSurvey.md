# Prevalence Ratios for Complex Survey Data

A convenience wrapper around
[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md)
for logistic regression models fitted on complex survey data using
[`survey::svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html).

## Usage

``` r
prLogisticSurvey(
  fit,
  standardisation = c("conditional", "marginal"),
  conf = 0.95,
  ref_values = NULL,
  ref_continuous = c("median", "mean")
)
```

## Arguments

- fit:

  A `svyglm` object fitted with `family = quasibinomial` (or `binomial`)
  and the logit link.

- standardisation:

  Character: `"conditional"` (default) or `"marginal"`.

- conf:

  Confidence level. Default `0.95`.

- ref_values:

  Named list of reference values. See
  [`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md).

- ref_continuous:

  `"median"` (default) or `"mean"`.

## Value

A `"prLogistic"` object. See
[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md).

## Details

[`svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html) incorporates
sampling weights and complex design features (stratification,
clustering, finite-population corrections) into parameter estimation.
The design-consistent variance-covariance matrix is extracted
automatically via [`vcov()`](https://rdrr.io/r/stats/vcov.html) and used
in the delta-method calculations.

**Note:** bootstrap resampling for survey data requires design-aware
resampling (e.g., survey bootstrap, balanced repeated replication). This
is currently not automated; use
[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md)
with a bootstrap-replicate survey design if needed.

## References

Lumley, T. (2004). Analysis of complex survey samples. *Journal of
Statistical Software*, **9**(1), 1-19.

Lumley, T. (2010). *Complex Surveys: A Guide to Analysis Using R*.
Wiley, New Jersey.

Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)

## See also

[`prLogisticDelta()`](https://raydonal.github.io/prLogistic/reference/prLogisticDelta.md),
[`survey::svyglm()`](https://rdrr.io/pkg/survey/man/svyglm.html)

## Examples

``` r
library(survey)
#> Loading required package: grid
#> Loading required package: Matrix
#> Loading required package: survival
#> 
#> Attaching package: ‘survey’
#> The following object is masked from ‘package:graphics’:
#> 
#>     dotchart
data(api, package = "survey")

# Create binary outcome
apiclus2$target_met <- as.numeric(apiclus2$sch.wide == "Yes")

# Stratified two-stage cluster sample
dclus2 <- svydesign(
  id   = ~dnum + snum,
  fpc  = ~fpc1 + fpc2,
  data = apiclus2
)

fit_svy <- svyglm(
  target_met ~ meals + stype,
  design = dclus2,
  family = quasibinomial
)

prLogisticSurvey(fit_svy, standardisation = "conditional")
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : svyglm 
#>   Method       : delta 
#>   Standardis.  : conditional 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>        Estimate   2.5%  97.5%
#> meals    0.9996 0.9989 1.0003
#> stypeH   0.1491 0.0505 0.4403
#> stypeM   0.6616 0.4246 1.0310
#> 
prLogisticSurvey(fit_svy, standardisation = "marginal")
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : svyglm 
#>   Method       : delta 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>        Estimate   2.5%  97.5%
#> meals    0.9982 0.9959 1.0005
#> stypeH   0.1341 0.0367 0.4899
#> stypeM   0.6078 0.2681 1.3777
#> 
```
