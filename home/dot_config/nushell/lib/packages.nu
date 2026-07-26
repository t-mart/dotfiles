# Reading the pacman package lists that chezmoi installs from.
#
# The lists live in the chezmoi working tree, not in the deployed home
# directory, so they are only readable on a machine that still has its chezmoi
# checkout. Everything here degrades to an empty list when that isn't the case.

# where chezmoi keeps the pacman package lists
def package-lists-dir []: nothing -> string {
  $nu.home-dir | path join .local share chezmoi data packagelists pacman
}

# The packages in a list that we've written a hint for, as {command, hint}
# records. Entries without a hint aren't CLI tools worth surfacing.
#
# Entries are dropped when neither their package nor their command resolves, so
# a list that isn't installed on this machine contributes nothing. We check both
# names because a command can be a shell definition rather than a binary (zoxide
# gives us `cdi`), while its package is still on PATH under its own name.
export def package-hints [list_name: string = base]: nothing -> table {
  let list_file = (package-lists-dir) | path join $"($list_name).yml"
  if not ($list_file | path exists) {
    return []
  }

  # a malformed list shouldn't stop a shell from starting
  try { open $list_file } catch { [] }
  | where {|entry| ($entry | describe | str starts-with record) and ($entry.hint? != null) }
  | where {|entry| which $entry.package ($entry.command? | default $entry.package) | is-not-empty }
  | each {|entry| {command: ($entry.command? | default $entry.package), hint: $entry.hint} }
}
