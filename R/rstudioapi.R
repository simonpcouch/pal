# replace selection with refactored code ---------------------------------------
rs_replace_selection <- function(context, role) {
  pal <- retrieve_pal(role)
  selection <- get_primary_selection(context)

  # make the format of the "final position" consistent
  selection_portions <- standardize_selection(selection, context)
  selection <- selection_portions$selection
  selection_remainder <- selection_portions$remainder
  n_lines_orig <- max(selection$range$end[["row"]] - selection$range$start[["row"]], 1)

  # fill selection with empty lines
  selection <- wipe_selection(selection, context)

  # start streaming
  stream_selection(selection, context, pal, n_lines_orig, selection_remainder)
}

# prefix selection with new code -----------------------------------------------
rs_prefix_selection <- function(context, role) {
  pal <- retrieve_pal(role)
  selection <- get_primary_selection(context)

  # add one blank line before the selection
  rstudioapi::modifyRange(selection$range, paste0("\n", selection[["text"]]), context$id)

  # make the "current selection" that blank line
  first_line <- selection$range
  first_line$start[["column"]] <- 1
  first_line$end[["row"]] <- selection$range$start[["row"]]
  first_line$end[["column"]] <- 100000
  selection$range <- first_line
  rstudioapi::setCursorPosition(selection$range$start)

  # start streaming into it--will be interactively appended to if need be
  stream_selection(selection, context, pal, n_lines_orig = 1)
}

# suffix selection with new code -----------------------------------------------
rs_suffix_selection <- function(context, role) {
  pal <- retrieve_pal(role)
  selection <- get_primary_selection(context)

  # add one blank line after the selection
  rstudioapi::modifyRange(selection$range, paste0(selection[["text"]], "\n"), context$id)

  # make the "current selection" that blank line
  last_line <- selection$range
  last_line$start[["row"]] <- selection$range$end[["row"]] + 1
  last_line$end[["row"]] <- selection$range$end[["row"]] + 1
  last_line$start[["column"]] <- 1
  last_line$end[["column"]] <- 100000
  selection$range <- last_line
  rstudioapi::setCursorPosition(selection$range$start)

  # start streaming into it--will be interactively appended to if need be
  stream_selection(selection, context, pal, n_lines_orig = 1)
}

# helpers ----------------------------------------------------------------------
retrieve_pal <- function(role) {
  if (exists(paste0(".pal_last_", role))) {
    pal <- get(paste0(".pal_last_", role))
  } else {
    tryCatch(
      pal <- .init_pal(role),
      error = function(cnd) {
        # rethrow condition message directly rather than setting
        # `cli::cli_abort(parent)` so that rstudioapi::showDialog is able
        # to handle the formatting (#62)
        stop(condition_message(cnd), call. = FALSE)
        return(NULL)
      }
    )
  }

  pal
}

condition_message <- function(cnd) {
  if ("message" %in% names(cnd)) {
    return(cnd$message)
  }

  cnd_message(cnd, inherit = FALSE, prefix = FALSE)
}

get_primary_selection <- function(context) {
  selection <- rstudioapi::primary_selection(context)

  if (selection[["text"]] == "") {
    stop("No code selected. Please highlight some code first.", call. = FALSE)
  }

  selection
}

standardize_selection <- function(selection, context) {
  # if the first entry on a newline, make it the last entry on the line previous
  if (selection$range$end[["column"]] == 1L) {
    selection$range$end[["row"]] <- selection$range$end[["row"]] - 1
    # also requires change to column -- see below
  }

  # ensure that models can fill in characters beyond the current selection's
  # while also ensuring that characters after the selection in the final
  # line are preserved (#35)
  selection_text <- selection[["text"]]
  selection$range$end[["column"]] <- 100000

  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  full_text <- rstudioapi::primary_selection(
    rstudioapi::getSourceEditorContext(id = context$id)
  )$text
  remainder <- gsub(gsub("\n$", "", selection_text), "", full_text, fixed = TRUE)
  remainder <- gsub("\n", "", remainder, fixed = TRUE)

  list(selection = selection, remainder = remainder)
}

# fill selection with empty lines
wipe_selection <- function(selection, context) {
  n_lines_orig <- selection$range$end[["row"]] - selection$range$start[["row"]]
  empty_lines <- paste0(rep("\n", n_lines_orig), collapse = "")
  rstudioapi::modifyRange(selection$range, empty_lines, context$id)
  rstudioapi::setCursorPosition(selection$range$start, context$id)
  selection
}


stream_selection <- function(selection, context, pal, n_lines_orig, remainder = "") {
  tryCatch(
    stream_selection_impl(
      selection = selection,
      context = context,
      pal = pal,
      n_lines_orig = n_lines_orig,
      remainder = remainder
    ),
    error = function(e) {
      rstudioapi::showDialog("Error", paste("The pal ran into an issue: ", e$message))
    }
  )
}

stream_selection_impl <- function(selection, context, pal, n_lines_orig, remainder = "") {
  selection_text <- selection[["text"]]
  output_lines <- character(0)
  stream <- pal$clone()[[".__enclos_env__"]][["private"]]$.stream(selection_text)

  coro::loop(for (chunk in stream) {
    if (identical(chunk, "")) {next}

    output_lines <- paste(output_lines, chunk, sep = "")
    output_lines_no_trailing_newline <- gsub("\n+$", "", output_lines)
    n_lines <- nchar(gsub("[^\n]+", "", output_lines_no_trailing_newline)) + 1

    # add trailing newlines so that the output at least extends to the n_lines
    # of the original selection (for visual effect only)
    output_padded <- paste0(
      output_lines_no_trailing_newline,
      paste0(rep("\n", max(n_lines_orig - n_lines, 0)), collapse = "")
    )
    
    row_start_before <- selection$range[[1]][[1]]
    row_end_before <- selection$range[[2]][[1]]
    before_lines <- rstudioapi::getActiveDocumentContext()
    before_lines <- before_lines$contents[row_start_before:row_end_before]

    res <- rstudioapi::modifyRange(
      selection$range,
      output_padded,
      context$id
    )
    res$text <- strsplit(res$text, "\n")[[1]]

    # there may be more lines in the output than there are in the range
    n_selection <- selection$range$end[[1]] - selection$range$start[[1]]
    n_lines_res <- nchar(gsub("[^\n]+", "", output_padded))
    selection$range$end[["row"]] <- selection$range$start[["row"]] + n_lines_res

    row_start_after <- selection$range[[1]][[1]]
    row_end_after <- selection$range[[2]][[1]]
    after_lines <- rstudioapi::getActiveDocumentContext()
    after_lines <- after_lines$contents[row_start_after:row_end_after]

    io$last_run <- c(
      io$last_run, 
      list(
        before = list(row_start_end = c(row_start_before, row_end_before), before = before_lines), 
        during = res,
        after = list(row_start_end = c(row_start_after, row_end_after), new_lines = after_lines)
      )
    )
  })

  # once the generator is finished, modify the range with the
  # unpadded version to remove unneeded newlines
  rstudioapi::modifyRange(
    selection$range,
    sub("\n$", "", paste0(output_lines, remainder)),
    context$id
  )

  # reindent the code
  rstudioapi::setSelectionRanges(selection$range, id = context$id)
  rstudioapi::executeCommand("reindent")

  rstudioapi::setCursorPosition(selection$range$start)
}

io <- new_environment()