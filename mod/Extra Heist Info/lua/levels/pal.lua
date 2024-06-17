local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local element_sync_triggers =
{
    [102887] = { time = 1800/30, id = "HeliCage", icons = Icon.HeliLootDrop, hook_element = 102892, hint = Hints.Loot }
}
---@type ParseTriggerTable
local triggers = {
    --[100240] = { id = "PAL", special_function = SF.RemoveTracker },
    [102502] = { time = 60, id = "PAL", icons = { Icon.Money }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.pal_Money },
    [102505] = { id = "PAL", special_function = SF.RemoveTracker },
    [102749] = { id = "PAL", special_function = SF.PauseTracker },
    [102738] = { id = "PAL", special_function = SF.PauseTracker },
    [102744] = { id = "PAL", special_function = SF.UnpauseTracker },
    [102826] = { id = "PAL", special_function = SF.RemoveTracker },

    [102301] = { time = 15, id = "Trap", icons = { Icon.C4 }, class = TT.Warning, hint = Hints.Explosion },
    [101566] = { id = "Trap", special_function = SF.RemoveTracker },

    [101230] = { time = 120, id = "Water", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.crojob3_Water, waypoint = { icon = Icon.Water, position_by_element = 101117 } },
    [101231] = { id = "Water", special_function = SF.PauseTracker }
}

local sync_triggers = {}
if EHI:EscapeVehicleWillReturn("pal") then
    local heli = { id = "HeliCageDelay", icons = Icon.HeliLootDropWait, special_function = SF.ReplaceTrackerWithTracker, data = { id = "HeliCage" }, class = TT.Warning, hint = Hints.LootTimed }
    sync_triggers[EHI:GetInstanceElementID(100013, 4700)] = heli
    sync_triggers[EHI:GetInstanceElementID(100013, 4750)] = heli
    sync_triggers[EHI:GetInstanceElementID(100013, 4800)] = heli
    sync_triggers[EHI:GetInstanceElementID(100013, 4850)] = heli
end
if EHI:IsClient() then
    local ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists = EHI:RegisterCustomSF(function(self, trigger, ...)
        self._trackers:RemoveTracker(trigger.data.id)
        if self._trackers:TrackerDoesNotExist(trigger.id) then
            self:CreateTracker(trigger)
        end
    end)
    triggers[102892] = { additional_time = 1800/30 + 120, random_time = 60, id = "HeliCage", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot }
    triggers[EHI:GetInstanceElementID(100013, 4700)] = { additional_time = 180, random_time = 60, id = "HeliCageDelay", icons = Icon.HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning, hint = Hints.LootTimed }
    triggers[EHI:GetInstanceElementID(100013, 4750)] = { additional_time = 180, random_time = 60, id = "HeliCageDelay", icons = Icon.HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning, hint = Hints.LootTimed }
    triggers[EHI:GetInstanceElementID(100013, 4800)] = { additional_time = 180, random_time = 60, id = "HeliCageDelay", icons = Icon.HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning, hint = Hints.LootTimed }
    triggers[EHI:GetInstanceElementID(100013, 4850)] = { additional_time = 180, random_time = 60, id = "HeliCageDelay", icons = Icon.HeliLootDropWait, special_function = ReplaceTrackerWithTrackerAndAddTrackerIfDoesNotExists, data = { id = "HeliCage" }, class = TT.Warning, hint = Hints.LootTimed }
end

---@type ParseAchievementTable
local achievements =
{
    pal_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [102301] = { class = TT.Achievement.Status },
            [101976] = { special_function = SF.SetAchievementComplete },
            [101571] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100658] = EHI:AddAssaultDelay({}) -- 30s; Captain is enabled from start
}
if EHI:GetWaypointOption("show_waypoints_escape") then
    for i = 4700, 4850, 50 do
        local waypoint_id = EHI:GetInstanceElementID(100019, i)
        other[EHI:GetInstanceElementID(100004, i)] = { special_function = SF.ShowWaypoint, data = { icon = Icon.LootDrop, position_by_element = waypoint_id } }
    end
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = {
        base = sync_triggers,
        element = element_sync_triggers
    }
})
local value_max = tweak_data.achievement.loot_cash_achievements.pal_2.secured.value
local loot_value = managers.money:get_secured_bonus_bag_value("counterfeit_money", 1)
local max = math.ceil(value_max / loot_value)
EHI:ShowAchievementLootCounter({
    achievement = "pal_2",
    max = max
})
EHI:ShowLootCounter({
    max_bags_for_level = {
        mission_xp = 3000,
        xp_per_bag_all = 1000,
        objective_triggers = { 103154, 100427, 100428, 103187, 103188, 103189 }
    },
    no_max = true
})

local DisableWaypoints =
{
    -- Defend
    [100912] = true,
    [100913] = true,
    -- Fix
    [100916] = true,
    [100917] = true
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:UpdateUnits({ [102192] = { remove_vanilla_waypoint = 100943 } }) -- Drill
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "counterfeit_found_sus_doors" },
        { amount = 2500, name = "counterfeit_first_hack_finish" },
        { amount = 2000, name = "counterfeit_defuse_c4", optional = true },
        { amount = 5000, name = "vault_drill_done" },
        { amount = 6000, name = "vault_open" },
        { amount = 4000, name = "counterfeit_printed_money", optional = true },
        { escape = 3000 }
    },
    loot =
    {
        counterfeit_money = 1000
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives = true
            },
            no_max = true
        }
    }
})