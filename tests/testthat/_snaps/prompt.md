# prompt_new errors informatively with redundant role

    Code
      prompt_new("boop", "replace")
    Condition
      Error in `prompt_new()`:
      ! There's already a pal with role "boop".
      i You can edit it with `prompt_edit("boop")`

---

    Code
      prompt_new("boop", "prefix")
    Condition
      Error in `prompt_new()`:
      ! There's already a pal with role "boop".
      i You can edit it with `prompt_edit("boop")`

---

    Code
      prompt_new("cli", "replace")
    Condition
      Error in `prompt_new()`:
      ! There's already a pal with role "cli".

# prompt_remove errors informatively with bad role

    Code
      prompt_remove("nonexistentrole")
    Condition
      Error in `prompt_remove()`:
      ! No prompts for `role` "nonexistentrole" found in the prompt directory

# new prompts can be pre-filled with contents

    Code
      p <- prompt_new("summarizeAlt", "prefix",
        "https://gist.githubusercontent.com/simonpcouch/daaa6c4155918d6f3efd6706d022e584/raw/ed1da68b3f38a25b58dd9fdc8b9c258d58c9b4da/summarize-prefix.md")

# new prompts error informatively with bad pre-fill contents

    Code
      p <- prompt_new("summarizeAlt", "prefix",
        "https://gist.github.com/simonpcouch/daaa6c4155918d6f3efd6706d022e584")
    Condition
      Error in `prompt_new()`:
      ! `contents` must be a connection to a markdown file.

