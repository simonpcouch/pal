# initializing a pal

    Code
      .pal_init("cli")
    Message
      
      -- A cli pal using claude-3-5-sonnet-20240620. 

---

    Code
      .pal_init("testthat")
    Message
      
      -- A testthat pal using claude-3-5-sonnet-20240620. 

# can use other models

    Code
      .pal_init("cli", fn = "chat_openai", model = "gpt-4o-mini")
    Message
      
      -- A cli pal using gpt-4o-mini. 

---

    Code
      .pal_init("cli")
    Message
      
      -- A cli pal using claude-3-5-sonnet-20240620. 

# errors informatively with bad role

    Code
      .pal_init()
    Condition
      Error in `.pal_init()`:
      ! `role` must be a single string, not `NULL`.

---

    Code
      .pal_init(NULL)
    Condition
      Error in `.pal_init()`:
      ! `role` must be a single string, not `NULL`.

---

    Code
      .pal_init("beep bop boop")
    Condition
      Error in `.pal_init()`:
      ! No pals with role `beep bop boop` registered.
      i See `pal_add()`.

