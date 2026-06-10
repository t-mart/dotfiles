import os
import subprocess
from pathlib import Path

__all__ = [
    "CHEZMOI_WORKING_TREE",
    "CHEZMOI_EXECUTABLE",
    "get_chezmoi_data_bool",
]

CHEZMOI_WORKING_TREE = Path(os.environ["CHEZMOI_WORKING_TREE"])
CHEZMOI_EXECUTABLE = os.environ["CHEZMOI_EXECUTABLE"]


def get_chezmoi_data_bool(key: str) -> bool:
    result = subprocess.run(
        [CHEZMOI_EXECUTABLE, "execute-template", f"{{{{ .{key} }}}}"],
        capture_output=True,
        text=True,
    )
    return result.stdout.strip() == "true"
