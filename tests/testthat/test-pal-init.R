test_that("initializing a pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_chat = ellmer::chat_claude())

  expect_snapshot(.init_pal("cli"))
  expect_snapshot(.init_pal("testthat"))
})

test_that("can use other models", {
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_chat = ellmer::chat_claude())

  # respects other argument values
  expect_snapshot(.init_pal(
    "cli",
    .pal_chat = ellmer::chat_openai(model = "gpt-4o-mini")
  ))
})

test_that("errors informatively with bad role", {
  expect_snapshot(.init_pal(), error = TRUE)
  expect_snapshot(.init_pal(NULL), error = TRUE)
  expect_snapshot(.init_pal("beepBopBoop"), error = TRUE)
})
