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

# ad-hoc check helpers -------
check_role <- function(role, call = caller_env()) {
  check_string(role, allow_empty = FALSE, call = call)

  if (!is_valid_role(role)) {
    cli::cli_abort(
      "{.arg role} must be a single string containing only letters and digits.",
      call = call
    )
  }

  invisible(role)
}

# miscellaneous ----------------------------------------------------------------
interactive <- NULL

is_valid_role <- function(role) {
  grepl("^[a-zA-Z0-9]+$", role)
}
