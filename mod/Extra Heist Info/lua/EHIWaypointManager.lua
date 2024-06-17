local EHI = EHI
local icons = tweak_data.ehi.icons
---@class EHIWaypointManager
EHIWaypointManager = {}
EHIWaypointManager._font = tweak_data.menu.pd2_large_font_id -- Large font
EHIWaypointManager._timer_font_size = 32
EHIWaypointManager._distance_font_size = tweak_data.hud.default_font_size
EHIWaypointManager._bitmap_w = 32
EHIWaypointManager._bitmap_h = 32
function EHIWaypointManager:new()
    self._enabled = EHI:GetOption("show_waypoints") --[[@as boolean]]
    self._present_timer = EHI:GetOption("show_waypoints_present_timer") --[[@as number]]
    self._stored_waypoints = {}
    self._waypoints = setmetatable({}, {__mode = "k"}) ---@type table<string, EHIWaypoint?>
    self._waypoints_to_update = setmetatable({}, {__mode = "k"}) ---@type table<string, EHIWaypoint?>
    self._base_waypoint_class = EHI.Waypoints.Base
    return self
end

---@param hud HUDManager
function EHIWaypointManager:SetPlayerHUD(hud)
    self._hud = hud
    for id, params in pairs(self._stored_waypoints) do
        self:AddWaypoint(id, params)
    end
    self._stored_waypoints = {}
end

---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypoint(id, params)
    if not self._enabled then
        return
    end
    if not self._hud then
        self._stored_waypoints[id] = params
        return
    end
    if self._waypoints[id] then
        self:RemoveWaypoint(id)
    end
    params.id = id
    params.timer = 0 ---@diagnostic disable-line
    params.pause_timer = 1 ---@diagnostic disable-line
    params.no_sync = true ---@diagnostic disable-line
    params.present_timer = params.present_timer or self._present_timer
    local waypoint = self._hud:AddEHIWaypoint(id, params)
    if not waypoint then
        return
    end
    if not (waypoint.bitmap and waypoint.timer_gui) then
        self._enabled = false -- Disable waypoints as they don't have correct fields
        self._hud:remove_waypoint(id)
        return
    end
    self:SetWaypointInitialIcon(waypoint, params)
    if waypoint.distance then
        waypoint.distance:set_font(self._font)
        waypoint.distance:set_font_size(self._distance_font_size)
    end
    waypoint.timer_gui:set_font(self._font)
    waypoint.timer_gui:set_font_size(self._timer_font_size)
    local w = _G[params.class or self._base_waypoint_class]:new(waypoint, params, self) --[[@as EHIWaypoint]]
    if w._update then
        self._waypoints_to_update[id] = w
    end
    self._waypoints[id] = w
    if params.remove_vanilla_waypoint then
        self._hud:SoftRemoveWaypoint2(params.remove_vanilla_waypoint)
    end
end

---@param id string
function EHIWaypointManager:RemoveWaypoint(id)
    if not self._waypoints[id] then
        return
    end
    self._waypoints[id]:destroy()
    self._waypoints[id] = nil
    self._waypoints_to_update[id] = nil
    self._hud:remove_waypoint(id)
end

---@param id number
function EHIWaypointManager:RestoreVanillaWaypoint(id)
    if not id then
        return
    end
    self._hud:RestoreWaypoint2(id)
end

---@param id string
---@param new_id string
function EHIWaypointManager:UpdateWaypointID(id, new_id)
    local wp = self._waypoints[id]
    if self._waypoints[new_id] or not wp then
        return
    end
    wp:UpdateID(new_id)
    self._waypoints[id] = nil
    self._waypoints[new_id] = wp
    if self._waypoints_to_update[id] then
        local update = self._waypoints_to_update[id]
        self._waypoints_to_update[id] = nil
        self._waypoints_to_update[new_id] = update
    end
end

---@param wp WaypointDataTable
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:SetWaypointInitialIcon(wp, params)
    local bitmap = wp.bitmap
    local bitmap_world = wp.bitmap_world -- VR
    local icon, texture_rect
    if params.texture then
        icon = params.texture
        texture_rect = params.text_rect
    else
        local _icon = type(params.icon) == "table" and params.icon[1] or params.icon --[[@as string]]
        if icons[_icon] then
            icon = icons[_icon].texture
            texture_rect = icons[_icon].texture_rect
        else
            icon, texture_rect = tweak_data.hud_icons:get_icon_or(_icon, icons.default.texture, icons.default.texture_rect)
        end
    end
    if texture_rect then
        bitmap:set_image(icon, unpack(texture_rect))
    else
        bitmap:set_image(icon)
    end
    bitmap:set_size(self._bitmap_w, self._bitmap_h)
    wp.size = Vector3(self._bitmap_w, self._bitmap_h, 0)
    if bitmap_world then
        if texture_rect then
            bitmap_world:set_image(icon, unpack(texture_rect))
        else
            bitmap_world:set_image(icon)
        end
        bitmap_world:set_size(self._bitmap_w, self._bitmap_h)
    end
end

---@param id string
---@param new_icon string
function EHIWaypointManager:SetWaypointIcon(id, new_icon)
    if id and self._waypoints[id] and self._waypoints[id]._bitmap then
        local wp = self._hud:get_waypoint_data(id)
        if not wp then
            return
        end
        local icon = { icon = new_icon }
        self:SetWaypointInitialIcon(wp, icon)
    end
end

---@param id string
---@param pos Vector3
function EHIWaypointManager:SetWaypointPosition(id, pos)
    if self:WaypointExists(id) then
        local wp = self._hud:get_waypoint_data(id)
        if wp and pos then
            wp.position = pos
            wp.init_data.position = pos
        end
    end
end

---@param id string
function EHIWaypointManager:WaypointExists(id)
    return id and self._waypoints[id] ~= nil or false
end

---@param id string
function EHIWaypointManager:WaypointDoesNotExist(id)
    return not self:WaypointExists(id)
end

---@param id string
---@param time number
function EHIWaypointManager:SetWaypointTime(id, time)
    local wp = self._waypoints[id]
    if wp then
        wp:SetTime(time)
    end
end

---@param id string
---@param jammed boolean
function EHIWaypointManager:SetTimerWaypointJammed(id, jammed)
    local wp = self._waypoints[id] --[[@as EHITimerWaypoint]]
    if wp and wp.SetJammed then
        wp:SetJammed(jammed)
    end
end

---@param id string
---@param powered boolean
function EHIWaypointManager:SetTimerWaypointPowered(id, powered)
    local wp = self._waypoints[id] --[[@as EHITimerWaypoint]]
    if wp and wp.SetPowered then
        wp:SetPowered(powered)
    end
end

---@param id string
function EHIWaypointManager:SetTimerWaypointRunning(id)
    local wp = self._waypoints[id] --[[@as EHITimerWaypoint]]
    if wp and wp.SetRunning then
        wp:SetRunning()
    end
end

---@param id string
---@param pause boolean
function EHIWaypointManager:SetWaypointPause(id, pause)
    local wp = self._waypoints[id] --[[@as EHIPausableWaypoint]]
    if wp and wp.SetPaused then
        wp:SetPaused(pause)
    end
end

---@param id string
---@param t number
function EHIWaypointManager:SetWaypointAccurate(id, t)
    local wp = id and self._waypoints[id] --[[@as EHIInaccurateWaypoint]]
    if wp and wp.SetWaypointAccurate then
        wp:SetWaypointAccurate(t)
    end
end

---@param id string
function EHIWaypointManager:IncreaseWaypointProgress(id)
    local wp = id and self._waypoints[id] --[[@as EHIProgressWaypoint]]
    if wp and wp.IncreaseProgress then
        wp:IncreaseProgress()
    end
end

function EHIWaypointManager:SwitchToLoudMode()
    for _, waypoint in pairs(self._waypoints) do
        waypoint:SwitchToLoudMode()
    end
end

---@param wp EHIWaypoint
function EHIWaypointManager:_add_waypoint_to_update(wp)
    self._waypoints_to_update[wp._id] = wp
end

---@param id string
function EHIWaypointManager:_remove_waypoint_from_update(id)
    self._waypoints_to_update[id] = nil
end

---@param dt number
function EHIWaypointManager:update(dt)
    for _, waypoint in pairs(self._waypoints_to_update) do
        waypoint:update(dt)
    end
end

function EHIWaypointManager:destroy()
    for key, _ in pairs(self._waypoints) do
        self._waypoints[key] = nil
    end
end

---@param id string
---@param f string
---@param ... any
function EHIWaypointManager:CallFunction(id, f, ...)
    local wp = self._waypoints[id]
    if wp and wp[f] then
        wp[f](wp, ...)
    end
end

do
    local path = EHI.LuaPath .. "waypoints/"
    dofile(path .. "EHIWaypoint.lua")
    dofile(path .. "EHIWarningWaypoint.lua")
    dofile(path .. "EHIPausableWaypoint.lua")
    dofile(path .. "EHITimerWaypoint.lua")
    dofile(path .. "EHIProgressWaypoint.lua")
    dofile(path .. "EHIInaccurateWaypoints.lua")
end

if EHI:IsVR() then
    return
end

if VoidUI and VoidUI.options.enable_waypoints then
    dofile(EHI.LuaPath .. "hud/waypoint/void_ui.lua")
elseif restoration and restoration.Options and restoration.Options:GetValue("HUD/Waypoints") then
    dofile(EHI.LuaPath .. "hud/waypoint/restoration_mod.lua")
end