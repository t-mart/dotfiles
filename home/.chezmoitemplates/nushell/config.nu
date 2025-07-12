# Nushell Config File

$env.config = {
    show_banner: false

    rm: {
        # always put in trash (e.g., Recycle Bin)
        always_trash: true
    }

    edit_mode: vi
}

# prepend and append a delimiter to the input
def surround [
    delim: string, # delimiter to surround the input with
]: string -> string {
    $delim + $in + $delim
}

if (is-installed-warn fzf) {
    # use es (Everything CLI) on Windows, which is way faster than default 
    #`find` for NTFS drives. note that es requires Everything to be running.
    let has_es = ($nu.os-info.name) == "windows" and (is-installed-warn es)

    if $has_es {
        # mimic default FZF behavior by filtering results to those under cwd.
        # fzf inspects this variable to know how to populate the results list.
        $env.FZF_DEFAULT_COMMAND = "es -path ."
    }

    # helper to build the command line edit command string for fzf. note that
    # we're not actually running a command, just building its string, because
    # keybindings run them at keypress time.
    def build-cmd-line-edit [
        has_es: bool,
        root: bool,
    ]: nothing -> string {
        # start with commandline edit prefix
        mut line = "commandline edit --insert ("

        if $root {
            if $has_es {
                # no es cwd filter
                $line = $line + "FZF_DEFAULT_COMMAND=es fzf"
            } else {
                # set to system root
                $line = $line + "fzf --walker-root=/"
            }
        } else {
            # otherwise, just use fzf as is
            # if we have es, we've already set FZF_DEFAULT_COMMAND, and if not,
            # walker-root is cwd by default
            $line = $line + "fzf"
        }

        # - layout reverse looks better to me
        # - backtick-quote the result for paths with spaces
        # - close subcommand parentheses
        $line = $line + " --layout=reverse | if ($in | str length) > 0 { $in | surround '`' } )"
        $line
    }

    $env.config = ($env.config | default [] keybindings)
    $env.config = (
        $env.config | upsert keybindings (
            $env.config.keybindings
            | append [
                # Ctrl-T to insert a fzf result (filtered to cwd) into the line 
                # editor
                {
                    name: fzf_insert_cwd
                    modifier: control
                    keycode: char_t
                    mode: [emacs vi_normal vi_insert]
                    event: {
                        send: executehostcommand
                        cmd: (build-cmd-line-edit false $has_es)
                    }
                }

                # Ctrl-Y to insert a fzf result (all files) into the line editor
                {
                    name: fzf_insert_root
                    modifier: control
                    keycode: char_y
                    mode: [emacs vi_normal vi_insert]
                    event: {
                        send: executehostcommand
                        cmd: (build-cmd-line-edit true $has_es)
                    }
                }
            ]
        )
    )
}

# generated scripts
source starship_init.nu
source atuin_init.nu
source zoxide_init.nu
source carapace_init.nu

# do this again, just in case the above scripts have added new paths
clean_path

# mkdir ($nu.data-dir | path join "vendor/autoload")
# starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")