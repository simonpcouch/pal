Pal <- R6::R6Class(
  "Pal",
  public = list(
    initialize = function(role, .pal_chat = getOption(".pal_chat")) {
      self$role <- role

      Chat <- fetch_pal_chat(.pal_chat)

      if (is.null(Chat)) {
        return()
      }

      Chat$set_system_prompt(get(paste0(".pal_prompt_", role), envir = pal_env()))
      private$Chat <- Chat

      .stash_last_pal(self)
    },
    chat = function(...) {
      private$Chat$chat(...)
    },
    stream = function(expr) {
      request <- deparse(substitute(expr))
      private$.stream(request)
    },
    role = NULL,
    print = function(...) {
      model <- private$Chat[[".__enclos_env__"]][["private"]][["provider"]]@model
      cli::cli_h3(
        "A {.field {self$role}} pal using {.field {model}}."
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

translate_pal_option <- function(.pal_fn, .pal_args) {
  # two notes on why this is funky:
  # * escapes brackets with doubling
  # * substitutes in a call, which is enumerated unless deparsed
  cli::format_inline(
    "function() {{{deparse(rlang::call2(.pal_fn, !!!.pal_args))}}"
  )
}

# this function fails with messages and a NULL return value rather than errors
# so that, when called from inside the addin, there's no dialog box raised by RStudio
fetch_pal_chat <- function(.pal_chat = getOption(".pal_chat")) {
  # first, check for old options
  .pal_fn <- getOption(".pal_fn")
  .pal_args <- getOption(".pal_args")
  if (!is.null(.pal_fn) && is.null(.pal_chat)) {
    new_option <- translate_pal_option(.pal_fn, .pal_args)
    cli::cli_inform(c(
      "{.pkg pal} now uses the option {cli::col_blue('.pal_chat')} instead
           of {cli::col_blue('.pal_fn')} and {cli::col_blue('.pal_args')}.",
      "i" = "Set {.code options(.pal_chat = {new_option})} instead."
    ), call = NULL)
    return(NULL)
  }

  # adapted from check_function, but errors a bit more informatively
  if (is.null(.pal_chat)) {
    cli::cli_inform(
      c(
        "!" = "pal requires configuring an ellmer Chat with the
        {cli::col_blue('.pal_chat')} option.",
        "i" = "Set e.g.
        {.code {cli::col_green('options(.pal_chat = function() ellmer::chat_claude())')}}
        in your {.file ~/.Rprofile} and restart R.",
        "i" = "See \"Choosing a model\" in
        {.code vignette(\"pal\", package = \"pal\")} to learn more."
      ),
      call = NULL
    )
    return(NULL)
  }

  if (!inherits(.pal_chat, "function")) {
    if (inherits(.pal_chat, "Chat")) {
      cli::cli_inform(
        c(
          "!" = "The {cli::col_blue('.pal_chat')} option must be a function that
           returns a Chat, not the Chat object itself.",
          "i" = "e.g. use {.code function(x) chat_*()} rather than {.code chat_*()}."
        ),
        call = NULL
      )
    } else {
      cli::cli_inform(
        c(
          "!" = "The {cli::col_blue('.pal_chat')} option must be a function that
           returns a Chat, not {.obj_type_friendly {x}}."
        ),
        call = NULL
      )
    }

    return(NULL)
  }

  res <- .pal_chat()

  if (!inherits(res, "Chat")) {
    cli::cli_inform(
      c(
        "!" = "The option {cli::col_blue('.pal_chat')} must be a function that
         returns an ellmer Chat object.",
        "The function returned {.obj_type_friendly {res}} instead."
      ),
      call = NULL
    )
  }

  res
}

#' @export
print.pal_response <- function(x, ...) {
  cat(x)
}
