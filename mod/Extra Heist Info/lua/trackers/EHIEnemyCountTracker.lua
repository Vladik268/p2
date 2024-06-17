---@class EHIEnemyCountTracker : EHICountTracker
---@field _icon2 PanelBitmap?
---@field super EHICountTracker
EHIEnemyCountTracker = class(EHICountTracker)
if EHI:GetOption("show_enemy_count_show_pagers") then
    EHIEnemyCountTracker._forced_icons = { "pager_icon", "enemy" }
    function EHIEnemyCountTracker:Format()
        return (self._alarm_count - self._alarm_count_answered) .. "|" .. self._count
    end
    EHIEnemyCountTracker.FormatCount = EHIEnemyCountTracker.Format
else
    EHIEnemyCountTracker._forced_icons = { "enemy" }
end
function EHIEnemyCountTracker:init(...)
    self._alarm_count = 0
    self._alarm_count_answered = 0
    EHIEnemyCountTracker.super.init(self, ...)
    self._update_on_alarm = true
end

---@param params EHITracker.params
function EHIEnemyCountTracker:post_init(params)
    EHIEnemyCountTracker.super.post_init(self, params)
    if params.alarm_sounded then
        self:OnAlarm()
    end
end

function EHIEnemyCountTracker:Update()
    self._text:set_text(self:FormatCount())
    self:AnimateBG()
end

function EHIEnemyCountTracker:OnAlarm()
    self._alarm_sounded = true
    self._count = self._count + self._alarm_count
    if self._icon2 then
        self._icon2:set_x(self._icon1:x())
        self._icon2:set_visible(true)
        self._icon1:set_visible(false)
        self:AnimateRepositionHintX(1)
        self:ChangeTrackerWidth(self._bg_box:w() + self._icon_gap_size_scaled, true)
        self.FormatCount = EHIEnemyCountTracker.super.FormatCount
    elseif self._forced_icons[1] ~= "enemy" then
        self:SetIcon("enemy")
    end
    self:Update()
    self:FitTheText()
    self:AnimateBG()
end

function EHIEnemyCountTracker:NormalEnemyRegistered()
    self._count = self._count + 1
    self:Update()
end

function EHIEnemyCountTracker:NormalEnemyUnregistered()
    self._count = self._count - 1
    self:Update()
end

function EHIEnemyCountTracker:AlarmEnemyRegistered()
    if self._alarm_sounded then
        self:NormalEnemyRegistered()
        return
    end
    self._alarm_count = self._alarm_count + 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyUnregistered()
    if self._alarm_sounded then
        self:NormalEnemyUnregistered()
        return
    end
    self._alarm_count = self._alarm_count - 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyPagerAnswered()
    self._alarm_count_answered = self._alarm_count_answered + 1
    self:Update()
    self:FitTheText()
end

function EHIEnemyCountTracker:AlarmEnemyPagerKilled()
    self._alarm_count_answered = self._alarm_count_answered - 1
    self:Update()
    self:FitTheText()
end