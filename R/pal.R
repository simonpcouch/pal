#' Create a pal
#'
#' @description
#' Pals are persistent LLM-driven helpers designed to help you complete common tasks in interactive data analysis, authoring, and package development. Once created, they can be attached to a keybinding and immediately get to work on repetitive but hard-to-automate tasks.
#'
#' To create a pal, simply pass `pal()` the ID of a pre-defined pal and a keybinding you'd like it attached to. For example, to use the cli pal:
#'
#' ```r
#' pal("cli", "Ctrl+Shift+C")
#' ```
#'
#' @param role The identifier for a pal prompt. Currently one
#' of `r glue::glue_collapse(paste0("[", glue::double_quote(supported_roles), "]", "[pal_", supported_roles, "]"), ", ", last = " or ")`.
#' @param keybinding A key binding for the pal.
#' @param fn A `new_*()` function, likely from the elmer package. Defaults
#'   to [elmer::new_chat_claude()]. To set a persistent alternative default,
#'   set the `.pal_fn` option; see examples below.
#' @param .ns The package that the `new_*()` function is exported from.
#' @param ... Additional arguments to `fn`. The `system_prompt` argument will
#'   be ignored if supplied. To set persistent defaults,
#'   set the `.pal_args` option; see examples below.
#'
#' @details
#' Upon successfully creating a pal, this function will assign the
#' result to the search path as `.last_pal`. At that point,
#' [.pal_cli()] and the RStudio add-in "Convert to cli" know to look
#' for `.last_pal` and you don't need to worry about passing your cli
#' pal yourself.
#'
#' If you have an Anthropic API key (or another API key and the `pal_*()`
#' options) set and this package installed, you are ready to using the add-in
#' in any R session with no setup or library loading required; the addin knows
#' to look for your API credentials and will call both
#' this function and [.pal_cli()] itself.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' pal()
#'
#' # or with OpenAI's 4o-mini:
#' pal(
#'   "new_chat_openai",
#'   model = "gpt-4o-mini"
#' )
#'
#' # to set OpenAI's 4o-mini as the default, for example, set the
#' # following options (possibly in your .Rprofile, if you'd like
#' # them to persist across sessions):
#' options(
#'   .pal_fn = "new_chat_openai",
#'   .pal_args = list(model = "gpt-4o-mini")
#' )
#' @export
pal <- function(
    role = NULL, keybinding = NULL,
    fn = getOption(".pal_fn", default = "new_chat_claude"), ..., .ns = "elmer"
  ) {
  check_role(role)
  args <- list(...)
  default_args <- getOption(".pal_args", default = list())
  args <- modifyList(default_args, args)

  # TODO: make this an environment initialized on onLoad that folks can
  # register dynamically
  args$system_prompt <- get(paste0(role, "_system_prompt"), envir = ns_env("pal"))

  pal <- rlang::eval_bare(rlang::call2(fn, !!!args, .ns = "elmer"))

  pal <- structure(pal, class = c(paste(role, "_pal"), "pal", class(pal)))
  .stash_last_pal(pal, role = role)
  pal
}

supported_roles <- c("cli", "testthat")

#' @export
print.pal <- function(x, ...) {
  model <- x[[".__enclos_env__"]][["private"]][["provider"]]@model
  role <- .pal_role(x)
  cli::cli_h3(
    "A {.field {role}}pal using {.field {model}}."
  )
}
