# Nushell Config File
#
# version = "0.92.2"

# The default config record. This is where much of your global configuration is setup.
$env.config = {
    show_banner: false 

    rm: {
        # always put in trash (e.g., Recycle Bin)
        always_trash: true
    }

    edit_mode: vi
}

# source scripts
source import-album.nu
source vendor/atuin_init.nu
source vendor/zoxide_init.nu
source vendor/carapace_init.nu
