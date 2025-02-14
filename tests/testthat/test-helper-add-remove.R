test_that("helper addition and removal works", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.chores_chat = ellmer::chat_claude())

  boop_prompt <- "just reply with beep bop boop regardless of input"
  .helper_add("boopery", boop_prompt)

  expect_equal(env_get(chores_env(), ".helper_prompt_boopery"), boop_prompt)
  expect_true(is_function(env_get(chores_env(), ".helper_rs_boopery")))

  helper_boopery <- .init_helper("boopery")
  expect_snapshot(helper_boopery)
  expect_true(".helper_last_boopery" %in% names(chores_env()))

  res <- helper_boopery$chat("hey there")
  expect_true(grepl("bop", res))

  .helper_remove("boopery")

  expect_false(".helper_last_boopery" %in% names(chores_env()))
  expect_false(".helper_prompt_boopery" %in% names(chores_env()))
  expect_false(".helper_rs_boopery" %in% names(chores_env()))
})

test_that("helper addition with bad inputs", {
  expect_snapshot(
    error = TRUE,
    .helper_add(chore = identity, prompt = "hey")
  )

  expect_snapshot(
    error = TRUE,
    .helper_add(chore = "sillyhead", prompt = "hey", interface = "no")
  )
  expect_snapshot(
    error = TRUE,
    .helper_add(chore = "sillyhead", prompt = "hey", interface = NULL)
  )
})

test_that("helper remove with bad inputs", {
  expect_snapshot(
    error = TRUE,
    .helper_remove(chore = identity)
  )
  expect_snapshot(
    error = TRUE,
    .helper_remove(chore = "notAnActiveHelper")
  )
})
