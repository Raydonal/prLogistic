# =============================================================================
# test-utils.R  — internal utilities (accessed via :::)
# =============================================================================

test_that(".expit is numerically stable and correct", {
  expect_equal(prLogistic:::.expit(0),   0.5)
  expect_equal(prLogistic:::.expit(Inf), 1)
  expect_equal(prLogistic:::.expit(-Inf), 0)
  expect_true(prLogistic:::.expit(-800) > 0)
  expect_equal(prLogistic:::.expit(2), 1 - prLogistic:::.expit(-2))
})

test_that(".is_* checkers work correctly", {
  fit <- glm(cbind(1, 0) ~ 1, family = binomial)
  expect_true(prLogistic:::.is_glm(fit))
  expect_false(prLogistic:::.is_glmer(fit))
  expect_false(prLogistic:::.is_gee(fit))
  expect_false(prLogistic:::.is_svyglm(fit))
})

test_that(".resolve_ref: binary columns default to 0", {
  X <- matrix(c(1,0,1,0, 10,20,15,30), nrow=4,
              dimnames = list(NULL, c("smoke","age")))
  ref <- prLogistic:::.resolve_ref(X, NULL, "median")
  expect_equal(ref["smoke"], c(smoke = 0))
  expect_equal(ref["age"], c(age = median(c(10,20,15,30))))
})

test_that(".resolve_ref: ref_values override defaults", {
  X <- matrix(c(10,20,15,30), nrow=4, dimnames = list(NULL,"age"))
  ref <- prLogistic:::.resolve_ref(X, list(age = 25), "median")
  expect_equal(ref["age"], c(age = 25))
})

test_that(".resolve_ref warns on unknown ref_values names", {
  X <- matrix(c(10,20), nrow=2, dimnames = list(NULL,"age"))
  expect_warning(
    prLogistic:::.resolve_ref(X, list(nonexistent=5), "median"),
    "not found"
  )
})

test_that(".build_contrast_rows returns correct structure", {
  ref  <- c(smoke=0, age=30, bmi=25)
  rows <- prLogistic:::.build_contrast_rows(j=1, ref=ref)
  expect_equal(rows$x1, c(1, 1, 30, 25))
  expect_equal(rows$x0, c(1, 0, 30, 25))
})

test_that(".delta_var_logPR returns non-negative scalar", {
  set.seed(1)
  Sigma <- crossprod(matrix(rnorm(9), 3, 3))
  v <- prLogistic:::.delta_var_logPR(p1=0.4, p0=0.2,
                                      x1=c(1,1,5), x0=c(1,0,5),
                                      Sigma=Sigma)
  expect_true(is.numeric(v) && length(v)==1 && v >= 0)
})
