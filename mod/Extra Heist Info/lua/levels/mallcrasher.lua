local EHI = EHI
local lerp = math.lerp
local sin = math.sin
local Color = Color
---@class EHIameno3Tracker : EHIAchievementTracker, EHINeededValueTracker
---@field super EHIAchievementTracker
EHIameno3Tracker = class(EHIAchievementTracker)
EHIameno3Tracker.FormatNumber = EHINeededValueTracker.Format
EHIameno3Tracker.FormatNumber2 = EHINeededValueTracker.FormatNumberShort
EHIameno3Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
---@param o PanelText
---@param old_color Color
---@param color Color
---@param class EHIameno3Tracker
EHIameno3Tracker._anim_warning = function(o, old_color, color, start_t, class)
    local c = Color(old_color.r, old_color.g, old_color.b)
    local money = class._money_text
    while true do
        local t = 1
        while t > 0 do
            t = t - coroutine.yield()
            local n = sin(t * 180)
            c.r = lerp(old_color.r, color.r, n)
            c.g = lerp(old_color.g, color.g, n)
            c.b = lerp(old_color.b, color.b, n)
            o:set_color(c)
            money:set_color(c)
        end
        t = 1
    end
end
function EHIameno3Tracker:pre_init(params)
    self._cash_sign = managers.localization:text("cash_sign")
    self._max = params.max or 0
    self._progress = params.progress or 0
    self._progress_formatted = self:FormatNumber2(0)
    self._max_formatted = self:FormatNumber2(self._max)
end

function EHIameno3Tracker:post_init(params)
    EHI:AddAchievementToCounter({
        achievement = "ameno_3",
        counter =
        {
            check_type = EHI.LootCounter.CheckType.ValueOfSmallLoot
        }
    })
end

function EHIameno3Tracker:OverridePanel()
    self:SetBGSize()
    self._money_text = self:CreateText({
        text = self:FormatNumber(),
        w = self._bg_box:w() / 2,
        left = 0,
        FitTheText = true
    })
    self._text:set_left(self._money_text:right())
    self:SetIconX()
end

function EHIameno3Tracker:SetProgress(progress)
    if self._progress ~= progress and not self._disable_counting then
        self._progress = progress
        self._progress_formatted = self:FormatNumber2(progress)
        self._money_text:set_text(self:FormatNumber())
        self:FitTheText(self._money_text)
        self:AnimateBG()
        self:SetCompleted()
    end
end

function EHIameno3Tracker:SetCompleted()
    if self._progress >= self._max and not self._status then
        self._status = "completed"
        self._text:stop()
        self:SetTextColor(Color.green)
        self.update = self.update_fade
        self._disable_counting = true
        self._achieved_popup_showed = true
    end
end

function EHIameno3Tracker:SetTextColor(color)
    EHINeededValueTracker.super.SetTextColor(self, color)
    self._money_text:set_color(color)
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local MoneyTrigger = { id = "MallDestruction", special_function = EHI:RegisterCustomSF(function(self, trigger, element, ...)
    self._trackers:IncreaseTrackerProgress(trigger.id, element._values.amount)
end) }
local OverkillOrBelow = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL)
local triggers =
{
    -- Time before escape vehicle arrives
    [300248] = { time = (OverkillOrBelow and 120 or 300) + 25, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, waypoint = { icon = Icon.Escape, position_by_element = 300322 }, hint = Hints.Escape },
    -- 120: Base Delay on OVK or below
    -- 300: Base Delay on Mayhem or above
    -- 25: Escape zone activation delay

    [300043] = { max = 50000, id = "MallDestruction", class = TT.NeededValue, icons = { Icon.Destruction }, flash_times = 1, hint = Hints.mallcrasher_Destruction },
    [300843] = MoneyTrigger, -- +40
    [300844] = MoneyTrigger, -- +80
    [300845] = MoneyTrigger, -- +250
    [300846] = MoneyTrigger, -- +500
    [300847] = MoneyTrigger, -- +800
    [300848] = MoneyTrigger, -- +2000
    [300850] = MoneyTrigger, -- +2800
    [300849] = MoneyTrigger, -- +4000
    [300872] = MoneyTrigger, -- +5600
    [300851] = MoneyTrigger -- +8000, appears to be unused
}

if EHI:IsClient() then
    triggers[302287] = EHI:ClientCopyTrigger(triggers[300248], { time = (OverkillOrBelow and 115 or 120) + 25 })
    triggers[300223] = EHI:ClientCopyTrigger(triggers[300248], { time = 60 + 25 })
    triggers[302289] = EHI:ClientCopyTrigger(triggers[300248], { time = 30 + 25 })
    triggers[300246] = EHI:ClientCopyTrigger(triggers[300248], { time = 25 })
end

---@type ParseAchievementTable
local achievements =
{
    window_cleaner =
    {
        elements =
        {
            [301056] = { max = 171, flash_times = 1, class = TT.Achievement.Progress },
            [300791] = { special_function = SF.IncreaseProgress }
        }
    },
    ameno_3 =
    {
        difficulty_pass = EHI:IsDifficulty(EHI.Difficulties.OVERKILL),
        elements =
        {
            [301148] = { time = 50, max = 1800000, class = "EHIameno3Tracker" },
        },
        load_sync = function(self)
            local t = 50 - math.max(self._trackers._t, self._t)
            if t > 0 then
                self._trackers:AddTracker({
                    time = t,
                    id = "ameno_3",
                    progress = managers.loot:get_real_total_small_loot_value(),
                    max = 1800000,
                    icons = EHI:GetAchievementIcon("ameno_3"),
                    class = "EHIameno3Tracker"
                })
            end
        end,
        cleanup_callback = function()
            EHIameno3Tracker = nil ---@diagnostic disable-line
        end
    },
    uno_3 =
    {
        difficulty_pass = OverkillOrBelow, -- Can be achieved on any difficulty but the heli takes 5:25 to arrive on Mayhem or above
        elements =
        {
            [301148] = { time = 180, class = TT.Achievement.Base },
            [300241] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    }
}

local FirstAssaultDelay = 10
local other = {}
if EHI:IsMayhemOrAbove() then
    other[301049] = EHI:AddAssaultDelay({ control = FirstAssaultDelay })
else
    other[301138] = EHI:AddAssaultDelay({ control = 50 + FirstAssaultDelay })
    other[301766] = EHI:AddAssaultDelay({ control = 40 + FirstAssaultDelay })
    other[301771] = EHI:AddAssaultDelay({ control = 30 + FirstAssaultDelay })
    other[301772] = EHI:AddAssaultDelay({ control = 20 + FirstAssaultDelay })
    other[301773] = EHI:AddAssaultDelay({ control = 10 + FirstAssaultDelay })
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        mallcrasher = { amount = 1000, times = 6 }
    }
})