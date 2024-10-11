#' Creating custom pals
#'
#' @description
#' Users can create custom pals using the `.pal_add()` function; after passing
#' the function a role and prompt, the pal will be available on the command
#' palette.
#'
#' @param role A single string giving a descriptor of the pal's functionality.
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
