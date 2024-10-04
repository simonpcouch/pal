# initializing a pal

    Code
      pal("cli")
    Message
      
      -- A cli pal using claude-3-5-sonnet-20240620. 

---

    Code
      pal("testthat")
    Message
      
      -- A testthat pal using claude-3-5-sonnet-20240620. 

# can use other models

    Code
      pal("cli", fn = "new_chat_openai", model = "gpt-4o-mini")
    Message
      
      -- A cli pal using gpt-4o-mini. 

---

    Code
      pal("cli")
    Message
      
      -- A cli pal using claude-3-5-sonnet-20240620. 

# errors informatively with bad role

    Code
      pal()
    Condition
      Error in `pal()`:
      ! `role` must be one of "cli" or "testthat".

---

    Code
      pal(NULL)
    Condition
      Error in `pal()`:
      ! `role` must be one of "cli" or "testthat".

---

    Code
      pal("beep bop boop")
    Condition
      Error in `pal()`:
      ! `role` must be one of "cli" or "testthat".

