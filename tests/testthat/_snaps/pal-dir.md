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

