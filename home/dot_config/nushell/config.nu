# Nushell Config File

use std *

alias cz = chezmoi
alias less = bat
# bat is smart about styling/paging when in a non-interactive tty, such as when piping
alias cat = bat

$env.config.buffer_editor = "code"
$env.EDITOR = "code"
$env.VISUAL = "code"
$env.PAGER = "bat"

def --env add-path-if-exists [
  dir: string,
]: nothing -> nothing {
  if ($dir | path exists) {
    path add $dir
  }
}

add-path-if-exists ($nu.home-path | path join ".local" "bin")
add-path-if-exists ($nu.home-path | path join ".local" "share" "bin")
add-path-if-exists ($nu.home-path | path join "bin")
add-path-if-exists ($nu.home-path | path join ".cargo" "bin")
add-path-if-exists ($nu.home-path | path join "scoop" "shims")

## TODO: deno offers bash completions, which we might be able to bring in with carapace
add-path-if-exists ($nu.home-path | path join ".deno" "bin")

let pnpm_home_path = "/root/.local/share/pnpm"
if ($pnpm_home_path | path exists) {
    $env.PNPM_HOME = $pnpm_home_path
    path add $env.PNPM_HOME
}

let bun_install_path = ($nu.home-path | path join ".bun")
if ($bun_install_path | path exists) {
    $env.BUN_INSTALL = $bun_install_path
    path add ($env.BUN_INSTALL | path join "bin")
}

let local_vendor_autoload_path = ($nu.data-dir | path join "vendor" "autoload")
mkdir $local_vendor_autoload_path

# starship, a cross-shell prompt
# https://starship.rs/
$env.PROMPT_INDICATOR_VI_INSERT = $'(ansi green_bold)+(ansi reset) '
$env.PROMPT_INDICATOR_VI_NORMAL = $'(ansi yellow_bold)Δ(ansi reset) '
$env.PROMPT_MULTILINE_INDICATOR = $'(ansi grey)↵(ansi reset) '
starship init nu | save --force ($local_vendor_autoload_path | path join "starship.nu")

# carapace, a shell completion
# https://carapace.sh/
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
# NOTE: we don't use the default carapace init because:
# - we it doesn't allow selective completion based on command
# - it can throw these "ERR unknown shorthand flag" errors
# carapace _carapace nushell | save --force ($local_vendor_autoload_path | path join "carapace.nu")

# fzf, a command-line fuzzy finder
# https://junegunn.github.io/fzf/
# TODO?: set up with carapace, e.g. `fzf --bash`

# atuin, a shell history manager
# https://atuin.sh/
atuin init nu --disable-ctrl-r | save --force ($local_vendor_autoload_path | path join "atuin.nu")

# zoxide, a smart cd command
# https://zoxide.dev/
zoxide init nushell --cmd cd | save --force ($local_vendor_autoload_path | path join "zoxide.nu")

# from https://www.nushell.sh/cookbook/external_completers.html#err-unknown-shorthand-flag-using-carapace
# let fish_completer = ...
let carapace_completer = {|spans: list<string>|
  # if the current command is an alias, get it's expansion
  let expanded_alias = (scope aliases | where name == $spans.0 | get -i 0 | get -i expansion)

  # overwrite
  let spans = (if $expanded_alias != null  {
    # put the first word of the expanded alias first in the span
    $spans | skip 1 | prepend ($expanded_alias | split row " " | take 1 | str replace --regex  '\.exe$' '')
  } else {
    $spans | skip 1 | prepend ($spans.0 | str replace --regex  '\.exe$' '')
  })

  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# This completer will use carapace by default
let external_completer = {|spans|
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -i 0.expansion

  let spans = if $expanded_alias != null {
    $spans
    | skip 1
    | prepend ($expanded_alias | split row ' ' | take 1)
  } else {
    $spans
  }

  match $spans.0 {
    # carapace completions are incorrect for nu
    # nu => $fish_completer
    # fish completes commits and branch names in a nicer way
    # git => $fish_completer
    # carapace doesn't have completions for asdf
    # asdf => $fish_completer
    _ => $carapace_completer
  } | do $in $spans
}

# fzf stuff
# https://github.com/junegunn/fzf/issues/4122#issuecomment-2607368316
# TODO: make another file searcher for all files (not just those under current directory)

$env.FZF_ALT_C_COMMAND = "fd --type directory --hidden"
$env.FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -n 200'"
$env.FZF_CTRL_T_COMMAND = "fd --type file --hidden"
$env.FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=full --line-range=:500 {}' "
$env.FZF_DEFAULT_COMMAND = "fd --type file --hidden"

const alt_c = {
    name: fzf_dirs
    modifier: alt
    keycode: char_c
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let fzf_alt_c_command = \$\"($env.FZF_ALT_C_COMMAND) | fzf ($env.FZF_ALT_C_OPTS)\";
          let result = nu -c $fzf_alt_c_command;
          cd $result;
        "
      }
    ]
}

# History
const ctrl_r = {
  name: history_menu
  modifier: control
  keycode: char_r
  mode: [emacs, vi_insert, vi_normal]
  event: [
    {
      send: executehostcommand
      cmd: "
        let result = history
          | get command
          | str replace --all (char newline) ' '
          | to text
          | fzf --preview 'printf \'{}\' | nufmt --stdin 2>&1 | rg -v ERROR';
        commandline edit --append $result;
        commandline set-cursor --end
      "
    }
  ]
}

# Files
const ctrl_t =  {
    name: fzf_files
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: [
      {
        send: executehostcommand
        cmd: "
          let fzf_ctrl_t_command = \$\"($env.FZF_CTRL_T_COMMAND) | fzf ($env.FZF_CTRL_T_OPTS)\";
          let result = nu -l -i -c $fzf_ctrl_t_command;
          commandline edit --append $result;
          commandline set-cursor --end
        "
      }
    ]
}

$env.config = {
  show_banner: false
  edit_mode: vi
  completions: {
    external: {
      enable: true
      completer: $external_completer
    }
  }
  keybindings: [
    # $alt_c
    # $ctrl_r
    $ctrl_t
  ]
}

# LS_COLORS of the [ayu](https://github.com/ayu-theme) theme generated by 
# [vivid](https://github.com/sharkdp/vivid)
$env.LS_COLORS = ^vivid generate ayu
