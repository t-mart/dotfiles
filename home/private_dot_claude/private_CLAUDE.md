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
