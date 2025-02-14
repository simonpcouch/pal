# helpers for the chores environment ----------------------------------------------
.stash_last_helper <- function(x) {
  chores_env <- chores_env()
  chores_env[[paste0(".helper_last_", x$role)]] <- x
  chores_env[[".helper_last"]] <- x
  invisible(NULL)
}

.stash_binding <- function(role, fn) {
  chores_env <- chores_env()
  chores_env[[paste0(".helper_rs_", role)]] <- fn
  invisible(NULL)
}

.stash_prompt <- function(prompt, role) {
  chores_env <- chores_env()
  chores_env[[paste0(".helper_prompt_", role)]] <- prompt
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

retrieve_helper <- function(role) {
  if (exists(paste0(".helper_last_", role))) {
    helper <- get(paste0(".helper_last_", role))
  } else {
    tryCatch(
      helper <- .init_helper(role),
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
check_role <- function(role,
                       allow_default = !is.null(getOption(".helper_on_load")),
                       call = caller_env()) {
  check_string(role, allow_empty = FALSE, call = call)

  if (!is_valid_role(role)) {
    cli::cli_abort(
      "{.arg role} must be a single string containing only letters and digits.",
      call = call
    )
  }

  if (role %in% default_roles & !allow_default) {
    cli::cli_abort(
      "Default roles cannot be edited or removed.",
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

is_positron <- function() {
  Sys.getenv("POSITRON") == "1"
}
