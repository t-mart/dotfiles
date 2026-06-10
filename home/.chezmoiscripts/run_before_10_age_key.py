# Chezmoi before-apply Python script
#
# This script does the following:
# - Decrypts the age private key into ~/.config/chezmoi/key.txt, which every
#   subsequent chezmoi script and template depends on
#
# uv itself is bootstrapped by the sibling shell script, which chezmoi runs
# first (scripts run in alphabetical order).


from pathlib import Path

from lib.chezmoi import CHEZMOI_EXECUTABLE, CHEZMOI_WORKING_TREE
from lib.flow import phase, step
from lib.logging import log_info
from lib.proc import run


# ── age private key ───────────────────────────────────────────────────────────


@step("age key")
def decrypt_age_key() -> None:
    encrypted_key = CHEZMOI_WORKING_TREE / "data" / "chezmoi-age-key.txt.age"
    decrypted_key = Path.home() / ".config" / "chezmoi" / "key.txt"

    if decrypted_key.is_file():
        log_info(f"Age key already exists at '{decrypted_key}' — skipping.")
        return

    decrypted_key.parent.mkdir(parents=True, exist_ok=True)

    log_info("Enter your age passphrase (find it in 1Password under 'chezmoi').")
    run(
        [
            CHEZMOI_EXECUTABLE,
            "age",
            "decrypt",
            "--output",
            str(decrypted_key),
            "--passphrase",
            str(encrypted_key),
        ],
        check=True,
    )
    decrypted_key.chmod(0o600)
    log_info(f"Key decrypted to '{decrypted_key}'.")


def main() -> None:
    with phase("chezmoi — before apply"):
        decrypt_age_key()


if __name__ == "__main__":
    main()
