local EHI = EHI

---@generic T: table
---@param super T? A base achievement class
---@return T
function ehi_sidejob_class(super)
    local klass = class(super)
    klass._popup_type = "sidejob"
    klass._forced_icon_color = EHISideJobTracker._forced_icon_color
    klass._show_started = EHISideJobTracker._show_started
    klass._show_failed = EHISideJobTracker._show_failed
    klass._show_desc = EHISideJobTracker._show_desc
    klass.PrepareHint = EHISideJobTracker.PrepareHint
    return klass
end

---@class EHISideJobTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHISideJobTracker = class(EHIAchievementTracker)
EHISideJobTracker._popup_type = "sidejob"
EHISideJobTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "sidejob") }
EHISideJobTracker._show_started = EHI:GetUnlockableOption("show_daily_started_popup")
EHISideJobTracker._show_failed = EHI:GetUnlockableOption("show_daily_failed_popup")
EHISideJobTracker._show_desc = EHI:GetUnlockableOption("show_daily_description")
---@param params EHITracker.params
function EHISideJobTracker:post_init(params)
    self._daily_job = params.daily_job
    EHISideJobTracker.super.post_init(self, params)
end

---@param params EHITracker.params
function EHISideJobTracker:PrepareHint(params)
    local id = self._id or params.id
    params.hint = params.daily_job and ("menu_challenge_" .. id) or id
    self._hint_vanilla_localization = true
end

---@class EHISideJobProgressTracker : EHIAchievementProgressTracker
---@field super EHIAchievementProgressTracker
EHISideJobProgressTracker = ehi_sidejob_class(EHIAchievementProgressTracker)
---@param panel Panel
---@param params EHITracker.params
function EHISideJobProgressTracker:init(panel, params, ...)
    self._daily_job = params.daily_job
    EHISideJobProgressTracker.super.init(self, panel, params, ...)
end