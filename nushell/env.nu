# Nushell Environment Config File
#
# version = "0.92.2"

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

# A place to put vendor scripts (see usage below)
$env.NU_LIB_VENDOR_DIR = ($nu.default-config-dir | path join 'scripts' 'vendor')
mkdir $env.NU_LIB_VENDOR_DIR

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    $env.NU_LIB_VENDOR_DIR
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# Put scoop shims at the front of the $env.Path (on Windows). This specifically
# allows us to prefer these shim executables over Windows-built-in executables,
# like curl.
if ($nu.os-info.family) == "windows" {
    let scoop_shims = ("~/scoop/shims" | path expand)
    if $scoop_shims in $env.Path {
        $env.Path = ($env.Path | split row (char esep) | prepend $scoop_shims | uniq)
    }
}

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

## PROMPT CONFIG ##
def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# these characters show up in certain modes. note: some complex codepoints (non-ascii)
# render with wrong spacing in vscode terminal. try to keep simple.
$env.PROMPT_INDICATOR_VI_INSERT = $'(ansi green_bold)+(ansi reset) '
$env.PROMPT_INDICATOR_VI_NORMAL = $'(ansi yellow_bold)Δ(ansi reset) '
$env.PROMPT_MULTILINE_INDICATOR = $'(ansi grey)↵(ansi reset) '

# Check if a program is installed
def is-installed [
    app: string  # the name of the app to check
] {
  ((which $app | length) > 0)
}

## ATUIN ##
# Atuin replaces your existing shell history with a SQLite database
# https://docs.atuin.sh/
# Press up or Ctrl-R to bring up interactive history search. Type query and/or
# navigate with arrow keys or Ctrl-P/Ctrl-N.
if (is-installed "atuin") {
    atuin init nu | save -f ($env.NU_LIB_VENDOR_DIR | path join "atuin_init.nu")
}

## ZOXIDE ##
# zoxide is a smarter cd command, inspired by z and autojump
# https://github.com/ajeetdsouza/zoxide
# Use `cd` (a rebinding of the zoxide's default `z` command) to navigate to
# directories.
# Use `cdi` (ditto, but for `zi`) to bring up a menu. Use arrow keys or
# Ctrl-P/Ctrl-N to navigate.
if (is-installed "zoxide") {
    zoxide init nushell --cmd cd | save -f ($env.NU_LIB_VENDOR_DIR | path join "zoxide_init.nu")
    $env._ZO_DATA_DIR = ($env.XDG_DATA_HOME | path join "zoxide")
    mkdir $env._ZO_DATA_DIR
}

## CARAPACE ##
# Carapace-bin provides argument completion for multiple CLI commands
# https://github.com/carapace-sh/carapace-bin
# Press tab to get completions after typing a command
if (is-installed "carapace") {
    carapace _carapace nushell | save -f ($env.NU_LIB_VENDOR_DIR | path join "carapace_init.nu")
}
