# Toenail Infection Trial – Longitudinal Binary Outcome

Data from a randomised clinical trial comparing two oral antifungal
treatments (itraconazole vs terbinafine) for toenail dermatophyte
infection. Patients were measured at up to 7 visits over 18 months.

## Usage

``` r
Toenail
```

## Format

A data frame with 1908 rows and 5 variables:

- ID:

  Patient identifier. There are 294 patients.

- Response:

  Presence of moderate or severe onycholysis (nail separation): factor
  with levels `"Not moderate/severe"`, `"Moderate/severe"`. Binary
  outcome.

- Treatment:

  Antifungal treatment: factor with levels `"Itraconazole"`,
  `"Terbinafine"`.

- Month:

  Time since randomisation (months, continuous).

- Visit:

  Visit number (1 to 7, integer).

## Source

De Backer, M. et al. (1998). Twelve weeks of continuous oral therapy for
toenail onychomycosis caused by dermatophytes. *Journal of the American
Academy of Dermatology*, **38**, S57-S63.

## Details

The dataset illustrates a longitudinal binary outcome with dropout (not
all patients have 7 visits). GEE with an unstructured or exchangeable
correlation is commonly used.

## Examples

``` r
data(Toenail)
table(Toenail$Response, Toenail$Treatment)
#>                      
#>                       Itraconazole Terbinafine
#>   Not moderate/severe          723         777
#>   Moderate/severe              214         194

if (FALSE) { # \dontrun{
library(geepack)
Toenail$resp_bin <- as.integer(Toenail$Response == "Moderate/severe")
fit_gee <- geeglm(resp_bin ~ Treatment + Month,
                  family = binomial, id = ID,
                  corstr = "exchangeable", data = Toenail)
prLogisticGEE(fit_gee)
} # }
```
