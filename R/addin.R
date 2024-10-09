pal_addin_append <- function(role, name, description, binding) {
  lines <- pal_addin_read()

  addin_list <- pal_addin_parse(lines)

  addin_list[[role]] <- list(
    Name = name,
    Description = description,
    Binding = binding,
    Interactive = "false"
  )

  lines_new <- pal_addin_unparse(addin_list)

  if (identical(lines, lines_new)) {
    return(invisible())
  }

  pal_addin_write(lines_new)

  pal_addin_source()

  invisible()
}

pal_addin_read <- function() {
  readLines(system.file("rstudio/addins.dcf", package = "pal"))
}

pal_addin_write <- function(lines) {
  writeLines(lines, system.file("rstudio/addins.dcf", package = "pal"))
}

pal_addin_parse <- function(lines) {
  lines <- lines[nzchar(lines)]

  result <- list()
  current_entry <- list()
  current_name <- NULL

  for (line in lines) {

    parts <- strsplit(line, ": ", fixed = TRUE)[[1]]
    key <- parts[1]
    value <- paste(parts[-1], collapse = ": ")

    if (key == "Name") {
      if (!is.null(current_name)) {
        result[[current_name]] <- current_entry
      }
      current_entry <- list()
      current_entry[[key]] <- value
    } else if (key == "Binding") {
      current_name <- sub("^rs_pal_", "", value)
      current_entry[[key]] <- value
    } else {
      current_entry[[key]] <- value
    }
  }

  if (!is.null(current_name)) {
    result[[current_name]] <- current_entry
  }

  return(result)
}

pal_addin_unparse <- function(parsed_list) {
  lines <- character(0)

  for (entry_name in names(parsed_list)) {
    entry <- parsed_list[[entry_name]]

    for (key in names(entry)) {
      lines <- c(lines, paste0(key, ": ", entry[[key]]))
    }
    lines <- c(lines, "")
  }

  if (length(lines) > 0 && lines[length(lines)] == "") {
    lines <- lines[-length(lines)]
  }

  return(lines)
}

pal_addin_source <- function() {
  # TODO: only do whatever it is that kicks in the addins.dcf loading
  inst_pal <- pkgload::inst("pal")
  # this only works with devtools shims active...

  shims_active <- "devtools_shims" %in% search()
  if (!shims_active) {
    do.call("attach", list(new.env(), pos = length(search()) + 1,
                           name = "devtools_shims"))

  }
  devtools::load_all(inst_pal)
  withr::defer(do.call("detach", list(name = "devtools_shims")))

  #devtools::load_all(".")
  #rstudioapi::executeCommand("updateAddinRegistry")
  #rstudioapi::executeCommand("updateAddinRegistry")
  #rstudioapi::executeCommand("updateAddinRegistry")
  #invisible()
}
