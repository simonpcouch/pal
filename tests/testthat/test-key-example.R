test_that("key_get works", {
  withr::local_envvar(example = "variable")
  expect_error(key_get("example"), regexp = NA)

  withr::local_envvar(example = NULL)
  expect_error(key_get("example"), regexp = "Can't find env var `example`")
})
