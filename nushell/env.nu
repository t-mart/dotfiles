# Nushell Environment Config File

# use nu standard library
use std *

# `~/.profile.nu` is for nushell configuration that is *not* source-controlled.
# It is useful for things that are local to this user or this machine. Examples
# include `PATH` modifications or any other environment variable. This is not a
# standard Nushell convention -- it is of my own design.
#
# Its name is modeled after the `.profile` file for bash.
#
# QUIRK: Due to nushell's must-already-exist requirement for sourced files, it must
# be manually created *before* is Nushell is run. Nushell does not currently support
# a way to detect if a file exists before sourcing it, so there is no way to print
# a helpful message: the parse will just fail.
source-env ($nu.home-path | path join ".profile.nu")

# XDG env vars
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
{
    XDG_CACHE_HOME: ($nu.home-path | path join ".cache"),
    XDG_CONFIG_HOME: ($nu.home-path | path join ".config"),
    XDG_DATA_HOME: ($nu.home-path | path join ".local" "share"),
    XDG_STATE_HOME: ($nu.home-path | path join ".local" "state"),
} | items { |name, path|
    # use the existing path if it's already set
    let path = ($env | get --ignore-errors $name | default $path)
    mkdir $path
    {
        name: $name,
        path: $path
    }
} | transpose --ignore-titles -d -r | load-env

# Add .local/bin (according to XDG spec)
export-env {
    let local_bin = ($nu.home-path | path join ".local" "bin")
    mkdir $local_bin
    path add $local_bin
}

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# A place to put scripts generated by tools
$env.GENERATED_SCRIPTS_DIR = ($nu.default-config-dir | path join 'scripts_generated')
mkdir $env.GENERATED_SCRIPTS_DIR

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # source-controlled scripts
    ($nu.default-config-dir | path join 'scripts')

    # tool-generated scripts
    $env.GENERATED_SCRIPTS_DIR
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# Put scoop shims at the front of the $env.Path (on Windows). This specifically
# allows us to prefer these shim executables over Windows-built-in executables,
# like curl.
if ($nu.os-info.name) == "windows" {
    let scoop_shims = ("~/scoop/shims" | path expand)
    # only if it's in the path already
    if $scoop_shims in ($env.Path | split row (char esep) | path expand) {
        # this will prepend it, making it appear twice (and we will dedupe at end of file)
        path add $scoop_shims
    }
}

# Return true if the tool named `name` is installed on the system.
def is-installed [
    name: string,
]: nothing -> bool {
    (which $name | length) > 0
}

# Initialize a tool named `name`, or more specifically, iff `name` is present on
# the system, load the environment variables in `env_record` and save the output of `init_cmd` to 
# file in `$env.GENERATED_SCRIPTS_DIR` / `<name>_init.nu`  (to be sourced later in
# config.nu).
#
# This command uses `which` on `$name` to check if the tool is installed. Therefore, it must
# be present in your PATH variable.
def --env init [
    name: string,             # the name of the tool (will be checked with `which`)
    init_cmd: closure,        # the command to run to initialize the tool iff the tool is installed
    env_record: record = {},  # An optional record of environment variables to set iff the tool is installed
]: nothing -> nothing {
    let warn_path = ($env.XDG_CACHE_HOME | path join $"nu_warn_($name)")
    if (is-installed $name) {
        $env_record | load-env
        rm --force $warn_path  # remove dangling warning file
        
        # this must be last: it's our script output
        do $init_cmd
    } else {
        # show a warning once a day if a tool is not installed.
        # exists? | age > 1day? | result
        # T       | T           | warn & touch
        # T       | F           | (noop)
        # F       | T           | warn & touch
        # F       | F           | warn & touch
        if (not ($warn_path | path exists)) or (date now) - (ls $warn_path).modified.0 > 1day {
            print $"The loaded nushell config wants to use `($name)`, but is not installed."
            "This is a marker file to prevent this warning from showing up too often.\n" | save --force $warn_path
        }

        # placeholder contents, so that the `source` command doesn't fail in config.nu
        $"# This is a placeholder for the ($name) init script, which is not yet installed.\n"
    } | save -f ($env.GENERATED_SCRIPTS_DIR | path join $"($name)_init.nu")
}

## STARSHIP ##
# The minimal, blazing-fast, and infinitely customizable prompt for any shell!
# https://starship.rs/
init starship {
    starship init nu
} {
    # these characters show up in certain modes. note: some complex codepoints (non-ascii)
    # render with wrong spacing in vscode terminal. try to keep simple.
    PROMPT_INDICATOR_VI_INSERT: $'(ansi green_bold)+(ansi reset) '
    PROMPT_INDICATOR_VI_NORMAL: $'(ansi yellow_bold)Δ(ansi reset) '
    PROMPT_MULTILINE_INDICATOR: $'(ansi grey)↵(ansi reset) '
}

## ATUIN ##
# Atuin replaces your existing shell history with a SQLite database
# https://docs.atuin.sh/
# Press Ctrl-R to bring up interactive history search. Type query and/or
# navigate with arrow keys or Ctrl-P/Ctrl-N.
init atuin {
    # --disable-up-arrow: disable up arrow key to navigate history, but retain
    # Ctrl-R.
    atuin init nu --disable-up-arrow
}

## ZOXIDE ##
# zoxide is a smarter cd command, inspired by z and autojump
# https://github.com/ajeetdsouza/zoxide
# Use `cd` (a rebinding of the zoxide's default `z` command) to navigate to
# directories.
# Use `cdi` (ditto, but for `zi`) to bring up a menu. Use arrow keys or
# Ctrl-P/Ctrl-N to navigate.
init zoxide {
    mkdir $env._ZO_DATA_DIR
    zoxide init nushell --cmd cd
} {
    _ZO_DATA_DIR: ($env.XDG_DATA_HOME | path join "zoxide")
}

## CARAPACE ##
# Carapace-bin provides argument completion for multiple CLI commands
# https://github.com/carapace-sh/carapace-bin
# Press tab to get completions after typing a command
init carapace {
    carapace _carapace nushell
} {
    CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'
}

# Dedupe and expand the path variable
def --env dedupe_and_expand_path []: nothing -> nothing {
    let path_name = if "PATH" in $env { "PATH" } else { "Path" }
    load-env {
        $path_name: (
        $env
            | get $path_name
            | split row (char esep)
            | path expand
            | uniq
        )
    }
}

# do this last to ensure its effects
dedupe_and_expand_path
