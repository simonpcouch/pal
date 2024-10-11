#' Creating custom pals
#'
#' @description
#' Users can create custom pals using the `.pal_add()` function; after passing
#' the function a role and prompt, the pal will be available on the command
#' palette.
#'
#' @param role A single string giving the [.pal_init()] role.
# TODO: actually do this once elmer implements
#' @param prompt A file path to a markdown file giving the system prompt or
#' the output of [elmer::interpolate()].
# TODO: only add prefix when not supplied one
#' @param interface One of `"replace"`, `"prefix"`, or `"suffix"`, describing
#' how the pal will interact with the selection. For example, the
#' [cli pal][pal_cli] `"replace"`s the selection, while the
#' [roxygen pal][pal_roxygen] `"prefixes"` the selected code with documentation.
#' @param dir A directory of markdown files. See "Adding multiple, persistent
#' pals" section below.
#'
#' @section Adding multiple, persistent pals:

#' Pals can also be added in batch with `.pal_add_dir()`, which takes a directory
#' of markdown files. Prompts are markdown files with the
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
#'
#' @returns
#' `NULL`, invisibly. Called for its side effect: a pal with role `role`
#' is registered with the pal package.
#'
#' @name pal_add_remove
#' @export
.pal_add <- function(
    role,
    prompt = NULL,
    interface = c("replace", "prefix", "suffix")
) {
  # TODO: need to check that there are no spaces (or things that can't be
  # included in a variable name)
  check_string(role, allow_empty = FALSE)

  # TODO: make this an elmer interpolate or an .md file
  prompt <- .stash_prompt(prompt, role)
  binding <- parse_interface(interface, role)

  invisible()
}

#' @rdname pal_add_remove
.pal_remove <- function(role) {
  check_string(role)
  if (!role %in% list_pals()) {
    cli::cli_abort("No active pal with the given {.arg role}.")
  }

  env_unbind(
    pal_env(),
    c(paste0(".pal_prompt_", role), paste0(".pal_rs_", role))
  )

  if (paste0(".pal_last_", role) %in% names(pal_env())) {
    env_unbind(pal_env(), paste0(".pal_last_", role))
  }

  invisible()
}

supported_interfaces <- c("replace", "prefix", "suffix")

# given an interface and role, attaches a function binding in pal's `.pal_env`
parse_interface <- function(interface, role, call = caller_env()) {
  if (isTRUE(identical(interface, supported_interfaces))) {
    interface <- interface[1]
  }
  if (isTRUE(
    length(interface) != 1 ||
    !interface %in% supported_interfaces
  )) {
    cli::cli_abort(
      "{.arg interface} should be one of {.or {.val {supported_interfaces}}}.",
      call = call
    )
  }

  if (interface == "suffix") {
    # TODO: implement suffixing
    cli::cli_abort("Suffixing not implemented yet.", call = call)
  }

  .stash_binding(
    role,
    function(context = rstudioapi::getActiveDocumentContext()) {
      do.call(
        paste0("rs_", interface, "_selection"),
        args = list(context = context, role = role)
      )
    }
  )

  paste0(".pal_rs_", role)
}

# mapping over multiple calls to `.pal_add()` ----------------------------------
#' @rdname pal_add_remove
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


