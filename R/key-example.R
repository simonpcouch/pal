key_get <- function(name, error_call = caller_env()) {
  val <- Sys.getenv(name)
  if (!identical(val, "")) {
    val
  } else {
    rlang::abort(
      paste0("Can't find env var `", name, "`."),
      call = error_call
    )
  }
}
