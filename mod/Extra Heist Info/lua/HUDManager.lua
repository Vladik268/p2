local EHI = EHI
if EHI:CheckLoadHook("HUDManager") then
    return
end

local original =
{
    set_waypoint_timer_pause = HUDManager.set_waypoint_timer_pause,
    save = HUDManager.save,
    load = HUDManager.load
}

---@class HUDManager
---@field _hud table
---@field _hud_hint table HUDHint class
---@field _hud_mission_briefing HUDMissionBriefing
---@field PLAYER_PANEL number
---@field add_waypoint fun(self: self, id: number|string, params: table)
---@field remove_waypoint fun(self: self, id: number|string)
---@field get_waypoint_data fun(self: self, id: number|string): WaypointDataTable?
---@field add_updator fun(self: self, id: string, cb: function)
---@field remove_updator fun(self: self, id: string)
---@field script fun(self: self, name: string): { panel: Panel }
---@field custom_ingame_popup_text fun(self: self, title: string?, text: string, icon_id: string?)
---@field show_hint fun(self: self, params: table)
---@field make_fine_text fun(self: self, text: PanelText)

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
---@return WaypointDataTable?
function HUDManager:AddEHIWaypoint(id, params)
    self:add_waypoint(id, params)
    return self:get_waypoint_data(id)
end

---@param id string
---@param params table
function HUDManager:AddWaypointFromTrigger(id, params)
    if params.icon_redirect then
        local wp = self:AddEHIWaypoint(id, params)
        if wp and wp.bitmap then
            managers.ehi_waypoint:SetWaypointInitialIcon(wp, params)
        else -- Remove the waypoint as it does not have bitmap
            self:remove_waypoint(id)
        end
    else
        self:add_waypoint(id, params)
    end
end

---@param id number
---@param data WaypointDataTable|VanillaWaypointDataTable
function HUDManager:AddWaypointSoft(id, data)
    self._hud.stored_waypoints[id] = data
    self._hud.ehi_removed_waypoints = self._hud.ehi_removed_waypoints or {}
    self._hud.ehi_removed_waypoints[id] = true
end

---@param id number
function HUDManager:SoftRemoveWaypoint(id)
    local init_data = self._hud.waypoints[id] and self._hud.waypoints[id].init_data
    if init_data then
        self:remove_waypoint(id)
        self:AddWaypointSoft(id, init_data)
    end
end

---@param id number
function HUDManager:SoftRemoveWaypoint2(id)
    self:SoftRemoveWaypoint(id)
    EHI:DisableElementWaypoint(id)
end

---@param id number
function HUDManager:RestoreWaypoint(id)
    local data = self._hud.stored_waypoints[id]
    if data then
        self:add_waypoint(id, data)
        self._hud.stored_waypoints[id] = nil
    end
    if type(self._hud.ehi_removed_waypoints) == "table" then
        self._hud.ehi_removed_waypoints[id] = nil
    end
end

---@param id number
function HUDManager:RestoreWaypoint2(id)
    self:RestoreWaypoint(id)
    EHI:RestoreElementWaypoint(id)
end

---@param id string
function HUDManager:set_waypoint_timer_pause(id, ...)
    if id and managers.ehi_waypoint:WaypointExists(id) then -- Block attempts of pausing waypoints created in EHIWaypointManager
        return
    end
    original.set_waypoint_timer_pause(self, id, ...)
end

function HUDManager:save(data, ...)
    original.save(self, data, ...)
    local state = data.HUDManager
    -- Sync hidden waypoints to ensure that unmodified clients will see them correctly
    for id, _ in pairs(self._hud.ehi_removed_waypoints or {}) do
        if self._hud.stored_waypoints[id] then
            state.waypoints[id] = self._hud.stored_waypoints[id]
        end
    end
end

function HUDManager:load(...)
    original.load(self, ...)
    for id, _ in pairs(self._hud.waypoints or {}) do
        if EHI._cache.IgnoreWaypoints[id] then
            self:SoftRemoveWaypoint(id)
        end
    end
end