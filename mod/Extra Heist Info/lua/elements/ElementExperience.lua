local EHI = EHI
if EHI:CheckLoadHook("ElementExperience") or EHI:IsXPTrackerDisabled() then
    return
end

local original =
{
    init = ElementExperience.init,
    on_executed = ElementExperience.on_executed
}

function ElementExperience:init(...)
    original.init(self, ...)
    managers.ehi_experience:AddXPElement(self)
end

function ElementExperience:on_executed(...)
    if not self._values.enabled then
        return
    end
    managers.ehi_experience:MissionXPAwarded(self._values.amount)
    if EHI.debug.gained_experience.enabled then
        managers.hud:DebugExperience(self._id, self._editor_name, self._values.amount)
    end
    original.on_executed(self, ...)
end