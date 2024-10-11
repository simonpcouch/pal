test_that("pal addition and removal works", {
  skip_if(identical(Sys.getenv("ANTHROPIC_API_KEY"), ""))
  skip_if_not_installed("withr")
  withr::local_options(.pal_fn = NULL, .pal_args = NULL)

  boop_prompt <- "just reply with beep bop boop regardless of input"
  .pal_add("boopery", boop_prompt)

  expect_equal(env_get(pal_env(), ".pal_prompt_boopery"), boop_prompt)
  expect_true(is_function(env_get(pal_env(), ".pal_rs_boopery")))

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

test_that(".pal_add_dir works", {
  tmp_dir <- withr::local_tempdir()

  writeLines(
    text = "Respond with 'beep bop boop' regardless of input.",
    con = file.path(tmp_dir, "beep-replace.md")
  )
  writeLines(
    text = "Respond with 'wee wee wop' regardless of input.",
    con = file.path(tmp_dir, "wop-prefix.md")
  )

  withr::defer(
    try_fetch(
      {
        .pal_remove("boop")
        .pal_remove("wop")
      },
      error = function(e) {invisible()}
    )

  )

  .pal_add_dir(tmp_dir)

  expect_true(all(c("beep", "wop") %in% list_pals()))
})

test_that("filter_single_hyphenated messages informatively", {
  x <- c("base-name", "basename", "base_name")

  expect_snapshot(res <- filter_single_hyphenated(x))
  expect_equal(res, x[1])
  expect_snapshot(res <- filter_single_hyphenated(x[1:2]))
  expect_equal(res, x[1])
  expect_no_message(filter_single_hyphenated(x[1]))
})

test_that("filter_interfaces messages informatively", {
  x <- list(c("beep", "replace"), c("bop", "bad"), c("boop", "silly"))

  expect_snapshot(res <- filter_interfaces(x))
  expect_equal(res, x[1])
  expect_snapshot(res <- filter_interfaces(x[1:2]))
  expect_equal(res, x[1])
})

