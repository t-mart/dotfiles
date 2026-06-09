-- sleeptimer
-- ----------
-- Registers the "cycle-sleep-timer" function to set a sleep timer for a preset duration of time.
-- This time will be shown as a message on the OSD. Subsequent invocations of the function will
-- reset the timer and cycle to another larger preset duration. (Only one sleep timer will be
-- active at a time.)
--
-- When the duration elapses, MPV will quit-watch-later.
--
-- To disable the sleep timer after it has been set, continue invoking the function until it reaches
-- the "unset" state.
--
-- If a sleep timer is set, its remaining duration may be queried with the "show-sleep-timer"
-- function, which will show it on the OSD.
--
-- The countdown only ticks while media is playing; it pauses when the player is paused.
--
-- A timer can also be set programmatically via script-message:
--   script-message-to sleeptimer set-sleep-timer <seconds>
-- Pass 0 to unset.

local mp = require("mp")

local sleep_durations_seconds = {
    0,           -- not set. keep this, important for being able to disable
    60,          -- 1 minute
    5 * 60,      -- 5 minutes
    15 * 60,     -- 15 minutes
    30 * 60,     -- 30 minutes
    60 * 60,     -- 1 hour
    2 * 60 * 60, -- 2 hours
    4 * 60 * 60  -- 4 hours
}

assert(sleep_durations_seconds[1] == 0, "sleep_durations_seconds[1] must be 0 (the unset sentinel)")

-- show a warning when the duration crosses these thresholds
local warn_seconds = { 30, 5 }

---@class TimerState
---@field remaining number
---@field expire number|nil

---@type TimerState|nil
local active = nil
local scheduled = {}
local duration_index = 1

local function humanize_duration(total_seconds)
    local hours = math.floor(total_seconds / 3600)
    local minutes = math.floor((total_seconds % 3600) / 60)
    local seconds = total_seconds % 60

    local units = {}
    if hours > 0 then
        table.insert(units, string.format("%dh", hours))
    end
    if minutes > 0 then
        table.insert(units, string.format("%dm", minutes))
    end
    if seconds > 0 then
        table.insert(units, string.format("%.0fs", seconds))
    end

    return table.concat(units, " ")
end

local function cancel_all()
    for _, t in ipairs(scheduled) do
        t:kill()
    end
    scheduled = {}
end

local function on_timer_fire()
    cancel_all()
    active = nil
    mp.command_native({ name = "quit-watch-later" })
end

local function start_timeout()
    ---@cast active -nil
    cancel_all()
    active.expire = mp.get_time() + active.remaining
    table.insert(scheduled, mp.add_timeout(active.remaining, on_timer_fire))
    for _, threshold in ipairs(warn_seconds) do
        if active.remaining > threshold then
            table.insert(scheduled, mp.add_timeout(active.remaining - threshold, function()
                mp.osd_message("Sleeping in " .. humanize_duration(threshold))
            end))
        end
    end
end

local function stop_timeout()
    if active ~= nil and active.expire ~= nil then
        active.remaining = active.expire - mp.get_time()
        active.expire = nil
        cancel_all()
    end
end

local function show_sleep_timer_raw(seconds, is_paused)
    local suffix = is_paused and " (paused)" or ""
    mp.osd_message("Will sleep after " .. humanize_duration(seconds) .. suffix)
end

local function show_sleep_timer()
    if active == nil then
        mp.osd_message("No sleep timer set")
        return
    end

    local seconds = active.expire ~= nil
        and math.floor(active.expire - mp.get_time())
        or math.floor(active.remaining)
    local is_paused = mp.get_property_bool("pause")
    show_sleep_timer_raw(seconds, is_paused)
end

local function set_timer(seconds)
    stop_timeout()

    if seconds == 0 then
        active = nil
        duration_index = 1
        mp.osd_message("Sleep timer unset")
        return
    end

    active = { remaining = seconds, expire = nil }

    local is_paused = mp.get_property_bool("pause")

    if not is_paused then
        start_timeout()
    end

    show_sleep_timer_raw(seconds, is_paused)
end

-- set a sleep timer with a duration from a group of durations. invoke the function again to cycle
-- through the durations. if a sleep timer was already set, it will be cancelled and a new timer
-- created. An OSD message will display the currently set duration.
local function cycle_sleep_timer()
    duration_index = duration_index + 1

    if duration_index > #sleep_durations_seconds then
        duration_index = 1
    end

    set_timer(sleep_durations_seconds[duration_index])
end

mp.observe_property("pause", "bool", function(_, paused)
    if paused then
        stop_timeout()
    elseif active ~= nil then
        start_timeout()
    end
end)

mp.register_script_message("set-sleep-timer", function(seconds_str)
    local seconds = tonumber(seconds_str)
    if seconds == nil or seconds < 0 then
        mp.osd_message("set-sleep-timer: invalid duration")
        return
    end
    duration_index = 1
    set_timer(seconds)
end)

mp.add_key_binding(nil, 'cycle-sleep-timer', cycle_sleep_timer)
mp.add_key_binding(nil, 'show-sleep-timer', show_sleep_timer)
