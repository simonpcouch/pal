#' @section Interfacing manually with the <%= role %> pal:
#'
#' Pals are typically interfaced with via the pal addin. To call the <%= role %>
#' pal directly, use:
#'
#' ```r
#' pal_<%= role %> <- .pal_init("<%= role %>")
#' ```
#'
#' Then, to submit a query, run:
#'
#' ```r
#' pal_<%= role %>$chat({expr})
#' ```
#' @md
