#' Working with helper prompts
#'
#' @description
#' The chores package provides a number of tools for working on system _prompts_.
#' System prompts are what instruct helpers on how to behave and provide
#' information to live in the models' "short-term memory."
#'
#' `prompt_*()` functions allow users to conveniently create, edit, remove,
#' the prompts in chores' "[prompt directory][directory]."
#'
#' * `prompt_new()` creates a new markdown file that will automatically
#' create a helper with the specified chore, prompt, and interface on package load.
#' Specify a `contents` argument to prefill with contents from a markdown file
#' on your computer or the web.
#' * `prompt_edit()` and `prompt_remove()` open and delete, respectively, the
#' file that defines the given chore's system prompt.
#'
#' Load the prompts you create with these functions using [directory_load()]
#' (which is automatically called when the package loads).
#'
#' @inheritParams helper_add_remove
#' @param contents Optional. Path to a markdown file with contents that will
#' "pre-fill" the file. Anything file ending in `.md` or `.markdown` that can be
#' read with `readLines()` is fair game; this could be a local file, a "raw"
#' URL to a GitHub Gist or file in a GitHub repository, etc.
#'
#' @seealso The [directory] help-page for more on working with prompts in
#' batch using `directory_*()` functions, and `vignette("custom", package = "chores")`
#' for more on sharing helper prompts and using prompts from others.
#'
#' @returns
#' Each `prompt_*()` function returns the file path to the created, edited, or
#' removed filepath, invisibly.
#'
#' @examplesIf FALSE
#' # create a new helper for chore `"boop"` that replaces the selected text:
#' prompt_new("boop")
#'
#' # after writing a prompt, register it with the chores package with:
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
#'   chore = "summarize",
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
prompt_new <- function(chore, interface, contents = NULL) {
  check_chore(chore)
  arg_match0(interface, supported_interfaces)
  check_string(contents, allow_null = TRUE)

  current_path <- try_fetch(prompt_locate(chore), error = function(cnd) {NULL})
  suggestion <- character(0)
  if (!chore %in% default_chores || !is.null(current_path)) {
    suggestion <- c("i" = "You can edit it with {.code prompt_edit({.val {chore}})}")
  }
  if (chore %in% list_helpers() || !is.null(current_path)) {
    cli::cli_abort(c(
      "There's already a helper for chore {.val {chore}}.",
      suggestion
    ))
  }

  dir_path <- directory_path()
  if (!dir.exists(dir_path)) {
    dir.create(dir_path, recursive = TRUE)
  }
  path <- paste0(dir_path, "/", chore, "-", interface, ".md")

  # TODO: should this message "Register with `directory_load()`" or
  # something as it creates the file?
  file.create(path)
  prompt_prefill(path = path, contents = contents, chore = chore)
  if (interactive()) {
    file.edit(path)
  }

  invisible(path)
}

#' @rdname prompt
#' @export
prompt_remove <- function(chore) {
  check_chore(chore)
  path <- prompt_locate(chore)
  file.remove(path)

  chores_env <- chores_env()
  rlang::env_unbind(chores_env, paste0(".helper_prompt_", chore))
  rlang::env_unbind(chores_env, paste0(".helper_rs_", chore))

  invisible(path)
}

#' @rdname prompt
#' @export
prompt_edit <- function(chore) {
  check_chore(chore)
  path <- prompt_locate(chore)
  if (interactive()) {
    file.edit(path)
  }
  invisible(path)
}

prompt_locate <- function(chore, call = caller_env()) {
  path <- directory_path()
  base_names <- directory_base_names(path)
  chores <- gsub("-replace\\.md|-prefix\\.md|-suffix\\.md", "", base_names)
  match <- which(chores == chore)

  if (identical(match, integer(0))) {
    cli::cli_abort(
      "No prompts for {.arg chore} {.val {chore}} found in the prompt directory",
      call = call
    )
  }

  file.path(path, base_names[match])
}

prompt_prefill <- function(path, contents, chore, call = caller_env()) {
  if (!is.null(contents) && !is_markdown_file(contents)) {
    cli::cli_abort(
      "{.arg contents} must be a connection to a markdown file.",
      call = call
    )
  }

  if (is.null(contents)) {
    contents <- system.file("template.md", package = "chores")
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
