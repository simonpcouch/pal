# nocov start

.onLoad <- function(libname, pkgname) {
  pal_env <- pal_env()

  directory_load(system.file("prompts", package = "pal"))

  pal_dir <- getOption(".pal_dir", default = file.path("~", ".config", "pal"))
  if (dir.exists(pal_dir)) {
    directory_load(pal_dir)
  }
}

# nocov end
