#' Apply pals to code
#'
#' @param expr Lines of code that raise an error, as an expression.
#' @param pal A pal created with [pal()].
#'
#' @examplesIf FALSE
#' pal <- pal("cli")
#'
#' pal_chat(stop("An error message."))
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

# TODO: these should just be methods in an R6 object
.pal_stream <- function(pal, request, call = caller_env()) {
  if (identical(request, "")) {
    cli::cli_abort("Please supply a non-empty chat request.", call = call)
  }
  pal$stream(paste0(request, collapse = "\n"))
}

#' @export
print.pal_response <- function(x, ...) {
  cat(x)
}
