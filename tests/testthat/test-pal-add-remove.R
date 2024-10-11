test_that("pal addition and removal works", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  boop_prompt <- "just reply with beep bop boop regardless of input"
  .pal_add("boopery", boop_prompt)

  expect_equal(.pal_prompt_boopery, boop_prompt)
  expect_true(is_function(.pal_rs_boopery))
  expect_true(".pal_prompt_boopery" %in% names(pal_env()))
  expect_true(".pal_rs_boopery" %in% names(pal_env()))

  pal_boopery <- .pal_init("boopery")
  expect_snapshot(pal_boopery)
  expect_true(".pal_last_boopery" %in% names(pal_env()))

  res <- pal_boopery$chat("hey there")
  expect_true(grepl("bop", res))

  .pal_remove("boopery")

  expect_false(".pal_last_boopery" %in% names(pal_env()))
  expect_false(".pal_prompt_boopery" %in% names(pal_env()))
  expect_false(".pal_rs_boopery" %in% names(pal_env()))
})

test_that("pal addition with bad inputs", {
  expect_snapshot(
    error = TRUE,
    .pal_add(role = identity, prompt = "hey")
  )

  # TODO: decide on `prompt` interface and test


  expect_snapshot(
    error = TRUE,
    .pal_add(role = "sillyhead", prompt = "hey", interface = "no")
  )
  expect_snapshot(
    error = TRUE,
    .pal_add(role = "sillyhead", prompt = "hey", interface = "suffix")
  )
  expect_snapshot(
    error = TRUE,
    .pal_add(role = "sillyhead", prompt = "hey", interface = NULL)
  )
})

test_that("pal remove with bad inputs", {
  expect_snapshot(
    error = TRUE,
    .pal_remove(role = identity)
  )
  expect_snapshot(
    error = TRUE,
    .pal_remove(role = "notAnActivePal")
  )
})
