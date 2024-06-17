local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [100322] = { time = 120, id = "Fuel", icons = { Icon.Oil }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { icon = Icon.Defend, position_by_element_and_remove_vanilla_waypoint = EHI:GetInstanceElementID(100038, 8075) }, hint = EHI.Hints.FuelTransfer },
    [100323] = { id = "Fuel", special_function = SF.PauseTracker }
}

if EHI:IsClient() then
    triggers[100047] = EHI:ClientCopyTrigger(triggers[100322], { time = 60 })
    triggers[100049] = EHI:ClientCopyTrigger(triggers[100322], { time = 30 })
end

local DisableWaypoints = {}

for i = 6850, 7525, 225 do
    DisableWaypoints[EHI:GetInstanceElementID(100021, i)] = true -- Defend
    DisableWaypoints[EHI:GetInstanceElementID(100022, i)] = true -- Fix
end

---@type ParseAchievementTable
local achievements =
{
    wwh_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100012] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [101250] = { special_function = SF.SetAchievementFailed },
            [100082] = { special_function = SF.SetAchievementComplete },
        }
    },
    wwh_10 =
    {
        elements =
        {
            [100946] = { max = 4, class = TT.Achievement.Progress },
            [101226] = { special_function = SF.IncreaseProgress }
        }
    }
}

local other =
{
    [100946] = EHI:AddAssaultDelay({}) -- 30s
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100374] = { id = "Snipers", single_sniper = true, remaining_snipers = 8, class = TT.Sniper.Count }
    other[100375] = { id = "Snipers", sniper_count = 2, remaining_snipers = 8, class = TT.Sniper.Count }
    other[100376] = { id = "Snipers", sniper_count = 3, remaining_snipers = 8, class = TT.Sniper.Count }
    other[100513] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100516] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100517] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    assault = { diff = 1 }
})
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({ max = 8 })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "alaskan_deal_crew_saved" },
        { amount = 5000, name = "alaskan_deal_captain_reached_boat" },
        { amount = 6000, name = "alaskan_deal_boat_fueled" },
        { escape = 1000 }
    },
    loot =
    {
        money = 400,
        weapon = 600
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    money = { max = 4 },
                    weapon = { max = 4 }
                }
            }
        }
    }
})