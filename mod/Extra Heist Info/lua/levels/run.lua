local EHI = EHI
local Icon = EHI.Icons
---@class EHIrun9Tracker : EHIAchievementUnlockTracker
---@field super EHIAchievementUnlockTracker
EHIrun9Tracker = class(EHIAchievementUnlockTracker)
---@param dt number
function EHIrun9Tracker:update(dt)
    EHIrun9Tracker.super.update(self, dt)
    if self._time <= 0 then
        self._text:stop()
        self._achieved_popup_showed = true
        self:SetTextColor(Color.green)
        self:SetStatusText("finish")
        self:AnimateBG()
        self:RemoveTrackerFromUpdate()
    end
end

---@class EHIGasTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIGasTracker = class(EHIProgressTracker)
EHIGasTracker._forced_icons = { Icon.Fire }
function EHIGasTracker:Format()
    if self._max == 0 then
        return self._progress .. "/?"
    end
    return EHIGasTracker.super.Format(self)
end
EHIGasTracker.FormatProgress = EHIGasTracker.Format

---@class EHIZoneTracker : EHIWarningTracker
EHIZoneTracker = class(EHIWarningTracker)
EHIZoneTracker._forced_icons = { Icon.Wait }
EHIZoneTracker.SetCompleted = EHIAchievementTracker.SetCompleted

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local SetProgressMax = EHI:RegisterCustomSF(function(self, trigger, ...)
    if self._cache.ProgressMaxSet then
        return
    elseif self._trackers:CallFunction3(trigger.id, "SetTrackerProgressMax", trigger.max) then
        self._trackers:AddTracker({
            id = trigger.id,
            progress = 1,
            max = trigger.max,
            class = "EHIGasTracker",
            hint = Hints.run_Gas
        })
    end
    self._cache.ProgressMaxSet = true
end)
---@type ParseTriggerTable
local triggers = {
    [100377] = { time = 90, id = "ClearPickupZone", class = "EHIZoneTracker", hint = Hints.run_FinalZone },
    [101550] = { id = "ClearPickupZone", special_function = SF.CallCustomFunction, f = "SetCompleted" },

    -- Parking lot
    [102543] = { time = 6.5 + 8 + 4, id = "ObjectiveWait", icons = { Icon.Wait }, hint = Hints.Wait },

    [101967] = { time = 55 + 5 + 10 + 3, id = "HeliArrival", icons = { Icon.Heli, Icon.Escape }, waypoint = { icon = Icon.Goto, position_by_element_and_remove_vanilla_waypoint = 100372, restore_on_done = true }, hint = Hints.friend_Heli },

    [100144] = { id = "GasAmount", class = "EHIGasTracker", trigger_times = 1, hint = Hints.run_Gas },
    [100051] = { id = "GasAmount", special_function = SF.RemoveTracker }, -- In case the tracker gets stuck for drop-ins

    [1] = { id = "GasAmount", special_function = SF.IncreaseProgress },
    [2] = { special_function = SF.RemoveTrigger, data = { 102775, 102776, 102868 } }, -- Don't blink twice, just set the max once and remove the triggers

    [102876] = { special_function = SF.Trigger, data = { 1028761, 1 } },
    [1028761] = { time = 60, id = "Gas1", icons = { Icon.Fire }, hint = Hints.Fire },
    [102875] = { special_function = SF.Trigger, data = { 1028751, 1 } },
    [1028751] = { time = 60, id = "Gas2", icons = { Icon.Fire }, hint = Hints.Fire },
    [102874] = { special_function = SF.Trigger, data = { 1028741, 1 } },
    [1028741] = { time = 60, id = "Gas3", icons = { Icon.Fire }, hint = Hints.Fire },
    [102873] = { special_function = SF.Trigger, data = { 1028731, 1 } },
    [1028731] = { time = 80, id = "Gas4", icons = { Icon.Fire, Icon.Escape }, hint = Hints.run_GasFinal },

    [102775] = { special_function = SF.Trigger, data = { 1027751, 2 } },
    [1027751] = { max = 4, id = "GasAmount", special_function = SetProgressMax },
    [102776] = { special_function = SF.Trigger, data = { 1027761, 2 } },
    [1027761] = { max = 3, id = "GasAmount", special_function = SetProgressMax },
    [102868] = { special_function = SF.Trigger, data = { 1028681, 2 } },
    [1028681] = { max = 2, id = "GasAmount", special_function = SetProgressMax }
}
if EHI:MissionTrackersAndWaypointEnabled() then
    triggers[2] = { special_function = SF.CustomCode, f = function()
        managers.hud:RestoreWaypoint(101290)
    end } -- Show "exclamation" waypoint; overwrites default behavior -> Remove Triggers
    triggers[3] = { special_function = SF.CustomCode, f = function()
        managers.hud:SoftRemoveWaypoint(101290)
    end } -- Hide "exclamation" waypoint
    triggers[102876].data[3] = 3
    triggers[1028761].waypoint = { position_by_element = 101290 }
    triggers[102875].data[3] = 3
    triggers[1028751].waypoint = { position_by_element = 101290 }
    triggers[102874].data[3] = 3
    triggers[1028741].waypoint = { position_by_element = 101290 }
    triggers[102873].data[3] = 3
    triggers[1028731].waypoint = { icon = Icon.Escape, position_by_element = 101290 }
end

---@type ParseAchievementTable
local achievements =
{
    run_8 =
    {
        elements =
        {
            [102426] = { max = 8, class = TT.Achievement.Progress },
            [100658] = { special_function = SF.IncreaseProgress }
        },
        sync_params = { from_start = true }
    },
    run_9 =
    {
        elements =
        {
            [100120] = { time = 1800, class = "EHIrun9Tracker" },
            [100144] = { special_function = SF.SetAchievementFailed }
        },
        cleanup_callback = function()
            EHIrun9Tracker = nil ---@diagnostic disable-line
        end
    },
    run_10 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            [102426] = { class = TT.Achievement.Status },
            [100111] = { special_function = SF.SetAchievementFailed },
            [100664] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101486] = EHI:AddAssaultDelay({ trigger_times = 1 }) -- 30s
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local objectives =
{
    { amount = 4000, name = "heat_street_reached_crashsite" },
    { amount = 6000, name = "van_open" },
    { amount = 4000, name = "heat_street_reached_parking" },
    { amount = 6000, name = "heat_street_reached_hill" },
    { escape = 6000 }
}
if EHI._cache.street_new then
    objectives[1].amount = 7500
    objectives[2].amount = 7500
    objectives[3].amount = 7500
    objectives[4].amount = 7500
    objectives[5].escape = 10000
    EHI._cache.street_new = nil
end
EHI:AddXPBreakdown({
    objectives = objectives
})