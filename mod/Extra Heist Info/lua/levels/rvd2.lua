local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local element_sync_triggers =
{
    [101374] = { id = "VaultTeargas", icons = { Icon.Teargas }, hook_element = 101377, hint = Hints.Teargas }
}
---@type ParseTriggerTable
local triggers = {
    [100903] = { time = 120, id = "LiquidNitrogen", icons = { Icon.LiquidNitrogen }, waypoint = { position_by_element = 100941 }, hint = Hints.rvd2_LiquidNitrogen },

    [100699] = { time = 8 + 25 + 13, id = "ObjectiveWait", icons = { Icon.Wait }, hint = Hints.Wait },

    [100939] = { time = 5, id = "C4Vault", icons = { Icon.C4 }, waypoint = { position_by_element = 100941 }, hint = Hints.Explosion }
}
local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:IsHost() then
    triggers[101498] = { time = 6 + 4 + 30 + 24 + 3, id = "HeliC4", icons = Icon.HeliDropC4, waypoint = { icon = Icon.C4, position_by_element = 100943 }, hint = Hints.C4Delivery }
    ---`mesh_variation "set_level_mia"`  
    ---units/payday2/equipment/gen_interactable_sec_safe_2x05/gen_interactable_sec_safe_2x05 (buggy mesh_variation -> `"set_level_rat_2"` instead)
    ---units/payday2/equipment/gen_interactable_sec_safe_2x05_titan/gen_interactable_sec_safe_2x05_titan
    ---units/payday2/equipment/gen_interactable_sec_safe_05x05_titan/gen_interactable_sec_safe_05x05_titan
    local SafeTriggers =
    {
        loot =
        {
            "spawn_loot_money"
        },
        no_loot =
        {
            "spawn_loot_value_a",
            "spawn_loot_value_d",
            "spawn_loot_value_e",
            "spawn_loot_crap_b", -- titan
            "spawn_loot_crap_c", -- titan
            "spawn_loot_crap_d"
        }
    }
    ---@param truck_id number
    local function IncreaseMax(truck_id)
        managers.ehi_loot:SyncIncreaseLootCounterMaxRandom(9)
        tweak_data.ehi.functions.HookArmoredTransportUnit(truck_id, { "money" })
    end
    EHI:ShowLootCounterSynced({
        max = 19,
        max_random = 3,
        triggers =
        {
            [101287] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 101647 },
            [101492] = { special_function = SF.CustomCode, f = IncreaseMax, arg = 102104 }
        },
        sequence_triggers =
        {
            [300960] = SafeTriggers, -- art_reg continent
            [500001] = SafeTriggers, -- mkp continent
            [501562] = SafeTriggers -- mkp continent
        }
    })
else
    ---@param self EHIManager
    ---@param trigger ElementTrigger
    local function WP(self, trigger)
        if self._waypoints:WaypointDoesNotExist("LiquidNitrogen") then
            self._waypoints:AddWaypoint("LiquidNitrogen", {
                time = trigger.time - 10,
                icon = Icon.LiquidNitrogen,
                position = self:GetElementPositionOrDefault(100941)
            })
        end
        if self._waypoints:WaypointDoesNotExist("HeliC4") then
            self._waypoints:AddWaypoint("HeliC4", {
                time = trigger.time,
                icon = Icon.C4,
                position = self:GetElementPositionOrDefault(100943)
            })
        end
    end
    triggers[101366] = { additional_time = 5 + 40, random_time = 10, id = "VaultTeargas", icons = { Icon.Teargas }, hint = Hints.Teargas }
    local LiquidNitrogen = EHI:RegisterCustomSF(function(self, trigger, ...)
        if self._trackers:TrackerDoesNotExist("LiquidNitrogen") then
            self._trackers:AddTracker({
                id = "LiquidNitrogen",
                time = trigger.time - 10,
                icons = { Icon.LiquidNitrogen },
                hint = Hints.rvd2_LiquidNitrogen
            })
        end
        if self._trackers:TrackerDoesNotExist("HeliC4") then
            self._trackers:AddTracker({
                id = "HeliC4",
                time = trigger.time,
                icons = Icon.HeliDropC4,
                hint = Hints.C4Delivery
            })
        end
    end)
    triggers[101498] = { time = 6 + 4 + 30 + 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
    triggers[100035] = { time = 4 + 30 + 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
    triggers[101630] = { time = 30 + 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
    triggers[101629] = { time = 24 + 3, special_function = LiquidNitrogen, waypoint_f = WP }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100358] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 2 }
    other[100359] = EHI:CopyTrigger(other[100358], { sniper_count = 3 })
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowAchievementLootCounter({
    achievement = "rvd_11",
    max = 19,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = { "diamonds_dah", "diamonds" }
    }
})

local DisableWaypoints =
{
    [101768] = true, -- Defend PC
    [101765] = true -- Fix PC

    -- levels/instances/unique/rvd/rvd_hackbox/world
    -- Handled in CoreWorldInstanceManager.lua
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 6000, name = "rvd2_hacking_done" },
        { amount = 2000, name = "vault_drills_done" },
        { amount = 4000, name = "rvd2_vault_frozen" },
        { amount = 2000, name = "c4_set_up" },
        { escape = 1000 }
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                -- max = 19 diamond bags, 3 money bags in the safes (random), 3 bags in GenSec transport (random)
                loot_all = { min = 6, max = 25 }
            }
        }
    }
})