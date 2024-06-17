local lerp = math.lerp
local sin = math.sin
local Color = Color
---@class EHIcac10Tracker : EHIAchievementTracker, EHIProgressTracker
EHIcac10Tracker = class(EHIAchievementTracker)
EHIcac10Tracker._update = false
EHIcac10Tracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIcac10Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac10Tracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
---@param o PanelText
---@param old_color Color
---@param color Color
---@param class EHIcac10Tracker
EHIcac10Tracker._anim_warning = function(o, old_color, color, start_t, class)
    local c = Color(old_color.r, old_color.g, old_color.b)
    local progress = class._progress_text
    local t = 1
    while true do
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            c.r = lerp(old_color.r, color.r, n)
            c.g = lerp(old_color.g, color.g, n)
            c.b = lerp(old_color.b, color.b, n)
            o:set_color(c)
            progress:set_color(c)
        end
        t = 1
    end
end
function EHIcac10Tracker:OverridePanel()
    self._max = 0
    self._progress = 0
    self:SetBGSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        w = self._bg_box:w() / 2,
        left = 0,
        FitTheText = true
    })
    self._text:set_left(self._progress_text:right())
    self:SetIconX()
end

function EHIcac10Tracker:SetProgressMax(max)
    self._max = max
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac10Tracker:SetProgress(progress)
    if self._progress ~= progress then
        self._progress = progress
        self._progress_text:set_text(self:FormatProgress())
        self:FitTheText(self._progress_text)
        self:AnimateBG()
    end
end

function EHIcac10Tracker:SetCompleted(force)
    self._status = "completed"
    self._text:stop()
    self:SetTextColor(Color.green)
    self.update = self.update_fade
    self._achieved_popup_showed = true
end

function EHIcac10Tracker:SetTextColor(color)
    EHIcac10Tracker.super.SetTextColor(self, color)
    self._progress_text:set_color(color)
end

---@class EHIgreen1Tracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIgreen1Tracker = class(EHIProgressTracker)
function EHIgreen1Tracker:SetCompleted(force)
    EHIgreen1Tracker.super.SetCompleted(self, force)
    self._disable_counting = false
end

function EHIgreen1Tracker:SetProgress(progress)
    EHIgreen1Tracker.super.SetProgress(self, progress)
    EHI:Log("green_1 -> Progress: " .. tostring(progress))
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local CF = EHI.ConditionFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [101299] = { time = 300, id = "Thermite", icons = { Icon.Fire }, special_function = SF.CreateAnotherTrackerWithTracker, data = { fake_id = 1012991 }, hint = Hints.Thermite },
    [1012991] = { time = 90, id = "ThermiteShorterTime", icons = { Icon.Fire, Icon.Wait }, class = TT.Warning, hint = Hints.red2_Thermite }, -- Triggered by 101299
    [101325] = { special_function = SF.TriggerIfEnabled, data = { 1013251, 1013252 } },
    [1013251] = { time = 180, id = "Thermite", icons = { Icon.Fire }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Thermite },
    [1013252] = { id = "ThermiteShorterTime", special_function = SF.RemoveTracker },
    [101684] = { time = 5.1, id = "C4", icons = { Icon.C4 }, hint = Hints.Explosion },
    [100211] = { chance = 10, id = "PCChance", icons = { Icon.PCHack }, class = TT.Chance, hint = Hints.man_Code, remove_on_alarm = true },
    [101226] = { id = "PCChance", special_function = SF.IncreaseChanceFromElement }, -- +17%
    [106680] = { id = "PCChance", special_function = SF.RemoveTracker }
}

---@type ParseAchievementTable
local achievements =
{
    green_1 =
    {
        difficulty_pass = false, -- TODO: Finish; remove after that
        elements =
        {
            [103373] = { max = 6, class = "EHIgreen1Tracker", show_finish_after_reaching_target = true },
            [102153] = { special_function = SF.IncreaseProgress },
            [102333] = { special_function = SF.DecreaseProgress },
            [102539] = { special_function = SF.DecreaseProgress }
        }
    },
    green_3 =
    {
        elements =
        {
            [103373] = { time = 817, class = TT.Achievement.Base },
            [102567] = { special_function = SF.SetAchievementFailed },
            [103491] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if self.ConditionFunctions.IsStealth() then
                self._achievements:AddTimedAchievementTracker("green_3", 817)
            end
        end
    },
    cac_10 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101341] = { time = 30, class = "EHIcac10Tracker", condition_function = CF.IsLoud },
            [107072] = { special_function = SF.SetAchievementComplete },
            [101544] = { special_function = SF.CallTrackerManagerFunction, f = "StartTrackerCountdown", arg = { "cac_10" }, trigger_times = 1 },
            [107066] = { special_function = SF.IncreaseProgressMax },
            [107067] = { special_function = SF.IncreaseProgress },
        }
    }
}

local other =
{
    [100850] = EHI:AddAssaultDelay({ control = 20, trigger_times = 1 }),
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:ShowLootCounter({
    max = 14,
    triggers =
    {
        [106684] = { max = 70, special_function = SF.IncreaseProgressMax2 }
    }
})

local min_bags = EHI:GetValueBasedOnDifficulty({
    hard_or_below = 4,
    veryhard = 6,
    overkill = 6,
    mayhem_or_above = 8
})
local loud_objectives =
{
    { amount = 2000, name = "fwb_server_room_open" },
    { amount = 2000, name = "pc_hack" },
    { amount = 4000, name = "fwb_gates_open" },
    { amount = 6000, name = "thermite_done" },
    { amount = 2000, name = "fwb_c4_escape" },
    { escape = 4000 } -- 2000 + 2000 (loud escape)
}
local custom_tactic =
{
    {
        name = "stealth",
        tactic =
        {
            objectives =
            {
                { amount = 2000, name = "fwb_server_room_open" },
                { amount = 1500, name = "fwb_rewired_circuit_box" },
                { amount = 1000, name = "fwb_found_code" },
                { amount = 2000, name = "fwb_gates_open" },
                { amount = 2000, name = "vault_open" },
                { escape = 2000 }
            },
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        objectives =
                        {
                            fwb_rewired_circuit_box = { min_max = 3 }
                        },
                        loot_all = { min = min_bags, max = 14 }
                    }
                }
            }
        }
    },
    {
        name = "loud",
        tactic =
        {
            objectives = loud_objectives,
            loot_all = 1000,
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot_all = { min = min_bags, max = 14 }
                    }
                }
            }
        }
    }
}
if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) then
    custom_tactic[3] = {
        name = "loud",
        additional_name = "fwb_overdrill",
        tactic =
        {
            objectives = loud_objectives,
            loot =
            {
                money = 1000,
                gold = 143
            },
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        loot =
                        {
                            money = { min = min_bags, max = 14 },
                            gold = { min = 0, max = 70 }
                        }
                    }
                }
            }
        },
        objectives_override =
        {
            add_objectives_with_pos =
            {
                { objective = { amount = 40000, name = "fwb_overdrill" }, pos = 5 }
            }
        }
    }
end
EHI:AddXPBreakdown({
    tactic =
    {
        custom = custom_tactic
    }
})