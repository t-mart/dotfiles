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

# Unzip a zip file into a folder named after the zip file's stem.
export def "unzip-smart" [
    zip_file: path,       # The source .zip file
    destination?: path    # Optional: The directory to place the new folder in
] {
    # 1. Validate the Zip File
    let absolute_zip = ($zip_file | path expand)
    if not ($absolute_zip | path exists) {
        error make {msg: $"Source file does not exist: ($zip_file)"}
    }
    if ($absolute_zip | path type) != "file" {
        error make {msg: $"Source is not a file: ($zip_file)"}
    }

    # 2. Determine the folder name (stem)
    let folder_name = ($absolute_zip | path parse | get stem)

    # 3. Handle the Destination Argument
    let target_parent = if ($destination == null) {
        $env.PWD
    } else {
        let abs_dest = ($destination | path expand)
        
        if not ($abs_dest | path exists) {
            error make {msg: $"Destination path not found: ($destination)"}
        }
        if ($abs_dest | path type) != "dir" {
            error make {msg: $"Destination is a file, not a directory: ($destination)"}
        }
        
        $abs_dest
    }

    # 4. Construct the final path
    let final_output_path = ($target_parent | path join $folder_name)

    # 5. Safety Check: Ensure the "would-be" directory doesn't already exist
    if ($final_output_path | path exists) {
        error make {
            msg: $"Target directory already exists. Aborting to prevent overwrite.",
            label: {
                text: "Already exists here",
                span: (metadata $final_output_path).span
            } 
        }
    }

    # 6. Execute unzip
    # We allow unzip standard output to print so the user sees progress
    ^unzip $absolute_zip -d $final_output_path

    # 7. Return the path
    return $final_output_path
}