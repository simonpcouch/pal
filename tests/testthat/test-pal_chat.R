test_that("pal_chat can find the previous pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  cli_pal <- pal("cli")
  expect_no_error(response <- pal_chat(stop("Error message here")))
  expect_s3_class(response, c("pal_response_testthat ", "pal_response"))
  expect_no_error(response <- pal_chat(stop("Error message here"), cli_pal))
  expect_s3_class(response, c("pal_response_testthat ", "pal_response"))
})

test_that("pal_chat errors informatively with no input", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  cli_pal <- pal("cli")
  expect_snapshot(error = TRUE, pal_chat())
})

test_that("pal_chat effectively integrates system prompt", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  pal("cli")
  response <- pal_chat(stop("Error message here"))
  expect_true(grepl("cli_abort", response))
  expect_true(grepl("Error message here", response))

  pal("testthat")
  response <- pal_chat(expect_error(beep_bop_boop()))
  expect_true(grepl("expect_snapshot", response))
  expect_true(grepl("beep_bop_boop", response))
})
