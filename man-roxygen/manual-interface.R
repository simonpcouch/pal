#' @section Interfacing manually with the <%= role %> helper:
#'
#' Pals are typically interfaced with via the chores addin. To call the <%= role %>
#' helper directly, use:
#'
#' ```r
#' helper_<%= role %> <- .init_helper("<%= role %>")
#' ```
#'
#' Then, to submit a query, run:
#'
#' ```r
#' helper_<%= role %>$chat({x})
#' ```
#' @md
