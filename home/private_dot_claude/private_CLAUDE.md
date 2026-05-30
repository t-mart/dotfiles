# Claude Instructions

- Favor pure functions, immutability, and early returns.

- If you ever give me commands to run on the command line, use nushell
  paradigms, built-in commands, and syntax. There is no line continuation in
  nushell. If you must give code that uses external commands, use `fd` (not
  `find`), `rg` (not `grep`), or `bat` (not `cat`).
