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

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
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


## ATUIN CONFIG ##
$env.ATUIN_NOBIND = true
source ~/.local/share/atuin/init.nu

## STARSHIP CONFIG ##
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


## CARAPACE CONFIG ##
let carapace_completer = {|spans|
  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1)
  } else {
    $spans
  })

  carapace $spans.0 nushell ...$spans
  | from json
}

mut current = (($env | default {} config).config | default {} completions)
$current.completions = ($current.completions | default {} external)
$current.completions.external = ($current.completions.external
| default true enable
| default $carapace_completer completer)

$env.config = $current
