---@class EHICivilianCountTracker : EHICountTracker
---@field super EHICountTracker
EHICivilianCountTracker = class(EHICountTracker)
EHICivilianCountTracker._forced_hint_text = "civilians"
EHICivilianCountTracker._forced_icons = { "civilians" }
if EHI:GetOption("civilian_count_tracker_format") >= 2 then
    if EHI:GetOption("civilian_count_tracker_format") == 2 then
        if not EHICivilianCountTracker._ONE_ICON then
            EHICivilianCountTracker._forced_icons = { "hostage", "civilians" }
        end
        function EHICivilianCountTracker:Format()
            return self._tied_count .. "|" .. self._count
        end
        EHICivilianCountTracker.FormatCount = EHICivilianCountTracker.Format
    else
        if not EHICivilianCountTracker._ONE_ICON then
            EHICivilianCountTracker._forced_icons[2] = "hostage"
        end
        function EHICivilianCountTracker:Format()
            return self._count .. "|" .. self._tied_count
        end
        EHICivilianCountTracker.FormatCount = EHICivilianCountTracker.Format
    end
end
function EHICivilianCountTracker:init(...)
    self._tied_count = 0
    self._tied_units = {}
    EHICivilianCountTracker.super.init(self, ...)
    self._flash_times = 1
end

---@param count number
function EHICivilianCountTracker:SetCount(count)
    if count <= 0 and self._tied_count <= 0 then
        self:delete()
        return
    end
    EHICivilianCountTracker.super.SetCount(self, count)
end

---@param count number
function EHICivilianCountTracker:SetCount2(count)
    self:SetCount(count - self._tied_count)
end

---@param civilian_key string
function EHICivilianCountTracker:DecreaseCount(civilian_key)
    if self._tied_units[civilian_key] then
        self._tied_units[civilian_key] = nil
        self._tied_count = self._tied_count - 1
        self._count = self._count + 1
    end
    EHICivilianCountTracker.super.DecreaseCount(self)
end

---@param unit_key string
function EHICivilianCountTracker:CivilianTied(unit_key)
    if self._tied_units[unit_key] then
        return
    end
    self._tied_units[unit_key] = true
    self._tied_count = self._tied_count + 1
    EHICivilianCountTracker.super.DecreaseCount(self)
end

---@param unit_key string
function EHICivilianCountTracker:CivilianUntied(unit_key)
    if self._tied_units[unit_key] then
        self._tied_units[unit_key] = nil
        self._tied_count = self._tied_count - 1
        self:IncreaseCount()
    end
end

function EHICivilianCountTracker:ResetCounter()
    self._count = 0
end