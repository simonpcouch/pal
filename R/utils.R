# helpers for the pal environment ----------------------------------------------
.stash_last_pal <- function(x) {
  pal_env <- pal_env()
  pal_env[[paste0(".pal_last_", x$role)]] <- x
  pal_env[[".pal_last"]] <- x
  invisible(NULL)
}

.stash_binding <- function(role, fn) {
  pal_env <- pal_env()
  pal_env[[paste0(".pal_rs_", role)]] <- fn
  invisible(NULL)
}

.stash_prompt <- function(prompt, role) {
  pal_env <- pal_env()
  pal_env[[paste0(".pal_prompt_", role)]] <- prompt
  invisible(NULL)
}

.pal_env <- new_environment()

pal_env <- function() {
  .pal_env
}

list_pals <- function() {
  pal_env <- pal_env()
  pal_env_names <- names(pal_env)
  prompt_names <- grep(".pal_prompt_", names(pal_env), value = TRUE)
  gsub(".pal_prompt_", "", prompt_names)
}

# ad-hoc check functions -------------------------------------------------------
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

# miscellaneous ----------------------------------------------------------------
interactive <- NULL
