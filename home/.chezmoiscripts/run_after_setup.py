# Chezmoi after-apply Python script
#
# This script does the following:
# - Installs yay
# - Installs packages based on the system type
# - Installs uv tools
# - Sets Nushell as the default shell
# - Imports GPG keys
# - Deploys non-home files


import os
import pwd
import sys
import tempfile
from pathlib import Path

from lib.arch_linux import (
    is_package_installed,
    get_missing_packages_from_list,
    install_packages,
)
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
    prompt_confirm,
)
from lib.proc import run
from lib.yaml import load_yaml


# ── yay ───────────────────────────────────────────────────────────────────────


@step("yay", arch_only=True)
def install_yay() -> None:
    if is_package_installed(["yay-bin"]):
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


@step("packages", arch_only=True)
def install_package_lists() -> None:
    missing = get_missing_packages_from_list("base")

    chezmoi_bool_package_list: dict[str, str] = {
        "isWorkstation": "workstation",
        "isGraphical": "graphical",
        "usesBrotherPrinter": "brother-printer",
        "isThinkpadZ13": "thinkpad-z13",
    }

    for bool_key, package_list_name in chezmoi_bool_package_list.items():
        if get_chezmoi_data_bool(bool_key):
            missing |= get_missing_packages_from_list(package_list_name)

    if not missing:
        log_info("All packages already installed.")
    else:
        log_info(f"Installing missing packages: {', '.join(missing)}")
        install_packages(missing)


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
    log_info("Shell changed. Log out and back in for it to take effect.")


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


def run_after_commands(commands: list[str]) -> None:
    listing = "\n".join(f"\t\t$ {cmd}" for cmd in commands)
    log_info(f"\tfile wants to run the following commands:\n{listing}")

    if not prompt_confirm("\tRun these now?"):
        log_info("\tSkipped — run them yourself when ready.")
        return

    # Inherit the terminal so output streams live (and interleaved), interactive
    # commands keep working, and sudo can prompt. Output is already on screen, so
    # a failure only needs the command and its exit code reported.
    for cmd in commands:
        log_info(f"\tRunning: {cmd}")
        result = run(cmd)
        if result.returncode != 0:
            log_error(f"\t`{cmd}` failed (exit {result.returncode}) — see output above.")
            break


@step("non-home files")
def deploy_non_home() -> None:
    non_home_config_file = CHEZMOI_WORKING_TREE / "non-home" / "non-home.yaml"

    config = load_yaml(non_home_config_file)
    copies_dir = non_home_config_file.parent

    for copy in config["copies"]:
        name: str = copy["name"]
        source: Path = (copies_dir / copy["source"]).resolve()
        dest: str = copy["dest"]
        reference_url: str | None = copy.get("reference_url")
        after_commands: list[str] = copy.get("after_commands", [])

        when: dict | None = copy.get("when")
        if when and not is_package_installed(when.get("packages_installed", [])):
            continue

        if not source.exists():
            log_error(f"{name}: source not found at {source}")
            sys.exit(1)

        dest_path = Path(dest)
        if dest_path.exists() and source.read_bytes() == dest_path.read_bytes():
            log_info(f"{name}: already up to date.")
            continue

        log_info(f"{name}")
        log_info(f"\t→ {dest}")
        if reference_url:
            log_info(f"\tsee {reference_url} for details.")
        log_info("\tcopying to dest (may see sudo prompt)...")
        run(["cp", str(source), dest], sudo=True, check=True)
        log_info("\tcopy complete.")

        if after_commands:
            run_after_commands(after_commands)


def main() -> None:
    with phase("chezmoi — after apply"):
        install_yay()
        install_package_lists()
        install_uv_tools()
        set_default_shell()
        import_gpg_keys()
        deploy_non_home()


if __name__ == "__main__":
    main()
