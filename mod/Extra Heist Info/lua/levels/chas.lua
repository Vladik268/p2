local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local element_sync_triggers = {
    [100209] = { time = 5, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, client_on_executed = true, hook_element = 100602, remove_trigger_when_executed = true, hint = Hints.LootEscape },
    [100883] = { time = 12.5, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, hook_element = 102453, remove_trigger_when_executed = true, hint = Hints.DrillDelivery }
}
local triggers = {
    [102863] = { time = 41.5, id = "TramArrivesWithDrill", icons = { Icon.Train, Icon.Drill, Icon.Goto }, hint = Hints.DrillDelivery }
}
if EHI:IsClient() then
    triggers[100602] = { additional_time = 90 + 5, random_time = 20, id = "LoudEscape", icons = Icon.CarEscape, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootEscape }
    triggers[102453] = { additional_time = 60 + 12.5, random_time = 20, id = "HeliArrivesWithDrill", icons = Icon.HeliDropDrill, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.DrillDelivery }
end

---@type ParseAchievementTable
local achievements =
{
    chas_9 =
    {
        elements =
        {
            [100781] = { status = EHI.Const.Trackers.Achievement.Status.Defend, class = TT.Achievement.Status },
            [100907] = { special_function = SF.SetAchievementFailed },
            [100906] = { special_function = SF.SetAchievementComplete }
        }
    },
    chas_11 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { time = 360, class = TT.Achievement.Base }
        },
        load_sync = function(self)
            self._achievements:AddTimedAchievementTracker("chas_11", 360)
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 2,
        overkill_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ShowAchievementLootCounter({
    achievement = "chas_10",
    max = 15,
    show_finish_after_reaching_target = true,
    load_sync = function(self)
        self._loot:SyncSecuredLoot("chas_10")
    end,
    show_loot_counter = true,
    loot_counter_on_fail = true,
    silent_failed_on_alarm = true,
    difficulty_pass = ovk_and_up
})

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})

local xp_override =
{
    params =
    {
        min_max =
        {
            loot_all = { max = 14 }
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
                { amount = 1000, name = "china1_alarm_disabled" },
                { amount = 1000, name = "china1_found_basement_door" },
                { amount = 1000, name = "diamond_heist_found_keycard" },
                { amount = 1000, name = "china1_enter_warehouse" },
                { amount = 500, name = "vault_found" },
                { amount = 2000, name = "btm_used_keycard" },
                { amount = 3000, name = "china1_auction_room_stealth" },
                { amount = 1000, name = "timelock_done" },
                { amount = 1000, name = "ggc_laser_disabled" },
                { amount = 1000, name = "china1_vault_gate_open" },
                { amount = 1000, name = "china1_vault_pc_hack", optional = true },
                { amount = 1000, name = "china1_dragon_statue_picked_up" },
                { amount = 2000, name = "china1_dragon_statue_secured" },
                { escape = 1000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "pc_hack" },
                { amount = 1000, name = "china1_found_forklift_keys" },
                { amount = 500, name = "china1_enter_warehouse" },
                { amount = 2000, name = "china1_pick_up_thermal_drill" },
                { amount = 1000, name = "china1_placed_thermal_drill" },
                { amount = 1000, name = "china1_gas_disabled" },
                { amount = 3000, name = "vault_open" },
                { amount = 2500, name = "china1_auction_room_loud" },
                { amount = 1000, name = "china1_vault_gate_open" },
                { escape = 3000 }
            },
            loot_all = 1000,
            total_xp_override = xp_override
        }
    }
})