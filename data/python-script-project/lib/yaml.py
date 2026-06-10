from pathlib import Path
from typing import Any

import yaml

__all__ = ["load_yaml"]


def load_yaml(path: Path) -> Any:
    with path.open() as f:
        return yaml.safe_load(f)
