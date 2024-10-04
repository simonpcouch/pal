rs_update_selection <- function(context, role) {
  # see if the user has run `pal()` successfully already
  if (exists(paste0(".last_pal_", role))) {
    pal <- get(paste0(".last_pal_", role))
  } else {
    tryCatch(
      pal <- pal(role),
      error = function(e) {
        rstudioapi::showDialog("Error", "Unable to create a pal. See `?pal()`.")
      }
    )
  }

  selection <- rstudioapi::primary_selection(context)
  selection_text <- selection[["text"]]

  if (selection_text == "") {
    rstudioapi::showDialog("Error", "No code selected. Please highlight some code first.")
    return(NULL)
  }

  tryCatch({
    output_str <- .pal_chat(pal, selection_text)

    rstudioapi::modifyRange(
      selection$range,
      output_str,
      context$id
    )
    n_lines <- length(gregexpr("\n", output_str)[[1]])
    selection$range$end[[1]] <- selection$range$start[[1]] + n_lines
    rstudioapi::setSelectionRanges(selection$range)
    rstudioapi::executeCommand("reindent")
  }, error = function(e) {
    rstudioapi::showDialog("Error", paste("The pal ran into an issue: ", e$message))
  })
}

rs_pal_cli <- function(context = rstudioapi::getActiveDocumentContext()) {
  rs_update_selection(context = context, role = "cli")
}

rs_pal_testthat <- function(context = rstudioapi::getActiveDocumentContext()) {
  rs_update_selection(context = context, role = "testthat")
}
