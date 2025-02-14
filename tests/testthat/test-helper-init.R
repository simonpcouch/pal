test_that("initializing a helper", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  expect_snapshot(.init_helper("cli"))
  expect_snapshot(.init_helper("testthat"))
})

test_that("can use other models", {
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  # respects other argument values
  expect_snapshot(.init_helper(
    "cli",
    .chores_chat = ellmer::chat_openai(model = "gpt-4o-mini")
  ))
})

test_that("errors informatively with bad chore", {
  expect_snapshot(.init_helper(), error = TRUE)
  expect_snapshot(.init_helper(NULL), error = TRUE)
  expect_snapshot(.init_helper("beepBopBoop"), error = TRUE)
})
