# Nushell Config File

$env.config = {
    show_banner: false

    rm: {
        # always put in trash (e.g., Recycle Bin)
        always_trash: true
    }

    edit_mode: vi
}

# source-controlled scripts
source import-album.nu
source ls-colors.nu

# generated scripts
source starship_init.nu
source atuin_init.nu
source zoxide_init.nu
source carapace_init.nu

# do this again, just in case the above scripts have added new paths
dedupe_and_expand_path
