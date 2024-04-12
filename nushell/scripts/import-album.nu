# Import an album from a YouTube Music URL to a beet library.
#
# First the album will be downloaded with yt-dlp, and then the interactive beet
# import command will run to apply metadata.
def import-album [ 
    yt_music_url: string # The URL of the album on YouTube Music.
] {
    # get a namespaced temporary directory
    let temp_dir = $nu.temp-path | path join "nu-album-import" (random uuid)

    # download the album
    yt-dlp --output $"($temp_dir)\\%\(playlist)s\\%\(playlist_index)s - %\(title)s.%\(ext)s" --extract-audio --format "bestaudio*[acodec=opus]/bestaudio*" $yt_music_url

    # import the album into the beet library
    beet import $temp_dir

    # remove the temporary directory
    rm -r $temp_dir
}