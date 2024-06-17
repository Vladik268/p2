local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local drill_delay = 30 + 2 + 1.5
local DrillWP = { icon = Icon.Drill, position_by_element = EHI:GetInstanceElementID(100002, 2835) }
local escape_delay = 3 + 27 + 1
local EscapeWP = { icon = Icon.Escape, position_by_element = EHI:GetInstanceElementID(100009, 2910) }
---@type ParseTriggerTable
local triggers = {
    [101855] = { time = 120 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(DrillWP), hint = Hints.DrillDelivery },
    [101854] = { time = 90 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(DrillWP), hint = Hints.DrillDelivery },
    [101853] = { time = 60 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(DrillWP), hint = Hints.DrillDelivery },
    [101849] = { time = 30 + drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(DrillWP), hint = Hints.DrillDelivery },
    [101844] = { special_function = SF.Trigger, data = { 1018441, 1018442 } },
    [1018441] = { time = drill_delay, id = "LanceDrop", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(DrillWP), hint = Hints.DrillDelivery },
    [1018442] = { time = 25, id = "ForcedAlarm", icons = { Icon.Alarm }, class = TT.Warning, condition_function = CF.IsStealth, hint = Hints.Alarm },
    [101629] = { id = "ForcedAlarm", special_function = SF.RemoveTracker },

    [102223] = { time = 90 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.LootEscape },
    [102188] = { time = 60 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.LootEscape },
    [102187] = { time = 45 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.LootEscape },
    [102186] = { time = 30 + escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.LootEscape },
    [102190] = { time = escape_delay, id = "Escape", icons = Icon.HeliEscape, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(EscapeWP), hint = Hints.LootEscape }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 25 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 20, time = 1 + 10 + 45, on_fail_refresh_t = 45, on_success_refresh_t = 20 + 10 + 45, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 2 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 3 })
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 4 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 20%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:ShowLootCounter({ max = 8 })

local required_bags = 4
if EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
    required_bags = 5
elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
    required_bags = 6
end
local total_xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                hox3_vault_objective = { min_max = 2 }
            },
            loot_all = { min = required_bags, max = 8 }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "vault_found" },
                { amount = 2000, name = "hox3_vault_objective" },
                { amount = 4000, name = "vault_open" },
                { amount = 2000, name = "hox3_traitor_killed" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = total_xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 4000, name = "vault_found" },
                { amount = 8000, name = "vault_open" },
                { amount = 2000, name = "hox3_traitor_killed" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override = total_xp_override
        }
    }
})