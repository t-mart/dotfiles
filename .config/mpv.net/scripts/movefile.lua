local utils = require('mp.utils')
local msg = require('mp.msg')

-- Check if path is a protocol, such as `http://...`
local function is_protocol(path) return path:match('^%a[%a%d-_]+://') end

-- remove the currently playing file from the playlist, or stop the player. this frees the
-- filesystem to do some destructive operation (e.g. moving) on the file.
local function playlist_remove_or_stop()
    local playlist_count = mp.get_property_native('playlist-count')
    if playlist_count > 1 then
        mp.commandv('playlist-remove', 'current')
    else
        mp.commandv('stop')
    end
end

-- Run a command in powershell
-- Remember to quote filenames so they're treating as one argument
local function run_pwsh_command(command_str)
    return mp.command_native({
        name = 'subprocess',
        args = {'pwsh', '-Command', command_str},
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true
    })
end

-- For the currently playing file, play the file after it and move the file to a special directory.
-- The name of the directory is "mpv_movefile". It will be created in the same directory as the file
-- if it does not exist.
--
-- The goal of this function is to designate files for deletion (or some other treatment) after
-- reviewing them. Deletion is forever, so we just place them in a nearby directory for a final
-- chance.
local function move_file_next()
    local file_path = mp.get_property_native('path')

    if is_protocol(file_path) then
        msg.info("Cannot move non-local file: " .. file_path)
        return
    end

    local dir_path, _ = utils.split_path(file_path)

    local move_to_dir_path = utils.join_path(dir_path, "mpv_movefile")

    playlist_remove_or_stop()

    -- we escape single quotes in file names with the addition of another single quote.
    -- https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-7.2
    run_pwsh_command('New-Item -Path \'' .. move_to_dir_path:gsub("'", "''") ..
                         '\' -ItemType directory -Force')

    run_pwsh_command('Move-Item -LiteralPath \'' .. file_path:gsub("'", "''") ..
                         '\' -Destination \'' ..
                         move_to_dir_path:gsub("'", "''") .. '\'')


    mp.osd_message("Moved file")
end

-- make the function available for use.
mp.add_key_binding(nil, 'move-file-next', move_file_next)
