#!/usr/bin/env python3
import os
import subprocess
from pathlib import Path

CONFIG_DIR = Path.home() / ".config" / "chezmoi"
CHEZMOI_SOURCE_PATH = Path(os.environ["CHEZMOI_SOURCE_DIR"])

DECRYPTED_AGE_KEY_PATH = CONFIG_DIR / "key.txt"
ENCRYPTED_AGE_KEY_PATH = CHEZMOI_SOURCE_PATH / ".data" / "key.txt.age"

def main() -> None:
    if DECRYPTED_AGE_KEY_PATH.exists():
        print("chezmoi age key already exists at:", DECRYPTED_AGE_KEY_PATH)
        return

    CONFIG_DIR.mkdir(parents=True, exist_ok=True)

    encrypted_key_path = CHEZMOI_SOURCE_PATH / ".data" / "key.txt.age"

    subprocess.run(
        [
            "chezmoi",
            "age",
            "decrypt",
            "--output",
            str(DECRYPTED_AGE_KEY_PATH),
            "--passphrase",
            str(encrypted_key_path),
        ],
        check=True,
    )
    print("Decryption successful.")


if __name__ == "__main__":
    main()
