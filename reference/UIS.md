# UIS Drug Treatment Study

Data from the University of Massachusetts AIDS Research Unit (UMARU)
Impact Study, a 5-year study comparing two residential treatment
programmes for drug abuse.

## Usage

``` r
UIS
```

## Format

A data frame with 575 rows and 7 variables:

- ID:

  Patient identifier.

- Age:

  Age at enrolment (years, centred).

- DrugUse:

  History of intravenous drug use: factor with levels `"Short"` (\<= 3
  years), `"Long"` (\> 3 years).

- race:

  Race: factor with levels `"White"`, `"Other"`.

- trt:

  Treatment assignment: factor with levels `"Short"` (3-month), `"Long"`
  (6-month).

- site:

  Treatment site: factor with levels `"A"`, `"B"`.

- drugFree:

  Drug-free at 6 months: factor with levels `"No"`, `"Yes"`. Binary
  outcome.

## Source

Hosmer, D. W. & Lemeshow, S. (2000). *Applied Logistic Regression*, 2nd
ed. Wiley, New York.

## Examples

``` r
data(UIS)
prop.table(table(UIS$drugFree))
#> 
#>        No       Yes 
#> 0.7443478 0.2556522 

fit <- glm(as.integer(drugFree == "Yes") ~ trt + Age + DrugUse + race + site,
           family = binomial, data = UIS)
prLogisticDelta(fit, standardisation = "conditional")
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
#> trtLong       1.4233 1.0489 1.9314
#> Age           0.6239 0.4376 0.8896
#> DrugUseLong   1.7785 1.3150 2.4055
#> raceOther     1.2665 0.9006 1.7811
#> siteB         1.2215 0.8798 1.6960
#> 
```
