test_that("initializing a pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  expect_snapshot(pal("cli"))
  expect_snapshot(pal("testthat"))
})

test_that("can use other models", {
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  # respects other argument values
  expect_snapshot(pal("cli", fn = "new_chat_openai", model = "gpt-4o-mini"))

  # respects .clipal_* options
  withr::local_options(
    .clipal_fn = "new_chat_openai",
    .clipal_args = list(model = "gpt-4o-mini")
  )
  expect_snapshot(pal("cli"))
})

test_that("errors informatively with bad role", {
  expect_snapshot(pal(), error = TRUE)
  expect_snapshot(pal(NULL), error = TRUE)
  expect_snapshot(pal("beep bop boop"), error = TRUE)
})
