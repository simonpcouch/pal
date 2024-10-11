# nocov start

.onLoad <- function(libname, pkgname) {
  pal_env <- pal_env()

  .pal_add_dir(system.file("prompts", package = "pal"))

  pal_dir <- getOption(".pal_dir", default = file.path("~", ".config", "pal"))
  if (dir.exists(pal_dir)) {
    .pal_add_dir(pal_dir)
  }
}

# nocov end
