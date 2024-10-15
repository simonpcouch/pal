test_that(".pal_last is up to date with most recent pal", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  .init_pal("cli")
  expect_snapshot(env_get(pal_env(), ".pal_last"))
  expect_snapshot(env_get(pal_env(), ".pal_last_cli"))

  .init_pal("cli", "chat_openai", model = "gpt-4o-mini")
  expect_snapshot(env_get(pal_env(), ".pal_last"))
})
