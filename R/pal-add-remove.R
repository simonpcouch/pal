#' Creating custom pals
#'
#' @description
#' Users can create custom pals using the `pal_add()` function; after passing
#' the function a role and prompt, the pal will be available on the command
#' palette.
#'
#' @param role A single string giving the [pal()] role.
# TODO: actually do this once elmer implements
#' @param prompt A file path to a markdown file giving the system prompt or
#' the output of [elmer::interpolate()].
# TODO: only add prefix when not supplied one
#' @param name A name for the command palette description; will be prefixed
#' with "Pal: " for discoverability.
#' @param description A longer-form description of the functionality of the pal.
#' @param interface One of `"replace"`, `"prefix"`, or `"suffix"`, describing
#' how the pal will interact with the selection. For example, the
#' [cli pal][pal_cli] `"replace"`s the selection, while the
#' [roxygen pal][pal_roxygen] `"prefixes"` the selected code with documentation.
#'
#' @details
#' `pal_add()` will register the add-in as coming from the pal package
#' itself—because of this, custom pals will be deleted when the pal
#' package is reinstalled. Include `pal_add()` code in your `.Rprofile` or
#' make a pal extension package using `pal_add(package = TRUE)` to create
#' persistent custom pals.
#'
#' @returns
#' The pal, invisibly. Called for its side effect: an add-in with name
#' "Pal: `name`" is registered with RStudio.
#'
#' @export
pal_add <- function(
    role,
    prompt = NULL,
    shortcut = NULL,
    name = NULL,
    description = NULL,
    interface = c("replace", "prefix", "suffix")
) {
  # TODO: need to check that there are no spaces (or things that can't be
  # included in a variable name)
  check_string(role, allow_empty = FALSE)
  # TODO: make this an elmer interpolate or an .md file
  #prompt <- check_prompt(prompt)
  prompt <- .stash_prompt(prompt, role)
  name <- paste0("Pal: ", name %||% role)
  description <- description %||% name
  binding <- parse_interface(interface, role)

  # add a description of the pal to addins.dcf
  pal_addin_append(
    role = role,
    name = name,
    description = description,
    binding = binding
  )

  invisible()
}

# TODO: fn to remove the addin associated with the role
pal_remove <- function(role) {
  invisible()
}

supported_interfaces <- c("replace", "prefix", "suffix")

# given an interface and role, attaches a function binding in pal's namespace
# for that role so that the addin can be provided a function.
parse_interface <- function(interface, role) {
  if (isTRUE(identical(interface, supported_interfaces))) {
    interface <- interface[1]
  }
  if (isTRUE(
    length(interface) != 1 ||
    !interface %in% supported_interfaces
  )) {
    cli::cli_abort(
      "{.arg interface} should be one of {.or {.val {supported_interfaces}}}."
    )
  }

  if (interface == "suffix") {
    # TODO: implement suffixing
    cli::cli_abort("Suffixing not implemented yet.")
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

  paste0("rs_pal_", role)
}

.stash_binding <- function(role, fn) {
  pal_env <- as.environment("pkg:pal")
  pal_env[[paste0("rs_pal_", role)]] <- fn
  invisible(NULL)
}

.stash_prompt <- function(prompt, role) {
  pal_env <- as.environment("pkg:pal")
  pal_env[[paste0("system_prompt_", role)]] <- prompt
  invisible(NULL)
}
