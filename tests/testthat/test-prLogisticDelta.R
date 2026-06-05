# =============================================================================
# test-prLogisticDelta.R
# Integration tests using infert (stable, always available)
# =============================================================================

# ---- Shared fixture --------------------------------------------------------
local_fit <- local({
  glm(case ~ induced + spontaneous + parity, family = binomial, data = infert)
})

local_data <- local({
  infert
})

# ---- Return type -----------------------------------------------------------
test_that("prLogisticDelta returns a prLogistic object", {
  res <- prLogisticDelta(local_fit)
  expect_s3_class(res, "prLogistic")
  expect_true(is.list(res))
  expect_true(all(c("table", "conf", "method", "standardisation",
                     "model_type", "call") %in% names(res)))
})

# ---- Table structure -------------------------------------------------------
test_that("result table has correct dimensions and column names", {
  res <- prLogisticDelta(local_fit)
  tbl <- res$table
  expect_true(is.matrix(tbl))
  expect_equal(ncol(tbl), 3L)
  expect_equal(colnames(tbl)[1], "Estimate")
  expect_equal(nrow(tbl), 3L)
})

# ---- PR values are positive ------------------------------------------------
test_that("PR estimates are positive", {
  res <- prLogisticDelta(local_fit, standardisation = "conditional")
  expect_true(all(res$table[, "Estimate"] > 0, na.rm = TRUE))
  res2 <- prLogisticDelta(local_fit, standardisation = "marginal")
  expect_true(all(res2$table[, "Estimate"] > 0, na.rm = TRUE))
})

# ---- CI ordering -----------------------------------------------------------
test_that("lower CI <= Estimate <= upper CI", {
  res <- prLogisticDelta(local_fit)
  tbl <- res$table
  expect_true(all(tbl[, 2] <= tbl[, 1] + 1e-10, na.rm = TRUE))
  expect_true(all(tbl[, 1] <= tbl[, 3] + 1e-10, na.rm = TRUE))
})

# ---- conf level stored correctly -------------------------------------------
test_that("confidence level is stored correctly", {
  res <- prLogisticDelta(local_fit, conf = 0.90)
  expect_equal(res$conf, 0.90)
  expect_match(colnames(res$table)[2], "5%")
  expect_match(colnames(res$table)[3], "95%")
})

# ---- marginal and conditional differ ---------------------------------------
test_that("conditional and marginal PRs differ (as expected)", {
  cond <- prLogisticDelta(local_fit, standardisation = "conditional")
  marg <- prLogisticDelta(local_fit, standardisation = "marginal")
  # They should not be identical
  expect_false(isTRUE(all.equal(cond$table, marg$table)))
})

# ---- ref_continuous = "mean" vs "median" -----------------------------------
test_that("ref_continuous mean vs median gives different results", {
  res_med  <- prLogisticDelta(local_fit, ref_continuous = "median")
  res_mean <- prLogisticDelta(local_fit, ref_continuous = "mean")
  # age and lwt are continuous, so results should differ
  expect_false(isTRUE(all.equal(res_med$table, res_mean$table)))
})

# ---- ref_values override ---------------------------------------------------
test_that("ref_values override changes the estimate", {
  res_default <- prLogisticDelta(local_fit, standardisation = "conditional")
  res_custom  <- prLogisticDelta(local_fit, standardisation = "conditional",
                                  ref_values = list(age = 20, lwt = 100))
  expect_false(isTRUE(all.equal(res_default$table, res_custom$table)))
})

# ---- Bad model raises error ------------------------------------------------
test_that("non-supported model raises informative error", {
  lm_fit <- lm(age ~ parity, data = infert)
  expect_error(prLogisticDelta(lm_fit), "glm.*glmerMod.*geeglm.*svyglm")
})

# ---- Wrong conf raises error -----------------------------------------------
test_that("conf outside (0,1) raises error", {
  expect_error(prLogisticDelta(local_fit, conf = 1.5), "`conf`")
  expect_error(prLogisticDelta(local_fit, conf = 0),   "`conf`")
})

# ---- S3 methods work -------------------------------------------------------
test_that("print.prLogistic runs without error", {
  res <- prLogisticDelta(local_fit)
  expect_output(print(res), "Prevalence Ratio")
})

test_that("coef.prLogistic returns named numeric vector", {
  res <- prLogisticDelta(local_fit)
  co  <- coef(res)
  expect_true(is.numeric(co))
  expect_named(co)
})

test_that("confint.prLogistic returns matrix with 2 columns", {
  res <- prLogisticDelta(local_fit)
  ci  <- confint(res)
  expect_true(is.matrix(ci))
  expect_equal(ncol(ci), 2L)
})

test_that("plot.prLogistic runs without error", {
  res <- prLogisticDelta(local_fit)
  expect_silent(plot(res))
})

# ---- Intercept-only model error -------------------------------------------
test_that("intercept-only model raises informative error", {
    fit0 <- glm(low ~ 1, family = binomial, data = infert)
  expect_error(prLogisticDelta(fit0), "no predictors")
})
