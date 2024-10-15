test_that("prompt_* functions work", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.pal_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  path <- "test-prompt-dir/floop-replace.md"
  if (file.exists(path)) {file.remove(path)}
  withr::defer({if (file.exists(path)) {file.remove(path)}})

  if ("floop" %in% list_pals()) {
    .pal_remove("floop")
  }

  .res <- prompt_new("floop", "replace")
  expect_equal(.res, path)
  expect_true(file.exists(.res))

  .res <- prompt_edit("floop")
  expect_equal(.res, path)
  expect_true(file.exists(.res))

  .res <- prompt_remove("floop")
  expect_equal(.res, path)
  expect_false(file.exists(.res))
})

test_that("prompt_new errors informatively with redundant role", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.pal_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  expect_snapshot(error = TRUE, prompt_new("boop", "replace"))
  expect_snapshot(error = TRUE, prompt_new("boop", "prefix"))

  expect_snapshot(error = TRUE, prompt_new("cli", "replace"))
})

test_that("prompt_remove errors informatively with bad role", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.pal_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  expect_snapshot(error = TRUE, prompt_remove("nonexistentrole"))
})
