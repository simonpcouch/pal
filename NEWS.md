# pal (development version)

* Initial CRAN submission.

## Notable changes pre-CRAN submission

Early adopters of the package will note two changes made shortly before the 
release of the package to CRAN:

* The configuration options `.pal_fn` and `.pal_args` have been 
  transitioned to one option, `.pal_chat`. That option takes a function
  that outputs an ellmer Chat, e.g. 
  `options(.pal_chat = function() ellmer::chat_claude())`.
  If you've configured an ellmer model using the previous options, you'll get
  an error that automatically translates to the new code you need to use.

* There is no longer a default ellmer model. Early in the development
  of pal, if you had an `ANTHROPIC_API_KEY` set up, the addin would
  "just work." While this was convenient for Claude users, but it means that the 
  package spends money on the users behalf without any explicit opt-in.
