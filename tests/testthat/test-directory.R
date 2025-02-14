test_that("directory_load works", {
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
      {.helper_remove("boop"); .helper_remove("wop")},
      error = function(e) {invisible()}
    )
  )

  directory_load(tmp_dir)

  expect_true(all(c("beep", "wop") %in% list_helpers()))
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

test_that("directory_list works", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {TRUE})
  expect_snapshot(directory_list())

  testthat::local_mocked_bindings(interactive = function(...) {TRUE})
  expect_snapshot(directory_list())
})

test_that("directory_list works", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  expect_equal(directory_path(), "test-prompt-dir")
})

test_that("directory_set works", {
  expect_snapshot(error = TRUE, directory_set(identity))

  withr::local_options(.chores_dir = "test-prompt-dir")
  path <- directory_path()
  withr::defer(directory_set(path))

  expect_snapshot(
    error = TRUE,
    directory_set("some/nonexistent/path")
  )

  path_new <- file.path(path, "test")
  if (file.exists(path_new)) {file.remove(path_new)}
  withr::defer({if (file.exists(path_new)) {file.remove(path_new)}})
  dir.create(path_new)
  .res <- directory_set(path_new)
  expect_equal(directory_path(), .res)
  expect_equal(directory_path(), path_new)
})

test_that("directory_load() doesn't warn with no trailing newline (#75)", {
  tmp_dir <- withr::local_tempdir()

  writeLines(
    text = "Example prompt.",
    con = file.path(tmp_dir, "test-replace.md"),
    sep = ""
  )

  withr::defer(
    try_fetch({.helper_remove("test")}, error = function(e) {invisible()})
  )

  expect_no_warning(directory_load(tmp_dir))
  expect_true("test" %in% list_helpers())
})

test_that("directory_list returns empty and messages informatively when no files", {
  tmp_dir <- withr::local_tempdir()
  withr::local_options(.chores_dir = tmp_dir)
  testthat::local_mocked_bindings(interactive = function(...) {TRUE})

  expect_snapshot(res <- directory_list())
  expect_equal(res, character(0))
})

