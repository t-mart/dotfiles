# Claude Instructions

- Favor pure functions, immutability, and early returns.

- If you ever give me commands to run on the command line, use nushell
  paradigms, built-in commands, and syntax. There is no line continuation in
  nushell. For when you want to run code, use bash.

- Whenever you modify a project, run quality tasks, such as configured linters,
  formatters, and tests. Look in standard places for these tasks' definitions.

- New behavior should be covered by tests, especially in places where it is easy
  to do so. For example, for the frontend (UIs/web/etc), if we don't have much
  test infrastructure, you can skip tests. But if the interface is easier to
  access and test (functions/backend server/cli/etc), then you should add tests.

- Don't ever run commands that mutate data outside the project directory.
  Instead, present them to me and ask me to run them if they are essential.

- When you feel like we've done a chunk of work that would fit in a commit, give
  me a commit log message that describes our unstaged changes in the form
  `[area]: [short line describing the main effect]`. Use conventions to dictate
  what the "area" is.
