#' The roxygen pal
#'
#' @description
#'
#' The roxygen pal prefixes the selected function with a minimal roxygen2
#' documentation template. The pal is instructed to only generate a subset
#' of a complete documentation entry, to be then completed by a developer:
#'
#' * Stub `@param` descriptions based on defaults and inferred types
#' * Stub `@returns` entry that describes the return value as well as important
#'   errors and warnings users might encounter.
#'
#'
#' @section Creating a roxygen pal:
#'
#' Create a roxygen pal with:
#'
#' ```r
#' pal("roxygen")
#' ```
#'
#' @section Cost:
#'
#' The system prompt from a roxygen pal includes something like 1,000 tokens.
#' Add in 200 tokens for the code that's actually highlighted
#' and also sent off to the model and you're looking at 1,200 input tokens.
#' The model returns maybe 10 to 15 lines of relatively barebones royxgen
#' documentation, so we'll call that 200 output tokens per refactor.
#'
#' As of the time of writing (October 2024), the default pal model Claude
#' Sonnet 3.5 costs \\$3 per million input tokens and $15 per million output
#' tokens. So, using the default model,
#' **roxygen pals cost around \\$4 for every 1,000 generated roxygen documentation
#' entries**. GPT-4o Mini, by contrast, doesn't tend to infer argument types
#' correctly as often and
#' often fails to line-break properly, but _does_ usually return syntactically
#' valid documentation entries, and it would cost around
#' 20 cents per 1,000 generated roxygen documentation entries.
#'
#' @section Gallery:
#'
#' This section includes a handful of examples
#' "[from the wild](https://github.com/hadley/elmer/tree/e497d627e7be01206df6f1420ca36235141dc22a/R)"
#' and are generated with the default model, Claude Sonnet 3.5.
#'
#' ```{r}
#' library(pal)
#'
#' roxygen_pal <- pal("roxygen")
#' ```
#'
#' ```{r}
#' roxygen_pal$chat({
#'   deferred_method_transform <- function(lambda_expr, transformer, eval_env) {
#'     transformer <- enexpr(transformer)
#'     force(eval_env)
#'
#'     unique_id <- new_id()
#'     env_bind_lazy(
#'       generators,
#'       !!unique_id := inject((!!transformer)(!!lambda_expr)),
#'       eval.env = eval_env
#'     )
#'
#'     inject(
#'       function(...) {
#'         (!!generators)[[!!unique_id]](self, private, ...)
#'       }
#'     )
#'   }
#' })
#' ```
#'
#' ```{r}
#' roxygen_pal$chat({
#'   set_default <- function(value, default, arg = caller_arg(value)) {
#'     if (is.null(value)) {
#'       if (!is_testing() || is_snapshot()) {
#'         cli::cli_inform("Using {.field {arg}} = {.val {default}}.")
#'       }
#'       default
#'     } else {
#'       value
#'     }
#'   }
#' })
#' ```
#'
#' ```{r}
#' roxygen_pal$chat({
#'   find_index <- function(left, e_right) {
#'     if (!is.list(e_right) || !has_name(e_right, "index") || !is.numeric(e_right$index)) {
#'       return(NA)
#'     }
#'
#'     matches_idx <- map_lgl(left, function(e_left) e_left$index == e_right$index)
#'     if (sum(matches_idx) != 1) {
#'       return(NA)
#'     }
#'     which(matches_idx)[[1]]
#'   }
#' })
#' ```
#'
#' @name pal_roxygen
NULL
