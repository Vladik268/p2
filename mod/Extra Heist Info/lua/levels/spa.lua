local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [100681] = { time = 60, id = "CharonPickLock", icons = { Icon.Door }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { position_by_unit = 102837 }, hint = Hints.Wait },
    [101430] = { id = "CharonPickLock", special_function = SF.PauseTracker },

    [102266] = { max = 6, id = "SniperDeath", icons = { "sniper" }, class = TT.Progress, hint = Hints.Kills },
    [103419] = { id = "SniperDeath", special_function = SF.IncreaseProgress },

    [100549] = { time = 20, id = "ObjectiveWait", icons = { Icon.Wait }, waypoint = { icon = Icon.Defend, position_by_element_and_remove_vanilla_waypoint = 100935, restore_on_done = true }, hint = Hints.Wait },
    [101202] = { time = 15, id = "Escape", icons = Icon.CarEscape, waypoint = { icon = Icon.Escape, position_by_element = 100944 }, hint = Hints.LootEscape },
    [101313] = { time = 75, id = "Escape", icons = Icon.CarEscape, waypoint = { icon = Icon.Escape, position_by_element = 100910 }, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    spa_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            -- It was 7 minutes before the change
            [101989] = { time = 360, class = TT.Achievement.Base },
            [101997] = { special_function = SF.SetAchievementComplete },
        },
        sync_params = { from_start = true }
    },
    spa_6 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101989] = { max = 8, class = TT.Achievement.Progress, show_finish_after_reaching_target = true },
            [101999] = { special_function = SF.IncreaseProgress },
            [102002] = { special_function = SF.FinalizeAchievement },
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [EHI:GetInstanceElementID(100003, 7950)] = EHI:AddAssaultDelay({ control_additional_time = 3 + 12 + 12 + 4 + 10, random_time = 5, trigger_times = 1 })
}
if EHI:IsClient() then
    local original = other[EHI:GetInstanceElementID(100003, 7950)]
    other[EHI:GetInstanceElementID(100024, 7950)] = EHI:ClientCopyTrigger(original, { control_additional_time = 12 + 12 + 4 + 10 })
    other[EHI:GetInstanceElementID(100053, 7950)] = EHI:ClientCopyTrigger(original, { control_additional_time = 12 + 4 + 10 })
    other[EHI:GetInstanceElementID(100026, 7950)] = EHI:ClientCopyTrigger(original, { control_additional_time = 4 + 10 })
    other[EHI:GetInstanceElementID(100179, 7950)] = EHI:ClientCopyTrigger(original, { control_additional_time = 10 })
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({ max = 4 })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "brooklyn_1010_opened_door_to_roof" },
        { amount = 6000, name = "brooklyn_1010_secured_briefcase" },
        { amount = 4000, name = "brooklyn_1010_used_zipline" },
        { escape = 8000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 4 }
            }
        }
    }
})