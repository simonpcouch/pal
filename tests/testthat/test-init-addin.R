test_that(".init_addin exits early with missing selection", {
  testthat::local_mocked_bindings(
    .chores_app = function() NULL,
    fetch_chores_chat = function(...) "hey"
  )
  expect_null(.init_addin())
})

test_that(".init_addin exits early with empty selection", {
  testthat::local_mocked_bindings(
    .chores_app = function() ".helper_rs_",
    fetch_chores_chat = function(...) "hey"
  )
  expect_null(.init_addin())
})

test_that("errors informatively on .chores_app error", {
  testthat::local_mocked_bindings(
    .chores_app = function() cli::cli_abort("some error"),
    fetch_chores_chat = function(...) "hey"
  )
  expect_snapshot(.init_addin(), error = TRUE)
})

test_that("errors informatively with missing binding", {
  testthat::local_mocked_bindings(
    .chores_app = function() ".helper_rs_some_fn",
    env_get = function(...) cli::cli_abort("nope."),
    fetch_chores_chat = function(...) "hey"
  )
  expect_snapshot(.init_addin(), error = TRUE)
})

test_that(".init_addin executes found binding", {
  mock_fn <- function() cli::cli_inform("howdy!")
  testthat::local_mocked_bindings(
    .chores_app = function() ".helper_rs_mock",
    env_get = function(...) mock_fn,
    fetch_chores_chat = function(...) "hey"
  )
  expect_snapshot(res <- .init_addin())
  expect_null(res)
})
