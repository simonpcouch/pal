# replace selection with refactored code
rs_replace_selection <- function(context, role) {
  # check if pal exists
  if (exists(paste0(".pal_last_", role))) {
    pal <- get(paste0(".pal_last_", role))
  } else {
    tryCatch(
      pal <- pal(role),
      error = function(e) {
        rstudioapi::showDialog("Error", "Unable to create a pal. See `?pal()`.")
        return(NULL)
      }
    )
  }

  selection <- rstudioapi::primary_selection(context)

  if (selection[["text"]] == "") {
    rstudioapi::showDialog("Error", "No code selected. Please highlight some code first.")
    return(NULL)
  }

  # make the format of the "final position" consistent
  selection <- standardize_selection(selection, context)
  n_lines_orig <- max(selection$range$end[["row"]] - selection$range$start[["row"]], 1)

  # fill selection with empty lines
  selection <- wipe_selection(selection, context)

  # start streaming
  tryCatch(
    stream_selection(selection, context, pal, n_lines_orig),
    error = function(e) {
      rstudioapi::showDialog("Error", paste("The pal ran into an issue: ", e$message))
    }
  )
}

standardize_selection <- function(selection, context) {
  # if the first entry on a newline, make it the last entry on the line previous
  if (selection$range$end[["column"]] == 1L) {
    selection$range$end[["row"]] <- selection$range$end[["row"]] - 1
    # also requires change to column -- see below
  }

  # ensure that models can fill in characters beyond the current selection's
  selection$range$end[["column"]] <- Inf

  rstudioapi::setSelectionRanges(selection$range, id = context$id)

  selection
}

# fill selection with empty lines
wipe_selection <- function(selection, context) {
  n_lines_orig <- selection$range$end[["row"]] - selection$range$start[["row"]]
  empty_lines <- paste0(rep("\n", n_lines_orig), collapse = "")
  rstudioapi::modifyRange(selection$range, empty_lines, context$id)
  rstudioapi::setCursorPosition(selection$range$start, context$id)
  selection
}

stream_selection <- function(selection, context, pal, n_lines_orig) {
  selection_text <- selection[["text"]]
  output_lines <- character(0)
  stream <- pal[[".__enclos_env__"]][["private"]]$.stream(selection_text)
  coro::loop(for (chunk in stream) {
    if (identical(chunk, "")) {next}
    output_lines <- paste(output_lines, sub("\n$", "", chunk), sep = "")
    n_lines <- nchar(gsub("[^\n]+", "", output_lines)) + 1
    if (n_lines_orig - n_lines > 0) {
      output_padded <-
        paste0(
          output_lines,
          paste0(rep("\n", n_lines_orig - n_lines + 1), collapse = "")
        )
    } else {
      output_padded <- paste(output_lines, "\n")
    }

    rstudioapi::modifyRange(
      selection$range,
      output_padded %||% output_lines,
      context$id
    )

    # there may be more lines in the output than there are in the range
    n_selection <- selection$range$end[[1]] - selection$range$start[[1]]
    n_lines_res <- nchar(gsub("[^\n]+", "", output_padded %||% output_lines))
    if (n_selection < n_lines_res) {
      selection$range$end[["row"]] <- selection$range$start[["row"]] + n_lines_res
    }

    # `modifyRange()` changes the cursor position to the end of the
    # range, so manually override
    rstudioapi::setCursorPosition(selection$range$start)
  })

  # once the generator is finished, modify the range with the
  # unpadded version to remove unneeded newlines
  rstudioapi::modifyRange(
    selection$range,
    output_lines,
    context$id
  )

  # reindent the code
  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  rstudioapi::executeCommand("reindent")

  rstudioapi::setCursorPosition(selection$range$start)
}

# prefix selection with new code -----------------------------------------------
rs_prefix_selection <- function(context, role) {
  # check if pal exists
  if (exists(paste0(".pal_last_", role))) {
    pal <- get(paste0(".pal_last_", role))
  } else {
    tryCatch(
      pal <- pal(role),
      error = function(e) {
        rstudioapi::showDialog("Error", "Unable to create a pal. See `?pal()`.")
        return(NULL)
      }
    )
  }

  selection <- rstudioapi::primary_selection(context)

  if (selection[["text"]] == "") {
    rstudioapi::showDialog("Error", "No code selected. Please highlight some code first.")
    return(NULL)
  }

  # add one blank line before the selection
  rstudioapi::modifyRange(selection$range, paste0("\n", selection[["text"]]), context$id)

  # make the "current selection" that blank line
  first_line <- selection$range
  first_line$start[["column"]] <- 1
  first_line$end[["row"]] <- selection$range$start[["row"]]
  first_line$end[["column"]] <- Inf
  selection$range <- first_line
  rstudioapi::setCursorPosition(selection$range$start)

  # start streaming into it--will be interactively appended to if need be
  tryCatch(
    stream_selection(selection, context, pal, n_lines_orig = 1),
    error = function(e) {
      rstudioapi::showDialog("Error", paste("The pal ran into an issue: ", e$message))
    }
  )
}

