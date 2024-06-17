local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ThermiteWP = { icon = Icon.Fire, position_by_element = 104326 }
---@type ParseTriggerTable
local triggers = {
    [105842] = { time = 16.7 * 18, id = "Thermite", icons = { Icon.Fire }, waypoint = deep_clone(ThermiteWP), hint = Hints.Thermite },

    [105197] = { time = 45, id = "PickUpAPhone", icons = { Icon.Phone, Icon.Interact }, class = TT.Warning, hint = Hints.PickUpPhone },
    [105219] = { id = "PickUpAPhone", special_function = SF.RemoveTracker },

    [103050] = { time = 60, id = "PickUpManagersPhone", icons = { Icon.Phone, Icon.Interact }, class = TT.Warning, hint = Hints.PickUpPhone },
    [105248] = { id = "PickUpManagersPhone", special_function = SF.RemoveTracker },

    [101377] = { time = 5, id = "C4Explosion", icons = { Icon.C4 }, hint = Hints.Explosion },

    [104532] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, hint = Hints.Hack },
    [103179] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103198 }, hint = Hints.Hack },
    [103259] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103177 }, hint = Hints.Hack },
    [103590] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103196 }, hint = Hints.Hack },
    [103620] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103293 }, hint = Hints.Hack },
    [103671] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103311 }, hint = Hints.Hack },
    [103734] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103313 }, hint = Hints.Hack },
    [103776] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103323 }, hint = Hints.Hack },
    [103815] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103328 }, hint = Hints.Hack },
    [103903] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103335 }, hint = Hints.Hack },
    [103920] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103356 }, hint = Hints.Hack },
    [103936] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103361 }, hint = Hints.Hack },
    [103956] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103376 }, hint = Hints.Hack },
    [103974] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103397 }, hint = Hints.Hack },
    [103988] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103418 }, hint = Hints.Hack },
    [104014] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103445 }, hint = Hints.Hack },
    [104029] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103463 }, hint = Hints.Hack },
    [104051] = { time = 20, id = "PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 103504 }, hint = Hints.Hack },

    -- Heli escape
    [104126] = { time = 23 + 1, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape },

    [104091] = { time = 200/30, id = "CraneLiftUp", icons = { "piggy" }, hint = Hints.big_Piggy },
    [104261] = { time = 1000/30, id = "CraneMoveLeft", icons = { "piggy" }, hint = Hints.big_Piggy },
    [104069] = { time = 1000/30, id = "CraneMoveRight", icons = { "piggy" }, hint = Hints.big_Piggy },

    [104783] = { time = 8, id = "Bus", icons = { Icon.Wait }, hint = Hints.Wait }
}
if EHI:IsClient() then
    triggers[101605] = { time = 16.7 * 17, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(ThermiteWP), hint = Hints.Thermite }
    local doesnotexists = {
        [101817] = true,
        [101819] = true,
        [101825] = true,
        [101826] = true,
        [101828] = true,
        [101829] = true
    }
    local multiplier = 16
    for i = 101812, 101833, 1 do
        if not doesnotexists[i] then
            triggers[i] = { time = 16.7 * multiplier, id = "Thermite", icons = { Icon.Fire }, special_function = SF.AddTrackerIfDoesNotExist, waypoint = deep_clone(ThermiteWP), hint = Hints.Thermite }
            multiplier = multiplier - 1
        end
    end
end

local bigbank_4 = { special_function = SF.Trigger, data = { 1, 2 } }
---@type ParseAchievementTable
local achievements =
{
    bigbank_4 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            [1] = { time = 720, class = TT.Achievement.Base },
            [2] = { special_function = SF.RemoveTrigger, data = { 100107, 106140, 106150 } },
            [100107] = bigbank_4,
            [106140] = bigbank_4,
            [106150] = bigbank_4,
        },
        load_sync = function(self)
            self._achievements:AddTimedAchievementTracker("bigbank_4", 720)
        end
    },
    cac_22 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [106250] = { special_function = SF.SetAchievementFailed },
            [106247] = { special_function = SF.SetAchievementComplete }
        },
        alarm_callback = function(dropin)
            if dropin or not managers.preplanning:IsAssetBought(106594) then -- C4 Escape
                return
            end
            managers.ehi_achievement:AddAchievementStatusTracker("cac_22")
        end,
        sync_params = { from_start = true }
    }
}
if TheFixes then
    local Preventer = TheFixesPreventer or {}
    if not Preventer.achi_matrix_with_lasers and achievements.cac_22.difficulty_pass then -- Fixed
        achievements.cac_22.cleanup_callback = EHIAchievementManager:AddTFCallback("cac_22", "EHI_BigBank_TheFixes")
    end
end

local other =
{
    -- "Silent Alarm 30s delay" does not delay first assault
    -- Reported in:
    -- https://steamcommunity.com/app/218620/discussions/14/3487502671137130788/
    [100109] = EHI:AddAssaultDelay({ control = 30, trigger_times = 1 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 3 }
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
    achievement = achievements,
    other = other
})
EHI:ShowAchievementLootCounter({
    achievement = "bigbank_3",
    max = 16,
    show_finish_after_reaching_target = true
})

local tbl =
{
    --units/payday2/props/gen_prop_security_timelock/gen_prop_security_timelock
    [101457] = { icons = { Icon.Door } },
    [104671] = { icons = { Icon.Door } },

    --units/payday2/equipment/gen_interactable_lance_huge/gen_interactable_lance_huge
    [105318] = { remove_vanilla_waypoint = 103700 },
    [105319] = { remove_vanilla_waypoint = 103702 },
    [105320] = { remove_vanilla_waypoint = 103704 },
    [105321] = { remove_vanilla_waypoint = 103705 },

    --units/payday2/props/gen_prop_construction_crane/gen_prop_construction_crane_arm
    [105111] = { f = function(id, unit_data, unit)
        if not EHI:GetOption("show_waypoints") then
            return
        end
        local t = { unit = unit }
        EHI:AddWaypointToTrigger(104091, t)
        EHI:AddWaypointToTrigger(104261, t)
        EHI:AddWaypointToTrigger(104069, t)
        unit:unit_data():add_destroy_listener("EHIDestroy", function(...)
            managers.ehi_waypoint:RemoveWaypoint("CraneLiftUp")
            managers.ehi_waypoint:RemoveWaypoint("CraneMoveLeft")
            managers.ehi_waypoint:RemoveWaypoint("CraneMoveRight")
        end)
    end }
}
EHI:UpdateUnits(tbl)

EHI:SetMissionDoorData({
    -- Server Room
    [Vector3(733.114, 1096.92, -907.557)] = { w_id = 103457, restore = true, unit_id = 104582 },
    [Vector3(1419.89, -1897.92, -907.557)] = { w_id = 103461, restore = true, unit_id = 104584 },
    [Vector3(402.08, -1266.89, -507.56)] = { w_id = 103465, restore = true, unit_id = 104585 },

    -- Roof
    [Vector3(503.08, 1067.11, 327.432)] = { w_id = 101306, restore = true, unit_id = 100311 },
    [Vector3(503.08, -1232.89, 327.432)] = { w_id = 106362, restore = true, unit_id = 103322 },
    [Vector3(3446.92, -1167.11, 327.432)] = { w_id = 106372, restore = true, unit_id = 105317 },
    [Vector3(3466.11, 1296.92, 327.432)] = { w_id = 106382, restore = true, unit_id = 106336 }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 8000, name = "correct_pc_hack" },
        { amount = 4000, name = "timelock_done" },
        { amount = 10000, name = "fs_secured_required_bags" },
        { escape = 8000 }
    },
    loot_all = 1000
})