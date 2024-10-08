#' Create a pal
#'
#' @description
#' Pals are persistent, ergonomic LLM assistants designed to help you complete
#' repetitive, hard-to-automate tasks quickly. When created, they automatically
#' generate RStudio add-ins registered to keyboard shortcuts. After selecting
#' some code, press the keyboard shortcut you've chosen and watch your code
#' be rewritten.
#'
#' @param role The identifier for a pal prompt. Currently one
#' of `r glue::glue_collapse(paste0("[", glue::double_quote(supported_roles), "]", "[pal_", supported_roles, "]"), ", ", last = " or ")`.
#' @param keybinding A key binding for the pal. **Currently unused.**
#' Keybdings have to be registered in the usual way (via Tools >
#' Modify Keyboard Shortcuts), for now.
#' @param fn A `new_*()` function, likely from the elmer package. Defaults
#'   to [elmer::chat_claude()]. To set a persistent alternative default,
#'   set the `.pal_fn` option; see examples below.
#' @param .ns The package that the `new_*()` function is exported from.
#' @param ... Additional arguments to `fn`. The `system_prompt` argument will
#'   be ignored if supplied. To set persistent defaults,
#'   set the `.pal_args` option; see examples below.
#'
#' @details
#' Upon successfully creating a pal, this function will assign the
#' result to the search path as `.last_pal`.
#'
#' If you have an Anthropic API key (or another API key and the `pal_*()`
#' options) set and this package installed, you are ready to using the add-in
#' in any R session with no setup or library loading required; the addin knows
#' to look for your API credentials and will call needed functions by itself.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' pal()
#'
#' # or with OpenAI's 4o-mini:
#' pal(
#'   "chat_openai",
#'   model = "gpt-4o-mini"
#' )
#'
#' # to set OpenAI's 4o-mini as the default, for example, set the
#' # following options (possibly in your .Rprofile, if you'd like
#' # them to persist across sessions):
#' options(
#'   .pal_fn = "chat_openai",
#'   .pal_args = list(model = "gpt-4o-mini")
#' )
#' @export
pal <- function(
    role = NULL, keybinding = NULL,
    fn = getOption(".pal_fn", default = "chat_claude"), ..., .ns = "elmer"
  ) {
  check_role(role)

  Pal$new(
    role = role,
    keybinding = keybinding,
    fn = fn,
    ...,
    .ns = .ns
  )
}

supported_roles <- c("cli", "testthat", "roxygen")
