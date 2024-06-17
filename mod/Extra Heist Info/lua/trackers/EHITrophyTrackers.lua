local EHI = EHI
---@class EHITrophyTracker : EHIAchievementTracker
---@field super EHIAchievementTracker
EHITrophyTracker = class(EHIAchievementTracker)
EHITrophyTracker._popup_type = "trophy"
EHITrophyTracker._forced_icon_color = { EHI:GetColorFromOption("unlockables", "trophy") }
EHITrophyTracker._show_started = EHI:GetUnlockableOption("show_trophy_started_popup")
EHITrophyTracker._show_failed = EHI:GetUnlockableOption("show_trophy_failed_popup")
EHITrophyTracker._show_desc = EHI:GetUnlockableOption("show_trophy_description")
---@param params EHITracker.params
function EHITrophyTracker:PrepareHint(params)
    params.hint = self._id or params.id
    self._hint_vanilla_localization = true
end