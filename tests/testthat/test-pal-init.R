test_that("initializing a pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  expect_snapshot(.pal_init("cli"))
  expect_snapshot(.pal_init("testthat"))
})

test_that("can use other models", {
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  # respects other argument values
  expect_snapshot(.pal_init("cli", fn = "chat_openai", model = "gpt-4o-mini"))

  # respects .clipal_* options
  withr::local_options(
    .clipal_fn = "chat_openai",
    .clipal_args = list(model = "gpt-4o-mini")
  )
  expect_snapshot(.pal_init("cli"))
})

test_that("errors informatively with bad role", {
  expect_snapshot(.pal_init(), error = TRUE)
  expect_snapshot(.pal_init(NULL), error = TRUE)
  expect_snapshot(.pal_init("beep bop boop"), error = TRUE)
})
