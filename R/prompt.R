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
#' Specify a `contents` argument to prefill with contents from a markdown file
#' on your computer or the web.
#' * `prompt_edit()` and `prompt_remove()` open and delete, respectively, the
#' file that defines the given role's system prompt.
#'
#' Load the prompts you create with these functions using [directory_load()]
#' (which is automatically called when the package loads).
#'
#' @inheritParams pal_add_remove
#' @param contents Optional. Path to a markdown file with contents that will
#' "pre-fill" the file. Anything file ending in `.md` or `.markdown` that can be
#' read with `readLines()` is fair game; this could be a local file, a "raw"
#' URL to a GitHub Gist or file in a GitHub repository, etc.
#'
#' @seealso The [directory] help-page for more on working with prompts in
#' batch using `directory_*()` functions, and `vignette("custom", package = "pal")`
#' for more on sharing pal prompts and using prompts from others.
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
#' # pull prompts from files on local drives or the web with
#' # `prompt_new(contents)`. for example, here is a GitHub Gist:
#' # paste0(
#' #  "https://gist.githubusercontent.com/simonpcouch/",
#' #  "daaa6c4155918d6f3efd6706d022e584/raw/ed1da68b3f38a25b58dd9fdc8b9c258d",
#' #  "58c9b4da/summarize-prefix.md"
#' # )
#' #
#' # press "Raw" and then supply that URL as `contents` (you don't actually
#' # have to use the paste0() to write out the URL--we're just keeping
#' # the characters per line under 80):
#' prompt_new(
#'   role = "summarize",
#'   interface = "prefix",
#'   contents =
#'     paste0(
#'       "https://gist.githubusercontent.com/simonpcouch/",
#'       "daaa6c4155918d6f3efd6706d022e584/raw/ed1da68b3f38a25b58dd9fdc8b9c258d",
#'       "58c9b4da/summarize-prefix.md"
#'     )
#' )
#'
#' @name prompt

#' @rdname prompt
#' @export
prompt_new <- function(role, interface, contents = NULL) {
  check_role(role)
  arg_match0(interface, supported_interfaces)
  check_string(contents, allow_null = TRUE)

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

  dir_path <- directory_path()
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  path <- paste0(dir_path, "/", role, "-", interface, ".md")

  # TODO: should this message "Register with `directory_load()`" or
  # something as it creates the file?
  file.create(path)
  prompt_prefill(path = path, contents = contents, role = role)
  if (interactive()) {
    file.edit(path)
  }

  invisible(path)
}

#' @rdname prompt
#' @export
prompt_remove <- function(role) {
  check_role(role)
  path <- prompt_locate(role)
  file.remove(path)

  pal_env <- pal_env()
  rlang::env_unbind(pal_env, paste0(".pal_prompt_", role))
  rlang::env_unbind(pal_env, paste0(".pal_rs_", role))

  invisible(path)
}

#' @rdname prompt
#' @export
prompt_edit <- function(role) {
  check_role(role)
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

prompt_prefill <- function(path, contents, role, call = caller_env()) {
  if (!is.null(contents) && !is_markdown_file(contents)) {
    cli::cli_abort(
      "{.arg contents} must be a connection to a markdown file.",
      call = call
    )
  }

  if (is.null(contents)) {
    contents <- system.file("template.md", package = "pal")
  }

  suppressWarnings(
    try_fetch(
      {
        lines <- base::readLines(contents)
        writeLines(text = lines, con = path)
      },
      error = function(cnd) {
        cli::cli_abort(
          "An error occurred while pre-filling the prompt with {.arg contents}.",
          call = call,
          parent = cnd
        )
      }
    )
  )

  invisible(path)
}

is_markdown_file <- function(x) {
  grepl("\\.(md|markdown)$", x, ignore.case = TRUE)
}
