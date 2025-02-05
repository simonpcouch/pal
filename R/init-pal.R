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
#' @param .pal_chat An ellmer Chat, e.g.
#' `function() ellmer::chat_claude()`. Defaults to the option by the same name,
#' so e.g. set `options(.pal_chat = ellmer::chat_claude()` in your
#' `.Rprofile` to configure pal with ellmer every time you start a new R session.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' .init_pal()
#'
#' # or with OpenAI's 4o-mini:
#' .init_pal(.pal_chat = ellmer::chat_openai(model = "gpt-4o-mini"))
#'
#' # to set OpenAI's 4o-mini as the default model powering pal, for example,
#' # set the following option (possibly in your .Rprofile, if you'd like
#' # them to persist across sessions):
#' options(
#'   .pal_chat = ellmer::chat_openai(model = "gpt-4o-mini")
#' )
#' @export
.init_pal <- function(
    role = NULL,
    .pal_chat = getOption(".pal_chat")
  ) {
  check_role(role, allow_default = TRUE)
  if (!role %in% list_pals()) {
    cli::cli_abort(c(
      "No pals with role {.arg {role}} registered.",
      "i" = "See {.fn .pal_add}."
    ))
  }

  Pal$new(role = role, .pal_chat = .pal_chat)
}

default_roles <- c("cli", "testthat", "roxygen")
