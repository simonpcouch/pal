test_that(".helper_last is up to date with most recent helper", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if(identical(Sys.getenv("OPENAI_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  .init_helper("cli")
  expect_snapshot(env_get(chores_env(), ".helper_last"))
  expect_snapshot(env_get(chores_env(), ".helper_last_cli"))

  .init_helper("cli", ellmer::chat_openai(model = "gpt-4o-mini"))
  expect_snapshot(env_get(chores_env(), ".helper_last"))
})


test_that("chore checks error informatively", {
  expect_snapshot(error = TRUE, check_chore("hey there"))
  expect_snapshot(error = TRUE, check_chore(identity))
})

test_that("is_valid_chore works", {
  expect_true(is_valid_chore("chore"))
  expect_true(is_valid_chore("newRole"))
  expect_true(is_valid_chore("chore123"))
  expect_true(is_valid_chore("ROLE"))
  expect_true(is_valid_chore("r"))
  expect_true(is_valid_chore("1"))

  expect_false(is_valid_chore("new chore"))
  expect_false(is_valid_chore("new@chore"))
  expect_false(is_valid_chore("chore_"))
  expect_false(is_valid_chore("chore-"))
  expect_false(is_valid_chore("new-chore"))
  expect_false(is_valid_chore("chore\n123"))
  expect_false(is_valid_chore(" "))
})
