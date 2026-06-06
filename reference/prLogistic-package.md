# prLogistic: Estimation of Prevalence Ratios via Logistic Regression Models

Estimates adjusted prevalence ratios (PR) and their confidence intervals
from logistic regression models, addressing the well-known limitation of
odds ratios (OR) as approximations to PR in cross-sectional studies with
common outcomes. Supports independent observations (glm()),
clustered/multilevel data (glmer() from 'lme4'), longitudinal data via
Generalised Estimating Equations (geeglm() from 'geepack'), and complex
survey designs (svyglm() from 'survey'). Inference is available via the
delta method (conditional and marginal standardisation) and via
bootstrap (normal-approximation and percentile intervals). Continuous
covariates are handled through user-specified or median-based reference
values; flexible baseline specification allows any reference category to
be chosen for factor predictors. Based on the methodology described in
Amorim & Ospina (2021)
[doi:10.1590/0001-3765202120190316](https://doi.org/10.1590/0001-3765202120190316)
.

## See also

Useful links:

- <https://github.com/Raydonal/prLogistic>

- <https://raydonal.github.io/prLogistic/>

- Report bugs at <https://github.com/Raydonal/prLogistic/issues>

## Author

**Maintainer**: Raydonal Ospina <raydonal@de.ufpe.br>
([ORCID](https://orcid.org/0000-0002-9884-9090))

Authors:

- Raydonal Ospina <raydonal@de.ufpe.br>
  ([ORCID](https://orcid.org/0000-0002-9884-9090))

- Leila D. Amorim <leiladen@ufba.br>
  ([ORCID](https://orcid.org/0000-0002-1112-2332))
