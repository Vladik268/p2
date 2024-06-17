local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local LootDrop = { Icon.Escape, Icon.LootDrop }
local TimedLootDrop = { Icon.Escape, Icon.LootDrop, Icon.Wait }
local triggers = {
    [100647] = { time = 240 + 60, id = "Chimney", icons = LootDrop, hint = Hints.Loot }
}
if EHI:EscapeVehicleWillReturn("cane") then
    triggers[EHI:GetInstanceElementID(100078, 10700)] = { time = 60, id = "Chimney", icons = LootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot }
    triggers[EHI:GetInstanceElementID(100078, 11000)] = { time = 60, id = "Chimney", icons = LootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot }
    triggers[EHI:GetInstanceElementID(100011, 10700)] = { time = 207 + 3, id = "ChimneyClose", icons = TimedLootDrop, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" }, hint = Hints.LootTimed }
    triggers[EHI:GetInstanceElementID(100011, 11000)] = { time = 207 + 3, id = "ChimneyClose", icons = TimedLootDrop, class = TT.Warning, special_function = SF.ReplaceTrackerWithTracker, data = { id = "Chimney" }, hint = Hints.LootTimed }
    if EHI:MissionTrackersAndWaypointEnabled() then
        local DisableWaypoints =
        {
            [EHI:GetInstanceElementID(100016, 10700)] = true,
            [EHI:GetInstanceElementID(100016, 11000)] = true
        }
        EHI:DisableWaypoints(DisableWaypoints)
        triggers[EHI:GetInstanceElementID(100011, 10700)].waypoint = { icon = Icon.LootDrop, position_by_element = EHI:GetInstanceElementID(100016, 10700) }
        triggers[EHI:GetInstanceElementID(100011, 11000)].waypoint = { icon = Icon.LootDrop, position_by_element = EHI:GetInstanceElementID(100016, 11000) }
    end
end

---@param present_amount number?
local function cane_5(present_amount)
    EHI:HookWithID(PlayerManager, "set_synced_deployable_equipment", "EHI_cane_5_fail_trigger", function(self, ...)
        if self._peer_used_deployable then
            managers.ehi_achievement:SetAchievementFailed("cane_5")
            EHI:Unhook("cane_5_fail_trigger")
        end
    end)
    EHI:ShowAchievementLootCounterNoCheck({
        achievement = "cane_5",
        progress = present_amount or 0,
        max = 10,
        counter =
        {
            loot_type = "present"
        },
        no_sync = true
    })
end
---@type ParseAchievementTable
local achievements =
{
    cane_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101167] = { time = 1800, class = TT.Achievement.Unlock },
            [101176] = { special_function = SF.SetAchievementFailed },
        }
    },
    cane_5 =
    {
        elements =
        {
            [100544] = { special_function = SF.CustomCode, f = function()
                if #managers.assets:get_unlocked_asset_ids(true) == 0 then
                    cane_5()
                end
            end },
        },
        load_sync = function(self)
            if #managers.assets:get_unlocked_asset_ids(true) ~= 0 or managers.player:has_deployable_been_used() then
                return
            end
            local present_amount = managers.loot:GetSecuredBagsTypeAmount("present")
            if present_amount < 10 then
                cane_5(present_amount)
            end
        end
    }
}

local other =
{
    [EHI:GetInstanceElementID(100002, 10100)] = EHI:AddAssaultDelay({ control_additional_time = 20 + 15 + 405/30 + 15, random_time = 5 + 9 + 10 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102604] = { id = "Snipers", class = TT.Sniper.Count, single_sniper = true }
    other[102606] = { id = "Snipers", class = TT.Sniper.Count, sniper_count = 2 }
    other[102610] = { id = "Snipers", class = TT.Sniper.Count, sniper_count = 3 }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102391] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[102361] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102362] = { id = "Snipers", special_function = SF.DecreaseCounter }
    if EHI:IsClient() then
        other[102369] = { id = "Snipers", class = TT.Sniper.Count, special_function = SF.AddTrackerIfDoesNotExist, trigger_times = 1 }
    end
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowAchievementLootCounter({
    achievement = "cane_3",
    max = 100,
    show_finish_after_reaching_target = true,
    difficulty_pass = ovk_and_up
})
EHI:ShowLootCounter({
    max_bags_for_level =
    {
        mission_xp = 4000,
        xp_per_bag_all = 1000,
        objective_triggers = { 100584, 101163 }
    },
    no_max = true
})

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1000, name = "present_finished" },
        { amount = 4000, name = "safe_event_done", optional = true },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min =
            {
                objectives =
                {
                    present_finished = { times = 4 },
                    escape = true
                },
                loot_all = { times = 4 }
            },
            no_max = true
        }
    }
})