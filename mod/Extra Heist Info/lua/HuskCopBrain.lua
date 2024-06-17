local EHI = EHI
if EHI:CheckLoadHook("HuskCopBrain") or EHI:IsHost() or not EHI:CanShowCivilianCountTracker() or EHI:GetOption("civilian_count_tracker_format") == 1 then
    return
end

local original = HuskCopBrain.sync_net_event
---@param event_id number
function HuskCopBrain:sync_net_event(event_id, ...)
    original(self, event_id, ...)
    if self._dead then
        return
    end
    if event_id == self._NET_EVENTS.surrender_civilian_tied then
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianTied", tostring(self._unit:key()))
    elseif event_id == self._NET_EVENTS.surrender_civilian_untied then
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", tostring(self._unit:key()))
    end
end