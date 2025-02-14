# chores (development version)

* Initial CRAN submission.

## Notable changes pre-CRAN submission

Early adopters of the package will note a few changes made shortly before the 
release of the package to CRAN:

* The package was renamed from pal to chores, and the grammar surrounding the 
  package shifted a bit in the process: "a pal from the pal package with a 
  given role" is now "a helper from the chores package for a given chore."

* The configuration options `.pal_fn` and `.pal_args` have been 
  transitioned to one option, `.chores_chat`. That option takes an ellmer Chat, 
  e.g. `options(.chores_chat = ellmer::chat_claude())`.

* There is no longer a default ellmer model. Early in the development
  of chores, if you had an `ANTHROPIC_API_KEY` set up, the addin would
  "just work." While this was convenient for Claude users, but it means that the 
  package spends money on the users behalf without any explicit opt-in.
