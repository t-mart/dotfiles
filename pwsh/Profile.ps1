function dfgit {
    git --git-dir=$HOME/.dotfile_config/ --work-tree=$HOME $args
}

# takes a playlist url, like "https://music.youtube.com/playlist?list=OLAK5uy_lm79pWsUmJcnAPQdRZd9X41Ywv7m79cC0"
function yt-dlp-beet-import {
    $dirName = ".ytdlpbeetimport-$(Get-Date -Format yyyy-MM-dd-HH-mm-ss-fffffff)"
    New-Item -Name "$dirName" -ItemType "directory"
    yt-dlp --output "$dirName/%(playlist)s/%(title)s.%(ext)s" --extract-audio --format "bestaudio*[acodec=opus]/bestaudio*" "$args"
    beet import "$dirName"
    Remove-Item -LiteralPath ".\$dirName\" -Force -Recurse
}

Invoke-Expression (&starship init powershell)
