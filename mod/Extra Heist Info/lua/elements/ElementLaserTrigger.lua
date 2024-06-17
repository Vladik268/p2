local EHI = EHI
if EHI:CheckLoadHook("ElementLaserTrigger") or not EHI:GetOption("show_laser_tracker") then
    return
end

---@class EHILaserTracker : EHITracker
---@field super EHITracker
EHILaserTracker = class(EHITracker)
EHILaserTracker._forced_icons = { EHI.Icons.Lasers }
EHILaserTracker._forced_hint_text = "laser"
---@param params EHITracker.params
function EHILaserTracker:pre_init(params)
    self._next_cycle_t = params.time
end

function EHILaserTracker:update(dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self._time = self._next_cycle_t
    end
end

function EHILaserTracker:UpdateInterval(t)
    self._time = t
end

local original =
{
    init = ElementLaserTrigger.init,
    add_callback = ElementLaserTrigger.add_callback,
    remove_callback = ElementLaserTrigger.remove_callback,
    load = ElementLaserTrigger.load
}

function ElementLaserTrigger:init(...)
    original.init(self, ...)
    self._ehi_id = "laser_" .. self._id
end

function ElementLaserTrigger:add_callback(...)
    if not self._callback and self._is_cycled then
        managers.ehi_tracker:AddLaserTracker({
            id = self._ehi_id,
            time = self._values.cycle_interval,
            remove_on_alarm = true,
            class = "EHILaserTracker"
        })
    end
    original.add_callback(self, ...)
end

function ElementLaserTrigger:remove_callback(...)
    original.remove_callback(self, ...)
	managers.ehi_tracker:RemoveLaserTracker(self._ehi_id)
end

function ElementLaserTrigger:load(...)
    original.load(self, ...)
    managers.ehi_tracker:CallFunction(self._ehi_id, "UpdateInterval", self._next_cycle_t)
end