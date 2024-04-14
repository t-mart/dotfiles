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

# generated scripts
overlay use starship_init.nu # starship init can be an overlay
source atuin_init.nu
source zoxide_init.nu
source carapace_init.nu

# local env (see env.nu for details)
source-env local_env.nu
