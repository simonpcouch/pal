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

retrieve_pal <- function(role) {
  if (exists(paste0(".pal_last_", role))) {
    pal <- get(paste0(".pal_last_", role))
  } else {
    tryCatch(
      pal <- .init_pal(role),
      error = function(cnd) {
        # rethrow condition message directly rather than setting
        # `cli::cli_abort(parent)` so that rstudioapi::showDialog is able
        # to handle the formatting (#62)
        stop(condition_message(cnd), call. = FALSE)
        return(NULL)
      }
    )
  }

  pal
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
                       allow_default = !is.null(getOption(".pal_on_load")),
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
