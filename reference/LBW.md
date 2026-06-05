# Low Birth Weight – Longitudinal Study (Salvador, Brazil)

Data from a longitudinal study of 244 mothers followed during two
pregnancies in Salvador, Bahia, Brazil. The outcome is whether the
newborn had low birth weight (\< 2500 g). The study illustrates
clustered binary data (two births per mother) and is the primary
motivating example in Amorim & Ospina (2021).

## Usage

``` r
LBW
```

## Format

A data frame with 488 rows and 6 variables:

- ID:

  Mother identifier (integer).

- birth:

  Birth order within mother: 1 or 2.

- smoke:

  Maternal smoking during pregnancy: factor with levels `"No"`, `"Yes"`.

- race:

  Maternal race: factor with levels `"White"`, `"Non-white"`.

- age:

  Maternal age at delivery (years, centred).

- low:

  Birth weight category: factor with levels `"Normal"` (\>= 2500 g),
  `"Low"` (\< 2500 g). This is the binary outcome of interest.

## Source

Amorim, L. D. & Ospina, R. (2021). Prevalence ratio estimation using R.
*Anais da Academia Brasileira de Ciencias*, **93**(4), e20190316.
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)

## Details

The dataset contains repeated observations: each mother contributes two
records (one per birth). Models should account for this clustering –
either with a random intercept (`glmer`) or via GEE (`geeglm`).

Prevalence of low birth weight across both births: approximately 18%.

## Examples

``` r
data(LBW)
table(LBW$low, LBW$smoke)
#>         
#>           No Yes
#>   Normal 223 114
#>   Low     70  81

# GEE model accounting for within-mother correlation
if (FALSE) { # \dontrun{
library(geepack)
fit_gee <- geeglm(as.integer(low == "Low") ~ smoke + race + age,
                  family = binomial, id = ID,
                  corstr = "exchangeable", data = LBW)
prLogisticGEE(fit_gee)
} # }
```
