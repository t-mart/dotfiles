-- sleeptimer
-- ----------
-- Registers the "cycle-sleep-timer" function to set a sleep timer for a preset duration of time.
-- This time will be shown as a message on the OSD. Subsequent invocations of the function will
-- reset the timer and cycle to another larger preset  duration. (Only one sleep timer will be
-- active at a time.)
--
-- When the duration elapses, MPV will quit-watch-later.
--
-- To disable the sleep timer after it has been set, continue invoking the function until it reaches
-- the "unset" state.
--
-- If a sleep timer is set, it's remaining duration may be queried with the "show-sleep-timer"
-- function, which will show it on the OSD.

-- TODO: option for stop vs quit vs quit-watch-later
-- TODO: configurable seconds

local durations = {
    0, -- not set. keep this, important for being to disable
    60, -- 1 minute
    5 * 60, -- 5 minutes
    15 * 60, -- 15 minutes
    30 * 60, -- 30 minutes
    60 * 60, -- 1 hour
    2 * 60 * 60, -- 2 hours
    4 * 60 * 60 -- 4 hours
}

-- sorry, but global state
local timer = nil
local timer_expire = nil
local duration_index = 1

local function humanize_duration(seconds)
    local left = seconds
    local hours, left = math.floor(left / 3600), left % 3600
    local minutes, seconds = math.floor(left / 60), left % 60

    units = {}
    if hours > 0 then table.insert(units, string.format("%dh", hours)) end
    if minutes > 0 then table.insert(units, string.format("%dm", minutes)) end
    if seconds > 0 then table.insert(units, string.format("%.0fs", seconds)) end

    return table.concat(units, " ")
end

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

    if timer ~= nil then timer:kill() end

    timer = mp.add_timeout(durations[duration_index],
                           function() mp.command_native({name = "quit-watch-later"}) end)
    timer_expire = mp.get_time() + durations[duration_index]

    mp.osd_message("Will sleep in " ..
                       humanize_duration(durations[duration_index]))
end

-- if the timer is set, show in how many seconds it will expire.
local function show_sleep_timer()
    if timer == nil then
        mp.osd_message("No sleep timer set")
        return
    end

    local diff = timer_expire - mp.get_time()

    mp.osd_message("Will sleep in " .. humanize_duration(math.floor(diff)))
end

-- make the functions available for use.
mp.add_key_binding(nil, 'cycle-sleep-timer', cycle_sleep_timer)
mp.add_key_binding(nil, 'show-sleep-timer', show_sleep_timer)
