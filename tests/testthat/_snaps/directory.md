# filter_single_hyphenated messages informatively

    Code
      res <- filter_single_hyphenated(x)
    Message
      Prompts "basename.md" and "base_name.md" must contain a single hyphen in their filenames and will not be registered with chores.

---

    Code
      res <- filter_single_hyphenated(x[1:2])
    Message
      Prompt "basename.md" must contain a single hyphen in its filename and will not be registered with chores.

# filter_interfaces messages informatively

    Code
      res <- filter_interfaces(x)
    Message
      Prompts "bop-bad.md" and "boop-silly.md" have an unrecognized `interface` noted in their filenames and will not be registered with chores.
      `interface` (following the hyphen) must be one of `replace`, `prefix`, or `suffix`.

---

    Code
      res <- filter_interfaces(x[1:2])
    Message
      Prompt "bop-bad.md" has an unrecognized `interface` noted in its filename and will not be registered with chores.
      `interface` (following the hyphen) must be one of `replace`, `prefix`, or `suffix`.

# directory_list works

    Code
      directory_list()
    Message
      
      -- Prompts:  
      * 'test-prompt-dir/boop-replace.md'
      * 'test-prompt-dir/wop-prefix.md'

---

    Code
      directory_list()
    Message
      
      -- Prompts:  
      * 'test-prompt-dir/boop-replace.md'
      * 'test-prompt-dir/wop-prefix.md'

# directory_set works

    Code
      directory_set(identity)
    Condition
      Error in `directory_set()`:
      ! `dir` must be a single string, not a function.

---

    Code
      directory_set("some/nonexistent/path")
    Condition
      Error in `directory_set()`:
      ! `dir` doesn't exist.
      i If desired, create it with `dir.create("some/nonexistent/path", recursive = TRUE)`.

# directory_list returns empty and messages informatively when no files

    Code
      res <- directory_list()
    Message
      
      -- No custom prompts. 
      i Create a new prompt with `prompt_new()` (`?chores::prompt_new()`).

