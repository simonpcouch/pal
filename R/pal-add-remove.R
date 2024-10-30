#' Registering pals
#'
#' @description
#' Users can create custom pals using the `.pal_add()` function; after passing
#' the function a role and prompt, the pal will be available in the
#' [pal addin][.init_addin].
#'
#' **Most users should not need to interact with these functions.**
#' [prompt_new()] and friends can be used to create prompts for new pals, and
#' those pals can be registered with pal using [directory_load()] and friends.
#' The pals created by those functions will be persistent across sessions.
#'
#' @param role A single string giving a descriptor of the pal's functionality.
#' Cand only contain letters and numbers.
#' @param prompt A single string giving the system prompt. In most cases, this
#' is a rather long string, containing several newlines.
#' @param interface One of `"replace"`, `"prefix"`, or `"suffix"`, describing
#' how the pal will interact with the selection. For example, the
#' [cli pal][pal_cli] `"replace"`s the selection, while the
#' [roxygen pal][pal_roxygen] `"prefixes"` the selected code with documentation.
#'
#' @returns
#' `NULL`, invisibly. Called for its side effect: a pal with role `role`
#' is registered (or unregistered) with the pal package.
#'
#' @name pal_add_remove
#' @export
.pal_add <- function(
    role,
    prompt = NULL,
    interface = c("replace", "prefix", "suffix")
) {
  check_role(role)
  check_string(prompt)

  .stash_prompt(prompt, role)
  parse_interface(interface, role)

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
