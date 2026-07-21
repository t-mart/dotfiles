# Instructions

- Favor pure functions, immutability, and early returns.

- When writing documentation or comments in code, avoid LLM tropes, especially
  use of em/en-dashes, unicode arrows/symbols, smart/curly quotes, and other
  special characters that can't be easily typed on a standard keyboard.

- If you ever give me commands to run on the command line, use nushell
  paradigms, built-in commands, and syntax. There is no line continuation in
  nushell. (On the other hand, for commands you want to run yourself, you can
  choose whatever shell you want.)

- Whenever you modify a project's code, run quality tasks, such as configured
  linters, formatters, and tests. Look in standard places for these tasks'
  definitions. Try to bundle the invocation of such tools so that you get as
  much feedback as possible in one run. (If we are deficient in this area,
  suggest improvements.)

- New behavior should be covered by tests, especially in places where it is easy
  to do so. If the project feels small/one-off/ad-hoc, then don't write tests.

- Don't ever run commands that mutate data outside the project directory.
  Instead, present them to me and ask me to run them if they are essential.

- When you feel like we've done a chunk of work that would fit in a commit, give
  me a commit log message that describes our unstaged changes in the form
  `[area]: [short line describing the main effect]`. Use conventions to dictate
  what the "area" is.
  - If I provided an issue number, include it in the commit message in a way
    that GitHub will close it when the commit is pushed. For example, end with
    "Closes #123" where 123 is the issue number.
  - Do not add co-author trailers for yourself.

- If there's a CHANGELOG file, in the "Unreleased" section (add one if it does
  not exist), describe user-facing changes and if an issue number is provided,
  link to the provided issue.

- Don't install dependencies or tools for me. Instead, present them to me and
  ask me to install them with commands.

- Unless specifically requested, only interact with git read-only. Don't create
  branches, commits, stage things, push, etc. I can do those things myself.

- Be judicious about comments in code. If the code is reasonably expressive and
  without footguns, then don't add comments. And again, no special unicode
  characters, only plain text that can be easily typed.
