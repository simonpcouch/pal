#' Convert erroring code to use cli
#'
#' This help-page documents the function that pals created with `pal("cli")`
#' apply. For more on cli pals, see [pal_cli].
#'
#' @param expr Lines of code that raise an error, as an expression.
#' @param pal A pal created with [pal("cli")][pal_cli].
#'
#' @examplesIf FALSE
#' pal <- pal("cli")
#'
#' .pal_cli(stop("An error message."))
#'
#' @export
pal_chat <- function(expr, pal = NULL) {
  pal <- last_pal(pal)
  request <- deparse(substitute(expr))
  .pal_chat(pal, request)
}

.pal_chat <- function(pal, request, call = caller_env()) {
  if (identical(request, "")) {
    cli::cli_abort("Please supply a non-empty chat request.", call = call)
  }
  structure(
    pal$chat(paste0(request, collapse = "\n")),
    class = c(paste0("pal_response_", .pal_role(pal)), "pal_response", "character")
  )
}

#' @export
print.pal_response <- function(x, ...) {
  cat(x)
}
