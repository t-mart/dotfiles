# Extensions to nushell's built-in `path` namespace, plus the extension lists
# that back the `path is-*` predicates.
#
# These deliberately hang off `path` rather than standing alone, so that
# `path stem` reads beside the built-in `path parse` and `path join`.

# Return a path's extension. A convenience wrapper around `path parse | get extension`
# that returns an empty string if there is no extension instead of null.
@example "Get extension" { "foo/bar.txt" | path extension } --result txt
@example "Get extension with no extension" { "foo/bar" | path extension } --result ""
export def "path extension" []: string -> string {
    path parse | get extension | default ""
}

# Return a path with the provided extension.
@example "Change to .txt extension" { "foo.html" | path with-extension  txt } --result foo.txt
@example "Change to .md extension with closure" { "foo.html" | path with-extension {|ext| if $ext == html { "md" } else { $ext } } } --result foo.md
@example "Remove extension" { "bar.html" | path with-extension "" } --result bar
export def "path with-extension" [
    extension?: oneof<string, closure> # the extension without the dot (can be empty to remove) or a closure that takes the current extension and returns the new extension
]: string -> string {
    path parse | update extension ($extension | default "") | path join
}

# Return a path's stem. A convenience wrapper around `path parse | get stem`
# that returns an empty string if there is no stem instead of null.
@example "Get stem" { "foo/bar.txt" | path stem } --result bar
@example "Get stem with no stem" { "foo/.txt" | path stem } --result ""
export def "path stem" []: string -> string {
    path parse | get stem | default ""
}

# Return a path with the provided stem (i.e. filename without extension).
@example "Change stem" { "foo/bar.txt" | path with-stem baz } --result foo/baz.txt
@example "Change stem with closure" { "foo/bar.txt" | path with-stem {|stem| $"new_($stem)" } } --result foo/new_bar.txt
@example "Remove stem" { "foo/bar.txt" | path with-stem "" } --result foo/.txt
export def "path with-stem" [
    stem?: oneof<string, closure> # the stem string (can be empty to remove) or a closure that takes the current stem and returns the new stem
]: string -> string {
    path parse | update stem ($stem | default "") | path join
}

# Return a path with the provided basename (i.e. filename with extension).
@example "Change basename" { "foo/bar.txt" | path with-basename baz.md } --result foo/baz.md
@example "Change basename with closure" { "foo/bar.txt" | path with-basename {|basename| $"($basename).backup" } } --result foo/bar.txt.backup
@example "Remove basename" { "foo/bar.txt" | path with-basename "" } --result foo/
export def "path with-basename" [
    basename?: oneof<string, closure> # the basename string (can be empty to remove) or a closure that takes the current basename and returns the new basename
]: string -> string {
    let parse = $basename | default "" | path parse
    $in | path parse | update stem ($parse.stem | default "") | update extension ($parse.extension | default "") | path join
}

# Return the input path relative to the provided base path. If the input path
# is not under the base path, return the input path unchanged. This is the
# "safe" version of `path relative-to`, which errors when the input path is not
# under the base path.
export def "path relative-to-safe" [base: path]: string -> string {
    let path = $in
    try {
        $path | path relative-to $base
    } catch {
        $path
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

# Return if a path is a video based on its extension. Check "ext video" for the 
# list of extensions.
export def "path is-video" []: string -> bool {
    path extension | str lowercase | $in in (ext video)
}

# Return if a path is an image based on its extension. Check "ext image" for the
# list of extensions.
export def "path is-image" []: string -> bool {
    path extension | str lowercase | $in in (ext image)
}

# Return if a path is an audio file based on its extension. Check "ext audio" for the
# list of extensions.
export def "path is-audio" []: string -> bool {
    path extension | str lowercase | $in in (ext audio)
}

# Return if a path is an archive based on its extension. Check "ext archive" for the
# list of extensions.
export def "path is-archive" []: string -> bool {
    path extension | str lowercase | $in in (ext archive)
}
