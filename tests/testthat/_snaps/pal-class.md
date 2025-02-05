# chat errors informatively with no input

    Code
      cli_pal$chat()
    Condition
      Error in `user_turn()`:
      ! Must supply at least one input.

# fetch_pal_chat returns early with old options

    Code
      .res <- fetch_pal_chat()
    Message
      pal now uses the option .pal_chat instead of .pal_fn and .pal_args.
      i Set `options(.pal_chat = boop(model = "x"))` instead.

# fetch_pal_chat returns early with no option set

    Code
      .res <- fetch_pal_chat()
    Message
      ! pal requires configuring an ellmer Chat with the .pal_chat option.
      i Set e.g. `options(.pal_chat = ellmer::chat_claude()` in your '~/.Rprofile' and restart R.
      i See "Choosing a model" in `vignette("pal", package = "pal")` to learn more.

# fetch_pal_chat returns early with bad config

    Code
      .res <- fetch_pal_chat()
    Message
      ! The option .pal_chat must be an ellmer Chat object, not a string.
      i See "Choosing a model" in `vignette("pal", package = "pal")` to learn more.

