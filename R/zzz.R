# nocov start

.onLoad <- function(libname, pkgname) {
  prompts <- list.files(system.file("prompts", package = "pal"), full.names = TRUE)
  for (prompt in prompts) {
    id <- gsub(".md", "", basename(prompt))
    rlang::env_bind(
      rlang::ns_env("pal"),
      !!paste0(id, "_system_prompt") := paste0(readLines(prompt), collapse = "\n")
    )
  }
}

# nocov end
