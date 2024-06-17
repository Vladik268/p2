local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [101541] = { time = 2, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },
    [101558] = { time = 5, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },
    [101601] = { time = 7, id = "VanDriveAway", icons = Icon.CarWait, class = TT.Warning, hint = Hints.LootTimed },

    [103172] = { time = 45 + 830/30, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [103182] = { time = 600/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [103181] = { time = 580/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape },
    [101770] = { time = 650/30, id = "Van", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTracker, hint = Hints.LootEscape }
}
local other = {}
if EHI:GetOption("show_escape_chance") then
    other[101433] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
    local start_chance = EHI:GetValueBasedOnDifficulty({
        normal = 25,
        hard = 27,
        veryhard = 32,
        overkill_or_above = 36
    })
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_escape:AddEscapeChanceTracker(dropin, start_chance)
    end)
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[103183] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103194 } }
    other[103182] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103193 } }
    other[103181] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 103192 } }
    other[101770] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101776 } }
end

---@type ParseAchievementTable
local achievements =
{
    ameno_7 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100073] = { status = Status.Loud, class = TT.Achievement.Status },
            [100624] = { special_function = SF.SetAchievementFailed },
            [100634] = { special_function = SF.SetAchievementComplete },
            [100149] = { status = Status.Defend, special_function = SF.SetAchievementStatus }
        }
    }
}
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
            { amount = 2000, timer = 120, stealth = true },
            { amount = 6000, stealth = true },
            { amount = 8000, loud = true }
        }
    }
})