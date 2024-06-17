local EHI = EHI
if EHI:CheckLoadHook("ElementSpecialObjective") or not EHI:GetOption("show_captain_spawn_chance") or EHI:IsClient() then
    return
end

local original_init = ElementSpecialObjective.init
function ElementSpecialObjective:init(...)
    original_init(self, ...)
    if self._values.so_action == "AI_phalanx" then
        managers.ehi_phalanx:OnSOPhalanxCreated(self)
    end
end