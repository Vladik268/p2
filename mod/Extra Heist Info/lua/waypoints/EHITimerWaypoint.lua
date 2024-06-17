---@class EHITimerWaypoint : EHIWarningWaypoint
---@field super EHIWarningWaypoint
EHITimerWaypoint = class(EHIWarningWaypoint)
EHITimerWaypoint._update = false
EHITimerWaypoint._autorepair_color = EHI:GetTWColor("drill_autorepair")
EHITimerWaypoint._completion_color = EHI:GetTWColor("completion")
EHITimerWaypoint._paused_color = EHIPausableWaypoint._paused_color
---@param params table
function EHITimerWaypoint:post_init(params)
    self._warning = params.warning
    self._jammed = false
    self._not_powered = false
    if params.autorepair then
        self:SetAutorepair(true)
    end
    if params.completion then
        self._warning = true
        self._warning_color = self._completion_color
    end
end

---@param t number
function EHITimerWaypoint:SetTime(t)
    if self._time == t then
        return
    end
    EHITimerWaypoint.super.SetTime(self, t)
    if t <= 10 and self._warning and not self._anim_started then
        self:AnimateColor()
        self._anim_started = true
    end
end

---@param t number
---@param time string
function EHITimerWaypoint:SetTimeNoFormat(t, time)
    if self._time == t then
        return
    end
    self._time = t
    self._timer:set_text(time)
    if t <= 10 and self._warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

---@param jammed boolean
function EHITimerWaypoint:SetJammed(jammed)
    if self._anim_started and jammed then
        self._timer:stop()
        self._anim_started = false
    end
    self._jammed = jammed
    self:SetColorBasedOnStatus()
end

---@param powered boolean
function EHITimerWaypoint:SetPowered(powered)
    self._not_powered = not powered
    self:SetColorBasedOnStatus()
end

function EHITimerWaypoint:SetRunning()
    self:SetJammed(false)
    self:SetPowered(true)
end

function EHITimerWaypoint:SetColorBasedOnStatus()
    if self._jammed or self._not_powered then
        self:SetColor(self._paused_color)
    else
        self._timer:stop()
        self:SetColor()
        if self._time <= 10 and self._warning and not self._anim_started then
            self._anim_started = true
            self:AnimateColor()
        end
    end
end

---@param state boolean
function EHITimerWaypoint:SetAutorepair(state)
    if self._jammed or self._not_powered then
        if state then
            self:AnimateColor(nil, self._autorepair_color)
        end
        return
    elseif not self._anim_started then
        self._timer:stop()
        self:SetColor()
    end
end