#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["rich", "PyYAML"]
# ///

import os
import pwd
import shlex
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml
from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt

CHEZMOI_WORKING_TREE = Path(os.environ["CHEZMOI_WORKING_TREE"])
CHEZMOI_EXECUTABLE = os.environ["CHEZMOI_EXECUTABLE"]

console = Console()


# ── subprocess ────────────────────────────────────────────────────────────────


def run(cmd: str | list[str], **kwargs) -> subprocess.CompletedProcess:
    if isinstance(cmd, str):
        cmd = shlex.split(cmd)
    return subprocess.run(cmd, **kwargs)


# ── logging ───────────────────────────────────────────────────────────────────


def log_info(msg: str) -> None:
    console.print(f"[cyan]•[/cyan] {msg}")


def log_error(msg: str) -> None:
    console.print(f"[bold red]✗[/bold red] {msg}")


def log_banner(msg: str) -> None:
    console.rule(f"[bold magenta]{msg}[/bold magenta]")


# ── chezmoi data ──────────────────────────────────────────────────────────────


def get_chezmoi_data_bool(key: str) -> bool:
    result = subprocess.run(
        [CHEZMOI_EXECUTABLE, "execute-template", f"{{{{ .{key} }}}}"],
        capture_output=True,
        text=True,
    )
    return result.stdout.strip() == "true"


# ── environment detection ─────────────────────────────────────────────────────


def is_arch_linux() -> bool:
    return shutil.which("pacman") is not None and shutil.which("makepkg") is not None


# ── paru ──────────────────────────────────────────────────────────────────────


def pacman_package_installed(pkg: str) -> bool:
    return (
        run(
            f"pacman -Qq {pkg}",
            capture_output=True,
        ).returncode
        == 0
    )


def install_paru() -> None:
    log_banner("paru")
    if pacman_package_installed("paru"):
        log_info("paru already installed.")
        return

    log_info("Installing build dependencies...")
    run("sudo pacman -Syu --noconfirm --needed base-devel git gnupg", check=True)

    with tempfile.TemporaryDirectory() as tmp:
        log_info("Cloning paru from AUR...")
        run(
            ["git", "clone", "https://aur.archlinux.org/paru.git", f"{tmp}/paru"],
            check=True,
        )
        log_info("Building and installing paru...")
        run("makepkg -si --noconfirm", cwd=f"{tmp}/paru", check=True)

    log_info("paru installed.")


# ── packages ──────────────────────────────────────────────────────────────────


def install_packagelist(name: str) -> None:
    list_file = (
        CHEZMOI_WORKING_TREE / "data" / "packagelists" / "pacman" / f"{name}.yml"
    )
    if not list_file.exists():
        log_error(f"Packagelist file not found: {list_file}")
        return

    with list_file.open() as f:
        packages = yaml.safe_load(f) or []

    if not packages:
        return

    installed = set(
        run("pacman -Qq", capture_output=True, text=True).stdout.splitlines()
    )
    missing = [p for p in packages if p not in installed]

    if not missing:
        log_info(f"All packages from '{name}' already installed.")
        return

    log_info(
        f"Installing {len(missing)} missing package(s) from '{name}' via paru...",
    )
    run(
        f"paru --sync --sysupgrade --refresh --needed --pgpfetch --noconfirm {' '.join(missing)}",
        check=True,
    )


def install_packages() -> None:
    log_banner("packages")
    install_packagelist("base")

    if get_chezmoi_data_bool("isWorkstation"):
        install_packagelist("workstation")
    if get_chezmoi_data_bool("isGraphical"):
        install_packagelist("graphical")
    if get_chezmoi_data_bool("usesBrotherPrinter"):
        install_packagelist("brother-printer")
    if get_chezmoi_data_bool("isThinkpadZ13"):
        install_packagelist("thinkpad-z13")


# ── uv tools ──────────────────────────────────────────────────────────────────


def install_uv_tools() -> None:
    log_banner("uv tools")
    if not get_chezmoi_data_bool("isWorkstation"):
        log_info("Not a workstation — skipping.")
        return

    tools_file = CHEZMOI_WORKING_TREE / "data" / "packagelists" / "uv-tools.yml"
    with tools_file.open() as f:
        tools = yaml.safe_load(f) or []

    env = os.environ | {
        "PATH": f"{Path.home() / '.local' / 'bin'}:{os.environ['PATH']}"
    }

    for entry in tools:
        tool = entry["tool"]
        extras = entry.get("extras", [])
        log_info(f"Installing {tool}...")
        cmd = ["uv", "tool", "install", tool]
        for extra in extras:
            cmd += ["--with", extra]
        run(cmd, env=env, check=True)


# ── default shell ─────────────────────────────────────────────────────────────


def set_default_shell() -> None:
    log_banner("default shell")
    nu = Path("/usr/bin/nu")

    if not nu.is_file():
        log_error(f"Nushell not found at {nu} — skipping.")
        return

    shells = Path("/etc/shells")
    if shells.exists() and str(nu) not in shells.read_text().splitlines():
        log_info(f"Adding '{nu}' to /etc/shells...")
        run(
            ["sudo", "tee", "--append", str(shells)],
            input=f"{nu}\n",
            text=True,
            capture_output=True,
            check=True,
        )

    user = pwd.getpwuid(os.getuid())
    if user.pw_shell == str(nu):
        log_info(f"Default shell already '{nu}'.")
        return

    log_info(f"Changing default shell to '{nu}'...")
    run(["chsh", "-s", str(nu)], check=True)
    log_info("Shell changed — log out and back in for it to take effect.")


# ── GPG keys ──────────────────────────────────────────────────────────────────


def import_gpg_keys() -> None:
    log_banner("GPG keys")
    key_file = CHEZMOI_WORKING_TREE / "data" / "gpg-keys.txt.age"

    decrypted = run(
        [CHEZMOI_EXECUTABLE, "decrypt", str(key_file)],
        capture_output=True,
        check=True,
    )
    run("gpg --import --batch --yes", input=decrypted.stdout, check=True)
    log_info("GPG keys imported.")


# ── non-home files ────────────────────────────────────────────────────────────


def deploy_non_home() -> None:
    log_banner("non-home files")
    non_home_config_file = CHEZMOI_WORKING_TREE / "non-home" / "non-home.yaml"

    with non_home_config_file.open() as f:
        config = yaml.safe_load(f)

    copies_dir = non_home_config_file.parent

    for copy in config["copies"]:
        name = copy["name"]
        source = (copies_dir / copy["source"]).resolve()
        dest = copy["dest"]
        instructions = copy["instructions"]
        conditions = copy.get("when", [])

        if not all(get_chezmoi_data_bool(cond) for cond in conditions):
            continue

        if not source.exists():
            log_error(f"{name}: source not found at {source}")
            sys.exit(1)

        dest_path = Path(dest)
        if dest_path.exists() and source.read_bytes() == dest_path.read_bytes():
            log_info(f"{name}: already up to date.")
            continue

        log_info(f"{name}: copying to {dest}...")
        run(["sudo", "cp", str(source), dest], check=True)
        console.print(
            Panel(instructions.strip(), title=f"[bold]{name}[/bold] — next steps")
        )
        Prompt.ask("Press Enter to continue", default="")


def main() -> None:
    log_banner("chezmoi — after apply")

    if is_arch_linux():
        install_paru()
        install_packages()

    install_uv_tools()
    set_default_shell()
    import_gpg_keys()
    deploy_non_home()


if __name__ == "__main__":
    main()
