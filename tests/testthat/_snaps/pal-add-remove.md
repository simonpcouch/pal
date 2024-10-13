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

