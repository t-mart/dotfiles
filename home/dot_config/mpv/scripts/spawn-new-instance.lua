-- A script to spawn a new mpv instance with the current video.

local mp = require('mp')

local os_name = mp.get_property("platform")
local mpv_path = os_name == "windows" and mp.get_property_native("user-data/frontend/process-path") or "mpv"

local function spawn_new_instance()
    mp.command_native({
        name = "subprocess",
        args = { 
            mpv_path,
            mp.get_property("path")
        },
        detach = true,  -- Detach so the new instance runs independently.
        playback_only = false,  -- Allow this command to run even if playback is not active.
    })
end

-- Binds the function to a message, so we can call it from input.conf.
mp.add_key_binding(nil, "spawn-new-instance", spawn_new_instance)
