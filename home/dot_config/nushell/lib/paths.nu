# Extensions to nushell's built-in `path` namespace, plus the extension lists
# that back the `path is-*` predicates.
#
# These deliberately hang off `path` rather than standing alone, so that
# `path stem` reads beside the built-in `path parse` and `path join`.

# Like the built-ins, every command here takes either one path or a list of
# paths. Commands that only pass values through to the built-ins get that for
# free, since `path parse` returns a record for one path and a table for a list.
# Commands that compute per path use `vectorize`, which also keeps an empty list
# an empty list: `path join` on an empty list returns "", because it cannot tell
# an empty table of parsed paths from an empty list of path components.


# Apply a transformation to a single value or to each value of a list, so that a
# command accepts `string` or `list<string>`. The closure receives the value as
# its argument and as its pipeline input.
def vectorize [transform: closure]: [string -> any, list<string> -> list<any>] {
    let input = $in
    if ($input | describe --detailed | get type) == list {
        $input | each {|value| $value | do $transform $value }
    } else {
        $input | do $transform $input
    }
}

# Resolve a replacement that may be a literal string or a closure. A closure is
# called with the current value, both as its argument and as its pipeline input.
# A missing replacement (null) becomes an empty string.
#
# `update` cannot do this itself: given a closure it passes the whole record
# being updated, not the field's current value.
def resolve-replacement [current: string, replacement?: oneof<string, closure>]: nothing -> string {
    if ($replacement | describe) == closure {
        $current | do $replacement $current
    } else {
        $replacement | default ""
    }
}

# Return a path's extension. A convenience wrapper around `path parse | get extension`.
# Paths without an extension give an empty string.
@example "Get extension" { "foo/bar.txt" | path extension } --result txt
@example "Get extension with no extension" { "foo/bar" | path extension } --result ""
@example "Get extension of a list of paths" { [foo/bar.txt baz.md] | path extension } --result [txt md]
export def "path extension" []: [string -> string, list<string> -> list<string>] {
    path parse | get extension
}

# Return a path with the provided extension.
@example "Change to .txt extension" { "foo.html" | path with-extension  txt } --result foo.txt
@example "Change to .md extension with closure" { "foo.html" | path with-extension {|ext| if $ext == html { "md" } else { $ext } } } --result foo.md
@example "Remove extension" { "bar.html" | path with-extension "" } --result bar
@example "Change the extension of a list of paths" { [foo.html bar/baz.md] | path with-extension txt } --result [foo.txt bar/baz.txt]
export def "path with-extension" [
    extension?: oneof<string, closure> # the extension without the dot (can be empty to remove) or a closure that takes the current extension and returns the new extension
]: [string -> string, list<string> -> list<string>] {
    vectorize {|path|
        let parsed = $path | path parse
        $parsed | update extension (resolve-replacement $parsed.extension $extension) | path join
    }
}

# Return a path's stem. A convenience wrapper around `path parse | get stem`.
# Paths without a stem give an empty string.
@example "Get stem" { "foo/bar.txt" | path stem } --result bar
@example "Get stem of a dotfile" { "foo/.txt" | path stem } --result ".txt"
@example "Get stem with no stem" { "/" | path stem } --result ""
@example "Get stem of a list of paths" { [foo/bar.txt baz.md] | path stem } --result [bar baz]
export def "path stem" []: [string -> string, list<string> -> list<string>] {
    path parse | get stem
}

# Return a path with the provided stem (i.e. filename without extension).
@example "Change stem" { "foo/bar.txt" | path with-stem baz } --result foo/baz.txt
@example "Change stem with closure" { "foo/bar.txt" | path with-stem {|stem| $"new_($stem)" } } --result foo/new_bar.txt
@example "Remove stem" { "foo/bar.txt" | path with-stem "" } --result foo/.txt
@example "Change the stem of a list of paths" { [foo/bar.txt baz.md] | path with-stem {|stem| $"new_($stem)" } } --result [foo/new_bar.txt new_baz.md]
export def "path with-stem" [
    stem?: oneof<string, closure> # the stem string (can be empty to remove) or a closure that takes the current stem and returns the new stem
]: [string -> string, list<string> -> list<string>] {
    vectorize {|path|
        let parsed = $path | path parse
        $parsed | update stem (resolve-replacement $parsed.stem $stem) | path join
    }
}

# Return a path with the provided basename (i.e. filename with extension).
@example "Change basename" { "foo/bar.txt" | path with-basename baz.md } --result foo/baz.md
@example "Change basename with closure" { "foo/bar.txt" | path with-basename {|basename| $"($basename).backup" } } --result foo/bar.txt.backup
@example "Remove basename" { "foo/bar.txt" | path with-basename "" } --result foo
@example "Change the basename of a list of paths" { [foo/bar.txt baz.md] | path with-basename qux.log } --result [foo/qux.log qux.log]
export def "path with-basename" [
    basename?: oneof<string, closure> # the basename string (can be empty to remove) or a closure that takes the current basename and returns the new basename
]: [string -> string, list<string> -> list<string>] {
    # Unlike the other `with-*` commands this cannot ride the table form, since
    # one replacement has to fill in two columns without resolving twice.
    vectorize {|path|
        let replacement = resolve-replacement ($path | path basename) $basename | path parse
        $path | path parse | update stem $replacement.stem | update extension $replacement.extension | path join
    }
}

# Return the input path relative to the provided base path. If the input path
# is not under the base path, return the input path unchanged. This is the
# "safe" version of `path relative-to`, which errors when the input path is not
# under the base path.
@example "Get a path under the base" { "/home/tim/notes/todo.md" | path relative-to-safe /home/tim } --result notes/todo.md
@example "Get a path that is not under the base" { "/etc/hosts" | path relative-to-safe /home/tim } --result /etc/hosts
@example "Get a list of paths relative to the base" { [/home/tim/notes /etc/hosts] | path relative-to-safe /home/tim } --result [notes /etc/hosts]
export def "path relative-to-safe" [base: path]: [string -> string, list<string> -> list<string>] {
    vectorize {|path|
        try {
            $path | path relative-to $base
        } catch {
            $path
        }
    }
}

# List common video extensions
export def "ext video" []: nothing -> list<string> {
    [3g2 3gp asf avi f4v flv h264 h265 m2ts m4v mkv mov mp4 mp4v mpeg mpg ogm ogv rm rmvb ts vob webm wmv y4m]
}

# List common image extensions
export def "ext image" []: nothing -> list<string> {
    [apng avif bmp gif j2k jp2 jfif jpeg jpg jxl mj2 png svg tga tif tiff webp]
}

# List common audio extensions
export def "ext audio" []: nothing -> list<string> {
    [aac ac3 aiff ape au cue dsf dts flac m4a mid midi mka mp3 mp4a oga ogg opus spx tak tta wav weba wma wv]
}

# List common archive extensions
export def "ext archive" []: nothing -> list<string> {
    [zip tar gz tgz bz2 tbz2 xz txz 7z rar]
}

# Return whether a path's extension is one of the provided extensions, matched
# case-insensitively. `path extension` already handles lists, so only the
# membership test needs vectorizing.
def is-ext [extensions: list<string>]: [string -> bool, list<string> -> list<bool>] {
    path extension | vectorize {|ext| ($ext | str lowercase) in $extensions }
}

# Return if a path is a video based on its extension. Check "ext video" for the
# list of extensions.
@example "Check a path" { "clip.MKV" | path is-video } --result true
@example "Check a list of paths" { [clip.mkv notes.md] | path is-video } --result [true false]
export def "path is-video" []: [string -> bool, list<string> -> list<bool>] {
    is-ext (ext video)
}

# Return if a path is an image based on its extension. Check "ext image" for the
# list of extensions.
@example "Check a list of paths" { [photo.jpg notes.md] | path is-image } --result [true false]
export def "path is-image" []: [string -> bool, list<string> -> list<bool>] {
    is-ext (ext image)
}

# Return if a path is an audio file based on its extension. Check "ext audio" for the
# list of extensions.
@example "Check a list of paths" { [song.flac notes.md] | path is-audio } --result [true false]
export def "path is-audio" []: [string -> bool, list<string> -> list<bool>] {
    is-ext (ext audio)
}

# Return if a path is an archive based on its extension. Check "ext archive" for the
# list of extensions.
@example "Check a list of paths" { [backup.tgz notes.md] | path is-archive } --result [true false]
export def "path is-archive" []: [string -> bool, list<string> -> list<bool>] {
    is-ext (ext archive)
}
