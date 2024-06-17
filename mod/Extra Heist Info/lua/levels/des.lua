local EHI = EHI
local Icon = EHI.Icons
---@class EHIChemSetTracker : EHITracker
---@field super EHITracker
EHIChemSetTracker = class(EHITracker)
EHIChemSetTracker._forced_icons = { Icon.Methlab }
EHIChemSetTracker._update = false
EHIChemSetTracker._init_create_text = false
function EHIChemSetTracker:OverridePanel()
    self:SetBGSize(self._bg_box:w() / 2)
    self:SetIconX()
    local third = self._bg_box:w() / 3
    self._first_ingredient = self:CreateText({
        text = "0.69",
        w = third,
        FitTheText = true
    })
    local font_size = self._first_ingredient:font_size()
    self._first_ingredient:set_text("")
    self._first_ingredient:set_left(0)
    self._second_ingredient = self:CreateText({
        w = third,
        left = self._first_ingredient:right(),
        FitTheText = true,
        FitTheText_FontSize = font_size
    })
    self._third_ingredient = self:CreateText({
        w = third,
        left = self._second_ingredient:right(),
        FitTheText = true,
        FitTheText_FontSize = font_size
    })
    self._progress = 0
    self._refresh_on_delete = true
    self._ingredients = {}
    self._state = "idle"
end

function EHIChemSetTracker:IncreaseProgress()
    self._progress = self._progress + 1
    if self._progress == 1 then
        self._text = self._first_ingredient
    elseif self._progress == 2 then
        self._text = self._second_ingredient
    else
        self._text = self._third_ingredient
    end
end

---@param t number
function EHIChemSetTracker:SetCooking(t)
    self._time = t
    self:IncreaseProgress()
    self:SetTextColor(Color.yellow)
    self._state = "cooking"
    self:AddTrackerToUpdate()
    self:AnimateBG(1)
end

---@param t number
function EHIChemSetTracker:SetReset(t)
    self._time = t
    self:IncreaseProgress()
    self:SetTextColor(Color.red)
    self._state = "reset"
    self:AddTrackerToUpdate()
    self:AnimateBG(1)
end

---@param t number
function EHIChemSetTracker:SetInterrupted(t)
    self._time = t
    self:SetTextColor(Color.red)
    self._state = "interrupted"
    self:AnimateBG(1)
end

---@param ingredient string
---@param pos number
function EHIChemSetTracker:SetIngredient(ingredient, pos)
    self._ingredients[pos] = ingredient
    if pos == 1 then
        self._first_ingredient:set_text(ingredient)
    elseif pos == 2 then
        self._second_ingredient:set_text(ingredient)
    else
        self._third_ingredient:set_text(ingredient)
    end
end

function EHIChemSetTracker:Refresh()
    self:RemoveTrackerFromUpdate()
    if self._state == "reset" then
        self:SetTextColor(Color.white)
        self._text:set_text(self._ingredients[self._progress] or "?")
        self._progress = self._progress - 1
    elseif self._state == "interrupted" then
        self:SetTextColor(Color.white, self._first_ingredient)
        self:SetTextColor(Color.white, self._second_ingredient)
        self:SetTextColor(Color.white, self._third_ingredient)
        self._first_ingredient:set_text(self._ingredients[1] or "?")
        self._second_ingredient:set_text(self._ingredients[2] or "?")
        self._third_ingredient:set_text(self._ingredients[3] or "?")
        self._progress = 0
    else
        self:SetTextColor(Color.green)
        self._text:set_text(self._ingredients[self._progress] or "?")
    end
    self._state = "idle"
    self:AnimateBG(1)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
---@type ParseTriggerTable
local triggers = {
    [108538] = { time = 60, id = "Gas", icons = { Icon.Teargas }, hint = Hints.Teargas },

    [102520] = { time = 30, id = "ChemLabThermite", icons = { Icon.Fire }, hint = Hints.Thermite, waypoint = { position_by_element = 100881 } },

    [100423] = { time = 60 + 25 + 3, id = "EscapeHeli", icons = Icon.HeliEscape, waypoint = { icon = Icon.Heli, position_by_element = 100451 }, hint = Hints.LootEscape },
    -- 60s delay after flare has been placed
    -- 25s to land
    -- 3s to open the heli doors

    [102593] = { time = 30, id = "ChemSetReset", icons = { Icon.Methlab, Icon.Loop }, hint = Hints.des_ChemSetRestart },
    [101217] = { time = 30, id = "ChemSetInterrupted", icons = { Icon.Methlab, Icon.Loop }, special_function = SF.ReplaceTrackerWithTracker, data = { id = "ChemSetCooking" }, hint = Hints.des_ChemSetInterrupt },
    [102595] = { time = 30, id = "ChemSetCooking", icons = { Icon.Methlab }, hint = Hints.des_ChemSetCooking },

    [102009] = { time = 60, id = "Crane", icons = { Icon.Winch }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.des_Crane, waypoint = { icon = Icon.Defend, position_by_element_and_remove_vanilla_waypoint = 102470 } },
    [101702] = { id = "Crane", special_function = SF.PauseTracker },

    [102473] = { chance = 20, id = "HackChance", icons = { Icon.PCHack }, class = TT.Timer.Chance, hint = Hints.Hack },
    [108694] = { id = "HackChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
    [101485] = { id = "HackChance", special_function = SF.RemoveTracker }
}
if EHI:IsClient() then
    triggers[100564] = EHI:ClientCopyTrigger(triggers[100423], { time = 25 + 3 })
    -- Not worth adding the 3s delay here
end
if EHI:GetOption("show_mission_trackers") then
    local function SetIngredient(arg)
        managers.ehi_tracker:CallFunction("ChemSet", "SetIngredient", arg[1], arg[2])
    end
    local ChemSet = EHI:RegisterCustomSF(function(self, trigger, ...)
        if self._trackers:TrackerExists("ChemSet") then
            if trigger.id == "ChemSetCooking" then
                self._trackers:CallFunction("ChemSet", "SetCooking", trigger.time)
            elseif trigger.id == "ChemSetInterrupted" then
                self._trackers:CallFunction("ChemSet", "SetInterruped", trigger.time)
            else
                self._trackers:CallFunction("ChemSet", "SetReset", trigger.time)
            end
            return
        elseif trigger.id == "ChemSetReset" then
            self:ForceRemove(trigger.data.id)
        end
        self:CreateTracker(trigger)
    end)
    triggers[102593].special_function = ChemSet
    triggers[101217].special_function = ChemSet
    triggers[102595].special_function = ChemSet
    triggers[EHI:GetInstanceElementID(100046, 15000)] = { id = "ChemSet", class = "EHIChemSetTracker" }
    triggers[EHI:GetInstanceElementID(100048, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "A", 1 } }
    triggers[EHI:GetInstanceElementID(100049, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "B", 1 } }
    triggers[EHI:GetInstanceElementID(100050, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "C", 1 } }
    triggers[EHI:GetInstanceElementID(100051, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "D", 1 } }
    triggers[EHI:GetInstanceElementID(100066, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "A", 2 } }
    triggers[EHI:GetInstanceElementID(100068, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "B", 2 } }
    triggers[EHI:GetInstanceElementID(100070, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "C", 2 } }
    triggers[EHI:GetInstanceElementID(100072, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "D", 2 } }
    triggers[EHI:GetInstanceElementID(100074, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "A", 3 } }
    triggers[EHI:GetInstanceElementID(100076, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "B", 3 } }
    triggers[EHI:GetInstanceElementID(100078, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "C", 3 } }
    triggers[EHI:GetInstanceElementID(100080, 15000)] = { special_function = SF.CustomCode, f = SetIngredient, arg = { "D", 3 } }
    triggers[100715] = { id = "ChemSet", special_function = SF.RemoveTracker }
end

---@type ParseAchievementTable
local achievements =
{
    des_9 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100107] = { status = "push", class = TT.Achievement.Status },
            [102480] = { special_function = SF.Trigger, data = { 1024801, 1024802 } },
            [1024801] = { status = "finish", special_function = SF.SetAchievementStatus },
            [1024802] = { id = 102486, special_function = SF.RemoveTrigger }, ---@diagnostic disable-line
            [102710] = { special_function = SF.SetAchievementComplete },
            [102486] = { special_function = SF.SetAchievementFailed }
        },
        sync_params = { from_start = true }
    },
    des_11 =
    {
        elements =
        {
            [103025] = { time = 3, class = TT.Achievement.Base, trigger_times = 1 },
            [102822] = { special_function = SF.SetAchievementComplete }
        }
    },
    uno_5 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100296] = { max = 2, class = TT.Achievement.Progress },
            [103391] = { special_function = SF.IncreaseProgress },
            [103395] = { special_function = SF.SetAchievementFailed },
        }
    }
}

local other =
{
    [102065] = EHI:AddAssaultDelay({ control = 2 + 2 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100015] = { chance = 10, time = 1 + 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 30 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, trigger_times = 1, sniper_count = 2 }
    other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100297] = { chance = 25, recheck_t = 30, id = "SnipersBlackhawk", no_chance_reset = true, delay_on_max_chance = 23 + 25, class = TT.Sniper.HeliTimedChance }
    other[101295] = { id = "SnipersBlackhawk", special_function = SF.IncreaseChanceFromElement }
    other[101293] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess", arg = { 25 } }
    other[EHI:GetInstanceElementID(100023, 7500)] = { id = "SnipersBlackhawk", special_function = SF.IncreaseCounter }
    other[EHI:GetInstanceElementID(100007, 7500)] = { id = "SnipersBlackhawk", special_function = SF.DecreaseCounter }
    other[EHI:GetInstanceElementID(100025, 7500)] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SnipersKilled", arg = { 23 } }
    other[EHI:GetInstanceElementID(100023, 8000)] = { id = "SnipersBlackhawk", special_function = SF.IncreaseCounter }
    other[EHI:GetInstanceElementID(100007, 8000)] = { id = "SnipersBlackhawk", special_function = SF.DecreaseCounter }
    other[EHI:GetInstanceElementID(100025, 8000)] = { id = "SnipersBlackhawk", special_function = SF.CallCustomFunction, f = "SnipersKilled", arg = { 23 } }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    pre_parse = { filter_out_not_loaded_trackers = "show_timers" }
})

local tbl =
{
    --units/pd2_dlc_des/props/des_prop_inter_hack_computer/des_inter_hack_computer
    [103009] = { icons = { Icon.Power }, hint = Hints.Charging },

    --units/pd2_dlc_dah/props/dah_prop_hack_box/dah_prop_hack_ipad_unit
    [101323] = { remove_on_power_off = true },
    [101324] = { remove_on_power_off = true }
}

local DisableWaypoints =
{
    -- Crane Fix WP
    [102467] = true,

    -- Turret charging computer
    [101122] = true, -- Defend
    [103191] = true, -- Fix

    -- Outside hack turret box
    [102901] = true, -- Defend
    [102902] = true, -- Fix
    [102926] = true, -- Defend
    [102927] = true -- Fix
}

-- levels/instances/unique/des/des_computer/001-004
for i = 3000, 4500, 500 do
    tbl[EHI:GetInstanceUnitID(100051, i)] = { tracker_merge_id = "HackChance" }
end
-- levels/instances/unique/des/des_computer/012
tbl[EHI:GetInstanceUnitID(100051, 8500)] = { tracker_merge_id = "HackChance" }

-- levels/instances/unique/des/des_computer_001/001
-- levels/instances/unique/des/des_computer_002/001
for i = 6000, 6500, 500 do
    tbl[EHI:GetInstanceUnitID(i == 6000 and 100000 or 100051, i)] = { tracker_merge_id = "HackChance" }
end
-- levels/instances/unique/des/des_computer_002/002
tbl[EHI:GetInstanceUnitID(100051, 29550)] = { tracker_merge_id = "HackChance" }

EHI:UpdateUnits(tbl)
EHI:DisableWaypoints(DisableWaypoints)
EHI:ShowLootCounter({
    max = 8, -- 2 main loot; 6 artifacts in crates, one in Archaeology room -> 400511
    triggers =
    {
        [102491] = { special_function = SF.IncreaseProgressMax } -- Archaeology, one more bag next to the objective
    },
    load_sync = function(self)
        if self:IsMissionElementDisabled(101506) then
            self._loot:IncreaseLootCounterProgressMax()
        end
        self._loot:SyncSecuredLoot()
    end
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "diamond_heist_boxes_hack" },
        { amount = 2000, name = "ed1_hack_1" },
        { amount = 2000, name = "henrys_rock_first_mission_bag_on_belt" },
        {
            random =
            {
                max = 2,
                archaelogy =
                {
                    { amount = 6000, name = "henrys_rock_drilled_archaelogy_door" },
                    { amount = 2000, name = "henrys_rock_archaelogy_chest_open" }
                },
                biolab =
                {
                    { amount = 6000, name = "henrys_rock_made_concoction" }
                },
                weapon_lab =
                {
                    { amount = 4000, name = "henrys_rock_weapon_fired", times = 2 }
                },
                computer_lab =
                {
                    { amount = 2000, name = "pc_hack" },
                    { amount = 2000, name = "henrys_rock_crane" }
                }
            }
        },
        { amount = 4000, name = "twh_disable_aa" },
        { escape = 6000 }
    },
    loot =
    {
        mus_artifact = 2000
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    random =
                    {
                        min =
                        {
                            biolab = true,
                            computer_lab = true
                        },
                        max =
                        {
                            archaelogy = true,
                            computer_lab =
                            {
                                { times = 4 },
                                true
                            }
                        }
                    }
                },
                loot =
                {
                    mus_artifact = { max = 7 }
                }
            }
        }
    }
})