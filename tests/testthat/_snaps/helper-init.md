# initializing a helper

    Code
      .init_helper("cli")
    Message
      
      -- A cli chore helper using claude-3-5-sonnet-latest. 

---

    Code
      .init_helper("testthat")
    Message
      
      -- A testthat chore helper using claude-3-5-sonnet-latest. 

# can use other models

    Code
      .init_helper("cli", .chores_chat = ellmer::chat_openai(model = "gpt-4o-mini"))
    Message
      
      -- A cli chore helper using gpt-4o-mini. 

# errors informatively with bad role

    Code
      .init_helper()
    Condition
      Error in `.init_helper()`:
      ! `role` must be a single string, not `NULL`.

---

    Code
      .init_helper(NULL)
    Condition
      Error in `.init_helper()`:
      ! `role` must be a single string, not `NULL`.

---

    Code
      .init_helper("beepBopBoop")
    Condition
      Error in `.init_helper()`:
      ! No helpers with role `beepBopBoop` registered.
      i See `.helper_add()`.

