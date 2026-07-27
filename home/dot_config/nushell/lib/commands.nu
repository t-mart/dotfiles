use std *
use paths.nu ["path extension" "path relative-to-safe"]

# Add a directory to the PATH if it exists.
export def --env add-path-if-exists [
  dir: string,  # The directory to add
]: nothing -> nothing {
  if ($dir | path exists) {
    path add $dir
  }
}

# Returns whether an executable is available on the PATH.
export def is-installed [cmd: string]: nothing -> bool {
    (which $cmd | length) > 0
}

# Emits an error if an executable is not available on the PATH.
export def require-installed [cmd: string]: nothing -> nothing {
    if not (is-installed $cmd) {
        error make $"($cmd) must be installed to use this command"
    }
}

# Make a directory and cd into it.
export def --env mkcd [directory: path]: nothing -> nothing {
    mkdir $directory
    cd $directory
}

# Hardlink to files in <target_root> under <link_root>.
#
# The directory structure under <target_root> will be preserved under
# <link_root>. New directories are created as needed.
export def ln-recurse [
    target_root: string            # The root directory containing the files to hardlink
    link_root: string              # The root directory where the hardlinks will be created
    --force (-f)                   # Overwrite existing files at the link location
    --only-ext (-o): list<string>  # Only hardlink files with these extensions
    --dry-run (-d)                 # Do not actually create the hardlinks
]: nothing -> table<target: string, link: string> {
    require-installed ln
    
    # kinda awful syntax: https://github.com/nushell/nushell/issues/13219#issuecomment-2222675774
    ls ($"($target_root)/**/*" | into glob) --all --full-paths
        | where type == file
        | get name
        | where ($only_ext == null) or ($it | path extension | $in in $only_ext)
        | each {|target_path|
            # example:
            #   target_root:   /target/
            #   link_root:     /link/
            #   target_path:   /target/subdir/file.txt
            #   relative_path: subdir/file.txt
            #   link_path:     /link/subdir/file.txt
            let relative_path = $target_path | path relative-to ($target_root | path expand --strict)
            let link_path = $link_root | path join $relative_path

            if not $dry_run {
                mkdir ($link_path | path parse | get parent)
                let force_arg = if $force { ["--force"] } else { [] }
                ln ...$force_arg $target_path $link_path
            }

            {
                target: ($target_path | path relative-to-safe (pwd))
                link: ($link_path | path relative-to-safe (pwd))
            }
    }
}

# Produce a random port. It may be used or not, so check for availability before
# using.
#
# By default, returns a port in the range 1024-65535.
export def "random port" [
    --all (-a) # return a port in range 1-65535
    --priveleged (-p) # return a port in range 1-1023
]: nothing -> int {
    let lower = if $all or $priveleged { 1 } else { 1024 }
    let upper = if $priveleged { 1023 } else { 65535 }
    random int $lower..$upper
}

# Produce a random password based on the Bech32 character set.
export def "random password" [
    length?: int # the length of the password to generate, defaults to 32
]: nothing -> string {
    let alphabet = "qpzry9x8gf2tvdw0s3jn54khce6mua7l" | split chars
    let alphabet_length = $alphabet | length
    seq 1 ($length | default 32) | each {
        $alphabet | get (random int 0..<$alphabet_length)
    } | str join
}

# Return the path of the specified XDG directory. Delegates to `systemd-path`,
# which respects XDG environment variable overrides and the XDG Base Directory
# specification at https://specifications.freedesktop.org/basedir/latest/.
# The returned path is absolute but may not exist.
#
# This command only returns the singleton directories such as XDG_CONFIG_HOME.
# For the preference-ordered sets of directories such as XDG_CONFIG_DIRS, use
# the `xdg-dirs` command.
export def xdg [
    type: string # one of "data", "config", "state", "bin", "cache", or "runtime"
]: nothing -> string {
    require-installed systemd-path

    let systemd_key = match $type {
        "data"    => "user-shared"
        "config"  => "user-configuration"
        "state"   => "user-state-private"
        "bin"     => "user-binaries"
        "cache"   => "user-state-cache"
        "runtime" => "user-runtime"
        _ => { error make  $"Invalid XDG directory type: ($type)" }
    }

    let result = systemd-path $systemd_key | complete
    if $result.exit_code != 0 {
        error make  $"systemd-path failed: ($result.stderr)"
    }
    $result.stdout | str trim
}

# Parses an .env-formatted file and returns a table of key-value pairs. Relies
# on `python-dotenv` to handle the parsing, so it supports all features of that library
@example "Parse .env file" { parse-env-file "path/to/.env" } --result {KEY: VALUE}
export def parse-env-file [path?: string]: nothing -> table<key: string, value: string> {
    require-installed dotenv

    let path_args = if ($path != null) {
        ["--file" $path]
    } else {
        []
    }

    let result = dotenv ...($path_args) list --format json | complete

    if $result.exit_code != 0 {
        error make --unspanned {
            msg: $"Failed to parse env file: ($result.stderr)"
        }
    }

    $result.stdout | from json
}

# Load environment variables from an .env-formatted file. See `parse-env-file` 
# for details and supported features.
@example "Load .env file" { load-env-file "path/to/.env" }
export def --env load-env-file [path?: string]: nothing -> nothing {
    parse-env-file $path | load-env
}

# Return the process IDs bound to a network port. Delegates to `ss`, which
# must be installed. Defaults to TCP; pass --udp for UDP. A port may map to
# multiple PIDs (e.g. forked workers or separate IPv4/IPv6 sockets), so a list
# is always returned.
#
# Processes owned by other users are only visible to root, so pass --sudo to
# run `ss` under sudo (you will be prompted for your password).
@example "Find the PIDs listening on TCP 8080" { port pid 8080 } --result [1234]
export def "port pid" [
    port: int   # the network port to look up
    --udp (-u)  # look up UDP instead of TCP
    --all (-a)  # match any socket on the port, not just listening ones
    --sudo (-s) # run ss under sudo to see processes owned by other users
]: nothing -> list<int> {
    require-installed ss

    let proto = if $udp { "--udp" } else { "--tcp" }
    let state = if $all { "--all" } else { "--listening" }
    let ss_cmd = [
        (if $sudo { [sudo] } else { null })
        ss
        $proto
        $state
        --numeric
        --processes
        --no-header
        --oneline
        $"sport = :($port)"
    ] | where ($it | is-not-empty)

    run-checked ...$ss_cmd
        | parse --regex 'pid=(?<pid>\d+)'
        | get pid
        | uniq
        | into int
}

# Return a table of process details for the given PID(s), read natively from
# /proc. `name` is the kernel comm, `exe` the resolved executable path, and
# `cmdline` the full argument vector. `comm` and `cmdline` are world-readable,
# but reading another user's `exe` requires ptrace permission, so it falls back
# to null. Pass --sudo to resolve those `exe` paths via `sudo readlink` (you
# will be prompted for your password).
@example "Describe the processes on TCP 8080" { port pid 8080 | proc }
export def proc [
    --sudo (-s) # resolve other users' exe paths via sudo
]: oneof<int, list<int>> -> table<pid: int, name: string, exe: string, cmdline: list<string>> {
    [$in] | flatten | each {|pid|
        {
            pid: $pid
            name: (try { open --raw $"/proc/($pid)/comm" | decode utf-8 | str trim } catch { null })
            exe: (try {
                if $sudo {
                    run-checked [sudo readlink $"/proc/($pid)/exe"] | str trim
                } else {
                    ls --long $"/proc/($pid)/exe" | get 0?.target
                }
            } catch { null })
            cmdline: (try {
                open --raw $"/proc/($pid)/cmdline"
                    | decode utf-8
                    | split row \u{0}
                    | where ($it | is-not-empty)
            } catch { null })
        }
    }
}

# Run an external command and return its stdout, raising an error containing the
# command's stderr if it exits non-zero. The command is passed as a list so its
# own flags are not mistaken for flags to this helper.
#
# Pass --sudo to run it under sudo; credentials are validated up front
# (prompting if needed) so the password prompt stays visible instead of being
# swallowed by the captured output.
@example "Capture output or raise on failure" { run-checked [ss -tlnp] }
export def run-checked [
    ...cmd: string # the external command and its arguments
]: nothing -> string {
    if ($cmd | is-empty) {
        error make "run-checked requires a command to run"
    }

    let result = run-external ...$cmd | complete
    if $result.exit_code != 0 {
        error make $"`($cmd | str join ' ')` failed: ($result.stderr | str trim)"
    }
    $result.stdout
}
