# TODO

- registry file should be a go template to allow for interpolation of current
  user's scoop dir. make sure to escape backslashes.
- omp: if error code == error message, then don't print error message`
- shellcheck on all bash scripts
- rust_tree on arch?
- use paru-bin, not paru

- stop writing our own package management.
  - Arch: make a private metapackage, possibly not even in in this repo.
  - Windows: make a scoop manifest with a `depends` field
  - curl-sh: not sure, TODO
  - uv: not sure, TODO

its important to realize too that we don't want a one-sized-fits all collection
of packages: imagine the packages need on my desktop versus those used on my
router ... very different.

- incorporate some stuff from this mpv setup: https://github.com/noelsimbolon/mpv-config