local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local heli_delay = 26 + 6
local OVKorAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type EHI.ColorTable
local dah_laptop_codes =
{
    red = 1900,
    green = 2100,
    blue = 2300
}
local element_sync_triggers =
{
    [103569] = { time = 25, id = "CFOFall", icons = { Icon.Hostage, Icon.Goto }, hook_element = 100438, hint = Hints.Wait }
}
---@type ParseTriggerTable
local triggers = {
    [100276] = { time = 25 + 3 + 11, id = "CFOInChopper", icons = { Icon.Heli, Icon.Goto }, waypoint = { icon = Icon.Defend, position_by_element_and_remove_vanilla_waypoint = 102822 }, hint = Hints.Wait },

    [104875] = { time = 45 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 100475, remove_vanilla_waypoint = 104882 }, hint = Hints.Escape },
    [103159] = { time = 30 + heli_delay, id = "HeliEscapeLoud", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element_and_remove_vanilla_waypoint = 103163 }, hint = Hints.Escape },

    [103969] = { id = "ColorCodes", class = TT.ColoredCodes, remove_on_alarm = true },
    [101652] = { id = "ColorCodes", special_function = SF.RemoveTracker } -- Vault opened
}
EHI:HookColorCodes(dah_laptop_codes, { unit_id_all = 100052 })

local other =
{
    [100479] = EHI:AddAssaultDelay({ control = 30 + 2 })
}

---@param progress number?
local function dah_8(progress)
    progress = progress or 0
    if progress >= 12 then
        return
    end
    EHI:ShowAchievementLootCounterNoCheck({
        achievement = "dah_8",
        progress = progress,
        max = 12,
        counter =
        {
            check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
            loot_type = "diamondheist_big_diamond"
        }
    })
end
---@type ParseAchievementTable
local achievements =
{
    dah_8 =
    {
        difficulty_pass = OVKorAbove,
        elements =
        {
            [103969] = { special_function = SF.CustomCode, f = dah_8 },
            [102259] = { special_function = SF.SetAchievementComplete },
            [102261] = { special_function = SF.IncreaseProgress }
        },
        failed_on_alarm = true,
        load_sync = function(self)
            if self.ConditionFunctions.IsStealth() then
                dah_8(managers.loot:GetSecuredBagsTypeAmount("diamondheist_big_diamond"))
            end
        end,
        cleanup_callback = function()
            dah_8 = nil ---@diagnostic disable-line
        end
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})

local DisableWaypoints =
{
    [101368] = true -- Drill waypoint for vault with red diamond
}
EHI:DisableWaypoints(DisableWaypoints)

EHI:ShowLootCounter({
    max = 8,
    triggers =
    {
        [101019] = { special_function = SF.IncreaseProgressMax } -- Red Diamond
    },
    load_sync = function(self)
        -- Red Diamond spawns on OVK or above only
        if OVKorAbove and managers.game_play_central:GetMissionDisabledUnit(100950) then -- Red Diamond
            self._loot:IncreaseLootCounterProgressMax()
        end
        self._loot:SyncSecuredLoot()
    end
})
local loot, loot_all
if OVKorAbove then
    loot =
    {
        red_diamond = 2000,
        diamonds_dah = 400
    }
else
    loot_all = 400
end
local MinBags = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 4,
    veryhard = 6,
    overkill_or_above = 8
})
local xp_override =
{
    params =
    {
        min_max =
        {
            loot =
            {
                red_diamond = { max = 1 },
                diamonds_dah = { min = MinBags, max = 8 }
            },
            loot_all = { min = MinBags, max = 8 }
        }
    }
}
local xp =
{
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 4000, name = "diamond_heist_boxes_hack" },
                { amount = 1000, name = "diamond_heist_found_color_codes" },
                { amount = 2000, name = "diamond_heist_found_keycard" },
                { escape = 2000 }
            },
            loot = loot,
            loot_all = loot_all,
            total_xp_override = xp_override
        },
        loud =
        {
            objectives =
            {
                { amount = 4000, name = "diamond_heist_boxes_hack" },
                { amount = 2000, name = "diamond_heist_found_keycard" },
                { amount = 4000, name = "diamond_heist_cfo_in_heli" },
                { amount = 4000, name = "vault_open" },
                { escape = 4000 }
            },
            loot = loot,
            loot_all = loot_all,
            total_xp_override = xp_override
        }
    }
}
EHI:AddXPBreakdown(xp)
if EHI:IsHost() then
    dah_laptop_codes = nil ---@diagnostic disable-line
    return
end
if EHI:GetOption("show_mission_trackers") then
    local bg = Idstring("g_code_screen"):key()
    local codes = {}
    for color, _ in pairs(dah_laptop_codes) do
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
    EHI:AddLoadSyncFunction(function(self)
        if self.ConditionFunctions.IsStealth() then
            self:Trigger(103969)
            local wd = managers.worlddefinition
            for color, data in pairs(dah_laptop_codes) do
                local unit_id = EHI:GetInstanceUnitID(100052, data)
                local unit = wd:get_unit(unit_id)
                local code = CheckIfCodeIsVisible(unit, color)
                if code then
                    self._trackers:CallFunction("ColorCodes", "SetCode", color, code)
                end
            end
        end
        -- Clear memory
        bg = nil
        codes = nil
        dah_laptop_codes = nil ---@diagnostic disable-line
    end)
else
    dah_laptop_codes = nil ---@diagnostic disable-line
end