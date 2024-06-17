local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [103030] = { time = 19, id = "InsideManTalk", icons = { "pd2_talk" }, hint = Hints.Wait },

    -- Heli Extraction
    [101432] = { id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.GetElementTimerAccurate, element = 101362, hint = Hints.Escape },

    [102571] = { additional_time = 10 + 15.25 + 0.5 + 0.2, random_time = 5, id = "WinchDrop", icons = Icon.HeliDropWinch, hint = Hints.brb_WinchDelivery },

    [102675] = { additional_time = 5 + 10 + 14, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.GetElementTimerAccurate, element = 102674, hint = Hints.Wait },

    [103269] = { time = 7 + 614/30, id = "BoatEscape", icons = Icon.BoatEscapeNoLoot, hint = Hints.Escape }
}
if EHI:IsClient() then
    local wait_time = 90 -- Very Hard and below
    local pickup_wait_time = 25 -- Normal and Hard
    if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.Mayhem) then -- Very Hard to Mayhem
        pickup_wait_time = 40
    end
    if EHI:IsBetweenDifficulties(EHI.Difficulties.OVERKILL, EHI.Difficulties.Mayhem) then -- OVERKILL or Mayhem
        wait_time = 120
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
        wait_time = 150
        pickup_wait_time = 55
    end
    triggers[101432].client = { time = wait_time, random_time = 30 }
    triggers[102675].client = { time = pickup_wait_time, random_time = 15 }
    if ovk_and_up then -- OVK and up
        triggers[101456] = { time = 120, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
    end
    triggers[101366] = { time = 60, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
    triggers[101463] = { time = 45, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
    triggers[101367] = { time = 30, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
    triggers[101372] = { time = 15, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.SetTrackerAccurate, hint = Hints.Escape }
    triggers[102678] = { time = 45, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate, hint = Hints.Wait }
    triggers[102679] = { time = 15, id = "HeliPickUpSafe", icons = { Icon.Heli, Icon.Winch }, special_function = SF.SetTrackerAccurate, hint = Hints.Wait }
end

local function chca_9_fail()
    managers.ehi_achievement:SetAchievementFailed("chca_9")
    EHI:Unhook("chca_9_killed")
    EHI:Unhook("chca_9_killed_by_anyone")
end
---@type ParseAchievementTable
local achievements =
{
    chca_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            -- Players spawned
            [100264] = { special_function = SF.Trigger, data = { 1, 2 } }, -- Guest Rooms (civilian mode)
            [102955] = { special_function = SF.Trigger, data = { 1, 2 } }, -- Crew Deck
            [1] = { class = TT.Achievement.Status },
            [2] = { special_function = SF.CustomCode, f = function()
                local function check(_, data)
                    if data.variant ~= "melee" then
                        chca_9_fail()
                    end
                end
                EHI:HookWithID(StatisticsManager, "killed", "EHI_chca_9_killed", check)
                EHI:HookWithID(StatisticsManager, "killed_by_anyone", "EHI_chca_9_killed_by_anyone", check)
            end }
        },
        alarm_callback = chca_9_fail
    },
    chca_10 =
    {
        difficulty_pass = EHI:IsMayhemOrAbove(),
        elements =
        {
            [100264] = { max = 8, class = TT.Achievement.Progress, show_finish_after_reaching_target = true }, -- Guest Rooms (civilian mode)
            [102955] = { max = 8, class = TT.Achievement.Progress, show_finish_after_reaching_target = true }, -- Crew Deck
            [102944] = { special_function = SF.IncreaseProgress }, -- Bodybag thrown
            [103371] = { special_function = SF.SetAchievementFailed } -- Civie killed
        },
        failed_on_alarm = true,
        sync_params = { from_start = true }
    },
    chca_12 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [EHI:GetInstanceElementID(100041, 11770)] = { special_function = SF.ShowAchievementFromStart, class = TT.Achievement.Status },
            [103584] = { status = EHI.Const.Trackers.Achievement.Status.Finish, special_function = SF.SetAchievementStatus }
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 45 })
}
if EHI:CanShowAchievement("chca_12") and ovk_and_up then
    local active_saws = 0
    local function chca_12(unit_id, unit_data, unit)
        unit:timer_gui():chca_12()
    end
    local function check(...)
        active_saws = active_saws + 1
        if active_saws > 1 then
            managers.ehi_achievement:SetAchievementFailed("chca_12")
        end
    end
    local function saw_done()
        active_saws = active_saws - 1
    end
    function TimerGui:chca_12()
        local key = self._ehi_key or tostring(self._unit:key())
        local hook_key = "EHI_saw_start_" .. key
        if self.PostStartTimer then
            EHI:HookWithID(self, "PostStartTimer", hook_key, check)
        else
            EHI:HookWithID(self, "_start", hook_key, check)
        end
    end
    local tbl =
    {
        [100122] = { f = chca_12 },
        [100011] = { f = chca_12 },
        [100079] = { f = chca_12 },
        [100080] = { f = chca_12 }
    }
    EHI:UpdateInstanceUnitsNoCheck(tbl, 15470)
    local trigger = { special_function = SF.CustomCode, f = saw_done }
    other[EHI:GetInstanceElementID(100082, 15470)] = trigger
    other[EHI:GetInstanceElementID(100083, 15470)] = trigger
    other[EHI:GetInstanceElementID(100084, 15470)] = trigger
    other[EHI:GetInstanceElementID(100085, 15470)] = trigger
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        veryhard_or_below = 1,
        overkill_or_above = 2
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, single_sniper = sniper_count == 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
--[[local LootLeft = EHI:GetFreeCustomSFID()
EHI:ShowLootCounter({
    max = 18, -- 18 money bags, teaset and 1 money bundle in a safe
    triggers =
    {
        [103761] = { max = 16, special_function = SF.DecreaseProgressMax }, -- C4 Plan
        [EHI:GetInstanceElementID(100014, 15470)] = { special_function = LootLeft }, -- Ink (Stealth)
        [EHI:GetInstanceElementID(100063, 15470)] = { special_function = LootLeft } -- Burn (Loud)
    }
})
local units = {}
for i = 100017, 100020, 1 do
    units[EHI:GetInstanceElementID(i, 15470)] = true
end
for i = 100028, 100030, 1 do
    units[EHI:GetInstanceElementID(i, 15470)] = true
end
for i = 100034, 100041, 1 do
    units[EHI:GetInstanceElementID(i, 15470)] = true
end
EHI:RegisterCustomSF(LootLeft, function(self, ...)
    local left_to_burn = 16
    for unit_id, _ in pairs(units) do
        local unit = managers.worlddefinition:get_unit(unit_id)
        -- If the unit has "body" table, then players bagged it
        if unit and unit:damage()._state and unit:damage()._state.body then
            left_to_burn = left_to_burn - 1
        end
    end
    self._loot:DecreaseLootCounterProgressMax(left_to_burn)
end)
EHI:AddLoadSyncFunction(function(self)
    if managers.game_play_central:GetMissionDisabledUnit(200942) then -- AI Vision Blocker; "editor_only" continent
        self._loot:DecreaseLootCounterProgressMax(16)
    end
end)]]
local min_loot = EHI:GetValueBasedOnDifficulty({
    veryhard_or_below = 4,
    overkill = 8,
    mayhem = 8,
    deathwish_or_above = 12
})
local stealth_objectives =
{
    { amount = 2000, name = "china3_met_insider", additional_name = "china3_guest_entrance", optional = true },
    { amount = 2000, name = "ggc_gear_found", additional_name = "china3_guest_entrance", optional = true },
    { amount = 500, name = "china3_found_insider_info", additional_name = "china3_crew_deck_entrance", optional = true },
    { amount = 1000, name = "china3_found_lideng_or_xunkang" },
    { amount = 2000, name = "china3_found_lideng_safe" },
    { amount = 2000, name = "twh_safe_open" },
    { amount = 4000, name = "china3_found_xunkang", optional = true },
    { amount = 4000, name = "china3_bugged_meeting" },
    { amount = 2000, name = "china3_found_phone_number" },
    { amount = 2000, name = "china3_got_xunkang_hand" },
    { amount = 1000, name = "china3_guards_distracted" },
    { amount = 2000, name = "ggc_laser_disabled" },
    { amount = 1000, name = "vault_open" },
    { amount = 1000, name = "fs_secured_required_bags" },
    { amount = 2000, name = "china3_vault_empty" },
    { amount = 1000, name = "china3_lifeboat_lowered" }
}
local loud_objectives =
{
    { amount = 2000, name = "china3_met_insider", additional_name = "china3_guest_entrance", optional = true },
    { amount = 2000, name = "ggc_gear_found", additional_name = "china3_guest_entrance", optional = true },
    { amount = 500, name = "china3_found_insider_info", additional_name = "china3_crew_deck_entrance", optional = true },
    { amount = 2000, name = "china3_found_lideng_or_xunkang" },
    { amount = 500, name = "china3_found_lideng_safe" },
    { amount = 2000, name = "twh_safe_open" },
    { amount = 500, name = "china3_found_xunkang", optional = true },
    { amount = 500, name = "china3_glass_broken" },
    { amount = 500, name = "china3_glass_destroyed" },
    { amount = 4000, name = "china3_got_xunkang_hand" },
    { amount = 4000, name = "vault_found" },
    { amount = 500, name = "pc_hack" },
    { amount = 3000, name = "china3_firewall_disabled" },
    { amount = 3000, name = "rvd2_hacking_done" },
    { amount = 500, name = "vault_open" },
    { amount = 500, name = "fs_secured_required_bags" },
    { amount = 2000, name = "china3_vault_empty" },
    { amount = 500, name = "china3_signaled_heli" },
    { amount = 6000, name = "heli_arrival" }
}
local loud_c4_objectives =
{
    { amount = 2000, name = "china3_wall_exploded" },
    { amount = 9000, name = "saws_done" },
    { amount = 3000, name = "ggc_winch_set_up" },
    { amount = 6000, name = "china3_vault_out" },
    { amount = 5000, name = "china3_got_rid_of_police_heli" },
    { amount = 3000, name = "heli_arrival" },
    { amount = 1000, name = "china3_vault_secured" },
    { amount = 1000, name = "china3_boat_escape" }
}
local total_xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                china3_met_insider = { min = 0 },
                ggc_gear_found = { min = 0 },
                china3_found_insider_info = { max = 0 }
            },
            loot_all = { min = min_loot, max = 18 }
        }
    }
}
EHI:AddXPBreakdown({
    tactic =
    {
        custom =
        {
            {
                name = "stealth",
                tactic =
                {
                    objectives = stealth_objectives,
                    loot_all = 500,
                    total_xp_override = total_xp_override
                }
            },
            {
                name = "loud",
                tactic =
                {
                    objectives = loud_objectives,
                    loot_all = 500,
                    total_xp_override = total_xp_override
                }
            },
            {
                name = "loud",
                additional_name = "china3_c4",
                tactic =
                {
                    objectives = loud_c4_objectives,
                    loot_all = 500,
                    total_xp_override =
                    {
                        params =
                        {
                            min_max =
                            {
                                loot_all = { max = 1 }
                            }
                        }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "china3_most_xp",
                tactic =
                {
                    objectives = loud_objectives,
                    loot_all = 500,
                    total_xp_override =
                    {
                        params =
                        {
                            min_max =
                            {
                                objectives =
                                {
                                    china3_met_insider = { min = 0 },
                                    ggc_gear_found = { min = 0 },
                                    china3_found_insider_info = { max = 0 }
                                },
                                loot_all = { max = 2 }
                            }
                        }
                    }
                },
                objectives_override =
                {
                    stop_at_inclusive_and_add_objectives =
                    {
                        stop_at = "rvd2_hacking_done",
                        add_objectives =
                        {
                            { amount = table.ehi_get_objectives_xp_amount(loud_c4_objectives), name = "china3_c4_route" }
                        }
                    }
                }
            }
        }
    }
})