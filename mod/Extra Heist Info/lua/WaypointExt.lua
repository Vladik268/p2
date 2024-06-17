local EHI = EHI
if EHI:CheckLoadHook("WaypointExt") then
    return
end

function WaypointExt:add_waypoint_no_hud(icon_name, pos_z_offset, pos_locator, map_icon, show_on_hud)
    if self._is_active then
        self:remove_waypoint()
    end
    self._icon_name = icon_name or "pd2_goto"
    self._pos_z_offset = pos_z_offset and Vector3(0, 0, pos_z_offset) or Vector3(0, 0, 0)
    self._pos_locator = pos_locator
    self._map_icon = map_icon
    self._show_on_hud = show_on_hud
    self._is_active = true
end

function WaypointExt:ReplaceWaypointFunction()
    self.add_waypoint = self.add_waypoint_no_hud
    if self._is_active then
        self._icon_id = tostring(self._unit:key())
        self:remove_waypoint()
        self._icon_id = nil
        if EHI:IsHost() then
            self._is_active = true
        end
    end
end