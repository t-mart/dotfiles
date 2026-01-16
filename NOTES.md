# Notes

## Stop templating scripts

Chezmoi offers the execution of scripts during runs. I use this to do package
management (which is maybe an abuse of chezmoi, but its convenient).

Anyway, I used to (and in some cases still do) write these scripts in bash or
powershell, augmented with chezmoi Go templating. This creates frankenstein
scripts that are hard to read, write, and maintain.

Instead, a cleaner pattern seems to be to write in pure bash or powershell, but
run the `chezmoi` command to get information out of it.

To do this, in many cases, you need to use environment variables that chezmoi
sets when running the scripts. This allows for getting things like:

- the path of the chezmoi executable
- the path of the chezmoi source directory

Here's what that environment looks like on unix systems:

```text
CHEZMOI=1
CHEZMOI_ARCH=amd64
CHEZMOI_ARGS=/home/tim/.local/bin/chezmoi apply
CHEZMOI_CACHE_DIR=/home/tim/.cache/chezmoi
CHEZMOI_COMMAND=apply
CHEZMOI_COMMAND_DIR=/home/tim/.local/share/chezmoi/home/.chezmoiscripts/unix/before
CHEZMOI_CONFIG_FILE=/home/tim/.config/chezmoi/chezmoi.toml
CHEZMOI_DEST_DIR=/home/tim
CHEZMOI_EXECUTABLE=/home/tim/.local/bin/chezmoi
CHEZMOI_FQDN_HOSTNAME=00d0a78af1a2
CHEZMOI_GID=1000
CHEZMOI_GROUP=tim
CHEZMOI_HOME_DIR=/home/tim
CHEZMOI_HOSTNAME=00d0a78af1a2
CHEZMOI_KERNEL_OSRELEASE=6.6.87.2-microsoft-standard-WSL2
CHEZMOI_KERNEL_OSTYPE=Linux
CHEZMOI_KERNEL_VERSION=#1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025
CHEZMOI_OS=linux
CHEZMOI_OS_RELEASE_ANSI_COLOR=38;2;23;147;209
CHEZMOI_OS_RELEASE_BUG_REPORT_URL=https://gitlab.archlinux.org/groups/archlinux/-/issues
CHEZMOI_OS_RELEASE_BUILD_ID=rolling
CHEZMOI_OS_RELEASE_DOCUMENTATION_URL=https://wiki.archlinux.org/
CHEZMOI_OS_RELEASE_HOME_URL=https://archlinux.org/
CHEZMOI_OS_RELEASE_ID=arch
CHEZMOI_OS_RELEASE_LOGO=archlinux-logo
CHEZMOI_OS_RELEASE_NAME=Arch Linux
CHEZMOI_OS_RELEASE_PRETTY_NAME=Arch Linux
CHEZMOI_OS_RELEASE_PRIVACY_POLICY_URL=https://terms.archlinux.org/docs/privacy-policy/
CHEZMOI_OS_RELEASE_SUPPORT_URL=https://bbs.archlinux.org/
CHEZMOI_OS_RELEASE_VERSION_ID=20260111.0.480139
CHEZMOI_SOURCE_DIR=/home/tim/.local/share/chezmoi/home
CHEZMOI_SOURCE_FILE=.chezmoiscripts/unix/before/run_onchange_before_10-decrypt-private-key1.sh
CHEZMOI_UID=1000
CHEZMOI_USERNAME=tim
CHEZMOI_VERSION_BUILT_BY=goreleaser
CHEZMOI_VERSION_COMMIT=e2e3d1d416604bfe97ff2abfd14d197b79359e5b
CHEZMOI_VERSION_DATE=2026-01-16T01:48:52Z
CHEZMOI_VERSION_VERSION=2.69.3
CHEZMOI_WORKING_TREE=/home/tim/.local/share/chezmoi
```

And here's what it looks like on Windows:

```text
CHEZMOI=1
CHEZMOI_ARCH=amd64
CHEZMOI_ARGS=C:\Users\tim\scoop\apps\chezmoi\current\chezmoi.exe apply
CHEZMOI_CACHE_DIR=C:/Users/tim/.cache/chezmoi
CHEZMOI_COMMAND=apply
CHEZMOI_COMMAND_DIR=C:/Users/tim/.local/share/chezmoi
CHEZMOI_CONFIG_FILE=C:/Users/tim/.config/chezmoi/chezmoi.toml
CHEZMOI_DEST_DIR=C:/Users/tim
CHEZMOI_EXECUTABLE=C:/Users/tim/scoop/apps/chezmoi/current/chezmoi.exe
CHEZMOI_FQDN_HOSTNAME=fennel
CHEZMOI_GID=S-1-5-21-1189996077-2186073094-2703254590-1001
CHEZMOI_GROUP=
CHEZMOI_HOME_DIR=C:/Users/tim
CHEZMOI_HOSTNAME=fennel
CHEZMOI_OS=windows
CHEZMOI_SOURCE_DIR=C:/Users/tim/.local/share/chezmoi/home
CHEZMOI_SOURCE_FILE=.chezmoiscripts/windows/run_onchange_after_04-poop.ps1.tmpl
CHEZMOI_UID=S-1-5-21-1189996077-2186073094-2703254590-1001
CHEZMOI_USERNAME=FENNEL\tim
CHEZMOI_VERSION_BUILT_BY=goreleaser
CHEZMOI_VERSION_COMMIT=a08a575a051dbe93b9dadb63f683e437af1337ba
CHEZMOI_VERSION_DATE=2026-01-10T00:29:57Z
CHEZMOI_VERSION_VERSION=2.69.1
CHEZMOI_WINDOWS_VERSION_CURRENT_BUILD=26200
CHEZMOI_WINDOWS_VERSION_CURRENT_MAJOR_VERSION_NUMBER=10
CHEZMOI_WINDOWS_VERSION_CURRENT_MINOR_VERSION_NUMBER=0
CHEZMOI_WINDOWS_VERSION_CURRENT_VERSION=6.3
CHEZMOI_WINDOWS_VERSION_DISPLAY_VERSION=25H2
CHEZMOI_WINDOWS_VERSION_EDITION_ID=Professional
CHEZMOI_WINDOWS_VERSION_PRODUCT_NAME=Windows 10 Pro
CHEZMOI_WORKING_TREE=C:/Users/tim/.local/share/chezmoi
```