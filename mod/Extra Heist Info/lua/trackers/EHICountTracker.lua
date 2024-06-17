---@class EHICountTracker : EHITracker
---@field super EHITracker
---@field _anim_flash_set_count number?
EHICountTracker = class(EHITracker)
EHICountTracker._update = false
---@param params EHITracker.params
function EHICountTracker:pre_init(params)
    self._count = params.count or 0
end

---@param params EHITracker.params
function EHICountTracker:post_init(params)
    self._count_text = self._text
end

function EHICountTracker:Format()
    return tostring(self._count)
end

---@param count number?
function EHICountTracker:IncreaseCount(count)
    self:SetCount(self._count + (count or 1))
end

---@param count number?
function EHICountTracker:DecreaseCount(count)
    self:SetCount(self._count - (count or 1))
end

---@param count number
function EHICountTracker:SetCount(count)
    self._count = count
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(self._anim_flash_set_count)
end

---@param count number
function EHICountTracker:SetCountNoNegative(count)
    self._count = math.max(0, count)
    self._count_text:set_text(self:FormatCount())
    self:AnimateBG(self._anim_flash_set_count)
end

function EHICountTracker:ResetCount()
    self:SetCount(0)
end
EHICountTracker.FormatCount = EHICountTracker.Format