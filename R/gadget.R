.pal <- function() {
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
    do.call(pal_fn, args = list()),
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
