# Nushell Config File

source colors.nu

use std *

alias cz = chezmoi
alias less = bat
# bat is smart about styling/paging when in a non-interactive tty, such as when piping
alias cat = bat

$env.config.buffer_editor = "code"
$env.EDITOR = "code"
$env.VISUAL = "code"
$env.PAGER = "bat"
$env.MANPAGER = r#'sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman''#

def --env add-path-if-exists [
  dir: string,
]: nothing -> nothing {
  if ($dir | path exists) {
    path add $dir
  }
}

def 'is-installed' [ app: string ] {
  ((which $app | length) > 0)
}

def 'on-windows' []: nothing -> bool {
  if (version | get build_os | str starts-with "windows") {
    true
  } else {
    false
  }
}

def 'quote-path' []: string -> string {
  if ($in | str index-of ' ') == -1 {
    $in
  } else {
    $"`($in)`"
  }
}

add-path-if-exists ($nu.home-path | path join ".local/bin")
add-path-if-exists ($nu.home-path | path join ".local/share/bin")
add-path-if-exists ($nu.home-path | path join "bin")
add-path-if-exists ($nu.home-path | path join ".cargo/bin")
add-path-if-exists ($nu.home-path | path join "scoop/shims")
add-path-if-exists ($env.LOCALAPPDATA | path join "Programs/oh-my-posh/bin")
add-path-if-exists ($nu.home-path | path join ".deno/bin")

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
# $env.PROMPT_INDICATOR_VI_INSERT = $'(ansi green_bold)+(ansi reset) '
# $env.PROMPT_INDICATOR_VI_NORMAL = $'(ansi yellow_bold)Δ(ansi reset) '
# $env.PROMPT_MULTILINE_INDICATOR = $'(ansi grey)↵(ansi reset) '
# starship init nu | save --force ($local_vendor_autoload_path | path join "starship.nu")

# atuin, a shell history manager
# https://atuin.sh/
atuin init nu | save --force ($local_vendor_autoload_path | path join "atuin.nu")

# zoxide, a smart cd command
# https://zoxide.dev/
# we tell zoxide to work on the `cd` command, overriding the default. thusly,
# to use zoxide in interactive mode, use `cdi`
zoxide init nushell --cmd cd | save --force ($local_vendor_autoload_path | path join "zoxide.nu")

# carapace, a shell completion
# https://carapace.sh/
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
# NOTE: we don't use the default carapace init because:
# - we it doesn't allow selective completion based on command
# - it can throw these "ERR unknown shorthand flag" errors
# carapace _carapace nushell | save --force ($local_vendor_autoload_path | path join "carapace.nu")

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

# fzf
# https://github.com/junegunn/fzf
#
# this fzf config calls out to a few other programs, which we expect to be
# installed from our chezmoi scripts:
#
# - fd, a cross-platform file finder, which we use to find files and directories
# - es, a windows file finder, which is significantly faster than fd because it 
#   reads from the NTFS MFT (it is slower to start up, though)
# - tree, from rust crate `rust_tree`, which we use to preview directory
#   structure
# - bat, a cat replacement with syntax highlighting, which we use to preview
#   files
#
# Nushell reference: https://github.com/junegunn/fzf/issues/4122#issuecomment-2607368316

$env.FZF_DEFAULT_OPTS = "--style full"

# fzf keybindings
$env.KB_FZF_CD_CWD_COMMAND = "fd --type directory --hidden"
$env.KB_FZF_CD_ALL_COMMAND = if (on-windows) { 
  "es folder:" # directories only
} else {
  "fd --type directory --hidden . \$\"(pwd | path parse | get prefix)/\""
}
$env.KB_FZF_CD_OPTS = "--preview 'tree --color --classify --level 3 {} | head -n 200'"
$env.KB_FZF_FIND_FILES_CWD_COMMAND = "fd --type file --hidden"
$env.KB_FZF_FIND_FILES_ALL_COMMAND = if (on-windows) { 
  "es"
} else {
  "fd --hidden . \$\"(pwd | path parse | get prefix)/\""
}
$env.KB_FZF_FIND_FILES_OPTS = "--preview 'bat --color=always --style=full --line-range=:500 {}' "
$env.KB_FZF_DEFAULT_OPTS = "--scheme=path"

# cd to directories under current directory
const fzf_cd_cwd_keybinding = {
  name: fzf_dirs
  modifier: alt
  keycode: char_c
  mode: [emacs, vi_normal, vi_insert]
  event: [
    {
      send: executehostcommand
      cmd: "
        let fzf_cd_cwd_command = \$\"($env.KB_FZF_CD_CWD_COMMAND) | fzf ($env.KB_FZF_DEFAULT_OPTS) ($env.KB_FZF_CD_OPTS)\";
        let result = nu -c $fzf_cd_cwd_command;
        cd $result;
      "
    }
  ]
}

# cd to directories anywhere
const fzf_cd_all_keybinding = {
  name: fzf_dirs
  modifier: alt
  keycode: char_v
  mode: [emacs, vi_normal, vi_insert]
  event: [
    {
      send: executehostcommand
      cmd: "
        let fzf_cd_all_command = \$\"($env.KB_FZF_CD_ALL_COMMAND) | fzf ($env.KB_FZF_DEFAULT_OPTS) ($env.KB_FZF_CD_OPTS)\";
        let result = nu -c $fzf_cd_all_command;
        cd $result;
      "
    }
  ]
}

# insert files from under current directory
const fzf_find_files_cwd_keybinding =  {
  name: fzf_files
  modifier: alt
  keycode: char_n
  mode: [emacs, vi_normal, vi_insert]
  event: [
    {
      send: executehostcommand
      cmd: '
        let fzf_find_files_cwd_command = $"($env.KB_FZF_FIND_FILES_CWD_COMMAND) | fzf ($env.KB_FZF_DEFAULT_OPTS) ($env.KB_FZF_FIND_FILES_OPTS)";
        let result = nu -l -i -c $fzf_find_files_cwd_command;
        commandline edit --append ($result | quote-path);
        commandline set-cursor --end
      '
    }
  ]
}

# insert files anywhere
const fzf_find_files_all_keybinding =  {
  name: fzf_files
  modifier: alt
  keycode: char_m
  mode: [emacs, vi_normal, vi_insert]
  event: [
    {
      send: executehostcommand
      cmd: "
        let fzf_find_files_all_command = \$\"($env.KB_FZF_FIND_FILES_ALL_COMMAND) | fzf ($env.KB_FZF_DEFAULT_OPTS) ($env.KB_FZF_FIND_FILES_OPTS)\";
        let result = nu -l -i -c $fzf_find_files_all_command;
        commandline edit --append ($result | quote-path);
        commandline set-cursor --end
      "
    }
  ]
}

# Remind keybindings when starting Nushell
if $env.SHLVL == 1 {
  print $"Some keybindings. Turn this message off when you know them!

  (ansi green_bold)Ctrl+R(ansi reset) to search command history \(or just (ansi green_bold)Up(ansi reset)\) \((ansi purple_italic)atuin(ansi reset)\)
  (ansi green_bold)Alt+C(ansi reset)  to change directory to a directory under the current directory \((ansi purple_italic)fzf(ansi reset)\)
  (ansi green_bold)Alt+V(ansi reset)  to change directory to a directory anywhere \((ansi purple_italic)fzf(ansi reset)\)
  (ansi green_bold)Alt+N(ansi reset)  to insert a file from the current directory \((ansi purple_italic)fzf(ansi reset)\)
  (ansi green_bold)Alt+M(ansi reset)  to insert a file from anywhere \((ansi purple_italic)fzf(ansi reset)\)
  "
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
    $fzf_cd_cwd_keybinding,
    $fzf_cd_all_keybinding,
    $fzf_find_files_cwd_keybinding,
    $fzf_find_files_all_keybinding
  ]
  color_config: {
    separator: white
    leading_trailing_space_bg: { attr: n }
    header: green_bold
    empty: blue
    bool: light_cyan
    int: white
    filesize: cyan
    duration: white
    datetime: purple
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cell-path: white
    row_index: green_bold
    record: white
    list: white
    closure: green_bold
    glob:cyan_bold
    block: white
    hints: dark_gray
    search_result: { bg: red fg: white }
    shape_binary: purple_bold
    shape_block: blue_bold
    shape_bool: light_cyan
    shape_closure: green_bold
    shape_custom: green
    shape_datetime: cyan_bold
    shape_directory: cyan
    shape_external: cyan
    shape_externalarg: green_bold
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_glob_interpolation: cyan_bold
    shape_globpattern: cyan_bold
    shape_int: purple_bold
    shape_internalcall: cyan_bold
    shape_keyword: cyan_bold
    shape_list: cyan_bold
    shape_literal: blue
    shape_match_pattern: green
    shape_matching_brackets: { attr: u }
    shape_nothing: light_cyan
    shape_operator: yellow
    shape_pipe: purple_bold
    shape_range: yellow_bold
    shape_record: cyan_bold
    shape_redirection: purple_bold
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_table: blue_bold
    shape_variable: purple
    shape_vardecl: purple
    shape_raw_string: light_purple
    shape_garbage: {
        fg: white
        bg: red
        attr: b
    }
  }
}

# LS_COLORS of the [ayu](https://github.com/ayu-theme) theme generated by 
# [vivid](https://github.com/sharkdp/vivid)
$env.LS_COLORS = ^vivid generate ayu

# this is supposed to be done last (might not matter)

$env.PROMPT_INDICATOR_VI_INSERT = $'(ansi green_bold)+(ansi reset) '
$env.PROMPT_INDICATOR_VI_NORMAL = $'(ansi yellow_bold)Δ(ansi reset) '
$env.PROMPT_MULTILINE_INDICATOR = $'(ansi grey)↵(ansi reset) '
oh-my-posh init nu --config $"($nu.home-path | path join ".config/oh-my-posh.yaml")"
