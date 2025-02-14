#' Run the chores addin
#'
#' @description
#' The chores addin allows users to interactively select a chore helper to
#' interface with the current selection. **This function is not
#' intended to be interfaced with in regular usage of the package.**
#' To launch the chores addin in RStudio, navigate to `Addins > Chores`
#' and/or register the addin with a shortcut via
#' `Tools > Modify Keyboard Shortcuts > Search "Chores"`--we suggest `Ctrl+Alt+C`
#' (or `Ctrl+Cmd+C` on macOS).
#'
#' @returns
#' `NULL`, invisibly. Called for the side effect of launching the chores addin
#' and interfacing with selected text.
#'
#' @export
.init_addin <- function() {
  if (is.null(fetch_chores_chat())) {
    return(invisible())
  }

  # suppress "Listening on..." message and rethrow errors with new context
  try_fetch(
    suppressMessages(helper_fn_name <- .chores_app()),
    error = function(cnd) {cli::cli_abort(conditionMessage(cnd), call = NULL)}
  )

  if (is.null(helper_fn_name) || identical(helper_fn_name, ".helper_rs_")) {
    return(invisible())
  }

  # call the binding associated with the chosen helper
  try_fetch(
    helper_fn <- env_get(chores_env(), helper_fn_name),
    error = function(e) {
      cli::cli_abort("Unable to locate the requested helper.", call = NULL)
    }
  )

  do.call(helper_fn, args = list())

  invisible()
}

.chores_app <- function() {
  helper_choices <- list_helpers()

  ui <- miniUI::miniPage(
    miniUI::miniContentPanel(
      shiny::selectizeInput("helper", "Select a helper:",
                            choices = helper_choices,
                            multiple = FALSE,
                            options = list(
                              create = FALSE,
                              placeholder = 'Type to filter or select a helper',
                              onDropdownOpen = I("function($dropdown) {this.clear();}"),
                              onBlur = I("function() {this.clear();}"),
                              score = I("function(search) {
                                           return function(item) {
                                             const text = (item.value || item.text || '').toLowerCase();
                                             const searchLower = search.toLowerCase();
                                             if (text.startsWith(searchLower)) return 1;
                                             if (text.includes(searchLower)) return 0.5;
                                             return 0;
                                           };
                                         }")
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
      shiny::stopApp(returnValue = paste0(".helper_rs_", input$helper))
    })
    shiny::onStop(function() {
      shiny::stopApp(returnValue = NULL)
    })
  }

  viewer <- shiny::dialogViewer("Chore helper", width = 300, height = 10)
  shiny::runGadget(ui, server, viewer = viewer)
}
