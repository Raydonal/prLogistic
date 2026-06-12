# Estimate Prevalence Ratios via Logistic Regression – Delta Method

Estimates adjusted prevalence ratios (PR) and confidence intervals using
the delta method, from a fitted logistic regression model. Supports four
model types covering independent, clustered, longitudinal and
complex-survey data.

## Usage

``` r
prLogisticDelta(
  fit,
  standardisation = c("conditional", "marginal"),
  conf = 0.95,
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

- standardisation:

  Character string: `"conditional"` (default) or `"marginal"`. See
  *Details*.

- conf:

  Numeric scalar in (0, 1): confidence level. Default `0.95`.

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

### Standardisation procedures

**Conditional standardisation** fixes all covariates at their reference
values (median/mean for continuous, 0 for binary/dummy) and computes the
PR for each predictor by contrasting *exposed* (predictor = 1) vs
*unexposed* (predictor = 0) profiles: \$\$ \widehat{PR}\_j =
\frac{\mathrm{expit}(\hat\beta_0 + \hat\beta_j + \sum\_{k \neq j}
\hat\beta_k r_k)} {\mathrm{expit}(\hat\beta_0 + \sum\_{k \neq j}
\hat\beta_k r_k)} \$\$ where \\r_k\\ are the reference values of the
remaining covariates.

**Marginal standardisation** computes counterfactual prevalences using
the observed covariate distribution of the entire sample: \$\$
\widehat{PR}\_j = \frac{n^{-1}\sum_i \mathrm{expit}(\hat\eta_i^{(1)})}
{n^{-1}\sum_i \mathrm{expit}(\hat\eta_i^{(0)})} \$\$ where
\\\hat\eta_i^{(1)}\\ and \\\hat\eta_i^{(0)}\\ are the linear predictors
with predictor \\j\\ set to 1 and 0, respectively.

Variance estimates use the delta method (first-order Taylor expansion)
as described in Oliveira et al. (1997) and Amorim & Ospina (2021).

### Baseline / reference category

By default, the reference level of each factor predictor is determined
by the contrasts of the fitted model (typically the first level of the
[`factor()`](https://rdrr.io/r/base/factor.html)). You can override this
using `ref_values` for any predictor column present in the model matrix.

### Supported model types

|            |         |                             |
|------------|---------|-----------------------------|
| Class      | Package | Use case                    |
| `glm`      | stats   | Independent observations    |
| `glmerMod` | lme4    | Clustered / multilevel data |
| `geeglm`   | geepack | Longitudinal / GEE          |
| `svyglm`   | survey  | Complex survey designs      |

## References

Amorim, L. D. & Ospina, R. (2021). Prevalence ratio estimation using R.
*Anais da Academia Brasileira de Ciencias*, **93**(4), e20190316.
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)

Oliveira, N. F., Santana, V. S. & Lopes, A. A. (1997). Razoes de
proporcoes e uso da regressao log?stica em estudos transversais.
*Revista de Sa?de P?blica*, **31**, 90-99.

Wilcosky, T. C. & Chambless, L. E. (1985). A comparison of direct
adjustment and regression adjustment of epidemiologic measures. *Journal
of Chronic Diseases*, **38**, 849-856.

## See also

[`prLogisticBootCond()`](https://raydonal.github.io/prLogistic/reference/prLogisticBootCond.md),
[`prLogisticBootMarg()`](https://raydonal.github.io/prLogistic/reference/prLogisticBootMarg.md),
[`prLogisticGEE()`](https://raydonal.github.io/prLogistic/reference/prLogisticGEE.md),
[`prLogisticSurvey()`](https://raydonal.github.io/prLogistic/reference/prLogisticSurvey.md)

## Examples

``` r
# --- Independent observations (glm) --- infert is a built-in dataset ----
# outcome: case (spontaneous abortion), prevalence ~33%
fit_glm <- glm(case ~ induced + spontaneous + parity,
               family = binomial, data = infert)

# Conditional PR (continuous covariates at median)
prLogisticDelta(fit_glm, standardisation = "conditional")
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glm 
#>   Method       : delta 
#>   Standardis.  : conditional 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>             Estimate   2.5%  97.5%
#> induced       2.5500 1.5221 4.2720
#> spontaneous   4.3606 2.5417 7.4814
#> parity        0.5941 0.4497 0.7850
#> 

# Marginal PR
prLogisticDelta(fit_glm, standardisation = "marginal")
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glm 
#>   Method       : delta 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>             Estimate   2.5%  97.5%
#> induced       1.7024 1.1632 2.4914
#> spontaneous   3.0923 2.0353 4.6983
#> parity        0.8005 0.7103 0.9021
#> 

# Custom reference values
prLogisticDelta(fit_glm,
                standardisation = "conditional",
                ref_values = list(parity = 2))
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glm 
#>   Method       : delta 
#>   Standardis.  : conditional 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>             Estimate   2.5%  97.5%
#> induced       2.5500 1.5221 4.2720
#> spontaneous   4.3606 2.5417 7.4814
#> parity        0.5941 0.4497 0.7850
#> 

# \donttest{
# --- Clustered data (glmer) ---------------------------------------------
library(lme4)
fit_glmer <- glmer(case ~ induced + spontaneous + (1 | stratum),
                   family = binomial, data = infert)
#> boundary (singular) fit: see help('isSingular')
prLogisticDelta(fit_glmer, standardisation = "marginal")
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glmer 
#>   Method       : delta 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>             Estimate   2.5%  97.5%
#> induced       1.2649 0.9614 1.6644
#> spontaneous   2.2624 1.6580 3.0871
#> 

# --- Longitudinal / GEE -------------------------------------------------
library(geepack)
data(ohio, package = "geepack")
fit_gee <- geeglm(resp ~ smoke + age,
                  family  = binomial,
                  id      = id,
                  corstr  = "exchangeable",
                  data    = ohio)
prLogisticDelta(fit_gee, standardisation = "marginal")
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

# --- Complex survey design ----------------------------------------------
library(survey)
#> Loading required package: grid
#> Loading required package: survival
#> 
#> Attaching package: ‘survey’
#> The following object is masked from ‘package:graphics’:
#> 
#>     dotchart
data(api, package = "survey")
dclus2 <- svydesign(id = ~dnum + snum, fpc = ~fpc1 + fpc2, data = apiclus2)
fit_svy <- svyglm(sch.wide ~ meals + stype,
                  design = dclus2, family = quasibinomial)
prLogisticDelta(fit_svy, standardisation = "conditional")
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
# }
```
