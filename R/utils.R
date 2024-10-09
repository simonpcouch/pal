#' Save most recent results to search path
#'
#' @param x A pal.
#'
#' @return NULL, invisibly.
#'
#' @details The function will assign `x` to `.last_pal` and put it in
#' the search path.
#'
#' @export
#' @keywords internal
.stash_last_pal <- function(x) {
  pal_env <- as.environment("pkg:pal")
  pal_env[[paste0(".last_pal_", x$role)]] <- x
  pal_env[[".last_pal"]] <- x
  invisible(NULL)
}

#' @export
print.pal_response <- function(x, ...) {
  cat(x)
}

check_role <- function(role, call = caller_env()) {
  if (is_missing(role) ||
      is.null(role) ||
      !role %in% supported_roles
  ) {
    cli::cli_abort(
      "{.arg role} must be one of {.or {.val {supported_roles}}}.",
      call = call
    )
  }
}

check_prompt <- function(prompt, call = caller_env()) {
  if (inherits(prompt, "pal_prompt")) {
    return(prompt)
  }

  if (is_markdown_file(prompt)) {
    if (file.exists(prompt)) {
      cli::cli_abort(
        "The markdown file supplied as {.arg prompt} does not exist.",
        call = call
      )
    }
    prompt <- readLines(prompt)
  }

  cli::cli_abort(
    "{.arg prompt} should either be a {.code .md} file or
     the output of {.fn .pal_prompt}.",
    call = call
  )
}

is_markdown_file <- function(x) {
  grepl("\\.(md|markdown)$", x, ignore.case = TRUE)
}

last_pal <- function(pal, call = caller_env()) {
  if (!is.null(pal)) {
    return(pal)
  }

  pal_role <- pal$role

  if (exists(paste0(".last_pal_", pal_role))) {
    return(get(paste0(".last_pal_", pal_role)))
  }

  if (exists(".last_pal")) {
    return(.last_pal)
  }

  cli::cli_abort(
    "Create a pal with {.fn pal} to use this function.",
    call = call
  )
}
