# nocov start

.onLoad <- function(libname, pkgname) {
  if (!"pkg:pal" %in% search()) {
    do.call("attach", list(new.env(), pos = length(search()),
                           name = "pkg:pal"))
  }
  pal_env <- as.environment("pkg:pal")

  prompts <- list.files(system.file("prompts", package = "pal"), full.names = TRUE)
  for (prompt in prompts) {
    role <- gsub(".md", "", basename(prompt))
    rlang::env_bind(
      pal_env,
      !!paste0("system_prompt_", role) := paste0(readLines(prompt), collapse = "\n")
    )
  }
}

# nocov end
