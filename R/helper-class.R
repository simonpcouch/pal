Helper <- R6::R6Class(
  "Helper",
  public = list(
    initialize = function(chore, .chores_chat = getOption(".chores_chat")) {
      self$chore <- chore

      Chat <- .chores_chat$clone()

      Chat$set_system_prompt(get(paste0(".helper_prompt_", chore), envir = chores_env()))
      private$Chat <- Chat

      .stash_last_helper(self)
    },
    chat = function(...) {
      private$Chat$chat(...)
    },
    stream = function(expr) {
      request <- deparse(substitute(expr))
      private$.stream(request)
    },
    chore = NULL,
    print = function(...) {
      model <- private$Chat[[".__enclos_env__"]][["private"]][["provider"]]@model
      cli::cli_h3(
        "A {.field {self$chore}} chore helper using {.field {model}}."
      )
    }
  ),
  private = list(
    Chat = NULL,
    .stream = function(request, call = caller_env()) {
      if (identical(request, "")) {
        cli::cli_abort("Please supply a non-empty chat request.", call = call)
      }
      private$Chat$stream(paste0(request, collapse = "\n"))
    }
  )
)

# this function fails with messages and a NULL return value rather than errors
# so that, when called from inside the addin, there's no dialog box raised by RStudio
fetch_chores_chat <- function(.chores_chat = getOption(".chores_chat")) {
  if (is.null(.chores_chat)) {
    cli::cli_inform(
      c(
        "!" = "chores requires configuring an ellmer Chat with the
        {cli::col_blue('.chores_chat')} option.",
        "i" = "Set e.g.
        {.code {cli::col_green('options(.chores_chat = ellmer::chat_claude())')}}
        in your {.file ~/.Rprofile} and restart R.",
        "i" = "See \"Choosing a model\" in
        {.code vignette(\"chores\", package = \"chores\")} to learn more."
      ),
      call = NULL
    )
    return(NULL)
  }

  if (!inherits(.chores_chat, "Chat")) {
    cli::cli_inform(
      c(
        "!" = "The option {cli::col_blue('.chores_chat')} must be an ellmer
         Chat object, not {.obj_type_friendly { .chores_chat}}.",
        "i" = "See \"Choosing a model\" in
        {.code vignette(\"chores\", package = \"chores\")} to learn more."
      ),
      call = NULL
    )
    return(NULL)
  }

  .chores_chat
}

#' @export
print.helper_response <- function(x, ...) {
  cat(x)
}
