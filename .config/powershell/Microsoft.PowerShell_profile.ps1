function dfgit {
    git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME $args
}

# takes a playlist url, like "https://music.youtube.com/playlist?list=OLAK5uy_lm79pWsUmJcnAPQdRZd9X41Ywv7m79cC0"
function yt-dlp-beet-import {
    New-Item -Name ".ytdlpbeetimport" -ItemType "directory"
    yt-dlp --output ".ytdlpbeetimport/%(playlist)s/%(title)s.%(ext)s" --extract-audio --format "bestaudio*" "$args"
    beet import ".ytdlpbeetimport"
    Remove-Item -LiteralPath ".\.ytdlpbeetimport\" -Force -Recurse
}

Invoke-Expression (&starship init powershell)
