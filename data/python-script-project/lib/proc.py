import shlex
import subprocess

__all__ = ["run"]


def run(cmd: str | list[str], **kwargs) -> subprocess.CompletedProcess:
    if isinstance(cmd, str):
        cmd = shlex.split(cmd)
    return subprocess.run(cmd, **kwargs)
