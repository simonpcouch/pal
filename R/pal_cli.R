#' The cli pal
#'
#' @description
#'
#' A couple years ago, the tidyverse team began migrating to the cli R package
#' for raising errors, transitioning away from base R (e.g. `stop()`),
#' rlang (e.g. `rlang::abort()`), glue, and homegrown combinations of them.
#' cli's new syntax is easier to work with as a developer and more visually
#' pleasing as a user.
#'
#' In some cases, transitioning is as simple as Finding + Replacing
#' `rlang::abort()` to `cli::cli_abort()`. In others, there's a mess of
#' ad-hoc pluralization, `paste0()`s, glue interpolations, and other
#' assorted nonsense to sort through. Total pain, especially with thousands
#' upon thousands of error messages thrown across the tidyverse, r-lib, and
#' tidymodels organizations.
#'
#' The cli pal helps you convert your R package to use cli for error messages.
#'
#' @section Creating a cli pal:
#'
#' Create a cli pal with:
#'
#' ```r
#' pal("cli", "Ctrl+Shift+C")
#' ```
#'
#' @section Cost:
#'
# TODO: make this a template that takes in the token counts and prices as input
#'
#' The system prompt from a pal includes something like 4,000 tokens.
#' Add in (a generous) 100 tokens for the code that's actually highlighted
#' and also sent off to the model and you're looking at 4,100 input tokens.
#' The model returns approximately the same number of output tokens as it
#' receives, so we'll call that 100 output tokens per refactor.
#'
#' As of the time of writing (October 2024), the default pal model Claude
#' Sonnet 3.5 costs \$3 per million input tokens and $15 per million output
#' tokens. So, using the default model,
#' **pals cost around \$15 for every 1,000 refactored pieces of code**. GPT-4o
#' Mini, by contrast, doesn't tend to get cli markup classes right but _does_
#' return syntactically valid calls to cli functions, and it would cost around
#' 75 cents per 1,000 refactored pieces of code.
#'
#' @section Gallery:
#'
#' This section includes a handful of examples
#' ["from the wild"](https://github.com/tidymodels/tune/blob/f8d734ac0fa981fae3a87ed2871a46e9c40d509d/R/checks.R)
#' and are generated with the default model, Claude Sonnet 3.5.
#'
#' ```{r}
#' library(pal)
#'
#' cli_pal <- pal("cli")
#' ```
#'
#' At its simplest, a one-line message with a little bit of markup:
#'
#' ```{r}
#' cli_pal$chat({
#'   rlang::abort("`save_pred` can only be used if the initial results saved predictions.")
#' })
#' ```
#'
#' Some strange vector collapsing and funky line breaking:
#'
#' ```{r}
#' cli_pal$chat({
#'   extra_grid_params <- glue::single_quote(extra_grid_params)
#'   extra_grid_params <- glue::glue_collapse(extra_grid_params, sep = ", ")
#'
#'   msg <- glue::glue(
#'     "The provided `grid` has the following parameter columns that have ",
#'     "not been marked for tuning by `tune()`: {extra_grid_params}."
#'   )
#'
#'   rlang::abort(msg)
#' })
#' ```
#'
#' A message that probably best lives as two separate elements:
#'
#' ```{r}
#' cli_pal$chat({
#'   rlang::abort(
#'     paste(
#'       "Some model parameters require finalization but there are recipe",
#'       "parameters that require tuning. Please use ",
#'       "`extract_parameter_set_dials()` to set parameter ranges ",
#'       "manually and supply the output to the `param_info` argument."
#'     )
#'   )
#' })
#' ```
#'
#' Gnarly ad-hoc pluralization:
#'
#' ```{r}
#' cli_pal$chat({
#'   msg <- "Creating pre-processing data to finalize unknown parameter"
#'   unk_names <- pset$id[unk]
#'   if (length(unk_names) == 1) {
#'     msg <- paste0(msg, ": ", unk_names)
#'   } else {
#'     msg <- paste0(msg, "s: ", paste0("'", unk_names, "'", collapse = ", "))
#'   }
#'   rlang::inform(msg)
#' })
#' ```
#'
#' Some `paste0()` wonk:
#'
#' ```{r}
#' cli_pal$chat({
#'   rlang::abort(paste0(
#'     "The workflow has arguments to be tuned that are missing some ",
#'     "parameter objects: ",
#'     paste0("'", pset$id[!params], "'", collapse = ", ")
#'   ))
#' })
#' ```
#'
#' The model is instructed to only return a call to a cli function, so
#' erroring code that's run conditionally can get borked:
#'
#'   ```{r}
#' cli_pal$chat({
#'   cls <- paste(cls, collapse = " or ")
#'   if (!fine) {
#'     msg <- glue::glue("Argument '{deparse(cl$x)}' should be a {cls} or NULL")
#'     if (!is.null(where)) {
#'       msg <- glue::glue(msg, " in `{where}`")
#'     }
#'     rlang::abort(msg)
#'   }
#' })
#' ```
#'
#' Sprintf-style statements aren't an issue:
#'
#' ```{r}
#' cli_pal$chat({
#'   abort(sprintf("No such '%s' function: `%s()`.", package, name))
#' })
#' ```
#'
#' @name pal_cli
NULL
