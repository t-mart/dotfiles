import os
import subprocess
from pathlib import Path

__all__ = [
    "CHEZMOI_EXECUTABLE",
    "CHEZMOI_WORKING_TREE",
    "get_chezmoi_data_bool",
]

CHEZMOI_WORKING_TREE = Path(os.environ["CHEZMOI_WORKING_TREE"])
CHEZMOI_EXECUTABLE = os.environ["CHEZMOI_EXECUTABLE"]


def get_chezmoi_data_bool(key: str) -> bool:
    """Read a boolean out of chezmoi's template data.

    Raises rather than returning a value if chezmoi fails or the key does not
    hold a boolean. A silent False here would skip whole groups of packages
    with no indication that anything went wrong.
    """
    template = f"{{{{ .{key} }}}}"
    result = subprocess.run(
        [CHEZMOI_EXECUTABLE, "execute-template", template],
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        raise RuntimeError(
            f"`chezmoi execute-template {template}` failed "
            f"(exit {result.returncode}): {result.stderr.strip()}"
        )

    # An absent key is already an error above, but a key holding a non-boolean
    # renders fine and exits 0, so the output has to be checked too.
    value = result.stdout.strip()
    if value not in ("true", "false"):
        raise ValueError(f"chezmoi data key '{key}' is not a boolean: '{value}'")

    return value == "true"
