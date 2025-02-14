test_that("can find the previous helper", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  cli_helper <- .init_helper("cli")
  expect_no_error(response <- cli_helper$chat("stop(\"Error message here\")"))
})

test_that("chat errors informatively with no input", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  cli_helper <- .init_helper("cli")
  expect_snapshot(error = TRUE, cli_helper$chat())
})

test_that("chores_chat effectively integrates system prompt", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  cli_helper <- .init_helper("cli")
  response <- cli_helper$chat("stop(\"Error message here\")")
  expect_true(grepl("cli_abort", response))
  expect_true(grepl("Error message here", response))

  testthat_helper <- .init_helper("testthat")
  response <- testthat_helper$chat("expect_error(beep_bop_boop())")
  expect_true(grepl("expect_snapshot", response))
  expect_true(grepl("beep_bop_boop", response))
})

test_that("fetch_chores_chat returns early with no option set", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  withr::local_options(.chores_chat = NULL)
  skip_if_not_installed("withr")

  expect_snapshot(.res <- fetch_chores_chat())
  expect_null(.res)
})

test_that("fetch_chores_chat returns early with bad config", {
  withr::local_options(.chores_chat = "chat")
  expect_snapshot(.res <- fetch_chores_chat())
  expect_null(.res)

  mock_chat <- structure(list(), class = "Chat")
  expect_identical(fetch_chores_chat(mock_chat), mock_chat)
})
