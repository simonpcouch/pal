# nocov start

.onLoad <- function(libname, pkgname) {
  pal_env <- pal_env()

  prompts <- list.files(system.file("prompts", package = "pal"), full.names = TRUE)
  roles_and_interfaces <- gsub(".md", "", basename(prompts))
  roles_and_interfaces <- strsplit(roles_and_interfaces, "-")
  for (idx in seq_along(prompts)) {
    role <- roles_and_interfaces[[idx]][1]
    prompt <- paste0(readLines(prompts[idx]), collapse = "\n")
    interface <- roles_and_interfaces[[idx]][2]

    pal_add(role = role, prompt = prompt, interface = interface)
  }
}

# nocov end
