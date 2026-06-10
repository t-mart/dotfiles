# `python-script-project`

This `uv` project defines a Python environment for running my chezmoi scripts.
It must live outside `home/.chezmoiscripts` because chezmoi will attempt to run
any scripts in that directory.

Instead, configure chezmoi to use `uv run --project <this_dir>` to run scripts.

## Editor Setup

Editor setup: to prevent red squigglies, make sure to set the Python interpreter
to the one in the virtual environment here (make it if it doesn't exist with
`uv venv` in this directory).
