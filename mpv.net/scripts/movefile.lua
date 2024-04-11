-- move-file-next
-- --------------
-- This script registers a function "move-file-next" that:
-- 1. moves the currently playing file to a subdirectory in the same path named
--    "!mpv_movefile"
-- 2. skips past the file in the playlist (or stops if there are no more files
--    in the playlist)
--
-- Specifically for me, I use this categorize files to keep or delete. For
-- example, after playing through a directory and using this function on some
-- files, I can quickly delete all files in the "!mpv_movefile" directory.
--
-- To use this script, place it in your scripts location
-- (https://mpv.io/manual/stable/#script-location) and the assign
-- `move-file-next/move-file-next` to a keybinding in your input.conf, such
--  as:
--
--  ```
--  Shift+DEL    script-binding move-file-next/move-file-next
--  ```

-- not technically necessary because mp is preloaded, but lets static analyzers
-- know we're using it.
local mp = require('mp')
local utils = require('mp.utils')
local msg = require('mp.msg')

local move_dir_name = "!mpv_movefile"

-- Check if path is a protocol, such as `http://...`
local function is_protocol(path) return path:match('^%a[%a%d-_]+://') end

-- remove the currently playing file from the playlist (which stops it from
-- being played), or stop the player. this ensures we are no longer reading that
-- file when we move it.
local function playlist_remove_or_stop()
    local playlist_count = mp.get_property_native('playlist-count')
    if playlist_count > 1 then
        mp.commandv('playlist-remove', 'current')
    else
        mp.commandv('stop')
    end
end

-- move a file from src to dst. returns true on success, or (false,
-- error_message) on failure
local function move_file(src, dst)
    local success, error_message = os.rename(src, dst)
    if not success then
        return false, "Failed to move file: " .. error_message
    end
    return true
end

-- create a directory at path. returns true on success, or (false,
-- error_message) on failure
local function create_directory(path)
    local info, error_message = utils.file_info(path)
    if info then
        if info.is_dir then
            -- Path already exists and is a directory
            return true
        else
            -- Path exists but is not a directory
            return false, path .. " exists but is not a directory"
        end
    else
        -- Path does not exist, try to create it
        local success, error_message = os.execute('mkdir "' .. path .. '"')
        if not success then
            return false, "Failed to create directory: " .. error_message
        end
    end
    return true
end

-- log a message to the console at level and and display it to the user in the
-- UI. the level may be nil, which will log at "info" level, or it may be any of
-- `fatal`, `error`, `warn`, `info`, `v`, `debug`, or `trace`.
local function log_and_osd_message(msg, level)
    local level = level or 'info'
    msg.log(level, msg)
    mp.osd_message(msg)
end

-- skip the currently playing file and move it to the "!mpv_movefile" subdirectory
local function move_file_next()
    local file_path = mp.get_property('path')

    if is_protocol(file_path) then
        msg.info("Cannot move non-local file: " .. file_path)
        return
    end

    local file_dir_path, file_name = utils.split_path(file_path)
    local move_dir_path = utils.join_path(file_dir_path, move_dir_name)
    local target_path = utils.join_path(move_dir_path, file_name)

    playlist_remove_or_stop()

    local success, error_message = create_directory(move_dir_path)
    if not success then
        log_and_osd_message(error_message)
        return
    end

    local success, error_message = move_file(file_path, target_path)
    if not success then
        log_and_osd_message(error_message)
        return
    end

    mp.osd_message("Moved file to" .. target_path)
end

-- make the function available for use.
mp.add_key_binding(nil, 'move-file-next', move_file_next)
