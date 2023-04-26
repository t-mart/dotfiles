# Nushell Environment Config File
#
# version = 0.79.1

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

def create_right_prompt [] {
    # let time_segment = ([
    #     (ansi reset)
    #     (ansi magenta)
    #     (date now | date format '%m/%d/%Y %r')
    # ] | str join)
    #
    # let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
    #     (ansi rb)
    #     ($env.LAST_EXIT_CODE)
    # ] | str join)
    # } else { "" }
    #
    # ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = {|| create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = {|| "> " }
let-env PROMPT_INDICATOR_VI_INSERT = {|| ": " }
let-env PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
let-env PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
# let-env NU_LIB_DIRS = [
#     ($nu.default-config-dir | path join 'scripts')
# ]
#
# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
# let-env NU_PLUGIN_DIRS = [
#     ($nu.default-config-dir | path join 'plugins')
# ]

if not 'PATH' in $env and 'Path' in $env {
  let-env PATH = $env.Path
}

