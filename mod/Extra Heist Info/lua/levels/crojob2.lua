local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local MethlabIndex = { 1100, 1400, 1700, 2000, 2300, 2600, 2900, 3500, 3800, 4100, 4400, 4700 }
local interact = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop }, hint = Hints.mia_1_NextMethIngredient }
local element_sync_triggers = {}
for _, index in ipairs(MethlabIndex) do
    for i = 100169, 100172, 1 do
        local element_id = EHI:GetInstanceElementID(i, index)
        element_sync_triggers[element_id] = deep_clone(interact)
        element_sync_triggers[element_id].hook_element = EHI:GetInstanceElementID(100168, index)
    end
end
local chopper_delay = 25 + 1 + 2.5
local triggers = {
    [102120] = { time = 5400/30, id = "ShipMove", icons = { Icon.Boat, Icon.Wait }, trigger_times = 1, hint = Hints.Wait },

    [101545] = { time = 100 + chopper_delay, id = "C4FasterPilot", icons = Icon.HeliDropC4, hint = Hints.C4Delivery },
    [101749] = { time = 160 + chopper_delay, id = "C4", icons = Icon.HeliDropC4, hint = Hints.C4Delivery },

    [106295] = { time = 705/30, id = "Escape", icons = Icon.CarEscape, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootEscape },
    [106294] = { time = 1200/30, id = "HeliEscape", icons = Icon.HeliEscape, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootEscape },
    [100339] = { time = 0.2 + 450/30, id = "BoatEscape", icons = Icon.BoatEscape, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.LootEscape }
}
for _, index in ipairs(MethlabIndex) do
    triggers[EHI:GetInstanceElementID(100118, index)] = { time = 1, id = "MethlabRestart", icons = { Icon.Methlab, Icon.Loop }, hint = Hints.mia_1_NextMethIngredient }
    triggers[EHI:GetInstanceElementID(100152, index)] = { time = 5, id = "MethlabPickUp", icons = { Icon.Methlab, Icon.Interact }, hint = Hints.mia_1_MethDone }
end
if EHI:IsClient() then
    local random_time = { id = "MethlabInteract", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.SetRandomTime, data = { 25, 35, 45, 65 }, hint = Hints.mia_1_NextMethIngredient }
    for _, index in ipairs(MethlabIndex) do
        triggers[EHI:GetInstanceElementID(100149, index)] = random_time
        triggers[EHI:GetInstanceElementID(100150, index)] = random_time
        triggers[EHI:GetInstanceElementID(100184, index)] = { id = "MethlabInteract", special_function = SF.RemoveTracker }
    end
end

---@type ParseAchievementTable
local achievements =
{
    cow_10 =
    {
        elements =
        {
            [104086] = { status = "defend", class = TT.Achievement.Status },
            [102480] = { special_function = SF.SetAchievementFailed },
            [106581] = { special_function = SF.SetAchievementComplete }
        }
    },
    cow_11 =
    {
        elements =
        {
            [101737] = { time = 60, class = TT.Achievement.Base },
            [102466] = { special_function = SF.RemoveTracker },
            [102479] = { special_function = SF.SetAchievementComplete }
        }
    }
}

local other =
{
    [101742] = EHI:AddAssaultDelay({}) -- 30s
    -- Delay assault preplanning does not help as Captain Winter's group is there from the start, causing assaults to start prematurely
    -- See ´phalanx_start´ MissionScriptElement 106209
}
if EHI:IsLootCounterVisible() then
    local Weapons = { 100857, 103374 }
    other[101737] = EHI:AddLootCounter3(function(self, ...)
        local MayhemOrAbove = EHI:IsMayhemOrAbove()
        EHI:ShowLootCounterNoChecks({
            max = 6 + tweak_data.ehi.functions.GetNumberOfVisibleWeapons(Weapons), -- 4 Bomb parts; 2 Meth and Weapons
            -- Assume no collision spawned, more loot
            max_random = MayhemOrAbove and 14 or 18
        })
        if managers.game_play_central:GetMissionDisabledUnit(107388) then -- Collision (8th position)
            -- Collision is visible, less loot spawned
            self._loot:DecreaseLootCounterMaxRandom(2)
        end
    end, true)
    -- Random loot in crates
    local IncreaseMaximumTrigger = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:RandomLootSpawned()
    end) }
    local DecreaseMaximumTrigger = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:RandomLootDeclined()
    end) }
    for i = 103232, 103264, 1 do -- 1 - 11 Cocaine / Money / Gold
        other[i] = IncreaseMaximumTrigger
    end
    other[103284] = IncreaseMaximumTrigger -- 12 Cocaine
    other[103317] = IncreaseMaximumTrigger -- 12 Money
    other[103351] = IncreaseMaximumTrigger -- 13 Gold
    other[103352] = IncreaseMaximumTrigger -- 13 Cocaine
    other[103484] = IncreaseMaximumTrigger -- 13 Money
    other[103485] = IncreaseMaximumTrigger -- 13 Gold
    other[103738] = IncreaseMaximumTrigger -- 14 Cocaine
    other[103739] = IncreaseMaximumTrigger -- 14 Money
    other[103741] = IncreaseMaximumTrigger -- 14 Gold
    other[103742] = IncreaseMaximumTrigger -- 15 Cocaine
    other[103754] = IncreaseMaximumTrigger -- 15 Money
    other[103755] = IncreaseMaximumTrigger -- 15 Gold
    for i = 103857, 103861, 1 do -- 16 - 17 Money
        other[i] = IncreaseMaximumTrigger
    end
    other[104089] = IncreaseMaximumTrigger -- 17 Gold
    other[104090] = IncreaseMaximumTrigger -- 18 Cocaine
    other[104093] = IncreaseMaximumTrigger -- 18 Money
    other[104094] = IncreaseMaximumTrigger -- 18 Gold
    other[104135] = IncreaseMaximumTrigger -- 19 Cocaine
    for i = 104138, 104142, 1 do -- 19 Money - 20 Gold
        other[i] = IncreaseMaximumTrigger
    end
    other[104145] = IncreaseMaximumTrigger -- 21 Cocaine
    other[104455] = IncreaseMaximumTrigger -- 21 Money
    other[104582] = IncreaseMaximumTrigger -- 21 Gold
    other[104585] = IncreaseMaximumTrigger -- 22 Cocaine
    other[104587] = IncreaseMaximumTrigger -- 22 Money
    other[104588] = IncreaseMaximumTrigger -- 22 Gold
    other[104591] = IncreaseMaximumTrigger -- 23 Cocaine
    other[104593] = IncreaseMaximumTrigger -- 23 Money
    other[104603] = IncreaseMaximumTrigger -- 23 Gold
    other[104604] = IncreaseMaximumTrigger -- 24 Cocaine
    other[104607] = IncreaseMaximumTrigger -- 24 Money
    other[104608] = IncreaseMaximumTrigger -- 24 Gold
    other[101728] = DecreaseMaximumTrigger -- 1 Nothing
    other[102063] = DecreaseMaximumTrigger -- 2 Nothing
    other[102064] = DecreaseMaximumTrigger -- 3 Nothing
    for i = 104687, 104691, 1 do -- 4 - 8 Nothing
        other[i] = DecreaseMaximumTrigger
    end
    other[104726] = DecreaseMaximumTrigger -- 9 Nothing
    other[104727] = DecreaseMaximumTrigger -- 10 Nothing
    for i = 104730, 104734, 1 do -- 11 - 15 Nothing
        other[i] = DecreaseMaximumTrigger
    end
    for i = 104736, 104738, 1 do -- 16 - 18 Nothing
        other[i] = DecreaseMaximumTrigger
    end
    for i = 104740, 104742, 1 do -- 19 - 21 Nothing
        other[i] = DecreaseMaximumTrigger
    end
    for i = 104745, 104747, 1 do -- 22 - 24 Nothing
        other[i] = DecreaseMaximumTrigger
    end
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[101742] = { chance = 100, time = 150, on_fail_refresh_t = 120, id = "Snipers", class = TT.Sniper.Loop }
    other[101773] = { id = "Snipers", special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local id = trigger.id
        if self._trackers:TrackerDoesNotExist(id) then
            self._trackers:AddTracker({
                id = id,
                time = 120,
                chance = 25,
                on_fail_refresh_t = 120,
                class = TT.Sniper.Loop
            })
        end
        self._trackers:CallFunction(id, "AnnounceSniperSpawn")
        self._trackers:CallFunction(id, "OnChanceFail")
    end) }
    other[104336] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" } -- Both success and fail goes through this same element
    other[104245] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "AnnounceSniperSpawn" }
    other[104308] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 25%
    other[104309] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[104310] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[104330] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[104331] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:ShowAchievementLootCounter({
    achievement = "voff_2",
    max = 2,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = "meth"
    }
})

local tbl =
{
    -- units/payday2/equipment/gen_interactable_drill_small/gen_interactable_drill_small_no_jam
    [107585] = { remove_vanilla_waypoint = 102926 }, -- 1 front
    [100690] = { remove_vanilla_waypoint = 102926 }, -- 1 back
    [101046] = { remove_vanilla_waypoint = 102929 }, -- 2 front
    [100547] = { remove_vanilla_waypoint = 102929 }, -- 2 back
    [100640] = { remove_vanilla_waypoint = 102931 }, -- 3 front
    [100542] = { remove_vanilla_waypoint = 102931 }, -- 3 back
    [100642] = { remove_vanilla_waypoint = 102934 }, -- 4 front
    [100548] = { remove_vanilla_waypoint = 102934 }, -- 4 back
    [100644] = { remove_vanilla_waypoint = 102936 }, -- 5 front
    [100641] = { remove_vanilla_waypoint = 102936 }, -- 5 back
    [100659] = { remove_vanilla_waypoint = 103295 }, -- 6 front
    [100643] = { remove_vanilla_waypoint = 103295 }, -- 6 back
    [100660] = { remove_vanilla_waypoint = 102947 }, -- 7 front
    [100645] = { remove_vanilla_waypoint = 102947 }, -- 7 back
    [100671] = { remove_vanilla_waypoint = 103296 }, -- 9 front
    [100661] = { remove_vanilla_waypoint = 103296 }, -- 9 back
    [100672] = { remove_vanilla_waypoint = 103297 }, -- 10 front
    [100663] = { remove_vanilla_waypoint = 103297 }, -- 10 back
    [100678] = { remove_vanilla_waypoint = 103298 }, -- 11 front
    [100676] = { remove_vanilla_waypoint = 103298 }, -- 11 back
    [100684] = { remove_vanilla_waypoint = 103299 }, -- 12 front
    [100682] = { remove_vanilla_waypoint = 103299 }, -- 12 back
    [100689] = { remove_vanilla_waypoint = 103300 }, -- 13 front
    [100688] = { remove_vanilla_waypoint = 103300 }, -- 13 back
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 2500, name = "the_bomb_open_dock_gate" },
                { amount = 2500, name = "the_bomb_find_coordinates" },
                { amount = 2500, name = "the_bomb_call_captain" },
                { amount = 2500, name = "the_bomb_find_bomb" },
                { escape = 6000 }
            },
            loot_all = 500
        },
        loud =
        {
            objectives =
            {
                { amount = 6000, name = "the_bomb_blowup_dock_gate" },
                { amount = 6000, name = "pc_hack" },
                { amount = 6000, name = "the_bomb_find_bomb" },
                { escape = 6000 }
            },
            loot_all = 500
        }
    }
})