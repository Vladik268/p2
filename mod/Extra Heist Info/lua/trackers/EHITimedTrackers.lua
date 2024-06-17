---@class EHITimedChanceTracker : EHITracker, EHIChanceTracker
---@field super EHITracker
EHITimedChanceTracker = class(EHITracker)
EHITimedChanceTracker.pre_init = EHIChanceTracker.pre_init
EHITimedChanceTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHITimedChanceTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHITimedChanceTracker.SetChance = EHIChanceTracker.SetChance
EHITimedChanceTracker.FormatChance = EHIChanceTracker.FormatChance
EHITimedChanceTracker._anim_chance = EHIChanceTracker._anim_chance
EHITimedChanceTracker.delete = EHIChanceTracker.delete
function EHITimedChanceTracker:OverridePanel()
    self:PrecomputeDoubleSize()
    self._chance_text = self:CreateText({
        text = self:FormatChance()
    })
    self._text:set_left(self._chance_text:right())
    self._refresh_on_delete = true
end

---@param params EHITracker.params
function EHITimedChanceTracker:post_init(params)
    if params.start_opened then
        self:SetBGSize(self._bg_box_double, "set")
        self:SetIconsX()
    elseif params.stop_timer_on_end then
        self._stop_timer_on_end = true
        self._update = false
    end
end

---@param t number?
---@param no_update boolean?
function EHITimedChanceTracker:StartTimer(t, no_update)
    if t then
        self:SetTimeNoAnim(t)
    end
    self:AnimatePanelW(self._panel_double)
    self:ChangeTrackerWidth(self._bg_box_double + (self._icon_gap_size_scaled * self._n_of_icons))
    self:AnimIconsX(self._bg_box_double + self._gap_scaled)
    self._bg_box:set_w(self._bg_box_double)
    if not no_update then
        self:AddTrackerToUpdate()
    end
end

function EHITimedChanceTracker:StopTimer()
    self:AnimatePanelW(self._panel_w)
    self:ChangeTrackerWidth(self._default_bg_size + (self._icon_gap_size_scaled * self._n_of_icons))
    self:AnimIconsX(self._default_bg_size + self._gap_scaled)
    self._bg_box:set_w(self._default_bg_size)
    self:RemoveTrackerFromUpdate()
end

function EHITimedChanceTracker:Refresh()
    if self._stop_timer_on_end then
        self:StopTimer()
    end
end

---@class EHITimedWarningChanceTracker : EHITimedChanceTracker
---@field super EHITimedChanceTracker
EHITimedWarningChanceTracker = class(EHITimedChanceTracker)
EHITimedWarningChanceTracker._warning_color = EHIWarningTracker._warning_color
EHITimedWarningChanceTracker.update = EHIWarningTracker.update
EHITimedWarningChanceTracker.AnimateColor = EHIWarningTracker.AnimateColor
EHITimedWarningChanceTracker.SetTimeNoAnim = EHIWarningTracker.SetTimeNoAnim
EHITimedWarningChanceTracker.delete = EHIWarningTracker.delete
EHITimedWarningChanceTracker._anim_warning = EHIWarningTracker._anim_warning
EHITimedWarningChanceTracker._anim_chance = EHIChanceTracker._anim_chance

---@class EHITimedProgressTracker : EHIProgressTracker, EHITimedChanceTracker
---@field super EHIProgressTracker
EHITimedProgressTracker = class(EHIProgressTracker)
EHITimedProgressTracker.update = EHITracker.update
EHITimedProgressTracker.post_init = EHITracker.post_init
EHITimedProgressTracker.Format = EHITracker.Format
EHITimedProgressTracker.StartTimer = EHITimedChanceTracker.StartTimer
EHITimedProgressTracker.StopTimer = EHITimedChanceTracker.StopTimer
function EHITimedProgressTracker:OverridePanel()
    self:PrecomputeDoubleSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress()
    })
    self._text:set_left(self._progress_text:right())
    self._refresh_on_delete = true
end

function EHITimedProgressTracker:Refresh()
    self:StopTimer()
end

---@param time number
function EHITimedProgressTracker:SetTimeNoAnim(time)
    EHITimedProgressTracker.super.SetTimeNoAnim(self, time)
    self:StartTimer()
end

function EHITimedProgressTracker:DelayForcedDelete()
    self.update = self.update_fade
    EHITimedProgressTracker.super.DelayForcedDelete(self)
end