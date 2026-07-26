# Instructions

- Favor pure functions, immutability, and early returns.

- When you are blocked on a decision that is genuinely mine to make (one you
  cannot resolve from the request, the code, or sensible defaults), present the
  question to me and let me respond. Reserve this for decisions where the user's
  answer changes what you do next. Recommend at least one option.

- When writing documentation or comments in code, avoid LLM tropes, especially
  use of em/en-dashes, unicode arrows/symbols, smart/curly quotes, and other
  special characters that can't be easily typed on a standard keyboard.

- Whenever you modify a project's code, run quality tasks, such as configured
  linters, formatters, and tests. Try to bundle the invocation of such tools so
  that you get as much feedback as possible in one run. (If we are deficient in
  this area, suggest improvements.)

- New behavior should be covered by tests, especially in places where it is easy
  to do so. If the project feels small/one-off/ad-hoc, then don't write tests.

- When we've done a chunk of work that would fit in a commit, give me a commit
  log message in the form `[area]: [short line describing the main effect]`. I
  tend not to use the extended descriptions in commit messages.
  - If I provide an issue number, after the work is complete, add a trailer to
    the commit message in the form "Closes #123" where 123 is the issue number.
  - Do not add co-author trailers for yourself.

- If there's a CHANGELOG file, add an entry for changes you make that are
  user-facing.

- Don't install dependencies or tools for me. Instead, present them to me with
  commands. I will install them if warranted.

- Don't run commands that mutate data outside the project directory. Instead,
  present them to me and ask me to run them if they are essential.

- Don't mutate git history, but you can interact with it in a read-only
  capacity.

- If you ever want me to run commands, use nushell paradigms, built-in commands,
  and syntax. There is no line continuation in nushell.
