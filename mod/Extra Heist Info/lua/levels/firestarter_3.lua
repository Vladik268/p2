local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local triggers = {}
---@type ParseAchievementTable
local achievements = {}
local other = {}
local EscapeXP = 16000
if Global.game_settings.level_id == "firestarter_3" then
    triggers[102144] = { time = 90, id = "MoneyBurn", icons = { Icon.Fire }, hint = Hints.Fire }
    achievements.slakt_5 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [102144] = { class = TT.Achievement.Status },
            [102146] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [105237] = { special_function = SF.SetAchievementComplete },
            [105235] = { special_function = SF.SetAchievementFailed }
        }
    }
else
    -- Branchbank: Random, Branchbank: Gold, Branchbank: Cash, Branchbank: Deposit
    tweak_data.ehi.functions.uno_1()
    if EHI:GetOption("show_escape_chance") then
        other[103306] = { id = "EscapeChance", special_function = SF.IncreaseChanceFromElement }
        EHI:AddOnAlarmCallback(function(dropin)
            local start_chance = 5
            if managers.mission:check_mission_filter(2) or managers.mission:check_mission_filter(3) then -- Cash or Gold
                start_chance = 15 -- 5 (start_chance) + 10
            end
            managers.ehi_escape:AddEscapeChanceTracker(dropin, start_chance)
        end)
    end
    EscapeXP = 12000
end
triggers[101425] = { time = 24 + 7, id = "TeargasIncoming1", icons = { Icon.Teargas, "pd2_generic_look" }, class = TT.Warning, hint = Hints.Teargas }
triggers[105611] = { time = 24 + 7, id = "TeargasIncoming2", icons = { Icon.Teargas, "pd2_generic_look" }, class = TT.Warning, hint = Hints.Teargas }

achievements.voff_1 =
{
    difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
    elements =
    {
        [101539] = { status = Status.Bring, class = TT.Achievement.Status },
        [105686] = { special_function = SF.SetAchievementComplete },
        [105691] = { status = Status.Finish, special_function = SF.SetAchievementStatus }, -- Entered area again
        [105694] = { status = Status.Finish, special_function = SF.SetAchievementStatus }, -- Both secured
        [105698] = { status = Status.Bring, special_function = SF.SetAchievementStatus }, -- Left the area
        [105704] = { special_function = SF.SetAchievementFailed } -- Killed
    }
}

other[105364] = EHI:AddAssaultDelay({ control = 10 + 60, special_function = SF.AddTimeByPreplanning, data = { id = 104875, yes = 30, no = 15 } })
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100438] = { chance = 10, time = 30 + 60, id = "Snipers", class = TT.Sniper.Loop, single_sniper = true }
    other[105327] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[101481] = { id = "Snipers", special_function = EHI:RegisterCustomSF(function(self, trigger, element, ...)
        local id = trigger.id
        self._trackers:SetChance(id, element._values.chance) -- 20%
        self._trackers:SetTrackerTimeNoAnim(id, 60)
        self._trackers:CallFunction(id, "AnnounceSniperSpawn")
    end)}
    other[101446] = { special_function = SF.CallTrackerManagerFunction, f = "SetTrackerTimeNoAnim", arg = { "Snipers", 60 } }
    -- Sniper spawn
    other[103529] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[103534] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[101066] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100945] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[101068] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[101444] = { id = "Snipers", special_function = SF.IncreaseCounter }
    -- Sniper death
    other[101635] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101632] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101638] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101640] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101645] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[101627] = { id = "Snipers", special_function = SF.DecreaseCounter }
end
if EHI:IsLootCounterVisible() then
    local deposit_boxes = {
        104218, 104188, 103939, 100663, 101241, 104247, 104219, 104217, 104189, 104187,
        103940, 101390, 100664, 104261, 101247, 104244, 104220, 104214, 104190, 104184,
        103986, 101388, 101094, 104256, 101252, 104245, 104222, 104215, 104192, 104185,
        103988, 101389, 101240, 104251, 101257, 104243, 104223, 104213, 104193, 104183,
        104036, 101263, 101242, 104246, 101262, 104242, 104224, 104212, 104194, 104182,
        104038, 101261, 101243, 104241, 104146, 104240, 104225, 104210, 104195, 104180,
        104086, 101260, 101244, 104236, 104176, 104239, 104227, 104209, 104197, 104179,
        104088, 101259, 101245, 104231, 104181, 104238, 104228, 104208, 104198, 104178,
        104136, 101258, 101248, 104226, 104186, 104237, 104229, 104207, 104199, 104177,
        104138, 101256, 101249, 104221, 104191, 104235, 104230, 104205, 104200, 104175,
        104147, 101255, 101250, 104216, 104196, 104234, 104232, 104204, 104202, 104150,
        104148, 101254, 101251, 104211, 104201, 104233, 104203, 104149, 101253, 104206
    }
    other[105762] = EHI:AddLootCounter2(function()
        local firestarter = Global.game_settings.level_id == "firestarter_3"
        EHI:ShowLootCounterNoChecks({
            max = tweak_data.ehi.functions.GetNumberOfDepositBoxesWithLoot2(deposit_boxes),
            offset = firestarter,
            client_from_start = true,
            unknown_random = not firestarter
        })
    end)
    other[103372] = { special_function = EHI:RegisterCustomSF(function(self, ...)
        if not self._trackers:TrackerExists("LootCounter") then
            self:Trigger(105762) --- You had your last chance here, son.
        end
        self._loot:SetUnknownRandomLoot()
    end) }
    other[104647] = other[103372]
    local LootVisible = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:IncreaseLootCounterProgressMax()
    end) }
    for i = 104543, 104553, 1 do
        other[i] = LootVisible
    end
    other[104577] = LootVisible
    other[104578] = LootVisible
    other[104579] = LootVisible
    other[104594] = LootVisible
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    --units/payday2/equipment/gen_interactable_lance_large/gen_interactable_lance_large
    [104674] = { remove_vanilla_waypoint = 102633 },
    [104466] = { remove_vanilla_waypoint = 102752 }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objective =
    {
        escape = EscapeXP
    },
    loot_all = 500,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = EscapeXP == 12000 and 1 or 0, max = 5 + (EscapeXP == 12000 and 8 or 0) }
            }
        }
    }
})

if not EHI:CanShowAchievement("voff_1") then
    return
end
local dog_haters =
{
    [Idstring("units/payday2/characters/civ_male_dog_abuser_1/civ_male_dog_abuser_1"):key()] = true,
    [Idstring("units/payday2/characters/civ_male_dog_abuser_2/civ_male_dog_abuser_2"):key()] = true
}
EHI:AddLoadSyncFunction(function(self)
    local dog_haters_unit = {}
    local count = 0
    local civies = managers.enemy:all_civilians()
    for _, data in pairs(civies or {}) do
        local name_key = data.unit:name():key()
        if dog_haters[name_key] then
            count = count + 1
            dog_haters_unit[count] = data.unit
            dog_haters[name_key] = nil
        end
        if count == 2 then
            break
        end
    end
    dog_haters = nil
    if count ~= 2 then
        return
    end
    -- Exit areas share the same space
    local secure_area_1 = managers.mission:get_element_by_id(105674) -- ´dog_abuse_trigger_enter_001´ ElementAreaTrigger 105674
    local secure_area_2 = managers.mission:get_element_by_id(105678) -- ´dog_abuse_trigger_enter_002´ ElementAreaTrigger 105678
    local secure_area_3 = managers.mission:get_element_by_id(105679) -- ´dog_abuse_trigger_enter_003´ ElementAreaTrigger 105679
    if not (secure_area_1 and secure_area_2 and secure_area_3) then
        return
    end
    self:Trigger(101539)
    local pos_1 = dog_haters_unit[1]:position()
    local pos_2 = dog_haters_unit[2]:position()
    if (secure_area_1:_is_inside(pos_1) and secure_area_1:_is_inside(pos_2)) or
        (secure_area_2:_is_inside(pos_1) and secure_area_2:_is_inside(pos_2)) or
        (secure_area_3:_is_inside(pos_1) and secure_area_3:_is_inside(pos_2)) then
        self._achievements:SetAchievementStatus("voff_1", "finish")
    end
end)
EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    if EHI:IsPlayingFromStart() then
        local function fail(...)
            managers.ehi_achievement:SetAchievementFailed("voff_1")
        end
        local civies = managers.enemy:all_civilians()
        for _, data in pairs(civies or {}) do
            local name_key = data.unit:name():key()
            if dog_haters[name_key] then
                data.unit:base():add_destroy_listener("EHI_" .. tostring(name_key), fail)
            end
        end
        dog_haters = nil
    end
end)