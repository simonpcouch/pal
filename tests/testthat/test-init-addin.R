test_that(".init_addin exits early with missing selection", {
  testthat::local_mocked_bindings(.pal_app = function() NULL)
  expect_null(.init_addin())
})

test_that(".init_addin exits early with empty selection", {
  testthat::local_mocked_bindings(.pal_app = function() ".pal_rs_")
  expect_null(.init_addin())
})

test_that("errors informatively on .pal_app error", {
  testthat::local_mocked_bindings(
    .pal_app = function() cli::cli_abort("some error")
  )
  expect_snapshot(.init_addin(), error = TRUE)
})

test_that("errors informatively with missing binding", {
  testthat::local_mocked_bindings(
    .pal_app = function() ".pal_rs_some_fn",
    env_get = function(...) cli::cli_abort("nope.")
  )
  expect_snapshot(.init_addin(), error = TRUE)
})

test_that(".init_addin executes found binding", {
  mock_fn <- function() cli::cli_inform("howdy!")
  testthat::local_mocked_bindings(
    .pal_app = function() ".pal_rs_mock",
    env_get = function(...) mock_fn
  )
  expect_snapshot(res <- .init_addin())
  expect_null(res)
})
