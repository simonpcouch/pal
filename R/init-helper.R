#' Initialize a Helper object
#'
#' @description
#' **Users typically should not need to call this function.**
#'
#' * Create new helpers that will automatically be registered with this function
#' with [prompt_new()].
#' * The [chores addin][.init_addin()] will initialize needed helpers on-the-fly.
#'
#' @param chore The identifier for a helper prompt. By default one
#' of `r glue::glue_collapse(paste0("[", glue::double_quote(default_chores), "]", "[", default_chores, "_helper", "]"), ", ", last = " or ")`,
#' though custom helpers can be added with [.helper_add()].
#' @param .chores_chat An ellmer Chat, e.g.
#' `function() ellmer::chat_claude()`. Defaults to the option by the same name,
#' so e.g. set `options(.chores_chat = ellmer::chat_claude())` in your
#' `.Rprofile` to configure chores with ellmer every time you start a new R session.
#'
#' @examplesIf FALSE
#' # to create a chat with claude:
#' .init_helper()
#'
#' # or with OpenAI's 4o-mini:
#' .init_helper(.chores_chat = ellmer::chat_openai(model = "gpt-4o-mini"))
#'
#' # to set OpenAI's 4o-mini as the default model powering chores, for example,
#' # set the following option (possibly in your .Rprofile, if you'd like
#' # them to persist across sessions):
#' options(
#'   .chores_chat = ellmer::chat_openai(model = "gpt-4o-mini")
#' )
#' @export
.init_helper <- function(
    chore = NULL,
    .chores_chat = getOption(".chores_chat")
  ) {
  check_chore(chore, allow_default = TRUE)
  if (!chore %in% list_helpers()) {
    cli::cli_abort(c(
      "No helpers for chore {.arg {chore}} registered.",
      "i" = "See {.fn .helper_add}."
    ))
  }

  Helper$new(chore = chore, .chores_chat = .chores_chat)
}

default_chores <- c("cli", "testthat", "roxygen")
