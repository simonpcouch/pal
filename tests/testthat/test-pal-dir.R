
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

