local EHI = EHI
if EHI:CheckLoadHook("HuskCivilianDamage") or EHI:IsHost() or not EHI:CanShowCivilianCountTracker() or EHI:GetOption("civilian_count_tracker_format") == 1 then
    return
end

local original = HuskCivilianDamage.die
function HuskCivilianDamage:die(...)
    managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", tostring(self._unit:key()))
    original(self, ...)
end