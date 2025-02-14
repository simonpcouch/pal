test_that("prompt_* functions work", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  path <- "test-prompt-dir/floop-replace.md"
  if (file.exists(path)) {file.remove(path)}
  withr::defer({if (file.exists(path)) {file.remove(path)}})

  if ("floop" %in% list_helpers()) {
    .helper_remove("floop")
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

test_that("prompt_new errors informatively with redundant chore", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  expect_snapshot(error = TRUE, prompt_new("boop", "replace"))
  expect_snapshot(error = TRUE, prompt_new("boop", "prefix"))
})

test_that("prompt_new works when directory doesn't exist yet (#47)", {
  subdir <- "test-prompt-dir/subdir"
  withr::local_options(.chores_dir = subdir)
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  if (dir.exists(subdir)) {unlink(subdir, recursive = TRUE)}
  if ("floop" %in% list_helpers()) {.helper_remove("floop")}

  withr::defer({
    if (dir.exists(subdir)) {unlink(subdir, recursive = TRUE)}
    if ("floop" %in% list_helpers()) {.helper_remove("floop")}
  })

  .res <- prompt_new("floop", "replace")
  expect_equal(.res, paste0(subdir, "/floop-replace.md"))
  expect_true(file.exists(.res))
})

test_that("prompt_remove errors informatively with bad chore", {
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})

  expect_snapshot(error = TRUE, prompt_remove("nonexistentchore"))
})

test_that("new prompts can be pre-filled with contents", {
  skip_if_offline()
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})
  withr::defer(prompt_remove("summarizeAlt"))

  # expect that no "incomplete final line" warnings are raised
  expect_snapshot(
    p <-
      prompt_new(
        "summarizeAlt",
        "prefix",
        "https://gist.githubusercontent.com/simonpcouch/daaa6c4155918d6f3efd6706d022e584/raw/ed1da68b3f38a25b58dd9fdc8b9c258d58c9b4da/summarize-prefix.md"
      )
  )

  expected_path <- paste0(directory_path(), "/summarizeAlt-prefix.md")
  expect_equal(p, expected_path)
  lines <- base::readLines(expected_path)
  expect_true(grepl("Given some text", lines))
})

test_that("new prompts are pre-filled with a template by default (#57)", {
  skip_if_offline()
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})
  withr::defer(prompt_remove("template"))

  path <- prompt_new("template", "prefix")

  lines <- base::readLines(path)

  expect_equal(lines[1], "# Template chore helper")
})

test_that("new prompts error informatively with bad pre-fill contents", {
  skip_if_offline()
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})
  withr::defer(prompt_remove("summarizeAlt"))

  expect_snapshot(
    error = TRUE,
    p <-
      prompt_new(
        "summarizeAlt",
        "prefix",
        "https://gist.github.com/simonpcouch/daaa6c4155918d6f3efd6706d022e584"
      )
  )
})

test_that("prompts can be added, removed, and added again without restart (#58)", {
  skip_if_offline()
  # contains two prompts, `boop-replace` and `wop-prefix`
  withr::local_options(.chores_dir = "test-prompt-dir")
  testthat::local_mocked_bindings(interactive = function(...) {FALSE})
  withr::defer(prompt_remove("template"))

  path <- prompt_new("template", "prefix")
  prompt_remove("template")
  prompt_new("template", "prefix")

  expect_true(file.exists(path))
})

test_that("default chores can't be overwritten or deleted (#59)", {
  expect_snapshot(error = TRUE, prompt_new("cli", "replace"))
  expect_snapshot(error = TRUE, prompt_edit("cli"))
  expect_snapshot(error = TRUE, prompt_remove("cli"))
})

test_that("is_markdown_file works", {
  expect_true(is_markdown_file("some_file.md"))
  expect_true(is_markdown_file("some_file.Md"))
  expect_true(is_markdown_file("some_file.Markdown"))
  expect_true(is_markdown_file(
    "https://gist.githubusercontent.com/simonpcouch/daaa6c4155918d6f3efd6706d022e584/raw/ed1da68b3f38a25b58dd9fdc8b9c258d58c9b4da/summarize-prefix.md"
  ))

  expect_false(is_markdown_file("markdown_md.txtdev"))
  expect_false(is_markdown_file("some_file.txt"))
  expect_false(is_markdown_file(
    "https://gist.github.com/simonpcouch/daaa6c4155918d6f3efd6706d022e584"
  ))
})
