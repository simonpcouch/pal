#' Working with pal prompts
#'
#' @description
#' The pal package provides a number of tools for working on system _prompts_.
#' System prompts are what instruct pals on how to behave and provide
#' information to live in the models' "short-term memory."
#'
#' `prompt_*()` functions allow users to conveniently create, edit, remove,
#' the prompts in pal's "[prompt directory][directory]."
#'
#' * `prompt_new()` creates a new markdown file that will automatically
#' create a pal with the specified role, prompt, and interface on package load.
#' * `prompt_edit()` and `prompt_remove()` open and delete, respectively, the
#' file that defines the given role's system prompt.
#'
#' Load the prompts you create with these functions using [directory_load()]
#' (which is automatically called when the package loads).
#'
#' @inheritParams pal_add_remove
#'
#' @seealso The [directory] help-page for more on working with prompts in
#' batch using `directory_*()` functions.
#'
#' @returns
#' Each `prompt_*()` function returns the file path to the created, edited, or
#' removed filepath, invisibly.
#'
#' @examplesIf FALSE
#' # create a new pal with role `"boop"` that replaces the selected text:
#' prompt_new("boop")
#'
#' # after writing a prompt, register it with the pal package with:
#' directory_load()
#'
#' # after closing the file, reopen with:
#' prompt_edit("boop")
#'
#' # remove the prompt (next time the package is loaded) with:
#' prompt_remove("boop")
#'
#' @name prompt

#' @rdname prompt
#' @export
# TODO: function to bring in a prompt from a connection/URL to a given role/interface
prompt_new <- function(role, interface) {
  check_string(role)
  arg_match0(interface, supported_interfaces)

  current_path <- try_fetch(prompt_locate(role), error = function(cnd) {NULL})
  suggestion <- character(0)
  if (!role %in% default_roles || !is.null(current_path)) {
    suggestion <- c("i" = "You can edit it with {.code prompt_edit({.val {role}})}")
  }
  if (role %in% list_pals() || !is.null(current_path)) {
    cli::cli_abort(c(
      "There's already a pal with role {.val {role}}.",
      suggestion
    ))
  }

  path <- paste0(directory_path(), "/", role, "-", interface, ".md")
  # TODO: should there be some pre-filled instructions on how to write
  # prompts here?
  # TODO: should this message "Register with `directory_load()`" or
  # something as it creates the file?
  file.create(path)
  if (interactive()) {
    file.edit(path)
  }

  invisible(path)
}

#' @rdname prompt
#' @export
prompt_remove <- function(role) {
  path <- prompt_locate(role)
  file.remove(path)
  invisible(path)
}

#' @rdname prompt
#' @export
prompt_edit <- function(role) {
  path <- prompt_locate(role)
  if (interactive()) {
    file.edit(path)
  }
  invisible(path)
}

prompt_locate <- function(role, call = caller_env()) {
  path <- directory_path()
  base_names <- directory_base_names(path)
  roles <- gsub("-replace\\.md|-prefix\\.md|-suffix\\.md", "", base_names)
  match <- which(roles == role)

  if (identical(match, integer(0))) {
    cli::cli_abort(
      "No prompts for {.arg role} {.val {role}} found in the prompt directory",
      call = call
    )
  }

  file.path(path, base_names[match])
}
