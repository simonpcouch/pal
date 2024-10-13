#' The pal directory
#'
#' @description
#' Pals can be added in batch with `.pal_add_dir()`, which takes a directory
#' of markdown files. On package load, pal will add all pals defined in the pal
#' directory, located at `.pal_dir()` (by default, `~/.config/pal`). To add a
#' new pal that will be loaded every time the package is loaded, use `.pal_new()`.
#'
#' @param dir Path to a directory of markdown files--see `Details` for more.
#' @inheritParams pal_add_remove
#'
#' @details
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
#' prompts in `~/.config/pal` (or, to use some other folder, set
#' `options(.pal_dir = some_dir)` before loading the package).
#' @name pal_add_dir
#' @export
.pal_add_dir <- function(dir) {
  prompt_paths <- list.files(dir, full.names = TRUE)
  roles_and_interfaces <- roles_and_interfaces(prompt_paths)

  for (idx in seq_along(prompt_paths)) {
    role <- roles_and_interfaces[[idx]][1]
    prompt <- paste0(readLines(prompt_paths[idx]), collapse = "\n")
    interface <- roles_and_interfaces[[idx]][2]

    .pal_add(role = role, prompt = prompt, interface = interface)
  }
}

roles_and_interfaces <- function(prompt_paths) {
  prompt_basenames <- basename(prompt_paths)
  prompt_basenames <- grep("\\.md$", prompt_basenames, value = TRUE)
  prompt_basenames <- filter_single_hyphenated(prompt_basenames)

  roles_and_interfaces <- gsub("\\.md$", "", prompt_basenames)
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

#' @rdname pal_add_dir
#' @export
.pal_dir <- function() {
  getOption(".pal_dir", default = file.path("~", ".config", "pal"))
}

#' @rdname pal_add_dir
#' @export
.pal_new <- function(role, interface) {
  check_string(role)
  arg_match0(interface, supported_interfaces)

  file.edit(paste0(.pal_dir(), "/", role, "-", interface, ".md"))
}
