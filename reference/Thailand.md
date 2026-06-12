# Thailand Education Study – Clustered Binary Data

Data from a survey of primary school students in Thailand. The outcome
is whether the student repeated a grade (`rgi`). Students are nested
within schools, making this a clustered binary outcome dataset.

## Usage

``` r
Thailand
```

## Format

A data frame with 8582 rows and 4 variables:

- schoolid:

  School identifier (integer). There are 411 schools.

- sex:

  Student sex: factor with levels `"Girl"`, `"Boy"`.

- pped:

  Pre-primary education: factor with levels `"No"`, `"Yes"`.

- rgi:

  Repeated a grade: factor with levels `"No"`, `"Yes"`. Binary outcome
  of interest.

## Source

Raudenbush, S. W. & Bryk, A. S. (2002). *Hierarchical Linear Models*,
2nd ed. Sage.

Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)

## Details

Prevalence of grade repetition is approximately 16%, making PR a more
appropriate measure than OR. The clustering by school should be
accounted for with `glmer` or `geeglm`.

## Examples

``` r
data(Thailand)
prop.table(table(Thailand$rgi))
#> 
#>        No       Yes 
#> 0.8549289 0.1450711 

# Mixed model (random intercept per school)
# \donttest{
library(lme4)
#> Loading required package: Matrix
fit_ml <- glmer(as.integer(rgi == "Yes") ~ sex + pped + (1 | schoolid),
                family = binomial, data = Thailand)
#> Warning: Model failed to converge with max|grad| = 0.195109 (tol = 0.002, component 1)
#>   See ?lme4::convergence and ?lme4::troubleshooting.
#> Warning: Model is nearly unidentifiable: very large eigenvalue
#>  - Rescale variables?
prLogisticDelta(fit_ml, standardisation = "marginal")
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glmer 
#>   Method       : delta 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>         Estimate   2.5%  97.5%
#> sexBoy    1.6322 1.6312 1.6333
#> ppedYes   0.5723 0.5719 0.5727
#> 
# }
```
