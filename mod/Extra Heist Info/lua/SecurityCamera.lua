local EHI = EHI
if EHI:CheckLoadHook("SecurityCamera") or not EHI:GetOption("show_camera_loop") then
    return
end

local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_cameras")

local original =
{
    init = SecurityCamera.init,
    _start_tape_loop = SecurityCamera._start_tape_loop,
    _deactivate_tape_loop = SecurityCamera._deactivate_tape_loop,
    destroy = SecurityCamera.destroy
}

function SecurityCamera:init(unit, ...)
    original.init(self, unit, ...)
    self._ehi_key = tostring(unit:key())
end

function SecurityCamera:_start_tape_loop(tape_loop_t, ...)
    original._start_tape_loop(self, tape_loop_t, ...)
    local t = tape_loop_t + 5
    if not show_waypoint_only then
        managers.ehi_tracker:AddTracker({
            id = self._ehi_key,
            time = t,
            icons = { "camera_loop" },
            class = EHI.Trackers.Warning
        })
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key, {
            time = t,
            icon = "camera_loop",
            unit = self._unit,
            class = EHI.Waypoints.Warning
        })
    end
end

function SecurityCamera:_deactivate_tape_loop(...)
    original._deactivate_tape_loop(self, ...)
    managers.ehi_manager:Remove(self._ehi_key)
end

function SecurityCamera:destroy(...)
    managers.ehi_manager:Remove(self._ehi_key)
    original.destroy(self, ...)
end