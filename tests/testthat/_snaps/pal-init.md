# initializing a pal

    Code
      .init_pal("cli")
    Message
      
      -- A cli pal using claude-3-5-sonnet-20240620. 

---

    Code
      .init_pal("testthat")
    Message
      
      -- A testthat pal using claude-3-5-sonnet-20240620. 

# can use other models

    Code
      .init_pal("cli", fn = "chat_openai", model = "gpt-4o-mini")
    Message
      
      -- A cli pal using gpt-4o-mini. 

---

    Code
      .init_pal("cli")
    Message
      
      -- A cli pal using claude-3-5-sonnet-20240620. 

# errors informatively with bad role

    Code
      .init_pal()
    Condition
      Error in `.init_pal()`:
      ! `role` must be a single string, not `NULL`.

---

    Code
      .init_pal(NULL)
    Condition
      Error in `.init_pal()`:
      ! `role` must be a single string, not `NULL`.

---

    Code
      .init_pal("beepBopBoop")
    Condition
      Error in `.init_pal()`:
      ! No pals with role `beepBopBoop` registered.
      i See `.pal_add()`.

