from pathlib import Path

from lib.proc import run

from lib.chezmoi import (
    CHEZMOI_WORKING_TREE,
)
from lib.yaml import load_yaml

__all__ = [
    "is_arch_linux",
    "is_package_installed",
    "get_missing_packages_from_list",
    "install_packages",
]

type Packages = list[str] | set[str] | tuple[str, ...]

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


def get_installed_subset(check: Packages) -> set[str]:
    """Given a collection of package names, return the subset that is installed."""
    if not check:
        # raw `pacman -Qq` will list all installed packages, not what we want
        return set()
    result = run(
        # MUST use pacman here because we use this command to check if yay is installed.
        f"pacman -Qq {' '.join(check)}",
        capture_output=True,
        text=True,
    )
    return set(result.stdout.splitlines())


def is_package_installed(pkgs: Packages) -> bool:
    """Return True if all packages in the collection are installed."""
    return get_installed_subset(pkgs) == set(pkgs)


def get_missing_packages_from_list(package_list_name: str) -> set[str]:
    """Return the set of packages from the packagelist that are not installed."""
    list_file = (
        CHEZMOI_WORKING_TREE
        / "data"
        / "packagelists"
        / "pacman"
        / f"{package_list_name}.yml"
    )
    if not list_file.exists():
        raise FileNotFoundError(f"Packagelist file not found: {list_file}")

    packages = load_yaml(list_file) or []
    installed = get_installed_subset(packages)
    return set(packages) - installed


def install_packages(pkgs: Packages) -> None:
    """Install the given package(s) using yay."""
    run(
        f"yay --sync --sysupgrade --refresh --needed --pgpfetch --noconfirm {' '.join(pkgs)}",
        check=True,
    )
