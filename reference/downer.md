# Downer Cow Survival Data

Veterinary study of downer cows (cattle unable to rise after calving).
The outcome is whether the animal survived to discharge.

## Usage

``` r
downer
```

## Format

A data frame with 216 rows and 5 variables:

- AST:

  Aspartate aminotransferase (enzyme marker): 0 = normal, 1 = elevated.

- CK:

  Creatine kinase (enzyme marker): 0 = normal, 1 = elevated.

- Calving:

  Whether the downer condition was related to calving: 0 = No, 1 = Yes.

- Myopathy:

  Presence of myopathy: factor with levels `"No"`, `"Yes"`.

- Survival:

  Outcome: factor with levels `"Died"`, `"Survived"`. Binary outcome.

## Source

Dohoo, I., Martin, W. & Stryhn, H. (2003). *Veterinary Epidemiologic
Research*. AVC Inc., Prince Edward Island, Canada.

## Examples

``` r
data(downer)
prop.table(table(downer$Survival))
#> 
#>      Died  Survived 
#> 0.7453704 0.2546296 

fit <- glm(as.integer(Survival == "Survived") ~ Myopathy + AST + CK + Calving,
           family = binomial, data = downer)
prLogisticDelta(fit)
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
#> MyopathyYes   0.3034 0.1001 0.9191
#> AST           1.1900 0.5273 2.6857
#> CK            2.0026 0.8604 4.6611
#> Calving       0.7809 0.4080 1.4946
#> 
```
