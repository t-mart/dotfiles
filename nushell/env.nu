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
# QUIRK: Due to nushell's must-already-exist requirement for sourced files, it
# must be manually created *before* is Nushell is run because source paths are
# compile-time checked. Therefore, there is no way to gracefully handle/detect
# this -- the parse will just fail.
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
    mkdir $local_bin  # ensure exists, and no-op if already exists
    path add $local_bin
}

# Return true if the tool named `name` is installed on the system.
def is-installed [
    name: string,  # the name of the tool
]: nothing -> bool {
    (which $name | length) > 0
}

## pyenv ##
# pyenv is a python version manager that installs python versions in user space
# and makes them 
if ("~/.pyenv" | path exists) {
    path add "~/.pyenv/bin"
    path add $"(pyenv root)/shims"
}

## cargo ##
# Cargo is rust's package manager.
if ("~/.cargo" | path exists) {
    path add "~/.cargo/bin"
}

## fnm ##
# Fast and simple Node.js version manager, built in Rust
# We put this after cargo because it might be installed with cargo
if (is-installed fnm) {
    # thanks to this guy https://github.com/Schniz/fnm/issues/463#issuecomment-1321140065
    ^fnm env --json | from json | load-env
}

## snap ##
# Snap is a package manager for linux
if ("/snap/bin" | path exists) {
    path add "/snap/bin"
}

# code-insiders preferred
# TODO: wait for conditional aliasing and only do this if code-insiders is
# installed: https://github.com/nushell/nushell/discussions/7505
alias code = code-insiders

# systemd aliases. ditto on conditional aliases.
alias scstart = systemctl start
alias scstop = systemctl stop
alias screstart = systemctl restart
alias scdr = systemctl daemon-reload
alias scstatus = systemctl status
alias jctl = journalctl --unit
alias jctlf = journalctl --follow --unit

# rotz updater: pull latest dotfiles and link them into the home directory
def rotzup []: nothing -> nothing {
    if (is-installed rotz) and (is-installed git) and ($nu.home-path | path join ".dotfiles" | path exists) {
        git -C ($nu.home-path | path join ".dotfiles") pull
        rotz link
    } else {
        "rotz or git not installed, or ~/.dotfiles does not exist" | print
    }
}

# Expand (to absolute paths) and dedupe and expand the OS's path variable
def --env clean_path []: nothing -> nothing {
    let path_name = if "PATH" in $env { "PATH" } else { "Path" }
    load-env {
        $path_name: (
        $env
            | get $path_name
            | split row (char esep)
            | filter { path exists }
            | path expand --no-symlink
            | uniq
        )
    }
}

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands
#   (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s|
            $s | split row (char esep) | path expand --no-symlink
        }
        to_string: { |v|
            $v | path expand --no-symlink | str join (char esep)
        }
    }
    "Path": {
        from_string: { |s|
            $s | split row (char esep) | path expand --no-symlink
        }
        to_string: { |v| 
            $v | path expand --no-symlink | str join (char esep)
        }
    }
}

# A place to put scripts generated by tools
$env.GENERATED_SCRIPTS_DIR = (
    $nu.default-config-dir | path join 'scripts_generated'
)
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
    ($nu.default-config-dir | path join 'plugins')
]

# Put scoop shims at the front of the $env.Path (on Windows). This specifically
# allows us to prefer these shim executables over Windows-built-in executables,
# like curl.
if ($nu.os-info.name) == "windows" {
    let scoop_shims = ("~/scoop/shims" | path expand)
    # only if it's in the path already
    if $scoop_shims in ($env.Path | split row (char esep) | path expand) {
        # this will prepend it, making it appear twice (and we will dedupe at
        # end of file)
        path add $scoop_shims
    }
}

# Like `is-installed`, but also prints a warning if the tool is not installed at
# a frequency of at most once a day.
def is-installed-warn [
    name: string,  # the name of the tool
]: nothing -> bool {
    let warn_path = ($env.XDG_CACHE_HOME | path join $"nu_warn_($name)")
    if (is-installed $name) {
        rm --force $warn_path  # remove dangling warning file
        true
    } else {
        # show a warning at most once a day if a tool is not installed.
        let doesnt_exist = not ($warn_path | path exists)
        let too_old = {|p| (date now) - (ls $p).modified.0 > 1day}
        if $doesnt_exist or (do $too_old $warn_path) {
            $"The nushell config wants to use `($name)`, but is not installed" |
                print

            "Marker file, can be deleted.\n" | save --force $warn_path
        }
        false
    }
}

# Initialize a tool named `name`, or more specifically, iff `name` is present on
# the system, load the environment variables in `env_record` and save the output
# of the `init_cmd` to file in `$env.GENERATED_SCRIPTS_DIR` / `<name>_init.nu` 
# (to be sourced later in config.nu).
#
# This command uses `which` on `$name` to check if the tool is installed. 
# Therefore, it must be present in your PATH variable.
#
# Of particular note, `env_record` is applied *before* `init_cmd` is run. This
# can be helpful if `init_cmd` behaves differently based on environment
# variables.
def --env init-tool [
    name: string,             # the name of the tool (will be checked with
                              # `which`)
    init_cmd: closure,        # the command to run to initialize the tool iff
                              # the tool is installed
    env_record: record = {},  # An optional record of environment variables to 
                              # set iff the tool is installed
]: nothing -> nothing {

    if (is-installed-warn $name) {
        # first load environment
        $env_record | load-env

        # then pipe forward init command output
        do $init_cmd
    } else {
        # placeholder contents, so that the `source` command doesn't fail in
        # config.nu
        $"# Placeholder for the not-yet-installed `($name)` init script\n"
    } | save -f ($env.GENERATED_SCRIPTS_DIR | path join $"($name)_init.nu")
}

## starship ##
# The minimal, blazing-fast, and infinitely customizable prompt for any shell!
# https://starship.rs/
init-tool starship {
    starship init nu
} {
    # these characters show up in certain modes. note: some complex codepoints
    # (non-ascii) render with wrong spacing in vscode terminal. try to keep
    # simple.
    PROMPT_INDICATOR_VI_INSERT: $'(ansi green_bold)+(ansi reset) '
    PROMPT_INDICATOR_VI_NORMAL: $'(ansi yellow_bold)Δ(ansi reset) '
    PROMPT_MULTILINE_INDICATOR: $'(ansi grey)↵(ansi reset) '
}

## atuin ##
# Atuin replaces your existing shell history with a SQLite database
#
# https://docs.atuin.sh/
#
# Press Ctrl-R to bring up interactive history search. Type query and/or
# navigate with arrow keys or Ctrl-P/Ctrl-N.
init-tool atuin {
    # --disable-up-arrow: disable up arrow key to navigate history, but retain
    # Ctrl-R.
    atuin init nu --disable-up-arrow
}

## zoxide ##
# zoxide is a smarter cd command, inspired by z and autojump
#
# https://github.com/ajeetdsouza/zoxide
#
# Use `cd` (a rebinding of the zoxide's default `z` command) to navigate to
# directories.
# Use `cdi` (ditto, but for `zi`) to bring up a menu. Use arrow keys or
# Ctrl-P/Ctrl-N to navigate.
init-tool zoxide {
    mkdir $env._ZO_DATA_DIR
    zoxide init nushell --cmd cd
} {
    _ZO_DATA_DIR: ($env.XDG_DATA_HOME | path join "zoxide")
}

## carapace ##
# Carapace-bin provides argument completion for multiple CLI commands
#
# https://github.com/carapace-sh/carapace-bin
#
# Press tab to get completions after typing a command
init-tool carapace {
    carapace _carapace nushell
} {
    # use completions from other shells
    CARAPACE_BRIDGES: 'zsh,fish,bash,inshellisense'

    # don't leak carapace's get-env, set-env and unset-env functions
    CARAPACE_ENV: 0
}

# do this last to ensure its effects
clean_path
