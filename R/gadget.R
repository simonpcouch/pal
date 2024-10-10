.pal <- function() {
  pal_fn <- .pal_app()
  if (identical(pal_fn, "rs_pal_")) {
    return(NULL)
  }
  try_fetch(
    do.call(pal_fn, args = list()),
    error = function(e) {
      cli::cli_abort("Unable to locate the requested pal.")
    }
  )
}

.pal_app <- function() {
  pal_choices <- list_pals()

  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::selectizeInput("pal", "Select a pal:",
                            choices = NULL,
                            selected = NULL,
                            multiple = FALSE
      ),
      shiny::verbatimTextOutput("result"),
      shiny::tags$script(shiny::HTML("
        $(document).on('keyup', function(e) {
          if(e.key == 'Enter'){
            Shiny.setInputValue('done', true, {priority: 'event'});
          }
        });
      "))
    )
  )

  server <- function(input, output, session) {
    shiny::updateSelectizeInput(
      session, 'pal',
      choices = pal_choices,
      server = TRUE
    )
    shiny::observeEvent(input$done, {
      shiny::stopApp(returnValue = paste0("rs_pal_", input$pal))
    })
  }

  viewer <- shiny::dialogViewer("Pal", width = 300, height = 10)
  shiny::runGadget(ui, server, viewer = viewer)
}
