test_that("can find the previous pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_chat = ellmer::chat_claude())

  cli_pal <- .init_pal("cli")
  expect_no_error(response <- cli_pal$chat("stop(\"Error message here\")"))
})

test_that("chat errors informatively with no input", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_chat = ellmer::chat_claude())

  cli_pal <- .init_pal("cli")
  expect_snapshot(error = TRUE, cli_pal$chat())
})

test_that("pal_chat effectively integrates system prompt", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_chat = ellmer::chat_claude())

  cli_pal <- .init_pal("cli")
  response <- cli_pal$chat("stop(\"Error message here\")")
  expect_true(grepl("cli_abort", response))
  expect_true(grepl("Error message here", response))

  testthat_pal <- .init_pal("testthat")
  response <- testthat_pal$chat("expect_error(beep_bop_boop())")
  expect_true(grepl("expect_snapshot", response))
  expect_true(grepl("beep_bop_boop", response))
})

test_that("fetch_pal_chat returns early with old options", {
  withr::local_options(
    .pal_fn = "boop",
    .pal_args = list(model = "x"),
    .pal_chat = NULL
  )

  expect_snapshot(.res <- fetch_pal_chat())
  expect_null(.res)
})

test_that("fetch_pal_chat returns early with no option set", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  withr::local_options(.pal_chat = NULL)
  skip_if_not_installed("withr")

  expect_snapshot(.res <- fetch_pal_chat())
  expect_null(.res)
})

test_that("fetch_pal_chat returns early with bad config", {
  withr::local_options(.pal_chat = "chat")
  expect_snapshot(.res <- fetch_pal_chat())
  expect_null(.res)

  mock_chat <- structure(list(), class = "Chat")
  expect_identical(fetch_pal_chat(mock_chat), mock_chat)
})
