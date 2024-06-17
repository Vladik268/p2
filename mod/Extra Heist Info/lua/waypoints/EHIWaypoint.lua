---@class EHIWaypoint
---@field new fun(self: self, waypoint: WaypointDataTable, params: table, parent_class: EHIWaypointManager): self
EHIWaypoint = class()
EHIWaypoint._update = true
EHIWaypoint._fade_time = 5
EHIWaypoint._default_color = Color.white
---@param waypoint WaypointDataTable
---@param params table
---@param parent_class EHIWaypointManager
function EHIWaypoint:init(waypoint, params, parent_class)
    self:pre_init(params)
    self._id = params.id
    self._time = params.time or 0
    self._timer = waypoint.timer_gui
    self._bitmap = waypoint.bitmap
    self._arrow = waypoint.arrow
    self._bitmap_world = waypoint.bitmap_world -- VR
    self._parent_class = parent_class
    self._remove_on_alarm = params.remove_on_alarm --Removes waypoint when alarm sounds
    if params.force_format then
        self._timer:set_text(self:Format())
    end
    if params.remove_vanilla_waypoint and params.restore_on_done then
        self._vanilla_waypoint = params.remove_vanilla_waypoint
    end
    self:post_init(params)
end

function EHIWaypoint:pre_init(params)
end

function EHIWaypoint:post_init(params)
end

---@param new_id string
function EHIWaypoint:UpdateID(new_id)
    self._id = new_id
end

if EHI:GetOption("time_format") == 1 then
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatSecondsOnly
else
    EHIWaypoint.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
end

---@param dt number
function EHIWaypoint:update(dt)
    self._time = self._time - dt
    self._timer:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

---@param dt number
function EHIWaypoint:update_fade(dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

---@param t number
function EHIWaypoint:SetTime(t)
    self._time = t
    self._timer:set_text(self:Format())
end

---@param delay number
function EHIWaypoint:AddDelay(delay)
    self:SetTime(self._time + delay)
end

---@param color Color?
function EHIWaypoint:SetColor(color)
    local c = color or self._default_color
    self._timer:set_color(c)
    self._bitmap:set_color(c)
    self._arrow:set_color(c)
end

function EHIWaypoint:AddWaypointToUpdate()
    self._parent_class:_add_waypoint_to_update(self)
end

function EHIWaypoint:RemoveWaypointFromUpdate()
    self._parent_class:_remove_waypoint_from_update(self._id)
end

function EHIWaypoint:SwitchToLoudMode()
    if self._remove_on_alarm then
        self:delete()
    end
end

function EHIWaypoint:delete()
    self._parent_class:RemoveWaypoint(self._id)
end

function EHIWaypoint:destroy()
    if self._vanilla_waypoint then
        self._parent_class:RestoreVanillaWaypoint(self._vanilla_waypoint)
    end
end

if EHI:IsVR() then
    EHIWaypointVR = EHIWaypoint
    EHIWaypointVR.old_SetColor = EHIWaypoint.SetColor
    ---@param color Color?
    function EHIWaypointVR:SetColor(color)
        self:old_SetColor(color)
        self._bitmap_world:set_color(color or self._default_color)
    end
end