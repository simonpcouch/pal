# nocov start

.onLoad <- function(libname, pkgname) {
  chores_env <- chores_env()
  withr::local_options(.helper_on_load = TRUE)

  directory_load(system.file("prompts", package = "chores"))

  chores_dir <- getOption(".chores_dir", default = file.path("~", ".config", "chores"))
  if (dir.exists(chores_dir)) {
    directory_load(chores_dir)
  }
}

# nocov end
