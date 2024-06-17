local EHI = EHI
local Color = Color

---@generic T: table
---@param super T? A base class which `class` will derive from
---@return T
function ehi_achievement_class(super)
    local klass = class(super)
    klass._popup_type = "achievement"
    klass._forced_icon_color = EHIAchievementTracker._forced_icon_color
    klass._show_started = EHIAchievementTracker._show_started
    klass._show_failed = EHIAchievementTracker._show_failed
    klass._show_desc = EHIAchievementTracker._show_desc
    klass.ShowStartedPopup = EHIAchievementTracker.ShowStartedPopup
    klass.ShowFailedPopup = EHIAchievementTracker.ShowFailedPopup
    klass.ShowAchievementDescription = EHIAchievementTracker.ShowAchievementDescription
    klass.PrepareHint = EHIAchievementTracker.PrepareHint
    klass.PlayerSpawned = EHIAchievementTracker.PlayerSpawned
    return klass
end

---@class EHIAchievementTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIAchievementTracker = class(EHIWarningTracker)
EHIAchievementTracker._popup_type = "achievement"
EHIAchievementTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "achievement") }
EHIAchievementTracker._show_started = EHI:GetUnlockableOption("show_achievement_started_popup")
EHIAchievementTracker._show_failed = EHI:GetUnlockableOption("show_achievement_failed_popup")
EHIAchievementTracker._show_desc = EHI:GetUnlockableOption("show_achievement_description")
---@param params EHITracker.params
function EHIAchievementTracker:post_init(params)
    self._beardlib = params.beardlib
    self:ShowStartedPopup()
    self:ShowAchievementDescription()
    self:PrepareHint(params)
end

---@param params EHITracker.params
function EHIAchievementTracker:PrepareHint(params)
    local id = self._id or params.id
    if self._beardlib then
        params.hint = EHI._cache.Beardlib[id].name
        self._hint_no_localization = true
    else
        params.hint = "achievement_" .. id
        self._hint_vanilla_localization = true
    end
end

function EHIAchievementTracker:SetCompleted()
    self._text:stop()
    self.update = self.update_fade
    self._achieved_popup_showed = true
    self:SetTextColor(Color.green)
    self:AnimateBG()
end

function EHIAchievementTracker:SetFailed()
    self._text:stop()
    self.update = self.update_fade
    self:SetTextColor(Color.red)
    self:AnimateBG()
    self:ShowFailedPopup()
end

function EHIAchievementTracker:delete()
    self:ShowFailedPopup()
    EHIAchievementTracker.super.delete(self)
end

---@param delay_popup boolean?
function EHIAchievementTracker:ShowStartedPopup(delay_popup)
    if delay_popup or self._started_popup_showed or self._failed_on_sync or not self._show_started then ---@diagnostic disable-line
        return
    end
    if self._popup_type == "sidejob" then
        managers.hud:ShowSideJobStartedPopup(self._id, self._daily_job) ---@diagnostic disable-line
    elseif self._popup_type == "trophy" then
        managers.hud:ShowTrophyStartedPopup(self._id)
    else
        managers.hud:ShowAchievementStartedPopup(self._id, self._beardlib)
    end
    self._started_popup_showed = true
end

function EHIAchievementTracker:ShowFailedPopup()
    if self._failed_popup_showed or self._achieved_popup_showed or self._no_failure or not self._show_failed then ---@diagnostic disable-line
        return
    end
    self._failed_popup_showed = true
    if self._popup_type == "sidejob" then
        managers.hud:ShowSideJobFailedPopup(self._id, self._daily_job) ---@diagnostic disable-line
    elseif self._popup_type == "trophy" then
        managers.hud:ShowTrophyFailedPopup(self._id)
    else
        managers.hud:ShowAchievementFailedPopup(self._id, self._beardlib)
    end
end

---@param delay_popup boolean?
function EHIAchievementTracker:ShowAchievementDescription(delay_popup)
    if delay_popup or self._desc_showed or self._failed_on_sync or not self._show_desc then ---@diagnostic disable-line
        return
    end
    if self._popup_type == "achievement" then
        managers.hud:ShowAchievementDescription(self._id, self._beardlib)
    elseif self._popup_type == "sidejob" then
        managers.hud:ShowSideJobDescription(self._id, self._daily_job) ---@diagnostic disable-line
    else
        managers.hud:ShowTrophyDescription(self._id)
    end
    self._desc_showed = true
end

function EHIAchievementTracker:PlayerSpawned()
    EHIAchievementTracker.super.PlayerSpawned(self)
    self:ShowStartedPopup()
    self:ShowAchievementDescription()
end

function EHIAchievementTracker:save(data)
    data.time = self._time
end

function EHIAchievementTracker:load(data)
    self:SetTimeNoAnim(data.time)
end

---@class EHIAchievementUnlockTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIAchievementUnlockTracker = class(EHIAchievementTracker)
EHIAchievementUnlockTracker._show_completion_color = true
EHIAchievementUnlockTracker.delete = EHIAchievementUnlockTracker.super.super.delete
EHIAchievementUnlockTracker.SetCompleted = function(...) end

---@class EHIAchievementProgressTracker : EHIProgressTracker, EHIAchievementTracker
---@field super EHIProgressTracker
EHIAchievementProgressTracker = ehi_achievement_class(EHIProgressTracker)
---@param panel Panel
---@param params EHITracker.params
function EHIAchievementProgressTracker:init(panel, params, ...)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    self:PrepareHint(params)
    EHIAchievementProgressTracker.super.init(self, panel, params, ...)
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
end

---@param force boolean?
function EHIAchievementProgressTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIAchievementProgressTracker.super.SetCompleted(self, force)
end

function EHIAchievementProgressTracker:SetFailed()
    EHIAchievementProgressTracker.super.SetFailed(self)
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    self:ShowFailedPopup()
end

function EHIAchievementProgressTracker:save(data)
    data.progress = self._progress
end

function EHIAchievementProgressTracker:load(data)
    self:SetProgress(data.progress or 0)
end

---@class EHIAchievementProgressGroupTracker : EHIProgressGroupTracker, EHIAchievementTracker
EHIAchievementProgressGroupTracker = ehi_achievement_class(EHIProgressGroupTracker)
---@param panel Panel
---@param params EHITracker.params
function EHIAchievementProgressGroupTracker:init(panel, params, ...)
    self._beardlib = params.beardlib
    self:PrepareHint(params)
    EHIAchievementProgressGroupTracker.super.init(self, panel, params, ...)
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
end

function EHIAchievementProgressGroupTracker:save(data)
    local counters = {}
    for key, tbl in pairs(self._counters_table) do
        local counter = {}
        counter.progress = tbl.progress
        counters[key] = counter
    end
    data.counters = counters
end

function EHIAchievementProgressGroupTracker:load(data)
    local counters = data.counters or {}
    for key, counter in pairs(counters) do
        self:SetProgress(counter.progress or 0, key)
    end
end

---@class EHIAchievementBagValueTracker : EHINeededValueTracker, EHIAchievementTracker
---@field super EHINeededValueTracker
EHIAchievementBagValueTracker = ehi_achievement_class(EHINeededValueTracker)
---@param params EHITracker.params
function EHIAchievementBagValueTracker:post_init(params)
    self._beardlib = params.beardlib
    self:ShowStartedPopup(params.delay_popup)
    self:ShowAchievementDescription(params.delay_popup)
    self:PrepareHint(params)
end

function EHIAchievementBagValueTracker:SetCompleted(force)
    EHIAchievementBagValueTracker.super.SetCompleted(self, force)
    self._achieved_popup_showed = true
end

function EHIAchievementBagValueTracker:SetFailed()
    EHIAchievementBagValueTracker.super.SetFailed(self)
    if self._show_failed then
        self:ShowFailedPopup()
    end
end

---@class EHIAchievementStatusTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHIAchievementStatusTracker = class(EHIAchievementTracker)
EHIAchievementStatusTracker.update = EHIAchievementStatusTracker.update_fade
EHIAchievementStatusTracker._update = false
---@param panel Panel
---@param params EHITracker.params
function EHIAchievementStatusTracker:init(panel, params, ...)
    self._status = params.status or "ok"
    EHIAchievementStatusTracker.super.init(self, panel, params, ...)
    self:SetTextColor()
end

function EHIAchievementStatusTracker:Format()
    local status = "ehi_status_" .. self._status
    if LocalizationManager._custom_localizations[status] then
        return managers.localization:text(status)
    else
        return string.upper(self._status)
    end
end

---@param status string
function EHIAchievementStatusTracker:SetStatus(status)
    if self._dont_override_status or self._status == status then
        return
    end
    self._status = status
    self:SetStatusText(status)
    self:SetTextColor()
    self:AnimateBG()
end

function EHIAchievementStatusTracker:SetCompleted()
    self:SetStatus("done")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    self._achieved_popup_showed = true
end

function EHIAchievementStatusTracker:SetFailed()
    self:SetStatus("fail")
    self:AddTrackerToUpdate()
    self._dont_override_status = true
    self:ShowFailedPopup()
end

local green_status =
{
    ok = true,
    done = true,
    pass = true,
    finish = true,
    destroy = true,
    defend = true,
    no_down = true,
    secure = true
}
local yellow_status =
{
    alarm = true,
    ready = true,
    loud = true,
    push = true,
    hack = true,
    land = true,
    find = true,
    bring = true,
    mark = true,
    objective = true
}
---@param color Color?
function EHIAchievementStatusTracker:SetTextColor(color)
    local c
    if color then
        c = color
    elseif green_status[self._status] then
        c = Color.green
    elseif yellow_status[self._status] then
        c = Color.yellow
    else
        c = Color.red
    end
    EHIAchievementStatusTracker.super.SetTextColor(self, c)
end

function EHIAchievementStatusTracker:save(data)
    data.status = self._status
end

function EHIAchievementStatusTracker:load(data)
    self:SetStatus(data.status or "ok")
end