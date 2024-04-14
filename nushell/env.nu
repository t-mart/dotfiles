# Nushell Environment Config File

# use nu standard library
use std *

# XDG defaults, if not already set
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
{
    XDG_CACHE_HOME: ($nu.home-path | path join ".cache"),
    XDG_CONFIG_HOME: ($nu.home-path | path join ".config"),
    XDG_DATA_HOME: ($nu.home-path | path join ".local" "share"),
    XDG_STATE_HOME: ($nu.home-path | path join ".local" "state"),
} | items { |name, value|
    {
        name: $name,

        # use the existing value if it's already set
        value: ($env | get --ignore-errors $name | default $value)
    }
} | transpose --ignore-titles -d -r | load-env

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

# A place to put local scripts (local to this machine/user) that aren't version controlled.
# Of specific note, we create a local_env.nu file here, and `source-env` it by default in
# config.nu. Other scripts will need to be manually `source`d.
$env.LOCAL_SCRIPTS_DIR = ($nu.default-config-dir | path join 'local_env')
mkdir $env.LOCAL_SCRIPTS_DIR
do {
    let local_env_file = ($env.LOCAL_SCRIPTS_DIR | path join 'local_env.nu')
    if not ($local_env_file | path exists) {
        [
            "# This file is for setting environment variables local to this user/machine."
            "# E.g.:"
            "#   use std \"path add\"  # to use path add command"
            "#   path add /some/path"
            ""
        ] | str join "\n" | save $local_env_file
    }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    # source-controlled scripts
    ($nu.default-config-dir | path join 'scripts')

    # local scripts
    $env.LOCAL_SCRIPTS_DIR

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
    if $scoop_shims in $env.Path {
        $env.Path = ($env.Path | split row (char esep) | prepend $scoop_shims | uniq)
    }
}

# Initialize a tool named `name`, or more specifically, iff `name` is present on
# the system, load the environment variables in `env_record` and save the output of `init_cmd` to 
# file in `$env.GENERATED_SCRIPTS_DIR` / `<name>_init.nu`  (to be sourced later in
# config.nu).
#
# Note that `env_record` is loaded into the environment before the `init_cmd` is run.
# This allows you to set environment variables that the `init_cmd` might need.
def --env init [
    name: string,             # the name of the tool
    init_cmd: closure,        # the command to run to initialize the tool
    env_record: record = {},  # An optional record of environment variables to set
                              # before running the init command
] {
    let warn_path = ($env.XDG_CACHE_HOME | path join $"nu_warn_($name)")
    if ((which $name | length) > 0) {
        $env_record | load-env
        do $init_cmd
        rm --force $warn_path
    } else {
        # show a warning once a day if a tool is not installed.
        # exists? | age > 1day? | result
        # T       | T           | warn & touch
        # T       | F           | (noop)
        # F       | T           | warn & touch
        # F       | F           | warn & touch
        if (not ($warn_path | path exists)) or (date now) - (ls $warn_path).modified.0 > 1day {
            print $"The loaded Nu configs want to use ($name), but is not installed."
            "This is a marker file to prevent this warning from showing up too often.\n" | save --force $warn_path
        }

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
# Press up or Ctrl-R to bring up interactive history search. Type query and/or
# navigate with arrow keys or Ctrl-P/Ctrl-N.
init atuin {
    atuin init nu
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
}
