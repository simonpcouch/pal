
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Your pal <img src="man/figures/logo.png" align="right" height="240" alt="The package logo, a small yellow blob happily holding a clipboard." />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/pal)](https://CRAN.R-project.org/package=pal)
[![R-CMD-check](https://github.com/simonpcouch/pal/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/simonpcouch/pal/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The pal package provides a library of ergonomic LLM assistants designed
to help you complete repetitive, hard-to-automate tasks quickly. After
selecting some code, press the keyboard shortcut you’ve chosen to
trigger the pal addin (we suggest `Ctrl+Cmd+P`), select the pal, and
watch your code be rewritten.

## Installation

Getting started with pal takes three steps.

**1)** Install the pal package like so:

``` r
pak::pak("simonpcouch/pal")
```

**2)** Then, you need to configure pal with an
[ellmer](https://ellmer.tidyverse.org/) model. pal uses ellmer under the
hood, so any model that you can chat with through ellmer is also
supported by pal. To configure pal with ellmer, set the option
`.pal_chat` to a function that returns an ellmer Chat. For example, to
use Claude, you’d write
`options(.pal_chat = function() ellmer::chat_github())`, possibly in
your `.Rprofile` so that pal is ready to go every time you start R. To
learn more, see the [Getting started with
pal](https://simonpcouch.github.io/pal/articles/pal.html) vignette.

**3)** Pals are interfaced with the via the pal addin. For easiest
access, we recommend registering the pal addin to a keyboard shortcut.

**In RStudio**, navigate to
`Tools > Modify Keyboard Shortcuts > Search "Pal"`—we suggest
`Ctrl+Alt+P` (or `Ctrl+Cmd+P` on macOS).

**In Positron**, you’ll need to open the command palette, run “Open
Keyboard Shortcuts (JSON)”, and paste the following into your
`keybindings.json`:

``` json
    {
        "key": "Ctrl+Cmd+P",
        "command": "workbench.action.executeCode.console",
        "when": "editorTextFocus",
        "args": {
            "langId": "r",
            "code": "pal::.init_addin()",
            "focus": true
        }
    }
```

The analogous keybinding on non-macOS is `Ctrl+Alt+P`. That said, change
the `"key"` entry to any keybinding you wish!

Once those steps are completed, you’re ready to use pals with a keyboard
shortcut.

## Example

Pals are created automatically when users interact with the pal addin.
Just highlight some code, open the addin, begin typing the “role” of
your pal and press “Return”, and watch your code be rewritten:

<img src="https://raw.githubusercontent.com/simonpcouch/pal/refs/heads/main/inst/figs/addin.gif" alt="A screencast of an RStudio session. An .R file is open in the editor with a function definition. The user selects various subsets of the function and, after selecting from a dropdown menu, the pal assistant converts erroring code and drafts function documentation." width="100%" />

As-is, the package provides ergonomic LLM assistants for R package
development:

- `"cli"`: [Convert to
  cli](https://simonpcouch.github.io/pal/reference/pal_cli.html)
- `"testthat"`: [Convert to testthat
  3](https://simonpcouch.github.io/pal/reference/pal_testthat.html)
- `"roxygen"`: [Document functions with
  roxygen](https://simonpcouch.github.io/pal/reference/pal_roxygen.html)

Users have also contributed a number of pals for a wide range of
tasks–see `vignette("gallery", package = "pal")` for a gallery of
user-contributed pals!

That said, all you need to create your own pal is a markdown file with
some instructions on how you’d like it to work. See `prompt_new()` and
`directory_load()` for more information, and
[palpable](https://github.com/simonpcouch/palpable) for an example pal
extension package.

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
