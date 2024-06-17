---@class EHIPausableWaypoint : EHIWaypoint
---@field super EHIWaypoint
EHIPausableWaypoint = class(EHIWaypoint)
EHIPausableWaypoint._paused_color = EHI:GetTWColor("pause")
---@param params table
function EHIPausableWaypoint:post_init(params)
    self._paused = params.paused
    self:SetColor()
end

---@param dt number
function EHIPausableWaypoint:update(dt)
    if self._paused then
        return
    end
    EHIPausableWaypoint.super.update(self, dt)
end

---@param pause boolean
function EHIPausableWaypoint:SetPaused(pause)
    self._paused = pause
    self:SetColor()
end

function EHIPausableWaypoint:SetColor(color)
    color = self._paused and self._paused_color or (color or self._default_color)
    EHIPausableWaypoint.super.SetColor(self, color)
end