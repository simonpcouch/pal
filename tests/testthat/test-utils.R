test_that(".pal_last is up to date with most recent pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  pal("cli")
  expect_snapshot(.pal_last)
  expect_snapshot(.pal_last_cli)

  pal("cli", "chat_openai", model = "gpt-4o-mini")
  expect_snapshot(.pal_last)
})
