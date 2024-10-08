
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Your pal <img src="man/figures/logo.png" align="right" height="200" alt="" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/pal)](https://CRAN.R-project.org/package=pal)
<!-- badges: end -->

Pals are persistent, ergonomic LLM assistants designed to help you
complete repetitive, hard-to-automate tasks quickly. When created, they
automatically generate RStudio add-ins registered to keyboard shortcuts.
After selecting some code, press the keyboard shortcut you’ve chosen and
watch your code be rewritten.

**Much of the documentation in this package is aspirational and its
interface is likely to change rapidly.** Note, especially, that keyboard
shortcuts will have to registered in the usual way (via Tools \> Modify
Keyboard Shortcuts \> search “Pal”), for now.

## Installation

You can install pal like so:

``` r
pak::pak("simonpcouch/pal")
```

Then, ensure that you have an
[`ANTHROPIC_API_KEY`](https://console.anthropic.com/) set in your
[`.env`](https://github.com/gaborcsardi/dotenv). If you’d like to use an
LLM other than Anthropic’s Claude 3.5 Sonnet—like OpenAI’s ChatGPT—to
power the pal, see `?pal()` to set default metadata on that model.

## Example

To create a pal, simply pass `pal()` a pre-defined “role” and a
keybinding you’d like it attached to. For example, to use the [cli
pal](https://simonpcouch.github.io/pal/reference/pal_cli.html):

``` r
pal("cli", "Ctrl+Shift+C")
```

Then, highlight some code, press the keyboard shortcut, and watch your
code be rewritten:

![](https://github.com/simonpcouch/pal/raw/main/inst/figs/addin.gif)
As-is, the package provides ergonomic LLM assistants for R package
development:

- `"cli"`: [Convert to
  cli](https://simonpcouch.github.io/pal/reference/pal_cli.html)
- `"testthat"`: [Convert to testthat
  3](https://simonpcouch.github.io/pal/reference/pal_testthat.html)
- `"roxygen"`: [Document functions with
  roxygen](https://simonpcouch.github.io/pal/reference/pal_roxygen.html)

That said, the package provides infrastructure for others to make LLM
assistants for any task in R, from authoring to interactive data
analysis. With only a markdown file and a function call, users can
extend pal to assist with their own repetitive but hard-to-automate
tasks.

## How much do pals cost?

The cost of using pals depends on 1) the length of the underlying prompt
for a given pal and 2) the cost per token of the chosen model. Using the
cli pal with Anthropic’s Claude Sonnet 3.5, for example, [costs
something
like](https://simonpcouch.github.io/pal/reference/pal_cli.html#cost)
\$15 per 1,000 code refactorings, while using the testthat pal with
OpenAI’s GPT 4o-mini would cost something like \$1 per 1,000
refactorings. Pals using a locally-served LLM are “free” (in the usual
sense of code execution, ignoring the cost of increased battery usage).
