#' Run the pal addin
#'
#' @description
#' The pal addin allows users to interactively select a pal to
#' interface with the current selection. **This function is not
#' intended to be interfaced with in regular usage of the package.**
#' To launch the pal addin in RStudio, navigate to `Addins > Pal`
#' and/or register the addin with a shortcut via
#' `Tools > Modify Keyboard Shortcuts > Search "Pal"`—we suggest `Ctrl+Cmd+P`
#' (or `Ctrl+Alt+P` on non-macOS).
#'
#' @returns
#' `NULL`, invisibly. Called for the side effect of launching the pal addin
#' and interfacing with selected text.
#'
#' @export
.pal_addin <- function() {
  # suppress "Listening on..." message and rethrow errors with new context
  try_fetch(
    suppressMessages(pal_fn <- .pal_app()),
    error = function(cnd) {cli::cli_abort(conditionMessage(cnd), call = NULL)}
  )

  if (is.null(pal_fn) || identical(pal_fn, ".pal_rs_")) {
    return(invisible())
  }

  # call the binding associated with the chosen pal
  try_fetch(
    do.call(env_get(pal_env(), pal_fn), args = list()),
    error = function(e) {
      cli::cli_abort("Unable to locate the requested pal.")
    }
  )

  invisible()
}

.pal_app <- function() {
  pal_choices <- list_pals()

  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::selectizeInput("pal", "Select a pal:",
                            choices = pal_choices,
                            multiple = FALSE,
                            options = list(
                              create = FALSE,
                              placeholder = 'Type to filter or select a pal',
                              onDropdownOpen = I("function($dropdown) {this.clear();}"),
                              onBlur = I("function() {this.clear();}")
                            )
      ),
      shiny::verbatimTextOutput("result"),
      shiny::tags$script(shiny::HTML("
        $(document).on('keyup', function(e) {
          if(e.key == 'Enter'){
            Shiny.setInputValue('done', true, {priority: 'event'});
          }
        });
        $(document).ready(function() {
          setTimeout(function() {
            $('.selectize-input input').focus();
          }, 100);
        });
      "))
    )
  )

  server <- function(input, output, session) {
    shiny::observeEvent(input$done, {
      shiny::stopApp(returnValue = paste0(".pal_rs_", input$pal))
    })
    shiny::onStop(function() {
      shiny::stopApp(returnValue = NULL)
    })
  }

  viewer <- shiny::dialogViewer("Pal", width = 300, height = 10)
  shiny::runGadget(ui, server, viewer = viewer)
}
