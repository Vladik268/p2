local EHI = EHI
local Icon = EHI.Icons
---@class EHIdailycakeTracker : EHISideJobTracker, EHIProgressTracker
---@field super EHISideJobTracker
EHIdailycakeTracker = class(EHISideJobTracker)
EHIdailycakeTracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIdailycakeTracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIdailycakeTracker.SetProgress = EHIProgressTracker.SetProgress
function EHIdailycakeTracker:init(...)
    self._max = 4
    self._progress = 0
    EHIdailycakeTracker.super.init(self, ...)
end

function EHIdailycakeTracker:OverridePanel()
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

---@param force boolean?
function EHIdailycakeTracker:SetCompleted(force)
    if not self._status then
        self._status = "completed"
        self._progress_text:set_color(Color.green)
        self:SetStatusText("finish", self._progress_text)
        self._disable_counting = true
    elseif force then
        self._text:set_color(Color.green)
        self:DelayForcedDelete()
    end
end

function EHIdailycakeTracker:DelayForcedDelete()
    self.update = self.update_fade
    EHIdailycakeTracker.super.DelayForcedDelete(self)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local Status = EHI.Const.Trackers.Achievement.Status
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local triggers = {
    [100891] = { additional_time = 320/30 + 5, random_time = 5, id = "EMPBombDrop", icons = { Icon.Goto }, hint = Hints.mad_Bomb }
}

---@type ParseAchievementTable
local achievements =
{
    mad_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100547] = { status = Status.NoDown, class = TT.Achievement.Status },
            [101400] = { special_function = SF.SetAchievementFailed },
            [101823] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    },
    cac_13 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100547] = { status = Status.Defend, class = TT.Achievement.Status },
            [101925] = { special_function = SF.SetAchievementFailed },
            [101924] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    }
}

local sidejob =
{
    daily_cake =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [101906] = { time = 1200, class = "EHIdailycakeTracker" },
            [101898] = { special_function = SF.SetAchievementComplete },
            [EHI:GetInstanceElementID(100038, 3150)] = { special_function = SF.IncreaseProgress }
        },
        cleanup_callback = function()
            EHIdailycakeTracker = nil ---@diagnostic disable-line
        end
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    sidejob = sidejob
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "boiling_point_radar_blown_up" },
        { amount = 5000, name = "pc_hack" },
        { amount = 5000, name = "boiling_point_emp_triggered" },
        { amount = 1000, name = "boiling_point_gas_off_hand_taken" },
        { amount = 5000, name = "boiling_point_scan_finished" },
        { amount = 6000, name = "boiling_point_grabbed_server" },
        { escape = 6000 }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    boiling_point_scan_finished = { max = 4 }
                }
            }
        }
    }
})