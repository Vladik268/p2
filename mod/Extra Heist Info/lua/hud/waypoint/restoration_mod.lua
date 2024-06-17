local tweak_data = tweak_data
local original =
{
    AddWaypoint = EHIWaypointManager.AddWaypoint
}

EHIWaypointManager._font = Idstring(tweak_data.menu.medium_font)
EHIWaypointManager._timer_font_size = 20
EHIWaypointManager._distance_font_size = 32
---@param id string
---@param params AddWaypointTable|ElementWaypointTrigger
function EHIWaypointManager:AddWaypoint(id, params)
    params.distance = true ---@diagnostic disable-line
    original.AddWaypoint(self, id, params)
end

EHIWaypoint._default_color = tweak_data.hud.prime_color