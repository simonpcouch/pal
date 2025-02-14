#' @section Interfacing manually with the <%= chore %> helper:
#'
#' Chore helpers are typically interfaced with via the chores addin. To call the <%= chore %>
#' helper directly, use:
#'
#' ```r
#' helper_<%= chore %> <- .init_helper("<%= chore %>")
#' ```
#'
#' Then, to submit a query, run:
#'
#' ```r
#' helper_<%= chore %>$chat({x})
#' ```
#' @md
