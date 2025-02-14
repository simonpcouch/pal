# chat errors informatively with no input

    Code
      cli_helper$chat()
    Condition
      Error in `user_turn()`:
      ! Must supply at least one input.

# fetch_chores_chat returns early with no option set

    Code
      .res <- fetch_chores_chat()
    Message
      ! chores requires configuring an ellmer Chat with the .chores_chat option.
      i Set e.g. `options(.chores_chat = ellmer::chat_claude())` in your '~/.Rprofile' and restart R.
      i See "Choosing a model" in `vignette("chores", package = "chores")` to learn more.

# fetch_chores_chat returns early with bad config

    Code
      .res <- fetch_chores_chat()
    Message
      ! The option .chores_chat must be an ellmer Chat object, not a string.
      i See "Choosing a model" in `vignette("chores", package = "chores")` to learn more.

