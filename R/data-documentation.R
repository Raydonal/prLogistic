# =============================================================================
# data-documentation.R
# Roxygen2 documentation for all datasets bundled with prLogistic.
# =============================================================================

#' Low Birth Weight -- Longitudinal Study (Salvador, Brazil)
#'
#' Data from a longitudinal study of 244 mothers followed during two pregnancies
#' in Salvador, Bahia, Brazil. The outcome is whether the newborn had low birth
#' weight (< 2500 g). The study illustrates clustered binary data (two
#' births per mother) and is the primary motivating example in Amorim &
#' Ospina (2021).
#'
#' @format A data frame with 488 rows and 6 variables:
#' \describe{
#'   \item{ID}{Mother identifier (integer).}
#'   \item{birth}{Birth order within mother: 1 or 2.}
#'   \item{smoke}{Maternal smoking during pregnancy: factor with levels
#'     `"No"`, `"Yes"`.}
#'   \item{race}{Maternal race: factor with levels `"White"`, `"Non-white"`.}
#'   \item{age}{Maternal age at delivery (years, centred).}
#'   \item{low}{Birth weight category: factor with levels `"Normal"` (>= 2500 g),
#'     `"Low"` (< 2500 g). This is the binary outcome of interest.}
#' }
#'
#' @details
#' The dataset contains repeated observations: each mother contributes two
#' records (one per birth). Models should account for this clustering -- either
#' with a random intercept (`glmer`) or via GEE (`geeglm`).
#'
#' Prevalence of low birth weight across both births: approximately 18%.
#'
#' @source
#' Amorim, L. D. & Ospina, R. (2021). Prevalence ratio estimation using R.
#' *Anais da Academia Brasileira de Ciencias*, **93**(4), e20190316.
#' \doi{10.1590/0001-3765202120190316}
#'
#' @examples
#' data(LBW)
#' table(LBW$low, LBW$smoke)
#'
#' # GEE model accounting for within-mother correlation
#' \donttest{
#' library(geepack)
#' fit_gee <- geeglm(as.integer(low == "Low") ~ smoke + race + age,
#'                   family = binomial, id = ID,
#'                   corstr = "exchangeable", data = LBW)
#' prLogisticGEE(fit_gee)
#' }
"LBW"


#' Thailand Education Study -- Clustered Binary Data
#'
#' Data from a survey of primary school students in Thailand. The outcome is
#' whether the student repeated a grade (`rgi`). Students are nested within
#' schools, making this a clustered binary outcome dataset.
#'
#' @format A data frame with 8582 rows and 4 variables:
#' \describe{
#'   \item{schoolid}{School identifier (integer). There are 411 schools.}
#'   \item{sex}{Student sex: factor with levels `"Girl"`, `"Boy"`.}
#'   \item{pped}{Pre-primary education: factor with levels `"No"`, `"Yes"`.}
#'   \item{rgi}{Repeated a grade: factor with levels `"No"`, `"Yes"`.
#'     Binary outcome of interest.}
#' }
#'
#' @details
#' Prevalence of grade repetition is approximately 16%, making PR a more
#' appropriate measure than OR. The clustering by school should be accounted
#' for with `glmer` or `geeglm`.
#'
#' @source
#' Raudenbush, S. W. & Bryk, A. S. (2002). *Hierarchical Linear Models*,
#' 2nd ed. Sage.
#'
#' Amorim, L. D. & Ospina, R. (2021). *An Acad Bras Cienc*, **93**(4).
#' \doi{10.1590/0001-3765202120190316}
#'
#' @examples
#' data(Thailand)
#' prop.table(table(Thailand$rgi))
#'
#' # Mixed model (random intercept per school)
#' \donttest{
#' library(lme4)
#' fit_ml <- glmer(as.integer(rgi == "Yes") ~ sex + pped + (1 | schoolid),
#'                 family = binomial, data = Thailand)
#' prLogisticDelta(fit_ml, standardisation = "marginal")
#' }
"Thailand"


#' Toenail Infection Trial -- Longitudinal Binary Outcome
#'
#' Data from a randomised clinical trial comparing two oral antifungal
#' treatments (itraconazole vs terbinafine) for toenail dermatophyte infection.
#' Patients were measured at up to 7 visits over 18 months.
#'
#' @format A data frame with 1908 rows and 5 variables:
#' \describe{
#'   \item{ID}{Patient identifier. There are 294 patients.}
#'   \item{Response}{Presence of moderate or severe onycholysis (nail
#'     separation): factor with levels `"Not moderate/severe"`,
#'     `"Moderate/severe"`. Binary outcome.}
#'   \item{Treatment}{Antifungal treatment: factor with levels
#'     `"Itraconazole"`, `"Terbinafine"`.}
#'   \item{Month}{Time since randomisation (months, continuous).}
#'   \item{Visit}{Visit number (1 to 7, integer).}
#' }
#'
#' @details
#' The dataset illustrates a longitudinal binary outcome with dropout (not
#' all patients have 7 visits). GEE with an unstructured or exchangeable
#' correlation is commonly used.
#'
#' @source
#' De Backer, M. et al. (1998). Twelve weeks of continuous oral therapy for
#' toenail onychomycosis caused by dermatophytes. *Journal of the American
#' Academy of Dermatology*, **38**, S57-S63.
#'
#' @examples
#' data(Toenail)
#' table(Toenail$Response, Toenail$Treatment)
#'
#' \donttest{
#' library(geepack)
#' Toenail$resp_bin <- as.integer(Toenail$Response == "Moderate/severe")
#' fit_gee <- geeglm(resp_bin ~ Treatment + Month,
#'                   family = binomial, id = ID,
#'                   corstr = "exchangeable", data = Toenail)
#' prLogisticGEE(fit_gee)
#' }
"Toenail"


#' UIS Drug Treatment Study
#'
#' Data from the University of Massachusetts AIDS Research Unit (UMARU) Impact
#' Study, a 5-year study comparing two residential treatment programmes for
#' drug abuse.
#'
#' @format A data frame with 575 rows and 7 variables:
#' \describe{
#'   \item{ID}{Patient identifier.}
#'   \item{Age}{Age at enrolment (years, centred).}
#'   \item{DrugUse}{History of intravenous drug use: factor with levels
#'     `"Short"` (<= 3 years), `"Long"` (> 3 years).}
#'   \item{race}{Race: factor with levels `"White"`, `"Other"`.}
#'   \item{trt}{Treatment assignment: factor with levels `"Short"` (3-month),
#'     `"Long"` (6-month).}
#'   \item{site}{Treatment site: factor with levels `"A"`, `"B"`.}
#'   \item{drugFree}{Drug-free at 6 months: factor with levels `"No"`, `"Yes"`.
#'     Binary outcome.}
#' }
#'
#' @source
#' Hosmer, D. W. & Lemeshow, S. (2000). *Applied Logistic Regression*,
#' 2nd ed. Wiley, New York.
#'
#' @examples
#' data(UIS)
#' prop.table(table(UIS$drugFree))
#'
#' fit <- glm(as.integer(drugFree == "Yes") ~ trt + Age + DrugUse + race + site,
#'            family = binomial, data = UIS)
#' prLogisticDelta(fit, standardisation = "conditional")
"UIS"


#' Downer Cow Survival Data
#'
#' Veterinary study of downer cows (cattle unable to rise after calving).
#' The outcome is whether the animal survived to discharge.
#'
#' @format A data frame with 216 rows and 5 variables:
#' \describe{
#'   \item{AST}{Aspartate aminotransferase (enzyme marker): 0 = normal,
#'     1 = elevated.}
#'   \item{CK}{Creatine kinase (enzyme marker): 0 = normal, 1 = elevated.}
#'   \item{Calving}{Whether the downer condition was related to calving:
#'     0 = No, 1 = Yes.}
#'   \item{Myopathy}{Presence of myopathy: factor with levels `"No"`, `"Yes"`.}
#'   \item{Survival}{Outcome: factor with levels `"Died"`, `"Survived"`.
#'     Binary outcome.}
#' }
#'
#' @source
#' Dohoo, I., Martin, W. & Stryhn, H. (2003). *Veterinary Epidemiologic
#' Research*. AVC Inc., Prince Edward Island, Canada.
#'
#' @examples
#' data(downer)
#' prop.table(table(downer$Survival))
#'
#' fit <- glm(as.integer(Survival == "Survived") ~ Myopathy + AST + CK + Calving,
#'            family = binomial, data = downer)
#' prLogisticDelta(fit)
"downer"


#' Titanic Passenger Survival
#'
#' Survival data for 1307 passengers aboard the RMS Titanic. The outcome is
#' whether the passenger survived.
#'
#' @format A data frame with 1307 rows and 4 variables:
#' \describe{
#'   \item{pclass}{Passenger class: factor with levels `"1"`, `"2"`, `"3"`.}
#'   \item{survived}{Survived: factor with levels `"No"`, `"Yes"`.
#'     Binary outcome.}
#'   \item{sex}{Sex: factor with levels `"Female"`, `"Male"`.}
#'   \item{embarked}{Port of embarkation: 0 = Southampton, 1 = Cherbourg/
#'     Queenstown.}
#' }
#'
#' @details
#' Overall survival rate is approximately 38%, making this a common
#' outcome -- a setting where OR meaningfully diverges from PR.
#'
#' @source
#' Harrell, F. E. (2001). *Regression Modeling Strategies*. Springer, New York.
#'
#' @examples
#' data(titanic)
#' prop.table(table(titanic$survived, titanic$sex), margin = 2)
#'
#' fit <- glm(as.integer(survived == "Yes") ~ sex + pclass,
#'            family = binomial, data = titanic)
#'
#' # OR vs PR comparison
#' OR <- exp(coef(fit))
#' PR <- prLogisticDelta(fit, standardisation = "marginal")
#' print(PR)
"titanic"
