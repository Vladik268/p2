local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local zone_delay = 12
local LootDropWaypoint = { icon = Icon.LootDrop, position_by_element_and_remove_vanilla_waypoint = 104215 }
---@type ParseTriggerTable
local triggers = {
    [104176] = { time = 25 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, waypoint = deep_clone(LootDropWaypoint), hint = Hints.LootTimed },
    [104178] = { time = 35 + zone_delay, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, waypoint = deep_clone(LootDropWaypoint), hint = Hints.LootTimed },

    [103172] = { time = 2 + 830/30, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [103182] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [103181] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101770] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    lets_do_this =
    {
        elements =
        {
            [100073] = { time = 36, class = TT.Achievement.Base },
            [101784] = { special_function = SF.SetAchievementComplete },
        },
        load_sync = function(self)
            self._achievements:AddTimedAchievementTracker("lets_do_this", 36)
        end
    },
    cac_12 =
    {
        elements =
        {
            [100074] = { status = Status.Alarm, class = TT.Achievement.Status, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
                if self:InteractionExists("circuit_breaker_off") then
                    self:CreateTracker(trigger)
                end
            end) },
            [104406] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [104408] = { special_function = SF.SetAchievementComplete },
            [104409] = { special_function = SF.SetAchievementFailed },
            [103116] = { special_function = SF.SetAchievementFailed }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [104176] = EHI:AddAssaultDelay({ control = 25 + 90 }),
    [104178] = EHI:AddAssaultDelay({ control = 35 + 90 })
}
if EHI:GetOption("show_loot_counter") and not EHI:IsPlayingCrimeSpree() then
    other[100073] = EHI:AddLootCounter(function()
        EHI:ShowLootCounterNoCheck({ max = 10 })
    end, true, function(self)
        local jewelry = { 102948, 102949, 102950, 100005, 100006, 100013, 100014, 100007, 100008 }
        local jewelry_to_subtract = 0
        for _, jewelry_id in ipairs(jewelry) do
            if self:IsMissionElementDisabled(jewelry_id) then
                jewelry_to_subtract = jewelry_to_subtract + 1
            end
        end
        EHI:ShowLootCounterNoChecks({ max = 10 - jewelry_to_subtract })
    end, true)
    local DecreaseProgressMax = EHI:RegisterCustomSF(function(self, ...)
        self._loot:DecreaseLootCounterProgressMax()
    end)
    other[101613] = { special_function = DecreaseProgressMax }
    other[101617] = { special_function = DecreaseProgressMax }
    other[101637] = { special_function = DecreaseProgressMax }
    other[101754] = { special_function = DecreaseProgressMax }
    other[101852] = { special_function = DecreaseProgressMax }
    other[102018] = { special_function = DecreaseProgressMax }
    other[102091] = { special_function = DecreaseProgressMax }
    other[102098] = { special_function = DecreaseProgressMax }
    other[102126] = { special_function = DecreaseProgressMax }
end
if EHI:GetOption("show_escape_chance") then
    local start_chance = 30 -- Normal
    if EHI:IsDifficulty(EHI.Difficulties.Hard) then
        start_chance = 33
    elseif EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
        start_chance = 35
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
        start_chance = 37
    end
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, start_chance)
    end)
    other[101614] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103194 } }
    other[103182] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103193 } }
    other[103181] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103192 } }
    other[101770] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101776 } }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 4000, timer = 120, stealth = true },
            { amount = 10000, stealth = true },
            { amount = 10000, loud = true }
        }
    }
})