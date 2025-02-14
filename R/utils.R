# helpers for the chores environment ----------------------------------------------
.stash_last_helper <- function(x) {
  chores_env <- chores_env()
  chores_env[[paste0(".helper_last_", x$chore)]] <- x
  chores_env[[".helper_last"]] <- x
  invisible(NULL)
}

.stash_binding <- function(chore, fn) {
  chores_env <- chores_env()
  chores_env[[paste0(".helper_rs_", chore)]] <- fn
  invisible(NULL)
}

.stash_prompt <- function(prompt, chore) {
  chores_env <- chores_env()
  chores_env[[paste0(".helper_prompt_", chore)]] <- prompt
  invisible(NULL)
}

.chores_env <- new_environment()

chores_env <- function() {
  .chores_env
}

list_helpers <- function() {
  chores_env <- chores_env()
  chores_env_names <- names(chores_env)
  prompt_names <- grep(".helper_prompt_", names(chores_env), value = TRUE)
  gsub(".helper_prompt_", "", prompt_names)
}

retrieve_helper <- function(chore) {
  if (exists(paste0(".helper_last_", chore))) {
    helper <- get(paste0(".helper_last_", chore))
  } else {
    tryCatch(
      helper <- .init_helper(chore),
      error = function(cnd) {
        # rethrow condition message directly rather than setting
        # `cli::cli_abort(parent)` so that rstudioapi::showDialog is able
        # to handle the formatting (#62)
        stop(condition_message(cnd), call. = FALSE)
        return(NULL)
      }
    )
  }

  helper
}

condition_message <- function(cnd) {
  if ("message" %in% names(cnd)) {
    return(cnd$message)
  }

  cnd_message(cnd, inherit = FALSE, prefix = FALSE)
}

get_primary_selection <- function(context) {
  selection <- rstudioapi::primary_selection(context)

  if (selection[["text"]] == "") {
    stop("No code selected. Please highlight some code first.", call. = FALSE)
  }

  selection
}

# ad-hoc check helpers -------
check_chore <- function(chore,
                       allow_default = !is.null(getOption(".helper_on_load")),
                       call = caller_env()) {
  check_string(chore, allow_empty = FALSE, call = call)

  if (!is_valid_chore(chore)) {
    cli::cli_abort(
      "{.arg chore} must be a single string containing only letters and digits.",
      call = call
    )
  }

  if (chore %in% default_chores & !allow_default) {
    cli::cli_abort(
      "Default chores cannot be edited or removed.",
      call = call
    )
  }

  invisible(chore)
}

# miscellaneous ----------------------------------------------------------------
interactive <- NULL

is_valid_chore <- function(chore) {
  grepl("^[a-zA-Z0-9]+$", chore)
}

is_positron <- function() {
  Sys.getenv("POSITRON") == "1"
}
