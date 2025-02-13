#' @section Interfacing manually with the <%= role %> pal:
#'
#' Pals are typically interfaced with via the pal addin. To call the <%= role %>
#' pal directly, use:
#'
#' ```r
#' pal_<%= role %> <- .init_pal("<%= role %>")
#' ```
#'
#' Then, to submit a query, run:
#'
#' ```r
#' pal_<%= role %>$chat({x})
#' ```
#' @md
