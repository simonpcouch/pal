test_that("can find the previous pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  cli_pal <- .init_pal("cli")
  expect_no_error(response <- cli_pal$chat("stop(\"Error message here\")"))
})

test_that("chat errors informatively with no input", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  cli_pal <- .init_pal("cli")
  expect_snapshot(error = TRUE, cli_pal$chat())
})

test_that("pal_chat effectively integrates system prompt", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  cli_pal <- .init_pal("cli")
  response <- cli_pal$chat("stop(\"Error message here\")")
  expect_true(grepl("cli_abort", response))
  expect_true(grepl("Error message here", response))

  testthat_pal <- .init_pal("testthat")
  response <- testthat_pal$chat("expect_error(beep_bop_boop())")
  expect_true(grepl("expect_snapshot", response))
  expect_true(grepl("beep_bop_boop", response))
})
