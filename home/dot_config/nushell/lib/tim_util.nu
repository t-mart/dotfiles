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
export def 'on-windows' []: nothing -> bool {
  version | get build_os | str starts-with "windows"
}

# Returns whether a command is available.
export def 'is-installed' [cmd: string]: nothing -> bool {
    (which $cmd | length) > 0
}

export def 'is-absolute' [path: string]: nothing -> bool {
    let parse = $path | path parse
    if (on-windows) {
        ($parse | get prefix | str length) > 0
    } else {
        $parse | get parent | str starts-with "/"
    }
}

# Hardlink to files in <target_root> under <link_root>.
#
# The directory structure under <target_root> will be preserved under
# <link_root>. New directories are created as needed.
export def ln-recurse [
    target_root: string            # The root directory containing the files to hardlink
    link_root: string              # The root directory where the hardlinks will be created
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
    ]: nothing -> record<target: string, link: string> {
        let result = if (on-windows) {
            ^mklink /h $link $target
        } else {
            ^ln $target $link
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
        # target path is absolute right now, suitable for relative-to
        let relative_path = $target_path | path relative-to ($target_root | path expand --strict)
        let link_path = $link_root | path join $relative_path

        # now, fix up target_path so it matches the "absoluteness" of
        # target_root for better UI
        let target_path = if (is-absolute $target_root) {
            # fd is already printing absolute paths
            $target_path
        } else {
            $target_path | path relative-to (pwd)
        }

        if $dry_run {
            { target: $target_path, link: $link_path }
        } else {
            mkdir ($link_path | path parse | get parent)
            hardlink $target_path $link_path
        }
    }
}