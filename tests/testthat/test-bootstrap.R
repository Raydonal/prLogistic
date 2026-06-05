# =============================================================================
# test-bootstrap.R
# Tests for prLogisticBootCond and prLogisticBootMarg
# =============================================================================

# Use few replicates for speed in CI
R_test <- 49L

local_data <- local({
  infert
})

local_fit <- glm(low ~ smoke + race + age, family = binomial, data = local_data)


# ---- prLogisticBootCond ----------------------------------------------------

test_that("prLogisticBootCond returns prLogistic object", {
  set.seed(1)
  res <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  expect_s3_class(res, "prLogistic")
  expect_equal(res$method, "bootstrap")
  expect_equal(res$standardisation, "conditional")
})

test_that("bootstrap table has 5 columns (Estimate + 4 CI bounds)", {
  set.seed(1)
  res <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  expect_equal(ncol(res$table), 5L)
})

test_that("bootstrap estimates are positive", {
  set.seed(1)
  res <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  expect_true(all(res$table[, "Estimate"] > 0, na.rm = TRUE))
})

test_that("confint(type='normal') returns 2-column matrix", {
  set.seed(1)
  res <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  ci  <- confint(res, type = "normal")
  expect_equal(ncol(ci), 2L)
})

test_that("confint(type='percentile') returns 2-column matrix", {
  set.seed(1)
  res <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  ci  <- confint(res, type = "percentile")
  expect_equal(ncol(ci), 2L)
})

test_that("bootstrap CI lower <= Estimate <= upper (normal)", {
  set.seed(1)
  res <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  lo  <- res$table[, 2]; hi <- res$table[, 3]; est <- res$table[, 1]
  expect_true(all(lo <= est + 1e-8, na.rm = TRUE))
  expect_true(all(est <= hi + 1e-8, na.rm = TRUE))
})


# ---- prLogisticBootMarg ----------------------------------------------------

test_that("prLogisticBootMarg returns prLogistic object", {
  set.seed(2)
  res <- prLogisticBootMarg(local_fit, data = local_data, R = R_test)
  expect_s3_class(res, "prLogistic")
  expect_equal(res$method, "bootstrap")
  expect_equal(res$standardisation, "marginal")
})

test_that("marginal bootstrap estimates differ from conditional", {
  set.seed(3)
  res_c <- prLogisticBootCond(local_fit, data = local_data, R = R_test)
  set.seed(3)
  res_m <- prLogisticBootMarg(local_fit, data = local_data, R = R_test)
  expect_false(isTRUE(all.equal(res_c$table[, 1], res_m$table[, 1])))
})


# =============================================================================
# test-gee-survey.R  (smoke tests — require packages)
# =============================================================================

test_that("prLogisticGEE raises error for non-geeglm input", {
    fit <- glm(case ~ induced + spontaneous, family = binomial, data = infert)
  expect_error(prLogisticGEE(fit), "geeglm")
})

test_that("prLogisticSurvey raises error for non-svyglm input", {
    fit <- glm(case ~ induced + spontaneous, family = binomial, data = infert)
  expect_error(prLogisticSurvey(fit), "svyglm")
})

test_that("prLogisticGEE works end-to-end", {
  skip_if_not_installed("geepack")
  library(geepack)
  data(ohio, package = "geepack")
  fit_gee <- geeglm(resp ~ smoke + age,
                    family = binomial, id = id,
                    corstr = "exchangeable", data = ohio)
  res <- prLogisticGEE(fit_gee)
  expect_s3_class(res, "prLogistic")
  expect_equal(res$model_type, "geeglm")
  expect_true(all(res$table[, "Estimate"] > 0, na.rm = TRUE))
})

test_that("prLogisticSurvey works end-to-end", {
  skip_if_not_installed("survey")
  library(survey)
  data(api, package = "survey")
  apiclus2$target_met <- as.numeric(apiclus2$sch.wide == "Yes")
  dclus2 <- svydesign(id = ~dnum + snum, fpc = ~fpc1 + fpc2, data = apiclus2)
  fit_svy <- svyglm(target_met ~ meals + stype,
                    design = dclus2, family = quasibinomial)
  res <- prLogisticSurvey(fit_svy)
  expect_s3_class(res, "prLogistic")
  expect_equal(res$model_type, "svyglm")
})

test_that("prLogisticGEE with bootstrap returns prLogistic object", {
  skip_if_not_installed("geepack")
  library(geepack)
  data(ohio, package = "geepack")
  fit_gee <- geeglm(resp ~ smoke + age, family = binomial, id = id,
                    corstr = "independence", data = ohio)
  set.seed(42)
  res <- prLogisticGEE(fit_gee, method = "bootstrap",
                        data = ohio, R = R_test)
  expect_s3_class(res, "prLogistic")
  expect_equal(res$method, "bootstrap")
})
