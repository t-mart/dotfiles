# The one-line greeting printed at the top of a login shell.
#
# Lines come from two places: the keybindings in $env.config, and the hints in
# the pacman package lists. Writing a hint in either place adds a line here.
#
# $env.config is read when the greeting is built rather than when this module
# is imported, so the import can sit anywhere but the call has to come after
# $env.config is set.
#
# Named `main` because a module can't export a command sharing its own name.
# Importing this module as `use lib/motd.nu *` binds it as `motd`.

use packages.nu [package-hints]

# what each of our keybindings does, keyed by the binding's name. only the
# description lives here: the key combination itself is read back out of
# $env.config, so it can't drift from what is actually bound. write it as a verb
# phrase completing "Press <keys> to ...", the same way a package hint completes
# "Use <command> to ...".
const KEYBINDING_DOCS = {
  fzf_insert_file: "insert a file path from the current directory (alt+a inside fzf widens the search to the home directory)"
}

# our keybindings as MOTD lines. a binding with no description is left out, the
# same way a package without a hint is.
def keybinding-hints []: nothing -> list<string> {
  $env.config.keybindings
  | where {|binding| ($KEYBINDING_DOCS | get --optional $binding.name) != null }
  | each {|binding|
    let modifiers = $binding.modifier
    | str lowercase
    | split row '_'
    | str replace 'control' 'ctrl'

    let key = $binding.keycode | str lowercase | str replace --regex '^char_' ''
    let combo = $modifiers | append $key | str join '+'

    $"Press (ansi green_bold)($combo)(ansi reset) to ($KEYBINDING_DOCS | get --optional $binding.name)."
  }
}

# One line to greet you with, chosen at random from our keybindings and from the
# hints in the pacman package lists. Writing a hint in either place adds a line
# here.
export def main []: nothing -> string {
  let lines = keybinding-hints
  | append (package-hints | each {|pkg| $"Use (ansi green_bold)($pkg.command)(ansi reset) to ($pkg.hint)." })

  if ($lines | is-empty) {
    return ""
  }

  # `hint:` follows the lowercase diagnostic prefix that cargo and friends use.
  # dark_gray is the terminal's color8, so it picks up the gruvbox palette from
  # kitty rather than hardcoding a shade here.
  $"(ansi dark_gray)hint:(ansi reset) ($lines | shuffle | first)"
}
