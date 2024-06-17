---@class EHIHostageCountTracker : EHICountTracker
---@field super EHICountTracker
EHIHostageCountTracker = class(EHICountTracker)
EHIHostageCountTracker._forced_hint_text = "hostage"
EHIHostageCountTracker._forced_icons = { "hostage" }
if EHI:GetOption("hostage_count_tracker_format") == 1 then -- Total only
    function EHIHostageCountTracker:Format()
        return tostring(self._total_hostages)
    end
elseif EHI:GetOption("hostage_count_tracker_format") == 2 then -- Total | Police
    EHIHostageCountTracker._forced_icons[2] = { icon = "hostage", color = Color(0, 1, 1) }
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._total_hostages, self._police_hostages)
    end
elseif EHI:GetOption("hostage_count_tracker_format") == 3 then -- Police | Total
    EHIHostageCountTracker._forced_icons[1] = { icon = "hostage", color = Color(0, 1, 1) }
    EHIHostageCountTracker._forced_icons[2] = "hostage"
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._police_hostages, self._total_hostages)
    end
elseif EHI:GetOption("hostage_count_tracker_format") == 4 then -- Civilians | Police
    EHIHostageCountTracker._forced_icons[2] = { icon = "hostage", color = Color(0, 1, 1) }
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._civilian_hostages, self._police_hostages)
    end
else -- Police | Civilians
    EHIHostageCountTracker._forced_icons[1] = { icon = "hostage", color = Color(0, 1, 1) }
    EHIHostageCountTracker._forced_icons[2] = "hostage"
    function EHIHostageCountTracker:Format()
        return string.format("%d|%d", self._police_hostages, self._civilian_hostages)
    end
end
EHIHostageCountTracker.FormatCount = EHIHostageCountTracker.Format

---@param params EHITracker.params
function EHIHostageCountTracker:pre_init(params)
    self._total_hostages = 0
    self._civilian_hostages = 0
    self._police_hostages = 0
end

---@param total_hostages number
---@param police_hostages number?
function EHIHostageCountTracker:SetHostageCount(total_hostages, police_hostages)
    police_hostages = police_hostages or self:GetPoliceHostageCount(total_hostages)
    self._total_hostages = total_hostages
    self._civilian_hostages = total_hostages - police_hostages
    self._police_hostages = police_hostages
    self._count_text:set_text(self:Format())
    self:AnimateBG(1)
end

---@param total_hostages number
function EHIHostageCountTracker:GetPoliceHostageCount(total_hostages)
    if total_hostages == 0 then
        return 0
    end
    local civilian_hostages = 0
    for _, civ in pairs(managers.enemy:all_civilians()) do
        if alive(civ.unit) and civ.unit:brain():is_hostage() then
            civilian_hostages = civilian_hostages + 1
        end
    end
    return total_hostages - civilian_hostages
end