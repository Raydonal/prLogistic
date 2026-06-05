# prLogistic <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/Raydonal/prLogistic/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Raydonal/prLogistic/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/prLogistic)](https://CRAN.R-project.org/package=prLogistic)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-blue.svg)](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html)
<!-- badges: end -->

**prLogistic** estimates adjusted **prevalence ratios (PR)** and their
confidence intervals from logistic regression models, addressing the
well-known limitation of odds ratios (OR) as approximations to PR in
cross-sectional and other studies with common binary outcomes.

## Why PR instead of OR?

When the outcome is common (prevalence > 10%), the OR from logistic regression
**overestimates** the PR. For example, with a 30% baseline prevalence and an
OR = 2.5, the true PR is closer to 1.8. **prLogistic** corrects this using
conditional or marginal standardisation directly on the logistic model.

## Supported data structures

| Function              | Model      | Use case                        |
|-----------------------|------------|---------------------------------|
| `prLogisticDelta()`   | `glm`      | Independent observations        |
| `prLogisticDelta()`   | `glmerMod` | Clustered / multilevel data     |
| `prLogisticGEE()`     | `geeglm`   | Longitudinal data (GEE)         |
| `prLogisticSurvey()`  | `svyglm`   | Complex survey designs          |

## Installation

```r
# Stable release from CRAN
install.packages("prLogistic")

# Development version from GitHub
# install.packages("remotes")
remotes::install_github("Raydonal/prLogistic")
```

## Quick start

```r
library(prLogistic)

# Fit a standard logistic model
data(birthwt, package = "MASS")
birthwt$smoke <- factor(birthwt$smoke)
birthwt$race  <- factor(birthwt$race)

fit <- glm(low ~ smoke + race + age + lwt,
           family = binomial, data = birthwt)

# --- Delta method --------------------------------------------------------

# Conditional PR (default: continuous covariates at median)
prLogisticDelta(fit, standardisation = "conditional")

# Marginal PR (population-averaged)
prLogisticDelta(fit, standardisation = "marginal")

# Custom reference: age = 25, lwt = 55 kg
prLogisticDelta(fit,
                standardisation = "conditional",
                ref_values = list(age = 25, lwt = 55))

# --- Bootstrap CIs -------------------------------------------------------
set.seed(42)
prLogisticBootCond(fit, data = birthwt, R = 999)

# --- Forest plot ---------------------------------------------------------
res <- prLogisticDelta(fit)
plot(res)
```

## Longitudinal data (GEE)

```r
library(geepack)
data(ohio, package = "geepack")

fit_gee <- geeglm(resp ~ smoke + age,
                  family = binomial, id = id,
                  corstr = "exchangeable", data = ohio)

prLogisticGEE(fit_gee)
```

## Complex survey data

```r
library(survey)
data(api, package = "survey")
dclus2 <- svydesign(id = ~dnum + snum, fpc = ~fpc1 + fpc2, data = apiclus2)
fit_svy <- svyglm(sch.wide ~ meals + stype,
                  design = dclus2, family = quasibinomial)

prLogisticSurvey(fit_svy)
```

## Citation

If you use **prLogistic** in your research, please cite:

> Amorim, L. D. & Ospina, R. (2021). Prevalence ratio estimation using R.
> *Anais da Academia Brasileira de Ciências*, **93**(4), e20190316.
> <https://doi.org/10.1590/0001-3765202120190316>

```bibtex
@article{Amorim2021,
  author  = {Amorim, Leila D. and Ospina, Raydonal},
  title   = {Prevalence ratio estimation using {R}},
  journal = {Anais da Academia Brasileira de Ci\^{e}ncias},
  year    = {2021},
  volume  = {93},
  number  = {4},
  pages   = {e20190316},
  doi     = {10.1590/0001-3765202120190316}
}
```


## License
GPL (≥ 2). See the [GNU GPL v2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html) for details.
