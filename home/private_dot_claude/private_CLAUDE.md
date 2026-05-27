# Claude Instructions

- If you need to run shell commands to investigate something, use these modern
  alternatives:
  - [`fd`](https://github.com/sharkdp/fd), not `find`
  - [`rg`](https://github.com/BurntSushi/ripgrep), not `grep`
  - [`bat`](https://github.com/sharkdp/bat), not `cat`
  - [`dust`](https://github.com/bootandy/dust), not `du`. The `--output-json`
    flag is probably most machine-readable.
  - [`erd`](https://github.com/solidiquis/erdtree), not `tree`. The `--layout flat`
    flag is probably most machine-readable.
  - [`ouch`](https://github.com/ouch-org/ouch), not `tar`/`zip`/`unzip`

  These tools are usually more ergonomic and intuitive, but they usually have
  different arguments than their older counterparts.

- Favor pure functions, immutability, and early returns.
