% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/init-pal.R
\name{.init_pal}
\alias{.init_pal}
\title{Initialize a Pal object}
\usage{
.init_pal(role = NULL, .pal_chat = getOption(".pal_chat"))
}
\arguments{
\item{role}{The identifier for a pal prompt. By default one
of \link[=pal_cli]{"cli"}, \link[=pal_testthat]{"testthat"} or \link[=pal_roxygen]{"roxygen"},
though custom pals can be added with \code{\link[=.pal_add]{.pal_add()}}.}

\item{.pal_chat}{An ellmer Chat, e.g.
\code{function() ellmer::chat_claude()}. Defaults to the option by the same name,
so e.g. set \verb{options(.pal_chat = ellmer::chat_claude()} in your
\code{.Rprofile} to configure pal with ellmer every time you start a new R session.}
}
\description{
\strong{Users typically should not need to call this function.}
\itemize{
\item Create new pals that will automatically be registered with this function
with \code{\link[=prompt_new]{prompt_new()}}.
\item The \link[=.init_addin]{pal addin} will initialize needed pals on-the-fly.
}
}
\examples{
\dontshow{if (FALSE) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# to create a chat with claude:
.init_pal()

# or with OpenAI's 4o-mini:
.init_pal(.pal_chat = ellmer::chat_openai(model = "gpt-4o-mini"))

# to set OpenAI's 4o-mini as the default model powering pal, for example,
# set the following option (possibly in your .Rprofile, if you'd like
# them to persist across sessions):
options(
  .pal_chat = ellmer::chat_openai(model = "gpt-4o-mini")
)
\dontshow{\}) # examplesIf}
}
