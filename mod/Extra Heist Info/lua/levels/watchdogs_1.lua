local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local escape_delay = 18
local longest_car_drop_delay = 751/30
local triggers = {
    [102873] = { time = 36 + 5 + 3 + 60 + 30 + 38 + 7 + longest_car_drop_delay, id = "CarPickupLoot", icons = Icon.CarLootDrop, hint = Hints.Loot },
    [100936] = { time = 524/30, id = "CarPickupLoot", icons = Icon.CarLootDrop, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Loot },
    [102686] = { time = 552/30, id = "CarPickupLoot", icons = Icon.CarLootDrop, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Loot },

    [101256] = { time = 3 + 28 + 10 + 135/30 + 0.5 + 210/30, id = "CarEscape", icons = Icon.CarEscapeNoLoot, hint = Hints.Escape },
    [101088] = { id = "CarEscape", special_function = SF.RemoveTracker },

    [101218] = { time = 60 + 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [101219] = { time = 60 + 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [101221] = { time = 30 + 30 + escape_delay, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape }
}

if EHI:IsClient() then
    triggers[101307] = EHI:ClientCopyTrigger(triggers[102873], { time = 5 + 3 + 60 + 30 + 38 + 7 + longest_car_drop_delay })
    triggers[101308] = EHI:ClientCopyTrigger(triggers[102873], { time = 5 + 3 + 60 + 30 + 38 + 7 + longest_car_drop_delay })
    triggers[101309] = EHI:ClientCopyTrigger(triggers[102873], { time = 5 + 3 + 60 + 30 + 38 + 7 + longest_car_drop_delay })
    triggers[100944] = EHI:ClientCopyTrigger(triggers[102873], { time = 3 + 60 + 30 + 38 + 7 + longest_car_drop_delay })
    triggers[101008] = EHI:ClientCopyTrigger(triggers[102873], { time = 60 + 30 + 38 + 7 + longest_car_drop_delay })
    triggers[101072] = EHI:ClientCopyTrigger(triggers[102873], { time = 30 + 38 + 7 + longest_car_drop_delay })
    triggers[101073] = EHI:ClientCopyTrigger(triggers[102873], { time = 38 + 7 + longest_car_drop_delay })

    triggers[103300] = EHI:ClientCopyTrigger(triggers[101218], { time = 60 + 30 + 30 + escape_delay })
    triggers[103301] = EHI:ClientCopyTrigger(triggers[101218], { time = 30 + 30 + escape_delay })
    triggers[103302] = EHI:ClientCopyTrigger(triggers[101218], { time = 30 + escape_delay })
    triggers[101222] = EHI:ClientCopyTrigger(triggers[101218], { time = escape_delay })
end

---@type ParseAchievementTable
local achievements =
{
    hot_wheels =
    {
        elements =
        {
            [101137] = { status = EHI.Const.Trackers.Achievement.Status.Finish, class = TT.Achievement.Status },
            [102487] = { special_function = SF.SetAchievementFailed },
            [102470] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101244] = EHI:AddAssaultDelay({ control = 60 }),
    [101245] = EHI:AddAssaultDelay({ control = 45 }),
    [101249] = EHI:AddAssaultDelay({ control = 50 })
}
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[101223] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 101231 } }
    other[102855] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Escape, position_by_element = 102862 } }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({ max = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) and 12 or 8 })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "all_bags_secured" },
        { escape = 12000 },
        { amount = 2000, name = "heli_escape" }
    },
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives =
                {
                    escape = true
                }
            },
            max =
            {
                objectives = true
            }
        }
    }
})