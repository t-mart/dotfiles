# Chezmoi after-apply Python script
#
# This script does the following:
# - Installs paru and pacman packages (Arch only)
# - Installs uv tools
# - Sets Nushell as the default shell
# - Imports GPG keys
# - Deploys non-home files


import os
import pwd
import sys
import tempfile
from pathlib import Path

from lib.arch_linux import pacman_package_installed
from lib.chezmoi import (
    CHEZMOI_EXECUTABLE,
    CHEZMOI_WORKING_TREE,
    get_chezmoi_data_bool,
)
from lib.flow import phase, step
from lib.logging import (
    log_error,
    log_info,
    log_panel,
    prompt_continue,
)
from lib.proc import run
from lib.yaml import load_yaml


# ── paru ──────────────────────────────────────────────────────────────────────


@step("paru", arch_only=True)
def install_paru() -> None:
    if pacman_package_installed("paru"):
        log_info("paru already installed.")
        return

    log_info("Installing build dependencies...")
    run(
        "pacman -Syu --noconfirm --needed base-devel git gnupg",
        sudo=True,
        check=True,
    )

    with tempfile.TemporaryDirectory() as tmp:
        log_info("Cloning paru from AUR...")
        run(
            ["git", "clone", "https://aur.archlinux.org/paru.git", f"{tmp}/paru"],
            check=True,
        )
        log_info("Building and installing paru...")
        run("makepkg -si --noconfirm", cwd=f"{tmp}/paru", check=True)

    log_info("paru installed.")


# ── yay ───────────────────────────────────────────────────────────────────────


@step("yay", arch_only=True)
def install_yay() -> None:
    if pacman_package_installed("yay"):
        log_info("yay already installed.")
        return

    log_info("Installing build dependencies...")
    run(
        "pacman -Syu --noconfirm --needed base-devel git gnupg",
        sudo=True,
        check=True,
    )

    with tempfile.TemporaryDirectory() as tmp:
        log_info("Cloning yay-bin from AUR...")
        run(
            f"git clone https://aur.archlinux.org/yay-bin.git {tmp}/yay",
            check=True,
        )
        log_info("Installing yay...")
        run("makepkg -si --noconfirm", cwd=f"{tmp}/yay", check=True)

    log_info("yay installed.")


# ── packages ──────────────────────────────────────────────────────────────────


def install_packagelist(name: str) -> None:
    list_file = (
        CHEZMOI_WORKING_TREE / "data" / "packagelists" / "pacman" / f"{name}.yml"
    )
    if not list_file.exists():
        log_error(f"Packagelist file not found: {list_file}")
        return

    packages = load_yaml(list_file) or []

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


@step("packages", arch_only=True)
def install_packages() -> None:
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


@step("uv tools")
def install_uv_tools() -> None:
    if not get_chezmoi_data_bool("isWorkstation"):
        log_info("Not a workstation — skipping.")
        return

    tools_file = CHEZMOI_WORKING_TREE / "data" / "packagelists" / "uv-tools.yml"
    tools = load_yaml(tools_file) or []

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


@step("default shell")
def set_default_shell() -> None:
    nu = Path("/usr/bin/nu")

    if not nu.is_file():
        log_error(f"Nushell not found at {nu} — skipping.")
        return

    shells = Path("/etc/shells")
    if shells.exists() and str(nu) not in shells.read_text().splitlines():
        log_info(f"Adding '{nu}' to /etc/shells...")
        run(
            ["tee", "--append", str(shells)],
            sudo=True,
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


@step("GPG keys")
def import_gpg_keys() -> None:
    key_file = CHEZMOI_WORKING_TREE / "data" / "gpg-keys.txt.age"

    decrypted = run(
        [CHEZMOI_EXECUTABLE, "decrypt", str(key_file)],
        capture_output=True,
        check=True,
    )
    run("gpg --import --batch --yes", input=decrypted.stdout, check=True)
    log_info("GPG keys imported.")


# ── non-home files ────────────────────────────────────────────────────────────


@step("non-home files")
def deploy_non_home() -> None:
    non_home_config_file = CHEZMOI_WORKING_TREE / "non-home" / "non-home.yaml"

    config = load_yaml(non_home_config_file)
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
        run(["cp", str(source), dest], sudo=True, check=True)
        log_panel(instructions.strip(), title=f"[bold]{name}[/bold] — next steps")
        prompt_continue()


def main() -> None:
    with phase("chezmoi — after apply"):
        install_paru()
        install_yay()
        install_packages()

        install_uv_tools()
        set_default_shell()
        import_gpg_keys()
        deploy_non_home()


if __name__ == "__main__":
    main()
