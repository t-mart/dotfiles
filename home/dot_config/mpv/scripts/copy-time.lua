local mp = require('mp')
local msg = require 'mp.msg'

local function copy_timestamp()
    local time_pos = mp.get_property("time-pos")

    if not time_pos then
        msg.warn("No timestamp available (video might be stopped).")
        return
    end

    -- Construct the command to pipe to wl-copy
    -- We use 'subprocess' to execute this asynchronously so mpv doesn't stutter
    local cmd = {
        name = "subprocess",
        args = { "sh", "-c", string.format("echo -n '%s' | wl-copy", time_pos) },
        detach = true
    }
    
    mp.command_native(cmd)

    local message_text = string.format("Copied time to clipboard: %s", time_pos)

    msg.info(message_text)
    mp.osd_message(message_text)
end

mp.add_key_binding("C", "copy-timestamp", copy_timestamp)
