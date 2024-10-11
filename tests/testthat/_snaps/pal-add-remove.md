# pal addition and removal works

    Code
      pal_boopery
    Message
      
      -- A boopery pal using claude-3-5-sonnet-20240620. 

# pal addition with bad inputs

    Code
      .pal_add(role = identity, prompt = "hey")
    Condition
      Error in `.pal_add()`:
      ! `role` must be a single string, not a function.

---

    Code
      .pal_add(role = "sillyhead", prompt = "hey", interface = "no")
    Condition
      Error in `.pal_add()`:
      ! `interface` should be one of "replace", "prefix", or "suffix".

---

    Code
      .pal_add(role = "sillyhead", prompt = "hey", interface = "suffix")
    Condition
      Error in `.pal_add()`:
      ! Suffixing not implemented yet.

---

    Code
      .pal_add(role = "sillyhead", prompt = "hey", interface = NULL)
    Condition
      Error in `.pal_add()`:
      ! `interface` should be one of "replace", "prefix", or "suffix".

# pal remove with bad inputs

    Code
      .pal_remove(role = identity)
    Condition
      Error in `.pal_remove()`:
      ! `role` must be a single string, not a function.

---

    Code
      .pal_remove(role = "notAnActivePal")
    Condition
      Error in `.pal_remove()`:
      ! No active pal with the given `role`.

# filter_single_hyphenated messages informatively

    Code
      res <- filter_single_hyphenated(x)
    Message
      Prompts "basename.md" and "base_name.md" must contain a single hyphen in their filenames and will not be registered with pal.

---

    Code
      res <- filter_single_hyphenated(x[1:2])
    Message
      Prompt "basename.md" must contain a single hyphen in its filename and will not be registered with pal.

# filter_interfaces messages informatively

    Code
      res <- filter_interfaces(x)
    Message
      Prompts "bop-bad.md" and "boop-silly.md" have an unrecognized `interface` noted in their filenames and will not be registered with pal.
      `interface` (following the hyphen) must be one of `replace`, `prefix`, or `suffix`.

---

    Code
      res <- filter_interfaces(x[1:2])
    Message
      Prompt "bop-bad.md" has an unrecognized `interface` noted in its filename and will not be registered with pal.
      `interface` (following the hyphen) must be one of `replace`, `prefix`, or `suffix`.

