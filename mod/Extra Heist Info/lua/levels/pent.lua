local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local heli_element_timer = 102292
local heli_delay = 60 -- Normal -> Very Hard
-- Bugged because of braindead use of ElementTimerTrigger...
--[[if EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    heli_element_timer = 102293
    heli_delay = 80
elseif EHI:IsMayhemOrAbove() then
    heli_element_timer = 102294
    heli_delay = 100
end]]
---@type ParseTriggerTable
local triggers = {
    -- Loud Heli Escape
    [101539] = EHI:AddEndlessAssault(5),
    [102295] = { id = "DefendLights", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.GetElementTimerAccurate, element = heli_element_timer, hint = Hints.Defend },
    [102296] = { id = "DefendLights", special_function = SF.PauseTracker },
    [102297] = { id = "DefendLights", special_function = SF.UnpauseTracker },
    [102303] = { time = 40, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape },

    -- Elevator
    [101277] = { time = 12, id = "ElevatorDown", icons = { Icon.Wait }, hint = Hints.Wait },
    [102061] = { time = 900/30, id = "ElevatorUp", icons = { Icon.Wait }, hint = Hints.Wait },

    -- In CoreWorldInstanceManager:
    -- Window Cleaning Platform
    -- Elevator Generator
    -- Thermite
    -- Car Platform
    -- Lobby PCs
}
if EHI:IsClient() then
    -- FOR THE LOVE OF GOD
    -- OVERKILL
    -- STOP. USING. F... RANDOM DELAY, it's not funny
    triggers[102295].client = { time = heli_delay, random_time = 20 }
    -- Bugged because of braindead use of ElementTimerTrigger...
    triggers[103584] = { time = 70, id = "DefendLights", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.Defend }
    --[[if EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL) then
        triggers[103584] = { time = 70, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }
    else
        triggers[103585] = { time = 90, id = "HeliEscape", icons = Icon.HeliEscape, class = TT.Pausable, special_function = SF.SetTrackerAccurate, hint = Hints.LootEscape }
    end]]
end

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 50, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local time_for_prefereds = self:IsMissionElementEnabled(104439) and 5 or 0
        self._trackers:AddTracker({
            id = trigger.id,
            time = trigger.time + time_for_prefereds,
            class = trigger.class
        }, trigger.pos)
    end)})
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

EHI:ParseTriggers({ mission = triggers, other = other })
local loot_triggers = {}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    if EHI:CanShowAchievement("pent_12") then
        EHI:AddOnAlarmCallback(function()
            EHI:ShowAchievementLootCounterNoCheck({
                achievement = "pent_12",
                max = 1,
                show_finish_after_reaching_target = true,
                counter =
                {
                    check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
                    loot_type = "gnome"
                }
            })
        end)
    end
    loot_triggers[103616] = { special_function = SF.IncreaseProgressMax2 }
    loot_triggers[103617] = { special_function = SF.IncreaseProgressMax2 }
end

local max = 9 -- 8 gold + 1 teaset
EHI:ShowLootCounter({
    max = max,
    triggers = loot_triggers
})

function DigitalGui:pent_10()
    local key = self._ehi_key or tostring(self._unit:key())
    local hook_key = "EHI_pent_10_" .. key
    if EHI:GetUnlockableOption("show_achievement_started_popup") then
        local function AchievementStarted(...)
            managers.hud:ShowAchievementStartedPopup("pent_10")
        end
        if self.TimerStartCountDown then
            EHI:HookWithID(self, "TimerStartCountDown", hook_key .. "_start", AchievementStarted)
        else
            EHI:HookWithID(self, "timer_start_count_down", hook_key .. "_start", AchievementStarted)
        end
    end
    if EHI:GetUnlockableOption("show_achievement_failed_popup") then
        EHI:HookWithID(self, "_timer_stop", hook_key .. "_end", function(...)
            managers.hud:ShowAchievementFailedPopup("pent_10")
        end)
    end
end

local tbl =
{
    --units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [102452] = { f = function(unit_id, unit_data, unit)
        unit:digital_gui():SetRemoveOnPause(true)
        unit:digital_gui():SetWarning(true)
        if EHI:CanShowAchievement("pent_10") then
            unit:digital_gui():SetIcons(EHI:GetAchievementIcon("pent_10"))
            unit:digital_gui():pent_10()
        else
            unit:digital_gui():SetIcons({ EHI.Icons.Trophy })
        end
    end },
    [103872] = { ignore = true }
}
EHI:UpdateUnits(tbl)
local stealth_loot =
{
    gold_mission = { amount = 500, name = "gold", mandatory = 4 },
    gold_additional = { amount = 1000, name = "gold", additional = true },
    chas_teaset = 500
}
local stealth_total_xp_override =
{
    params =
    {
        min_max =
        {
            loot =
            {
                gold_mission = { min_max = 4 },
                gold_additional = { max = 4 },
                chas_teaset = { max = 1 }
            }
        }
    }
}
local loud_loot = deep_clone(stealth_loot)
local loud_total_xp_override = deep_clone(stealth_total_xp_override)
if EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard) then
    loud_loot.gnome = 500
    loud_total_xp_override.params.min_max.loot.gnome = { max = 1 }
end
local loud_objectives =
{
    { amount = 5000, name = "china4_hack_building_security" },
    { amount = 1000, name = "china4_call_elevator_from_basement" },
    { amount = 1000, name = "china4_disable_elevator_power" },
    { amount = 2000, name = "china4_elevator_shaft" },
    { amount = 2000, name = "china4_restart_and_call_elevator" },
    { amount = 2000, name = "china4_force_open_penthouse_door" },
    { amount = 2000, name = "china4_found_hidden_server_room" },
    { amount = 8000, name = "china4_steal_harddrive" }
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
                    objectives =
                    {
                        { amount = 1000, name = "china4_infiltrate_the_building" },
                        { amount = 4000, name = "china4_flip_correct_switches" },
                        { amount = 2000, name = "china4_call_elevator_from_basement" },
                        { amount = 2000, name = "china4_disable_elevator_power" },
                        { amount = 3000, name = "china4_elevator_shaft" },
                        { amount = 2000, name = "china4_get_on_cleaning_platform" },
                        { amount = 3000, name = "china4_found_hidden_server_room" },
                        { amount = 2000, name = "china4_steal_harddrive" },
                        { amount = 6000, name = "china4_decrypt_harddrive" },
                        { amount = 1000, name = "china4_fire_alarm_on" },
                        { amount = 4000, name = "china4_triad_leader_killed" },
                        { amount = 6000, name = "fs_secured_required_bags" }
                    },
                    loot = stealth_loot,
                    total_xp_override = stealth_total_xp_override
                }
            },
            {
                name = "loud",
                additional_name = "mex4_car_escape",
                tactic =
                {
                    objectives = loud_objectives,
                    loot = loud_loot,
                    total_xp_override = loud_total_xp_override
                },
                objectives_override =
                {
                    stop_at_inclusive_and_add_objectives =
                    {
                        stop_at = "china4_steal_harddrive",
                        add_objectives =
                        {
                            { amount = 2000, name = "china4_car_is_in_position" },
                            { amount = 1000, name = "china4_car_is_ready" },
                            { amount = 5000, name = "china4_car_smashed_through" },
                            { amount = 2000, name = "china4_triad_leader_killed" },
                            { amount = 4000, name = "china4_defend_lights" },
                            { amount = 2000, name = "fs_secured_required_bags" }
                        }
                    }
                }
            },
            {
                name = "loud",
                additional_name = "china4_thermite_route",
                tactic =
                {
                    objectives = loud_objectives,
                    loot = loud_loot,
                    total_xp_override = loud_total_xp_override
                },
                objectives_override =
                {
                    stop_at_inclusive_and_add_objectives =
                    {
                        stop_at = "china4_steal_harddrive",
                        add_objectives =
                        {
                            { amount = 5000, name = "china4_put_thermite" },
                            { amount = 2000, name = "china4_triad_leader_killed" },
                            { amount = 4000, name = "china4_defend_lights" },
                            { amount = 2000, name = "fs_secured_required_bags" }
                        }
                    }
                }
            }
        }
    }
})