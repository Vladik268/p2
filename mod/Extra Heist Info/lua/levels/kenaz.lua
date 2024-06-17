local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local refill_icon = { Icon.Water, Icon.Loop }
if EHI:GetOption("show_one_icon") then
    refill_icon = { { icon = Icon.Water, color = tweak_data.ehi.colors.WaterColor } }
end
---@type EHI.ColorTable
local keycode_units =
{
    red =
    {
        unit_id = 100000,
        indexes = { 28250, 15020, 15120 }
    },
    green =
    {
        unit_ids = { 100125, 100113, 100224, 100225, 100007, 100290 },
        indexes = { 21500, 25000, 31225 }
    },
    blue =
    {
        unit_ids = { 100061, 100064 },
        index = 15370
    }
}
local preload =
{
    { id = "RefillLeft01", icons = refill_icon, hide_on_delete = true, hint = Hints.crojob3_Water },
    { id = "RefillLeft02", icons = refill_icon, hide_on_delete = true, hint = Hints.crojob3_Water },
    { id = "RefillRight01", icons = refill_icon, hide_on_delete = true, hint = Hints.crojob3_Water },
    { id = "RefillRight02", icons = refill_icon, hide_on_delete = true, hint = Hints.crojob3_Water }
}
---@type ParseTriggerTable
local triggers = {
    [100282] = { id = "ColorCodes", class = TT.ColoredCodes, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        if managers.preplanning:IsAssetBought(101826) then -- Loud entry with C4
            return
        end
        self:CreateTracker(trigger)
    end) },
    [100091] = { id = "ColorCodes", special_function = SF.RemoveTracker }, -- Code entered (stealth)
    [101357] = { id = "ColorCodes", special_function = EHI:RegisterCustomSF(function(self, trigger, element, enabled)
        if enabled then
            self._trackers:RemoveTracker(trigger.id)
        end
    end) }, -- Code entered (loud)

    [EHI:GetInstanceElementID(100173, 66615)] = { time = 5 + 25, id = "ArmoryKeypadReboot", icons = { Icon.Wait }, waypoint = { position_by_unit = EHI:GetInstanceUnitID(100000, 66615) }, hint = Hints.KeypadReset },
    [EHI:GetInstanceElementID(100193, 66615)] = { time = 30, id = "ArmoryKeypadRebootECM", icons = { Icon.Wait }, special_function = SF.TriggerIfEnabled, waypoint = { position_by_unit = EHI:GetInstanceUnitID(100000, 66615) }, hint = Hints.KeypadReset },

    -- Heli Winch Drop handled in CoreWorldInstanceManager

    -- Toilets
    [EHI:GetInstanceElementID(100181, 13000)] = { id = "RefillLeft01", run = { time = 30 } },
    [EHI:GetInstanceElementID(100233, 13000)] = { id = "RefillRight01", run = { time = 30 } },
    [EHI:GetInstanceElementID(100299, 13000)] = { id = "RefillLeft02", run = { time = 30 } },
    [EHI:GetInstanceElementID(100300, 13000)] = { id = "RefillRight02", run = { time = 30 } },

    [100489] = { special_function = SF.RemoveTracker, data = { "WaterTimer1", "WaterTimer2" } },

    [EHI:GetInstanceElementID(100166, 37575)] = { id = "DrillDrop", icons = { Icon.Winch, Icon.Drill, Icon.Goto }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
    [EHI:GetInstanceElementID(100167, 37575)] = { id = "DrillDrop", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100166, 44535)] = { id = "DrillDrop", icons = { Icon.Winch, Icon.Drill, Icon.Goto }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101854, yes = 900/30, no = 1800/30 } },
    [EHI:GetInstanceElementID(100167, 44535)] = { id = "DrillDrop", special_function = SF.PauseTracker },

    -- Water during drilling
    [EHI:GetInstanceElementID(100148, 37575)] = { id = "WaterTimer1", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60 }, hint = Hints.crojob3_Water },
    [EHI:GetInstanceElementID(100146, 37575)] = { id = "WaterTimer1", special_function = SF.PauseTracker },
    [EHI:GetInstanceElementID(100149, 37575)] = { id = "WaterTimer2", icons = { Icon.Water }, class = TT.Pausable, special_function = SF.UnpauseOrSetTimeByPreplanning, data = { id = 101762, yes = 120, no = 60 }, hint = Hints.crojob3_Water },
    [EHI:GetInstanceElementID(100147, 37575)] = { id = "WaterTimer2", special_function = SF.PauseTracker },

    [100159] = { id = "BlimpWithTheDrill", icons = { Icon.Blimp, Icon.Drill }, special_function = SF.SetTimeByPreplanning, data = { id = 101854, yes = 976/30, no = 1952/30 }, hint = Hints.DrillDelivery },
    [100426] = { time = 1000/30, id = "BlimpLowerTheDrill", icons = { Icon.Blimp, Icon.Drill, Icon.Goto }, hint = Hints.Wait },

    [EHI:GetInstanceElementID(100173, 66365)] = { time = 30, id = "VaultKeypadReset", icons = { Icon.Loop }, hint = Hints.KeypadReset }
}
EHI:HookColorCodes(keycode_units)

---@type ParseAchievementTable
local achievements =
{
    kenaz_3 =
    {
        elements =
        {
            [102807] = { status = Status.Defend, class = TT.Achievement.Status },
            [102809] = { special_function = SF.SetAchievementFailed },
            [103163] = { status = Status.Finish, special_function = SF.SetAchievementStatus }
        }
    },
    kenaz_4 =
    {
        elements =
        {
            [100282] = { time = 840, class = TT.Achievement.Base }
        },
        load_sync = function(self)
            self._achievements:AddTimedAchievementTracker("kenaz_4", 840)
        end,
        mission_end_callback = true
    },
    kenaz_5 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100008, 12500)] = { class = TT.Achievement.Status },
            [EHI:GetInstanceElementID(100008, 12580)] = { class = TT.Achievement.Status },
            [EHI:GetInstanceElementID(100008, 12660)] = { class = TT.Achievement.Status },
            [EHI:GetInstanceElementID(100008, 18700)] = { class = TT.Achievement.Status },
            [102806] = { status = Status.Finish, special_function = SF.SetAchievementStatus },
            [102808] = { special_function = SF.SetAchievementFailed }
        }
    }
}

local other =
{
    [100228] = EHI:AddAssaultDelay({ control = 35 + 1, special_function = EHI:RegisterCustomSF(function(self, trigger, ...)
        local t = 0
        if managers.preplanning:IsAssetBought(101858) then
            t = 10
        elseif managers.preplanning:IsAssetBought(101815) then
            t = 30
        end
        trigger.time = trigger.time + t
        self:CreateTracker(trigger)
    end) })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        normal = 2,
        hard = 3,
        veryhard = 3,
        overkill_or_above = 5
    })
    other[100548] = { chance = 100, time = 150 + 120, on_fail_refresh_t = 120, on_success_refresh_t = 120, id = "Snipers", class = TT.Sniper.Loop, sniper_count = sniper_count }
    other[101405] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[101404] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[101406] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 25%
    other[101049] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[101050] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[101408] = { id = "Snipers", special_function = SF.DecreaseCounter }
    if EHI:IsClient() then
        other[101038] = EHI:CopyTrigger(other[100548], { chance = 25, time = 120 }, SF.AddTrackerIfDoesNotExist)
    end
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    preload = preload
})
local bags = 5 + 2 + 5 -- Normal + Hard
if EHI:IsDifficulty(EHI.Difficulties.VeryHard) then
    bags = 8 + 3 + 8
elseif EHI:IsDifficulty(EHI.Difficulties.OVERKILL) then
    bags = 10 + 4 + 10
elseif EHI:IsMayhemOrAbove() then
    bags = 12 + 5 + 12
end
EHI:ShowLootCounter({ max = 2 + bags }) -- Dentist loot (mandatory) + Money + Painting

local xp_override =
{
    params =
    {
        min_max =
        {
            objectives =
            {
                ggc_color_code = { min_max = 3 }
            },
            loot_all = { min = 1, max = bags + 2 }
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
                { amount = 1000, name = "ggc_gear_found" },
                { amount = 4000, name = "ggc_blueprint_found" },
                { amount = 4000, name = "ggc_blueprint_send" },
                { amount = 4000, name = "ggc_got_data" },
                { amount = 4000, name = "ggc_civie_drugged" },
                { amount = 4000, name = "ggc_gas_planted" },
                { amount = 4000, name = "ggc_color_code" },
                { amount = 4000, name = "vault_open" },
                { amount = 2000, name = "ggc_laser_disabled" }
            },
            loot_all = 500,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 4000, name = "ggc_color_code" },
                { amount = 2000, name = "ggc_locker_room_found" },
                { amount = 2000, name = "ggc_c4_taken", times = 1 },
                { amount = 4000, name = "ggc_weak_spot_found" },
                { amount = 3000, name = "ggc_winch_part_picked_up", times = 1 },
                { amount = 6000, name = "ggc_winch_set_up" },
                { amount = 2000, name = "ggc_fireworks" },
                { amount = 8000, name = "ggc_bfd_lowered" },
                { amount = 1000, name = "ggc_winch_connected_to_bfd" },
                { amount = 2000, name = "ggc_bfd_in_position" },
                { amount = 6000, name = "ggc_bfd_started" },
                { amount = 10000, name = "ggc_bfd_done" }
            },
            loot_all = 500,
            total_xp_override = xp_override
        }
    }
})

if EHI:IsHost() then
    keycode_units = nil ---@diagnostic disable-line
    return
end
local bg = Idstring("g_top_opened"):key()
local codes = {}
for color, _ in pairs(keycode_units) do
    codes[color] = {}
    local _c = codes[color]
    for i = 0, 9, 1 do
        local str = "g_number_" .. color .. "_0" .. tostring(i)
        _c[i] = Idstring(str):key()
    end
end
local function CheckIfCodeIsVisible(unit, color)
    if not unit then
        return nil
    end
    local color_codes = codes[color]
    local object = unit:damage() and unit:damage()._state and unit:damage()._state.object
    if object and object[bg] then
        for i = 0, 9, 1 do
            if object[color_codes[i]] then
                return i
            end
        end
    end
    return nil -- Has not been interacted yet
end
local function Cleanup()
    keycode_units = nil ---@diagnostic disable-line
    codes = nil
    bg = nil
end
EHI:AddLoadSyncFunction(function(self)
    if managers.preplanning:IsAssetBought(101826) then -- Loud entry with C4
        return Cleanup()
    elseif self.ConditionFunctions.IsStealth() and self:IsMissionElementDisabled(100270) then -- If it is disabled, the vault has been opened; exit
        return Cleanup()
    elseif managers.game_play_central:GetMissionEnabledUnit(EHI:GetInstanceUnitID(100184, 66615)) then -- If it is enabled, the armory has been opened; exit
        return Cleanup()
    end
    self._trackers:AddTracker({
        id = "ColorCodes",
        class = TT.ColoredCodes
    })
    local wd = managers.worlddefinition
    for color, data in pairs(keycode_units) do
        if data.unit_ids then
            for _, unit_id in ipairs(data.unit_ids) do
                if data.indexes then
                    for _, index in ipairs(data.indexes) do
                        local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, index))
                        local code = CheckIfCodeIsVisible(unit, color)
                        if code then
                            self._trackers:CallFunction("ColorCodes", "SetCode", color, code)
                            break
                        end
                    end
                else
                    local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, data.index))
                    local code = CheckIfCodeIsVisible(unit, color)
                    if code then
                        self._trackers:CallFunction("ColorCodes", "SetCode", color, code)
                        break
                    end
                end
            end
        else
            local unit_id = data.unit_id
            if data.indexes then
                for _, index in ipairs(data.indexes) do
                    local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, index))
                    local code = CheckIfCodeIsVisible(unit, color)
                    if code then
                        self._trackers:CallFunction("ColorCodes", "SetCode", color, code)
                        break
                    end
                end
            else
                local unit = wd:get_unit(EHI:GetInstanceUnitID(unit_id, data.index))
                local code = CheckIfCodeIsVisible(unit, color)
                if code then
                    self._trackers:CallFunction("ColorCodes", "SetCode", color, code)
                    break
                end
            end
        end
    end
    Cleanup()
end)