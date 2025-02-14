#' The testthat helper
#'
#' @description
#'
#' testthat 3.0.0 was released in 2020, bringing with it numerous changes
#' that were both huge quality of life improvements for package developers
#' and also highly breaking changes.
#'
#' While some of the task of converting legacy unit testing code to testthat
#' 3e is quite is pretty straightforward, other components can be quite tedious.
#' The testthat helper helps you transition your R package's unit tests to
#' the third edition of testthat, namely via:
#'
#' * Converting to snapshot tests
#' * Disentangling nested expectations
#' * Transitioning from deprecated functions like `expect_known_*()`
#'
#'
#' @section Cost:
#'
#' The system prompt from a testthat helper includes something like 1,000 tokens.
#' Add in (a generous) 100 tokens for the code that's actually highlighted
#' and also sent off to the model and you're looking at 1,100 input tokens.
#' The model returns approximately the same number of output tokens as it
#' receives, so we'll call that 100 output tokens per refactor.
#'
#' As of the time of writing (October 2024), the recommended chores model Claude
#' Sonnet 3.5 costs $3 per million input tokens and $15 per million output
#' tokens. So, using the recommended model,
#' **testthat helpers cost around $4 for every 1,000 refactored pieces of code**. GPT-4o
#' Mini, by contrast, doesn't tend to get many pieces of formatting right and
#' often fails to line-break properly, but _does_ usually return syntactically
#' valid calls to testthat functions, and it would cost around
#' 20 cents per 1,000 refactored pieces of code.
#'
#' @section Gallery:
#'
#' This section includes a handful of examples
#' "[from](https://github.com/tidymodels/broom/tree/7fa26488ab522bf577092e99aad1f2003f21b327/tests)
#' the [wild](https://github.com/tidymodels/tune/tree/f8d734ac0fa981fae3a87ed2871a46e9c40d509d/tests)"
#' and are generated with the recommended model, Claude Sonnet 3.5.
#'
#' Testthat helpers convert `expect_error()` (and `*_warning()` and `*_message()`
#' and `*_condition()`) calls to use `expect_snapshot()` when there's a
#' regular expression present:
#'
#' ```r
#' expect_warning(
#'   check_ellipses("exponentiate", "tidy", "boop", exponentiate = TRUE, quick = FALSE),
#'   "\\`exponentiate\\` argument is not supported in the \\`tidy\\(\\)\\` method for \\`boop\\` objects"
#' )
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_snapshot(
#'   .res <- check_ellipses(
#'     "exponentiate", "tidy", "boop", exponentiate = TRUE, quick = FALSE
#'   )
#' )
#' ```
#'
#' Note, as well, that intermediate results are assigned to an object so as
#' not to be snapshotted when their contents weren't previously tests.
#'
#' Another example with multiple, redudant calls:
#'
#' ```r
#' augment_error <- "augment is only supported for fixest models estimated with feols, feglm, or femlm"
#' expect_error(augment(res_fenegbin, df), augment_error)
#' expect_error(augment(res_feNmlm, df), augment_error)
#' expect_error(augment(res_fepois, df), augment_error)
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_snapshot(error = TRUE, augment(res_fenegbin, df))
#' expect_snapshot(error = TRUE, augment(res_feNmlm, df))
#' expect_snapshot(error = TRUE, augment(res_fepois, df))
#' ```
#'
#' They know about `regexp = NA`, which means "no error" (or warning, or message):
#'
#' ```r
#' expect_error(
#'   p4_b <- check_parameters(w4, p4_a, data = mtcars),
#'   regex = NA
#' )
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_no_error(p4_b <- check_parameters(w4, p4_a, data = mtcars))
#' ```
#'
#' They also know not to adjust calls to those condition expectations when
#' there's a `class` argument present (which usually means that one is
#' testing a condition from another package, which should be able to change
#' the wording of the message without consequence):
#'
#' ```r
#' expect_error(tidy(pca, matrix = "u"), class = "pca_error")
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_error(tidy(pca, matrix = "u"), class = "pca_error")
#' ```
#'
#' When converting non-erroring code, testthat helpers will assign intermediate
#' results so as not to snapshot both the result and the warning:
#'
#' ```r
#' expect_warning(
#'   tidy(fit, robust = TRUE),
#'   '"robust" argument has been deprecated'
#' )
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_snapshot(
#'   .res <- tidy(fit, robust = TRUE)
#' )
#' ```
#'
#' Nested expectations can generally be disentangled without issue:
#'
#' ```r
#' expect_equal(
#'   fit_resamples(decision_tree(cost_complexity = 1), bootstraps(mtcars)),
#'   expect_warning(tune_grid(decision_tree(cost_complexity = 1), bootstraps(mtcars)))
#' )
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_snapshot({
#'   fit_resamples_result <- fit_resamples(decision_tree(cost_complexity = 1),
#'                                         bootstraps(mtcars))
#'   tune_grid_result <- tune_grid(decision_tree(cost_complexity = 1),
#'                                 bootstraps(mtcars))
#' })
#' expect_equal(fit_resamples_result, tune_grid_result)
#' ```
#'
#' There are also a few edits the helper knows to make to third-edition code.
#' For example, it transitions `expect_snapshot_error()` and friends to
#' use `expect_snapshot(error = TRUE)` so that the error context is snapshotted
#' in addition to the message itself:
#'
#' ```r
#' expect_snapshot_error(
#'   fit_best(knn_pca_res, parameters = tibble(neighbors = 2))
#' )
#' ```
#'
#' Returns:
#'
#' ```r
#' expect_snapshot(
#'   error = TRUE,
#'   fit_best(knn_pca_res, parameters = tibble(neighbors = 2))
#' )
#' ```
#'
#' @templateVar chore testthat
#' @template manual-interface
#'
#' @name testthat_helper
NULL
