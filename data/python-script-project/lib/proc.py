import os
import shlex
import subprocess

__all__ = ["run"]

# Prefix used to run a command as root. Empty when we are already root (e.g. the
# Arch install ISO or a container), where sudo may not even be installed;
# otherwise sudo. Computed once — the effective uid can't change mid-process.
_SUDO_PREFIX = [] if os.geteuid() == 0 else ["sudo"]


def run(
    cmd: str | list[str], *, sudo: bool = False, **kwargs
) -> subprocess.CompletedProcess:
    if isinstance(cmd, str):
        cmd = shlex.split(cmd)
    if sudo:
        cmd = _SUDO_PREFIX + cmd
    return subprocess.run(cmd, **kwargs)
