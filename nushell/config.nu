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


## fnm - part 2 ##
# i hate this. see, fnm does a check if $env.FNM_MULTISHELL_PATH is present in $PATH and
# emits a scary warning if not. i would use std's `path add` function for this,
# but the implementation of it does a `path expand` on the input (i.e. it mutates it!). in this case,
# this is BAD because the path entry fnm wants gets expanded to some other
# path (its like a symlink or something). and it does this for each entry.
# and i use `path add` all over the place. so, i do this RIGHT AT THE END, the
# hard way, so no other `path add` gets in the way. I should PR 
# https://github.com/nushell/nushell/blob/46ed69ab126015375d5163972ae321715f34874b/crates/nu-std/std/mod.nu#L83
if (is-installed fnm) {
    let path_name = if "PATH" in $env { "PATH" } else { "Path" }

    let fnm_path = if ($nu.os-info.name) == "windows" {
        $env.FNM_MULTISHELL_PATH
    } else {
        $env.FNM_MULTISHELL_PATH | path join "bin"
    }

    load-env {$path_name: (
        $env
            | get $path_name
            | split row (char esep)
            | prepend $fnm_path
    )}
}
