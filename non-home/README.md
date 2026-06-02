# non-home/

Files that need to be deployed outside the home directory. Chezmoi only manages
`$HOME`, so this directory holds the source files and a deployment manifest.

## Directory layout

The directory tree mirrors the destination filesystem. For example, a file
destined for `/etc/foo/bar.conf` lives here at `etc/foo/bar.conf`. This makes it
easy to find and diff the source alongside its installed counterpart.

But note, this is just for organizational purposes. See `deployments.yaml` for
the actual destination paths used in deployment.

## Deployment manifest

`deployments.yaml` is the authoritative list of what gets deployed and where.
Each entry declares:

- `name` — label used in log output
- `source` — path relative to the repo root (i.e. `non-home/...`)
- `dest` — absolute path on the target system
- `when` — optional list of chezmoi data boolean keys that must all be `true`
  for the entry to be deployed; omit to deploy unconditionally
- `instructions` — text shown via `gum confirm` after the file is updated,
  prompting any manual follow-up steps

The deployment is driven by
`home/.chezmoiscripts/after/run_after_23-non-home.sh`, which reads this manifest
and deploys each applicable entry.

## Adding a new file

1. Drop the file into this tree at the path matching its destination.
2. Add an entry to `deployments.yaml`.
3. That's it — no script changes needed.
