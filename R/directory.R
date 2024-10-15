#' The prompt directory
#'
#' @description
#' The pal package's prompt directory is a directory of markdown files that
#' is automatically registered with the pal package on package load.
#' `directory_*()` functions allow users to interface with the directory,
#' making new "roles" available:
#'
#' * `directory_path()` returns the path to the prompt directory, which
#' defaults to `~/.config/pal`.
#' * `directory_set()` changes the path to the prompt directory (by setting
#'   the option `.pal_dir`).
#' * `directory_list()` enumerates all of the different prompts that currently
#'   live in the directory (and provides clickable links to each).
#' * `directory_load()` registers each of the prompts in the prompt
#'   directory with the pal package (via [.pal_add()]).
#'
#' [Functions prefixed with][prompt] `prompt*()` allow users to conveniently create, edit,
#' and delete the prompts in pal's prompt directory.
#'
#' @param dir Path to a directory of markdown files--see `Details` for more.
#'
#' @section Format of the prompt directory:
#' Prompts are markdown files with the
#' name `role-interface.md`, where interface is one of
#' `r glue::glue_collapse(glue::double_quote(supported_interfaces), ", ", last = " or ")`.
#' An example directory might look like:
#'
#' ```
#' /
#' ├── .config/
#' │   └── pal/
#' │       ├── proofread-replace.md
#' │       └── summarize-prefix.md
#' ```
#'
#' In that case, pal will register two custom pals when you call `library(pal)`.
#' One of them has the role "proofread" and will replace the selected text with
#' a proofread version (according to the instructions contained in the markdown
#' file itself). The other has the role "summarize" and will prefix the selected
#' text with a summarized version (again, according to the markdown file's
#' instructions). Note:
#'
#' * Files without a `.md` extension are ignored.
#' * Files with a `.md` extension must contain only one hyphen in their filename,
#'   and the text following the hyphen must be one of `replace`, `prefix`, or
#'   `suffix`.
#'
#' To load custom prompts every time the package is loaded, place your
#' prompts in `directory_path()`. To change the prompt directory without
#' loading the package, just set the `.pal_dir` option with
#' `options(.pal_dir = some_dir)`. To load a directory of files that's not
#' the prompt directory, provide a `dir` argument to `directory_load()`.
#' @name directory
#'
#' @examplesIf FALSE
#' # print out the current prompt directory
#' directory_get()
#'
#' # list out prompts currently in the directory
#' directory_list()
#'
#' # create a prompt in the prompt directory
#' prompt_new("boop", "replace")
#'
#' # view updated list of prompts
#' directory_list()
#'
#' # register the prompt with the package
#' # (this will also happen automatically on reload)
#' directory_load()
#'
#' # these are equivalent:
#' directory_set("some/folder")
#' options(.pal_dir = "some/folder")
#'
#' @export
directory_load <- function(dir = directory_path()) {
  prompt_base_names <- directory_base_names(dir)
  roles_and_interfaces <- roles_and_interfaces(prompt_base_names)
  prompt_paths <- file.path(dir, prompt_base_names)

  for (idx in seq_along(prompt_base_names)) {
    role <- roles_and_interfaces[[idx]][1]
    prompt <- paste0(readLines(prompt_paths[idx]), collapse = "\n")
    interface <- roles_and_interfaces[[idx]][2]

    .pal_add(role = role, prompt = prompt, interface = interface)
  }
}

#' @rdname directory
#' @export
directory_list <- function() {
  prompt_dir <- directory_path()
  prompt_base_names <- directory_base_names(prompt_dir)
  prompt_paths <- paste0(prompt_dir, "/", prompt_base_names)
  if (interactive()) {
    cli::cli_h3("Prompts: ")
    cli::cli_bullets(
      set_names(
        paste0(
          "{.file ", prompt_paths, "}"
        ),
        "*"
      )
    )
  }

  invisible(prompt_paths)
}

#' @rdname directory
#' @export
directory_path <- function() {
  getOption(".pal_dir", default = file.path("~", ".config", "pal"))
}

#' @rdname directory
#' @export
directory_set <- function(dir) {
  check_string(dir)
  if (!dir.exists(dir)) {
    cli::cli_abort(
      c(
        "{.arg dir} doesn't exist.",
        "i" = "If desired, create it with {.code dir.create({.val {dir}}, recursive = TRUE)}."
      )
    )
  }

  options(.pal_dir = dir)

  invisible(dir)
}

directory_base_names <- function(dir) {
  prompt_paths <- list.files(dir, full.names = TRUE)
  prompt_base_names <- basename(prompt_paths)
  prompt_base_names <- grep("\\.md$", prompt_base_names, value = TRUE)
  prompt_base_names <- filter_single_hyphenated(prompt_base_names)
  prompt_base_names
}

# this function assumes its input is directory_base_names() output
roles_and_interfaces <- function(prompt_base_names) {
  roles_and_interfaces <- gsub("\\.md$", "", prompt_base_names)
  roles_and_interfaces <- strsplit(roles_and_interfaces, "-")
  roles_and_interfaces <- filter_interfaces(roles_and_interfaces)

  roles_and_interfaces
}

filter_single_hyphenated <- function(x) {
  has_one_hyphen <- grepl("^[^-]*-[^-]*$", x)
  if (any(!has_one_hyphen)) {
    cli::cli_inform(
      "Prompt{?s} {.val {paste0(x[!has_one_hyphen], '.md')}} must contain
       a single hyphen in {?its/their} filename{?s} and will not
       be registered with pal.",
      call = NULL
    )
  }

  x[has_one_hyphen]
}

filter_interfaces <- function(x) {
  interfaces <- lapply(x, `[[`, 2)
  recognized <- interfaces %in% supported_interfaces
  if (any(!recognized)) {
    prompts <- vapply(x, paste0, character(1), collapse = "-")
    cli::cli_inform(
      c(
        "Prompt{?s} {.val {paste0(prompts[!recognized], '.md')}} {?has/have} an
       unrecognized {.arg interface} noted in {?its/their} filename{?s}
       and will not be registered with pal.",
        "{.arg interface} (following the hyphen) must be one of
        {.or {.code {supported_interfaces}}}."
      ),
      call = NULL
    )
  }

  x[recognized]
}


# TODO: make a test directory in tests/testthat that can be relied on
# for consistent output
