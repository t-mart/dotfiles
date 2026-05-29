# Claude Instructions

- If you need to run shell commands to investigate something, use these modern
  alternatives (that have different syntaxes):
  - [`fd`](https://github.com/sharkdp/fd), not `find`
  - [`rg`](https://github.com/BurntSushi/ripgrep), not `grep`
  - [`bat`](https://github.com/sharkdp/bat), not `cat`

- Favor pure functions, immutability, and early returns.

- If you ever give me code that I should run, use nushell paradigms, built-in
  commands, and syntax. There is no line continuation in nushell.
