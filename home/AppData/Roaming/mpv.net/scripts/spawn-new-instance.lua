-- A script to spawn a new mpv instance with the current video.

local mp = require('mp')
local msg = require('mp.msg')
local utils = require 'mp.utils'

local function spawn_new_instance()

    mp.command_native({
        name = "subprocess",
        args = { 
            "mpvnet",
            mp.get_property("path")
        },
        detach = true,  -- Detach so the new instance runs independently.
        playback_only = false,  -- Allow this command to run even if playback is not active.
    })
end

-- Binds the function to a message, so we can call it from input.conf.
mp.add_key_binding(nil, "spawn-new-instance", spawn_new_instance)
