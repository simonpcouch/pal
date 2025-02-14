#' Registering helpers
#'
#' @description
#' Users can create custom helpers using the `.helper_add()` function; after passing
#' the function a chore and prompt, the helper will be available in the
#' [chores addin][.init_addin].
#'
#' **Most users should not need to interact with these functions.**
#' [prompt_new()] and friends can be used to create prompts for new helpers, and
#' those helpers can be registered with chores using [directory_load()] and friends.
#' The helpers created by those functions will be persistent across sessions.
#'
#' @param chore A single string giving a descriptor of the helper's functionality.
#' Cand only contain letters and numbers.
#' @param prompt A single string giving the system prompt. In most cases, this
#' is a rather long string, containing several newlines.
#' @param interface One of `"replace"`, `"prefix"`, or `"suffix"`, describing
#' how the helper will interact with the selection. For example, the
#' [cli helper][cli_helper] `"replace"`s the selection, while the
#' [roxygen helper][roxygen_helper] `"prefixes"` the selected code with documentation.
#'
#' @returns
#' `NULL`, invisibly. Called for its side effect: a helper for chore `chore`
#' is registered (or unregistered) with the chores package.
#'
#' @name helper_add_remove
#' @export
.helper_add <- function(
    chore,
    prompt = NULL,
    interface = c("replace", "prefix", "suffix")
) {
  check_chore(chore)
  check_string(prompt)

  .stash_prompt(prompt, chore)
  parse_interface(interface, chore)

  invisible()
}

#' @rdname helper_add_remove
.helper_remove <- function(chore) {
  check_string(chore)
  if (!chore %in% list_helpers()) {
    cli::cli_abort("No active helper with the given {.arg chore}.")
  }

  env_unbind(
    chores_env(),
    c(paste0(".helper_prompt_", chore), paste0(".helper_rs_", chore))
  )

  if (paste0(".helper_last_", chore) %in% names(chores_env())) {
    env_unbind(chores_env(), paste0(".helper_last_", chore))
  }

  invisible()
}

supported_interfaces <- c("replace", "prefix", "suffix")

# given an interface and chore, attaches a function binding in chores' `.chores_env`
parse_interface <- function(interface, chore, call = caller_env()) {
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
    chore,
    function(context = rstudioapi::getActiveDocumentContext()) {
      selection <- get_primary_selection(context)
      helper <- retrieve_helper(chore)$clone()
      streamy::stream(
        generator =
          # TODO: this is gnarly--revisit when helpers are just Chats
          # or ensure selection$text isn't substituted
          helper[[".__enclos_env__"]][["private"]]$.stream(selection$text),
        context = context,
        interface = interface
      )
    }
  )

  paste0(".helper_rs_", chore)
}
