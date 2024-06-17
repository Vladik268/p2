---@class EHIPausableTracker : EHITracker
---@field super EHITracker
EHIPausableTracker = class(EHITracker)
EHIPausableTracker._paused_color = EHI:GetTWColor("pause")
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIPausableTracker:init(panel, params, parent_class)
    EHIPausableTracker.super.init(self, panel, params, parent_class)
    self._update = not params.paused
    self:_SetPause(not self._update)
end

---@param pause boolean
function EHIPausableTracker:SetPause(pause)
    self:_SetPause(pause)
    if pause then
        self:RemoveTrackerFromUpdate()
    else
        self:AddTrackerToUpdate()
    end
end

function EHIPausableTracker:_SetPause(pause)
    self._paused = pause
    self:SetTextColor()
end

function EHIPausableTracker:SetTextColor(color)
    self._text:set_color(self._paused and self._paused_color or (color or self._text_color))
end