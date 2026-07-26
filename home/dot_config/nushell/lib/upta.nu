# Updating a fleet of machines over ssh.
#
# This half only decides which hosts to visit and how to present what they say.
# The update recipe itself lives in `upta-local`, which chezmoi deploys to every
# machine, so that a change to what updating means doesn't have to travel from
# whichever box happens to be driving.

use commands.nu [xdg]

# Commands run on each host, in order.
#
# `chezmoi update` goes first and on its own, so that the `upta-local` we call
# next is the copy that just landed rather than the one from the last run.
const UPTA_REMOTE_STEPS = [
    "~/.local/bin/chezmoi update --init --apply"
    "~/.local/bin/upta-local --skip-chezmoi"
]

# Colors that tell hosts apart in prefixed output. Red is deliberately absent
# so that red only ever means something went wrong.
const UPTA_HOST_COLORS = [
    green yellow blue magenta cyan
    light_green light_yellow light_blue light_magenta light_cyan
]

# Pair each host with the colored `hostname |` stamp that will front every line
# of its output.
#
# Names are padded to a common width so the stamps line up into two readable
# columns, and colors are dealt out by position so that neighbors never share.
export def upta-prefixes []: list<string> -> table<host: string, prefix: string> {
    let hosts = $in
    let width = $hosts | each {|host| $host | str length } | math max
    let color_count = $UPTA_HOST_COLORS | length

    $hosts | enumerate | each {|entry|
        let color = $UPTA_HOST_COLORS | skip ($entry.index mod $color_count) | first
        let name = $entry.item | fill --width $width --alignment left
        {
            host: $entry.item
            prefix: $"(ansi $color)($name) |(ansi reset) "
        }
    }
}

# The hosts `upta` updates by default, from $XDG_CONFIG_HOME/upta.yml.
export def upta-hosts []: nothing -> list<string> {
    let config_path = xdg config | path join upta.yml
    if not ($config_path | path exists) {
        return []
    }

    # a malformed list shouldn't take the whole command down
    try { open $config_path } catch { [] }
        | default []
        | each {|host| $host | str trim }
        | where {|host| $host | is-not-empty }
}

# Whether a host answers ssh.
#
# ssh rather than ping, because plenty of hosts sit behind a wall that drops
# ICMP while sshd is perfectly happy. BatchMode keeps a missing key from
# hanging on a password prompt.
def upta-reachable [host: string]: nothing -> bool {
    let result = ^ssh -o ConnectTimeout=5 -o BatchMode=yes $host true | complete
    $result.exit_code == 0
}

# Run one remote command, printing each line behind the host's prefix as it
# arrives. stdout and stderr are merged so the ordering matches what you would
# see sitting at the machine.
#
# No pseudo-terminal is asked for here. Prefixing means piping, and a piped
# prompt sits invisible in the line buffer because it carries no trailing
# newline, so a tty would buy nothing. Without one the tools also drop their
# progress bars and emit clean line-oriented output. Anything that might ask a
# question wants --raw.
def upta-run-prefixed [target: record, command: string]: nothing -> bool {
    try {
        for line in (^ssh -A $target.host $command out+err>| lines) {
            print $"($target.prefix)($line)"
        }
        true
    } catch {
        false
    }
}

# Run one remote command with a full pass-through terminal and no prefixing,
# which is the only way a prompt on the far end can reach you.
def upta-run-raw [host: string, command: string]: nothing -> bool {
    try {
        ^ssh -A -t $host $command
        true
    } catch {
        false
    }
}

# Update a single host, returning a record of how it went.
def upta-host [target: record, raw: bool]: nothing -> record {
    let start = date now

    if not (upta-reachable $target.host) {
        print $"($target.prefix)(ansi red)unreachable over ssh, skipping(ansi reset)"
        return {
            host: $target.host
            status: unreachable
            step: null
            duration: ((date now) - $start)
        }
    }

    print $"($target.prefix)(ansi attr_dimmed)starting(ansi reset)"

    # Stop at the first failure: if chezmoi didn't land, the recipe we would run
    # next is stale, and there is little point upgrading on top of that.
    let outcome = $UPTA_REMOTE_STEPS | reduce --fold {failed: null} {|command, acc|
        if $acc.failed != null {
            $acc
        } else if (if $raw { upta-run-raw $target.host $command } else { upta-run-prefixed $target $command }) {
            $acc
        } else {
            {failed: $command}
        }
    }

    let status = if $outcome.failed == null { "ok" } else { "failed" }
    print $"($target.prefix)(ansi attr_dimmed)($status)(ansi reset)"

    {
        host: $target.host
        status: $status
        step: $outcome.failed
        duration: ((date now) - $start)
    }
}

# Update hosts over ssh: chezmoi, then system packages, uv tools, and cargo.
#
# Hosts given as arguments override the list in $XDG_CONFIG_HOME/upta.yml.
#
# By default each host is visited in turn and every line of its output is
# stamped with a colored hostname, so a thousand lines of pacman still tell you
# where they came from. That means piping the output, which in turn means a
# prompt on the far end would be swallowed. `chezmoi update` is the one step
# that might still ask something, over a merge; give it --raw when it does.
#
# Named `main` because a module can't export a command sharing its own name.
# Importing this module as `use lib/upta.nu *` binds this as `upta`.
export def main [
    ...hosts: string  # hosts to update, overriding the configured list
    --parallel (-p)   # visit hosts at the same time
    --raw (-r)        # pass the terminal straight through, no prefixing, prompts work
]: nothing -> table {
    if $parallel and $raw {
        error make {
            msg: "--parallel and --raw conflict: a prompt cannot be answered while hosts talk over each other"
        }
    }

    let hosts = (if ($hosts | is-not-empty) { $hosts } else { upta-hosts }) | uniq

    if ($hosts | is-empty) {
        error make {
            msg: $"No hosts to update: name them as arguments or list them in ((xdg config) | path join upta.yml)"
        }
    }

    let targets = $hosts | upta-prefixes

    let results = if $parallel {
        $targets | par-each {|target| upta-host $target $raw }
    } else {
        $targets | each {|target| upta-host $target $raw }
    }

    print ""
    $results | sort-by host
}
