use std *

# Add a directory to the PATH if it exists.
export def --env add-path-if-exists [
  dir: string,  # The directory to add
]: nothing -> nothing {
  if ($dir | path exists) {
    path add $dir
  }
}

# Returns true if the current platform is Windows.
export def on-windows []: nothing -> bool {
  version | get build_os | str starts-with "windows"
}

# Returns whether an executable is available on the PATH.
export def is-installed [cmd: string]: nothing -> bool {
    (which $cmd | length) > 0
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

    if not (is-installed 'fd') {
        error make --unspanned {
            msg: "fd must be installed"
        }
    }

    def hardlink [
        target: string
        link: string
        --force (-f)
        --dry-run (-d)
    ]: nothing -> record<target: string, link: string> {
        if ($dry_run) {
            return { target: $target, link: $link }
        }
        let result = if (on-windows) {
            if $force {
                error make --unspanned {
                    msg: "Overwriting existing files is not supported on Windows"
                }
            } else {
                ^mklink /h $link $target
            }
        } else {
            if $force {
                ^ln -f $target $link
            } else {
                ^ln $target $link
            }
        } | complete
        if ($result.exit_code == 0) {
            { target: $target, link: $link }
        } else {
            error make --unspanned {
                msg: $"Failed to create hard link \"($link)\": ($result.stderr)"
            }
        }
    }

    let extension_args = $only_ext | default [] | each {|ext| ['--extension' $ext] } | flatten

    let fd_result = ^fd --type file ...$extension_args --absolute-path . $target_root | complete

    if $fd_result.exit_code != 0 {
        error make --unspanned {
            msg: $"Failed to list files in target root: ($fd_result.stderr)"
        }
    }
    
    $fd_result.stdout | lines | each { |target_path|
        # example:
        #   target_root:   /target/
        #   link_root:     /link/
        #   target_path:   /target/subdir/file.txt
        #   relative_path: subdir/file.txt
        #   link_path:     /link/subdir/file.txt
        let relative_path = $target_path | path relative-to ($target_root | path expand --strict)
        let link_path = $link_root | path join $relative_path

        let result = if $dry_run {
            { target: $target_path, link: $link_path }
        } else {
            if $dry_run {
                hardlink --dry-run $target_path $link_path
            } else {
                mkdir ($link_path | path parse | get parent)
                hardlink $target_path $link_path
            }
        }

        { target: ($result.target | path relative-to-safe (pwd)), link: ($result.link | path relative-to-safe (pwd)) }
    }
}

# Return a path with the provided extension.
@example "Change to .txt extension" {"foo.html" | path with-extension "txt"} --result "foo.txt"
@example "Remove extension" {"bar.html" | path with-extension ""} --result "bar"
export def "path with-extension" [
    extension?: string # the extension (without the dot), or empty string to remove the extension
]: string -> string {
    path parse | update extension ($extension | default "") | path join
}

# Return a path with the provided stem (i.e. filename without extension).
@example "Change stem" {"foo/bar.txt" | path with-stem "baz"} --result "foo/baz.txt"
@example "Remove stem" {"foo/bar.txt" | path with-stem ""} --result "foo/.txt"
export def "path with-stem" [
    stem?: string # the stem, or empty string to remove the stem
]: string -> string {
    path parse | update stem ($stem | default "") | path join
}

# Return a path with the provided basename (i.e. filename with extension).
@example "Change basename" {"foo/bar.txt" | path with-basename "baz.md"} --result "foo/baz.md"
@example "Remove basename" {"foo/bar.txt" | path with-basename ""} --result "foo/"
export def "path with-basename" [
    basename?: string # the basename, or empty string to remove the basename
]: string -> string {
    let parse = $basename | default "" | path parse
    $in | path parse | update stem ($parse.stem | default "") | update extension ($parse.extension | default "") | path join
}

# Return the input path relative to the provided base path. If the input path
# is not under the base path, return the input path unchanged. This is the
# "safe" version of `path relative-to`, which errors when the input path is not
# under the base path.
export def "path relative-to-safe" [base: string]: string -> string {
    let $path = $in
    try {
        $path | path relative-to $base
    } catch {
        $path
    }
}

# Return a path with the provided 

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

# Update remote servers with paru, chezmoi, uv, and cargo.

# If no servers are provided, read from config file at
# $XDG_CONFIG_HOME/upta.txt for a line-separated list. Lines starting with #
# and empty lines are ignored.
export def upta [...servers: string] {
    let cmds = [
        # arch paru
        "paru --sync --sysupgrade --refresh --noconfirm --skipreview"

        # chezmoi
        "~/.local/bin/chezmoi update --init --apply"

        # uv
        "uv tool update --all"

        # rust
        "cargo install-update --all"
    ]

    mut servers = $servers
    let servers_path = xdg config | path join "upta.txt"

    if ($servers | is-empty) {
        if ($servers_path | path exists) {
            $servers = $servers_path | open | lines | where { |line|
                not ($line | str starts-with "#") and not ($line | str trim | is-empty)
            }
        }
    }

    # check again
    if ($servers | is-empty) {
        error make --unspanned {
            msg: $"No servers to update: no servers provided or config file at ($servers_path) is empty or does not exist"
        }
    }

    $servers = $servers | uniq

    for server in $servers {
        print $"\n(ansi g)--- STARTING UPDATE ON ($server) ---(ansi reset)"
        for cmd in $cmds {
            let ping_check = (ping -c 1 -W 1 $server | complete)
            
            if $ping_check.exit_code == 0 {
                ssh -A -t $server $cmd
            } else {
                print $"⚠️  ($server) is offline or unreachable. Skipping."
            }
        }
        print $"\n(ansi g)--- COMPLETED UPDATE ON ($server) ---(ansi reset)"
    }
}

# Return the path of the specified XDG directory according to the specification
# at https://specifications.freedesktop.org/basedir/latest/. The paths returned
# path will be absolute and may not exist.
#
# Exception: on XDG_RUNTIME_DIR, no permissions are checked.
#
# This command only returns the singleton directories such as XDG_CONFIG_HOME.
# For the preference-ordered sets of directories such as XDG_CONFIG_DIRS, use
# the `xdg-dirs` command.
export def xdg [
    type: string # one of "data", "config", "state", "bin", "cache", or "runtime"
]: nothing -> string {
    # should we use $nu.home-dir? spec says to use $HOME. are these equivalent?
    match $type {
        "data" => {
            $env.XDG_DATA_HOME? | default ($env.HOME | path join ".local/share")
        },
        "config" => {
            $env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config")
        },
        "state" => {
            $env.XDG_STATE_HOME? | default ($env.HOME | path join ".local/state")
        },
        "bin" => {
            # this isn't a "named" XDG dir like the others, but fine
            $env.XDG_BIN_HOME? | default ($env.HOME | path join ".local/bin")
        },
        "cache" => {
            $env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache")
        },
        "runtime" => {
            # no default if unset. should this be null instead?
            $env.XDG_RUNTIME_DIR? | default (error make --unspanned { msg: "XDG_RUNTIME_DIR is not set" })
        },
        _ => {
            error make --unspanned { msg: $"Invalid XDG directory: ($type)" }
        },
    }
}

# Return a list of paths for the specified preference-ordered set of XDG
# directories according to the specification at
# https://specifications.freedesktop.org/basedir/latest/. The paths returned
# are absolute and may not exist.
export def xdg-dirs [
    type: string # one of "data" or "config"
]: nothing -> list<string> {
    match $type {
        "data" => {
            $env.XDG_DATA_DIRS? | default "/usr/local/share:/usr/share" | split row ":"
        },
        "config" => {
            $env.XDG_CONFIG_DIRS? | default "/etc/xdg" | split row ":"
        },
        _ => {
            error make --unspanned { msg: $"Invalid XDG directory: ($type)" }
        },
    }
}