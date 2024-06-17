local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local heli_anim = 35
local heli_anim_full = 35 + 10 -- 10 seconds is hose lifting up animation when chopper goes refilling
local heli_20 = { time = 20 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.crojob3_WaterEnRoute }
local heli_65 = { time = 65 + heli_anim, id = "HeliWithWater", icons = { Icon.Heli, Icon.Water, Icon.Goto }, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.crojob3_WaterEnRoute }
local HeliWaterFill = { Icon.Heli, Icon.Water }
if EHI:GetOption("show_one_icon") then
    HeliWaterFill = { { icon = Icon.Heli, color = tweak_data.ehi.colors.WaterColor } }
end
---@type ParseTriggerTable
local triggers = {
    [101499] = { time = 155 + 25, id = "HeliEscape", icons = Icon.HeliEscape, waypoint = { icon = Icon.Heli, position_by_element = 101525 }, hint = Hints.LootEscape },
    [101253] = heli_65,
    [101254] = heli_20,
    [101255] = heli_65,
    [101256] = heli_20,
    [101259] = heli_65,
    [101278] = heli_20,
    [101279] = heli_65,
    [101280] = heli_20,

    [101691] = { time = 10 + 700/30, id = "PlaneEscape", icons = Icon.HeliEscape, waypoint = { icon = Icon.Heli, position_by_element = 100058 }, hint = Hints.LootEscape },

    [102996] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [102825] = { id = "WaterFill", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 160, no = 300 }, hint = Hints.crojob3_Water },
    [102905] = { id = "WaterFill", special_function = SF.PauseTracker },
    [102920] = { id = "WaterFill", special_function = SF.UnpauseTracker },

    [1] = { id = "HeliWaterFill", special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local wp = self._waypoints._hud:get_waypoint_data(trigger.id)
        if wp then
            self._cache.HeliWaterFillPos = wp.position
        end
        self._waypoints:RemoveWaypoint(trigger.id)
        self._trackers:SetTrackerPaused(trigger.id, true)
    end) },
    [2] = { id = "HeliWaterReset", icons = { Icon.Heli, Icon.Water, Icon.Loop }, special_function = SF.SetTimeByPreplanning, data = { id = 101033, yes = 62 + heli_anim_full, no = 122 + heli_anim_full }, hint = Hints.crojob3_WaterRefill, waypoint_f = function(self, trigger)
        if self._cache.HeliWaterFillPos then
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.time,
                icon = Icon.Loop,
                position = self._cache.HeliWaterFillPos
            })
            return
        end
        self._trackers:AddTrackerIfDoesNotExist(trigger, trigger.pos)
    end },

    -- Right
    [100283] = { time = 86, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100647 }, hint = Hints.Thermite },
    [100284] = { time = 86, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100648 }, hint = Hints.Thermite },
    [100288] = { time = 86, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100653 }, hint = Hints.Thermite },

    -- Left
    [100285] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100651 }, hint = Hints.Thermite },
    [100286] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100652 }, hint = Hints.Thermite },
    [100560] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100220 }, hint = Hints.Thermite },

    -- Top
    [100282] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100646 }, hint = Hints.Thermite },
    [100287] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100653 }, hint = Hints.Thermite },
    [100558] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100655 }, hint = Hints.Thermite },
    [100559] = { time = 90, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_element = 100656 }, hint = Hints.Thermite }
}
local IndexToWP =
{
    [100] = 101341,
    [150] = 100589,
    [250] = 101343,
    [300] = 101345
}
---@param self EHIManager
---@param trigger ElementTrigger
local function HeliWaterRefillWPAdd(self, trigger)
    local element = IndexToWP[trigger.index]
    if element then
        local pos = self:GetElementPositionOrDefault(element)
        self._waypoints:AddWaypoint(trigger.id, {
            time = trigger.time,
            icon = Icon.Water,
            position = pos,
            class = self.Waypoints.Pausable,
            remove_vanilla_waypoint = element,
            restore_on_done = true
        })
        self._cache.HeliWaterFillPos = pos
        self._cache.HeliWaterRestoreWP = element
        return
    end
    self._trackers:AddTrackerIfDoesNotExist(trigger, trigger.pos)
end
---@param id string
local function HeliWaterRefillWPRestore(id)
    local self = managers.ehi_manager
    if self._cache.HeliWaterFillPos then
        self._waypoints:AddWaypoint(id, {
            time = 120,
            icon = Icon.Water,
            position = self._cache.HeliWaterFillPos,
            class = self.Waypoints.Pausable,
            remove_vanilla_waypoint = self._cache.HeliWaterRestoreWP,
            force_format = true,
            paused = true
        })
        self._cache.HeliWaterFillPos = nil
        self._cache.HeliWaterRestoreWP = nil
    end
end
for _, index in ipairs({ 100, 150, 250, 300 }) do
    triggers[EHI:GetInstanceElementID(100032, index)] = { time = 240, id = "HeliWaterFill", icons = HeliWaterFill, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.crojob3_Water, waypoint_f = HeliWaterRefillWPAdd, index = index }
    triggers[EHI:GetInstanceElementID(100030, index)] = { id = "HeliWaterFill", special_function = SF.PauseTracker }
    triggers[EHI:GetInstanceElementID(100037, index)] = { special_function = SF.Trigger, data = { 1, 2 } }
    triggers[EHI:GetInstanceElementID(100006, index)] = { special_function = SF.CustomCode, f = HeliWaterRefillWPRestore, arg = "HeliWaterFill" }
end

---@type ParseAchievementTable
local achievements =
{
    cow_3 =
    {
        elements =
        {
            [103461] = { time = 5, class = TT.Achievement.Base, trigger_times = 1 },
            [103458] = { special_function = SF.SetAchievementComplete }
        }
    },
    cow_4 =
    {
        elements =
        {
            [101031] = { status = Status.Defend, class = TT.Achievement.Status, special_function = EHI:RegisterCustomSF(function(self, trigger, element, enabled)
                if enabled then
                    self:CreateTracker(trigger)
                end
            end) },
            [103468] = { special_function = SF.SetAchievementFailed, trigger_times = 1 },
            [104357] = { special_function = SF.SetAchievementComplete }
        }
    },
    cow_5 =
    {
        elements =
        {
            [101041] = { status = Status.Defend, class = TT.Achievement.Status },
            [104426] = { special_function = SF.SetAchievementComplete },
            [104364] = { special_function = SF.SetAchievementFailed, trigger_times = 1 }
        }
    }
}

local other =
{
    [100475] = EHI:AddAssaultDelay({ special_function = SF.AddTimeByPreplanning, data = { id = 101024, yes = 90, no = 60 } }) -- 30s
}
if EHI:IsLootCounterVisible() then
    local Trigger = { id = "LootCounter", special_function = SF.IncreaseProgressMax } -- Money spawned
    for _, index in ipairs({ 580, 830, 3120, 3370, 3620, 3870 }) do
        other[EHI:GetInstanceElementID(100197, index)] = Trigger
        other[EHI:GetInstanceElementID(100198, index)] = Trigger
        other[EHI:GetInstanceElementID(100201, index)] = Trigger
        other[EHI:GetInstanceElementID(100202, index)] = Trigger
    end
    other[101041] = { special_function = EHI:RegisterCustomSF(function(...)
        EHI:ShowLootCounterNoChecks({
            -- 1 flipped wagon crate; guaranteed to have gold or 2x money (15% chance)
            -- If second money bundle spawns, the maximum is increased in the Trigger above
            max = 5 -- 4 Bomb parts + 1
        })
    end)}
    local RandomLootSpawnedCheck = EHI:RegisterCustomSF(function(self, trigger, ...)
        self._loot:RandomLootSpawnedCheck(trigger.crate, true)
    end)
    -- 1 random loot in train wagon, 35% chance to spawn
    -- Wagons are selected randomly; sometimes 2 with possible loot spawns, sometimes 1
    local IncreaseMaxRandomLoot = EHI:RegisterCustomSF(function(self, trigger, ...)
        local index = trigger.index
        local crate = EHI:GetInstanceUnitID(100000, index)
        local LootTrigger = {}
        local loot_trigger = { special_function = RandomLootSpawnedCheck, crate = crate }
        LootTrigger[EHI:GetInstanceElementID(100009, index)] = loot_trigger
        LootTrigger[EHI:GetInstanceElementID(100010, index)] = loot_trigger
        managers.mission:add_runned_unit_sequence_trigger(crate, "interact", function(...)
            managers.ehi_loot:AddDelayedLootDeclinedCheck(crate)
        end)
        self:AddTriggers2(LootTrigger, nil, "LootCounter")
        self:HookElements(LootTrigger)
        self._loot:IncreaseLootCounterMaxRandom()
    end)
    other[104274] = { special_function = IncreaseMaxRandomLoot, index = 500 }
    other[104275] = { special_function = IncreaseMaxRandomLoot, index = 520 }
    other[104276] = { special_function = IncreaseMaxRandomLoot, index = 1080 }
    other[104277] = { special_function = IncreaseMaxRandomLoot, index = 1100 }
    other[104278] = { special_function = IncreaseMaxRandomLoot, index = 1120 }
    other[104279] = { special_function = IncreaseMaxRandomLoot, index = 1140 }
    other[104280] = { special_function = IncreaseMaxRandomLoot, index = 1160 }
    other[104281] = { special_function = IncreaseMaxRandomLoot, index = 1300 }
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100750] = { chance = 100, time = 120, on_fail_refresh_t = 40, initial_spawn_chance_set = 10, id = "Snipers", class = TT.Sniper.LoopRestart }
    other[100745] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100749] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess", arg = { 10 } } -- 10%
    other[102928] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "RequestRemoval" }
    other[100744] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100496] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100519] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100521] = { id = "Snipers", special_function = SF.IncreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "vault_found" },
        { amount = 12000, name = "the_bomb2_vault_filled" },
        { amount = 6000, name = "ggc_c4_taken" },
        { escape = 12000 }
    },
    loot_all = 1500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                -- Max = 2 money spawned instead of gold and all four train vagons have loot (very unprobable, but still...)
                loot_all = { min = 5, max = 10 }
            }
        }
    }
})