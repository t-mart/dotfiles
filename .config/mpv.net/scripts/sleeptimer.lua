local utils = require('mp.utils')
local msg = require('mp.msg')

local durations = {
    0, 5, 60, 5 * 60
    -- 15 * 60,
    -- 30 * 60,
    -- 60 * 60,
    -- 2 * 60 * 60,
}

-- sorry, but global state
local timer = nil
local timer_expire = nil
local duration_index = 1

-- set a sleep timer with a duration from a group of durations. invoke the function again to cycle
-- through the durations. if a sleep timer was already set, it will be killed and a new timer
-- created. An OSD message will display the currently set duration.
local function cycle_sleep_timer()
    duration_index = duration_index + 1

    if duration_index - 1 == #durations then duration_index = 1 end

    if durations[duration_index] == 0 then
        timer:kill()
        timer = nil
        mp.osd_message("Sleep timer unset")
        return
    end

    if timer ~= nil then
        timer:kill()
    end

    timer = mp.add_timeout(durations[duration_index],
                           function() mp.command_native({name = "quit"}) end)
    timer_expire = mp.get_time() + durations[duration_index]

    mp.osd_message(
        "Sleep timer set to " .. tostring(durations[duration_index]) ..
            " seconds")
end

-- if the timer is set, show in how many seconds it will expire.
local function show_sleep_timer()
    if timer == nil then
        mp.osd_message("No sleep timer set")
        return
    end

    local diff = timer_expire - mp.get_time()

    mp.osd_message("Will sleep in " .. diff .. " seconds")
end

-- make the functions available for use.
mp.add_key_binding(nil, 'cycle-sleep-timer', cycle_sleep_timer)
mp.add_key_binding(nil, 'show-sleep-timer', show_sleep_timer)
