# .helper_last is up to date with most recent helper

    Code
      env_get(chores_env(), ".helper_last")
    Message
      
      -- A cli chore helper using claude-3-5-sonnet-latest. 

---

    Code
      env_get(chores_env(), ".helper_last_cli")
    Message
      
      -- A cli chore helper using claude-3-5-sonnet-latest. 

---

    Code
      env_get(chores_env(), ".helper_last")
    Message
      
      -- A cli chore helper using gpt-4o-mini. 

# role checks error informatively

    Code
      check_role("hey there")
    Condition
      Error:
      ! `role` must be a single string containing only letters and digits.

---

    Code
      check_role(identity)
    Condition
      Error:
      ! `role` must be a single string, not a function.

