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

