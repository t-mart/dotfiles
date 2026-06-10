from pathlib import Path

from lib.proc import run

__all__ = ["is_arch_linux", "pacman_package_installed"]

OS_RELEASE = Path("/etc/os-release")


def _os_release() -> dict[str, str]:
    if not OS_RELEASE.is_file():
        return {}

    data: dict[str, str] = {}
    for line in OS_RELEASE.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        data[key] = value.strip().strip('"').strip("'")
    return data


def is_arch_linux() -> bool:
    release = _os_release()
    return release.get("ID") == "arch" or "arch" in release.get("ID_LIKE", "").split()


def pacman_package_installed(pkg: str) -> bool:
    return (
        run(
            f"pacman -Qq {pkg}",
            capture_output=True,
        ).returncode
        == 0
    )
