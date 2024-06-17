local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local WinchCar = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue } }
local ElementTimer = 102059
local ElementTimerPickup = 102075
local WeaponsPickUp = { Icon.Heli, Icon.Interact }
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
if OVKorAbove then
    ElementTimer = 102063
    ElementTimerPickup = 102076
end
local FultonCatchAgain = { id = "FultonCatchAgain", icons = WeaponsPickUp, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootTimed }
local FultonCatchSuccess = { time = 6.8, id = "FultonCatchSuccess", icons = WeaponsPickUp, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
    if self._trackers:TrackerDoesNotExist("FultonCatch") or self._trackers:TrackerDoesNotExist("FultonCatchAgain") then
        self:CreateTracker(trigger)
    end
end), hint = Hints.LootTimed }
local FultonCatchIncreaseChance = { id = "FultonCatchChance", special_function = SF.IncreaseChanceFromElement }
local FultonRemoveCatch = { id = "FultonCatch", special_function = SF.RemoveTracker }

local sync_triggers =
{
    [EHI:GetInstanceElementID(100070, 14950)] = FultonCatchAgain,
    [EHI:GetInstanceElementID(100070, 25500)] = FultonCatchAgain,
    [EHI:GetInstanceElementID(100070, 25650)] = FultonCatchAgain,
}
---@type ParseTriggerTable
local triggers = {
    [EHI:GetInstanceElementID(100083, 12500)] = { time = 230/30, id = "CarPush1", icons = WinchCar, hint = Hints.hox_1_Car },
    [EHI:GetInstanceElementID(100084, 12500)] = { time = 230/30 + 1, id = "CarPush2", icons = WinchCar, hint = Hints.hox_1_Car },
    [EHI:GetInstanceElementID(100087, 12500)] = { time = 250/30, id = "CarWinchUsed", icons = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue }, Icon.Winch }, hint = Hints.Winch },

    -- Thermite
    [EHI:GetInstanceElementID(100012, 2850)] = { time = 0.5 + 0.5 + 0.5 + 0.5 + 1, id = "ThermiteOpenGate", icons = { Icon.Fire }, hint = Hints.Thermite },
    [EHI:GetInstanceElementID(100012, 2950)] = { time = 0.5 + 0.5 + 0.5 + 0.5 + 1, id = "ThermiteOpenGate", icons = { Icon.Fire }, hint = Hints.Thermite },

    -- C4
    [EHI:GetInstanceElementID(100044, 2850)] = { time = 5, icon = "C4OpenGate", icons = { Icon.C4 }, hint = Hints.Explosion },
    [EHI:GetInstanceElementID(100044, 2950)] = { time = 5, icon = "C4OpenGate", icons = { Icon.C4 }, hint = Hints.Explosion },

    -- Fulton (Preplanning asset)
    [102053] = { additional_time = 7, id = "FultonDropCage", icons = Icon.HeliDropBag, special_function = SF.GetElementTimerAccurate, element = ElementTimer, hint = Hints.peta2_LootZoneDelivery },
    [EHI:GetInstanceElementID(100053, 14950)] = FultonCatchSuccess,
    [EHI:GetInstanceElementID(100053, 25500)] = FultonCatchSuccess,
    [EHI:GetInstanceElementID(100053, 25650)] = FultonCatchSuccess,
    [102070] = { special_function = SF.Trigger, data = { 1020701, 1020702 } },
    [1020701] = { chance = 34, id = "FultonCatchChance", icons = { Icon.Heli }, class = TT.Chance, hint = Hints.ranc_Chance },
    [1020702] = { additional_time = 6.8, id = "FultonCatch", icons = WeaponsPickUp, special_function = SF.GetElementTimerAccurate, element = ElementTimerPickup, hint = Hints.LootTimed },
    [103988] = { id = "FultonCatchChance", special_function = SF.RemoveTracker },
    [EHI:GetInstanceElementID(100055, 14950)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100055, 25500)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100055, 25650)] = FultonCatchIncreaseChance,
    [EHI:GetInstanceElementID(100056, 14950)] = FultonRemoveCatch,
    [EHI:GetInstanceElementID(100056, 25500)] = FultonRemoveCatch,
    [EHI:GetInstanceElementID(100056, 25650)] = FultonRemoveCatch
}

if EHI:IsClient() then
    triggers[102053].client = { time = OVKorAbove and 60 or 30, random_time = 5 }
    triggers[1020702].client = { time = OVKorAbove and 60 or 30, random_time = 5 }
    local FultonCatchAgainClient = { additional_time = 30, random_time = 30, id = "FultonCatchAgain", icons = FultonCatchAgain, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.LootTimed }
    triggers[EHI:GetInstanceElementID(100070, 14950)] = FultonCatchAgainClient
    triggers[EHI:GetInstanceElementID(100070, 25500)] = FultonCatchAgainClient
    triggers[EHI:GetInstanceElementID(100070, 25650)] = FultonCatchAgainClient
end

--[[
    anim_ranc_arrive_01 -> 215/30 + 2-7 + 10 + 10 -> 29,1666-34,1666
    anim_ranc_arrive_02 -> 202/30 + 10-15 + 5 + 10 -> 31,7333-36,7333
    anim_ranc_arrive_03 -> 170/30 + 6.9 + 10-15 + 10 -> 32,5666-37,5666
    anim_ranc_arrive_04 -> 894/30 + 0-5 + 10 -> 39,8-44,8
    anim_ranc_arrive_05 -> 980/30 + 5 + 10 -> 47,6666
]]
local other =
{
    [100109] = EHI:AddAssaultDelay({ control_additional_time = 20 + 215/30 + 2 + 10 + 10 + 10, random_time = 5 + 10 })
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
if EHI:IsLootCounterVisible() then
    local instances = { 4350, 5350, 5500, 5650, 5800, 5950, 6500, 13600, 13750, 13900, 14050, 23050, 23950, 24100, 24250, 24400, 25800, 7400, 25950, 26100, 26250, 26400, 26550, 26700, 26850, 27000, 27150, 27300, 27450, 27600 }
    other[103097] = EHI:AddLootCounter4(function()
        local barrels = 0
        local stocks = 0
        local receivers = 0
        local wd = managers.worlddefinition
        local red = Idstring("units/pd2_dlc_ranc/equipment/ranc_int_weapon_box_2x1x1m/ranc_weapon_box_marking_red")
        local blue = Idstring("units/pd2_dlc_ranc/equipment/ranc_int_weapon_box_2x1x1m/ranc_weapon_box_marking_blue")
        for _, index in ipairs(instances) do
            local unit_id = EHI:GetInstanceElementID(100042, index)
            if managers.game_play_central:GetMissionEnabledUnit(unit_id) then
                local unit = wd:get_unit(unit_id + 9) -- 100051
                if unit then
                    local material_config = unit:material_config()
                    if material_config == red then
                        barrels = barrels + 1
                    elseif material_config == blue then
                        stocks = stocks + 1
                    else
                        receivers = receivers + 1
                    end
                end
            end
        end
        EHI:ShowLootCounterNoChecks({
            max = math.min(barrels, stocks, receivers) + tweak_data.ehi.functions.GetNumberOfVisibleWeapons2(103574, 103588)
        })
        managers.ehi_loot:SyncSecuredLoot()
    end, 5, function(self)
        self:Trigger(103097)
    end, true)
end

EHI:ParseTriggers({
    mission = triggers,
    other = other,
    sync_triggers = { base = sync_triggers }
})
EHI:ShowAchievementKillCounter({
    achievement = "ranc_9", -- "Caddyshacked" achievement
    achievement_stat = "ranc_9_stat", -- 100
    achievement_option = "show_achievements_vehicle",
    difficulty_pass = OVKorAbove
})
local ranc_10 = { special_function = SF.IncreaseProgress }
local ranc_10_triggers =
{
    [EHI:GetInstanceElementID(100015, 28400)] = ranc_10
}
for i = 28600, 29300, 50 do
    ranc_10_triggers[EHI:GetInstanceElementID(100015, i)] = ranc_10
end
EHI:ShowAchievementLootCounter({
    achievement = "ranc_10",
    max = 5,
    triggers = ranc_10_triggers,
    load_sync = function(self)
        self._trackers:SetTrackerSyncData("ranc_10", 5 - self:CountInteractionAvailable("ranc_press_pickup_horseshoe"))
    end
})
EHI:ShowAchievementKillCounter({
    achievement = "ranc_11", -- "Marshal Law" achievement
    achievement_stat = "ranc_11_stat", -- 4
    achievement_option = "show_achievements_weapon",
    difficulty_pass = OVKorAbove
})
local min_bags = EHI:GetValueBasedOnDifficulty({
    veryhard_or_below = 6,
    overkill_or_above = 8
})
local max_loot = EHI:GetValueBasedOnDifficulty({
    veryhard_or_below = 16, -- 16 with a preplanning asset; 11 without it
    overkill_or_above = 14 -- 14 with a preplanning asset; 9 without it
})
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "texas1_entered_ranch_house" },
                { amount = 2000, name = "texas1_found_laptop" },
                { amount = 2000, name = "texas1_collected_biometrics", optional = true },
                { amount = 2000, name = "texas1_laptop_decrypted" },
                { amount = 1000, name = "texas1_found_gates_workshop", optional = true },
                { amount = 2000, name = "texas1_gates_open" },
                { amount = 2000, name = "texas1_picked_up_weapons", times = 1 },
                { amount = 7000, name = "fs_secured_required_bags" },
                { amount = 2000, name = "texas1_sabotaged_workbenches" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot_all = { min = min_bags, max = max_loot }
                    }
                }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "texas1_entered_ranch_house" },
                { amount = 3000, name = "texas1_entered_office" },
                { amount = 2000, name = "texas1_laptop_decrypted" },
                { amount = 1000, name = "texas1_found_gates_workshop" },
                { amount = 2000, name = "hox1_blockade_cleared" },
                { amount = 4000, name = "c4_set_up" },
                { amount = 1000, name = "texas1_fulton_cage_assembled", optional = true },
                { amount = 1000, name = "texas1_defended_fulton_cage", optional = true },
                { amount = 7000, name = "fs_secured_required_bags" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot_all = { min = min_bags, max = max_loot }
                    }
                }
            }
        }
    }
})