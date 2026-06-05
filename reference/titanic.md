# Titanic Passenger Survival

Survival data for 1307 passengers aboard the RMS Titanic. The outcome is
whether the passenger survived.

## Usage

``` r
titanic
```

## Format

A data frame with 1307 rows and 4 variables:

- pclass:

  Passenger class: factor with levels `"1"`, `"2"`, `"3"`.

- survived:

  Survived: factor with levels `"No"`, `"Yes"`. Binary outcome.

- sex:

  Sex: factor with levels `"Female"`, `"Male"`.

- embarked:

  Port of embarkation: 0 = Southampton, 1 = Cherbourg/ Queenstown.

## Source

Harrell, F. E. (2001). *Regression Modeling Strategies*. Springer, New
York.

## Details

Overall survival rate is approximately 38%, making this a common outcome
– a setting where OR meaningfully diverges from PR.

## Examples

``` r
data(titanic)
prop.table(table(titanic$survived, titanic$sex), margin = 2)
#>      
#>          Female      Male
#>   No  0.8090154 0.2737069
#>   Yes 0.1909846 0.7262931

fit <- glm(as.integer(survived == "Yes") ~ sex + pclass,
           family = binomial, data = titanic)

# OR vs PR comparison
OR <- exp(coef(fit))
PR <- prLogisticDelta(fit, standardisation = "marginal")
print(PR)
#> 
#> Prevalence Ratio Estimation via Logistic Regression
#> ----------------------------------------------------
#>   Model        : glm 
#>   Method       : delta 
#>   Standardis.  : marginal 
#>   Conf. level  : 95% 
#> ----------------------------------------------------
#> 
#>         Estimate   2.5%  97.5%
#> sexMale   3.5635 3.0375 4.1805
#> pclass1   1.7992 1.5325 2.1123
#> 
```
