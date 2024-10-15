#' Initialize a Pal object
#'
#' @description
#' **Users typically should not need to call this function.**
#'
#' * Create new pals that will automatically be registered with this function
#' with [prompt_new()].
#' * The [pal addin][.init_addin()] will initialize needed pals on-the-fly.
#'
#' @param role The identifier for a pal prompt. By default one
#' of `r glue::glue_collapse(paste0("[", glue::double_quote(default_roles), "]", "[pal_", default_roles, "]"), ", ", last = " or ")`,
#' though custom pals can be added with [.pal_add()].
#' @param fn A `new_*()` function, likely from the elmer package. Defaults
#'   to [elmer::chat_claude()]. To set a persistent alternative default,
#'   set the `.pal_fn` option; see examples below.
#' @param .ns The package that the `new_*()` function is exported from.
#' @param ... Additional arguments to `fn`. The `system_prompt` argument will
#'   be ignored if supplied. To set persistent defaults,
#'   set the `.pal_args` option; see examples below.
#'
#' @details
#' If you have an Anthropic API key (or another API key and the `pal_*()`
#' options) set and this package installed, you are ready to using the addin
#' in any R session with no setup or library loading required; the addin knows
#' to look for your API credentials and will call needed functions by itself.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' .init_pal()
#'
#' # or with OpenAI's 4o-mini:
#' .init_pal(
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
.init_pal <- function(
    role = NULL,
    fn = getOption(".pal_fn", default = "chat_claude"),
    ...,
    .ns = "elmer"
  ) {
  check_role(role)
  if (!role %in% list_pals()) {
    cli::cli_abort(c(
      "No pals with role {.arg {role}} registered.",
      "i" = "See {.fn .pal_add}."
    ))
  }

  Pal$new(
    role = role,
    fn = fn,
    ...,
    .ns = .ns
  )
}

default_roles <- c("cli", "testthat", "roxygen")
