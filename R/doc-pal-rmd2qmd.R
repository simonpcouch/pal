#' The rmd2qmd pal
#'
#' @description
#'
#' Rmarkdown and Quarto are two implmentations for combining prose with
#' executable code to make additional content, such as words, sentances, figures,
#' tables, and so on.
#'
#' @section Cost:
#'
#' The system prompt from a pal includes something
#'
#' @section Gallery:
#'
#' As an example, the following set of bookdown options:
#'
#' ````
#' ```{r srch, fig.width = 9, warning = FALSE, echo = FALSE, out.width = '100%', fig.height = 4, fig.cap = "Some examples.",  message = FALSE}
#' ````
#'
#' is converted to
#'
#' ````
#' ```{r}
#' #| label: srch
#' #| warning: false
#' #| echo: false
#' #| message: false
#' #| fig-width: 9
#' #| fig-height: 4
#' #| fig-cap: "Some examples."
#' #| out-width: 100%
#' ````
#'
#' As of Novermber 2024, [knitr::convert_chunk_header()] converts it to
#'
#' ````
#'```{r}
#' label = "srch",
#' fig.width = 9,
#' warning = FALSE,
#' echo = FALSE,
#' out.width = "100%",
#' fig.height = 4,
#' fig.cap = "Some examples.",
#' message = FALSE
#' ````
#' @templateVar role rmd2qmd
#' @template manual-interface
#'
#' @name pal_rmd2qmd
NULL
