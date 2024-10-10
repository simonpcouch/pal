Pal <- R6::R6Class(
  "Pal",
  public = list(
    initialize = function(role, fn, ..., .ns) {
      self$role <- role
      args <- list(...)
      default_args <- getOption(".pal_args", default = list())
      args <- modifyList(default_args, args)

      args$system_prompt <- get(
        paste0("system_prompt_", role),
        envir = search_envs()[["pkg:pal"]]
      )

      Chat <- rlang::eval_bare(rlang::call2(fn, !!!args, .ns = .ns))
      private$Chat <- Chat

      .stash_last_pal(self)
    },
    chat = function(expr) {
      request <- deparse(substitute(expr))
      private$.chat(request)
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
    .chat = function(request, call = caller_env()) {
      if (identical(request, "")) {
        cli::cli_abort("Please supply a non-empty chat request.", call = call)
      }
      structure(
        private$Chat$chat(paste0(request, collapse = "\n")),
        class = c("pal_response", "character")
      )
    },
    .stream = function(request, call = caller_env()) {
      if (identical(request, "")) {
        cli::cli_abort("Please supply a non-empty chat request.", call = call)
      }
      private$Chat$stream(paste0(request, collapse = "\n"))
    }
  )
)

#' @export
print.pal_response <- function(x, ...) {
  cat(x)
}
