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


test_that("role checks error informatively", {
  expect_snapshot(error = TRUE, check_role("hey there"))
  expect_snapshot(error = TRUE, check_role(identity))
})

test_that("is_valid_role works", {
  expect_true(is_valid_role("role"))
  expect_true(is_valid_role("newRole"))
  expect_true(is_valid_role("role123"))
  expect_true(is_valid_role("ROLE"))
  expect_true(is_valid_role("r"))
  expect_true(is_valid_role("1"))

  expect_false(is_valid_role("new role"))
  expect_false(is_valid_role("new@role"))
  expect_false(is_valid_role("role_"))
  expect_false(is_valid_role("role-"))
  expect_false(is_valid_role("new-role"))
  expect_false(is_valid_role("role\n123"))
  expect_false(is_valid_role(" "))
})
