# non-home/

Files that need to be deployed outside the home directory. Chezmoi only manages
`$HOME`, so this directory holds the source files and a deployment manifest.

## Directory layout

The directory tree mirrors the destination filesystem. For example, a file
destined for `/etc/foo/bar.conf` lives here at `non-home/etc/foo/bar.conf`. This
makes it easy to find.

But, this is just for organizational purposes. See `non-home.yaml` for the
actual destination paths used in deployment.

## Deployment manifest

`non-home.yaml` is the authoritative list of what gets deployed and where. It is
validated by `non-home.schema.json`, which is the authoritative description of
the format. Each entry under `copies` declares:

- `name`: label used in log output
- `source`: path relative to this `non-home/` directory (i.e. `./etc/...`)
- `dest`: absolute path on the target system
- `reference_url`: optional documentation URL, shown when the file is updated
- `when`: optional conditions that must all hold for the entry to be deployed;
  omit to deploy unconditionally. Currently the only condition is
  `packages_installed`, a list of pacman packages that must all be installed.
- `after_commands`: optional list of commands to run after the file is copied.
  They are printed first, and only run if you confirm the prompt.

The deployment is driven by `home/.chezmoiscripts/run_after_setup.py`, which
reads this manifest and deploys each applicable entry. A file is copied only
when its contents differ from what is already at `dest`.

## Adding a new file

1. Drop the file into this tree at the path matching its destination.
2. Add an entry to `non-home.yaml`.
3. That's it, no script changes needed.
