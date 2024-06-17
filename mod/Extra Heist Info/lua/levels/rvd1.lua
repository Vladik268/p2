local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local pink_car = { { icon = Icon.Car, color = Color("D983D1") }, Icon.Goto }
local triggers = {
    [100778] = { time = 10 + 17 + 13 + 15 + 17, id = "DefendWait", icons = { Icon.Wait }, hint = Hints.Wait },

    --310/30 anim_crash_04; Waypoint ID 100490
    [100010] = { time = 8 + 17 + 1 + 310/30, id = "PinkArrival", icons = pink_car, hint = Hints.rvd_Pink },
    --260/30 anim_crash_02; Waypoint ID 101196
    [101114] = { time = 260/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker, hint = Hints.rvd_Pink },
    --201/30 anim_crash_05; Waypoint ID 101201
    [101127] = { time = 201/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker, hint = Hints.rvd_Pink },
    --284/30 anim_crash_03; Waypoint ID 101138
    [101108] = { time = 284/30, id = "PinkArrival", icons = pink_car, special_function = SF.SetTimeOrCreateTracker, hint = Hints.rvd_Pink },

    [100727] = { time = 6 + 18 + 8.5 + 30 + 25 + 375/30, id = "Escape", icons = Icon.CarEscape, hint = Hints.LootEscape },
    [100207] = { time = 260/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTrackerIfEnabled, hint = Hints.LootEscape },
    [100209] = { time = 250/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.SetTimeOrCreateTrackerIfEnabled, hint = Hints.LootEscape }
}
if EHI:IsClient() then
    triggers[100753] = EHI:ClientCopyTrigger(triggers[100778], { time = 17 + 13 + 15 + 17 })
    triggers[100756] = EHI:ClientCopyTrigger(triggers[100778], { time = 13 + 15 + 17 })
    triggers[100757] = EHI:ClientCopyTrigger(triggers[100778], { time = 15 + 17 })
    triggers[100761] = EHI:ClientCopyTrigger(triggers[100778], { time = 17 })
    triggers[100169] = EHI:ClientCopyTrigger(triggers[100010], { time = 17 + 1 + 310/30 })
    triggers[100731] = EHI:ClientCopyTrigger(triggers[100727], { time = 18 + 8.5 + 30 + 25 + 375/30 })
    triggers[100716] = EHI:ClientCopyTrigger(triggers[100727], { time = 8.5 + 30 + 25 + 375/30 })
    triggers[100286] = EHI:ClientCopyTrigger(triggers[100727], { time = 30 + 25 + 375/30 })
    triggers[101065] = EHI:ClientCopyTrigger(triggers[100727], { time = 25 + 375/30 })
end

---@type ParseAchievementTable
local achievements =
{
    rvd_9 =
    {
        elements =
        {
            [100107] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [100839] = { special_function = SF.SetAchievementFailed },
            [100869] = { special_function = SF.SetAchievementComplete },
        },
        sync_params = { from_start = true }
    },
    rvd_10 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [100057] = { time = 60, class = TT.Achievement.Base, special_function = SF.ShowAchievementFromStart },
            [100247] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [100179] = EHI:AddAssaultDelay({ control = 1 + 9.5 + 11 + 1 })
}
if EHI:IsLootCounterVisible() then
    other[100107] = { special_function = EHI:RegisterCustomSF(function(...)
        EHI:ShowLootCounterNoChecks({ max = 6 })
    end)}
    other[100037] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:SecuredMissionLoot() -- Secured diamonds at Mr. Blonde or in a Van
    end) }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 3 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 2 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:GetWaypointOption("show_waypoints_escape") then
    other[101105] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 100490 } }
    other[101104] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101196 } }
    other[101106] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101201 } }
    other[101102] = { special_function = SF.ShowWaypoint, data = { icon = Icon.Car, position_by_element = 101138 } }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 4000, name = "rvd1_defended_warehouse" },
        { amount = 4000, name = "rvd1_escorted_pink" },
        { amount = 1500, name = "saw_done" }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    saw_done = { max = 4 }
                },
                loot_all = { min = 1, max = 6 }
            }
        }
    }
})