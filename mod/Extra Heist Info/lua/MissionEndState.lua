local EHI = EHI
if EHI:CheckLoadHook("MissionEndState") then
    return
end

EHI:PreHook(MissionEndState, "at_enter", function(self, ...)
    EHI:CallCallbackOnce(EHI.CallbackMessage.MissionEnd, self._success)
    EHI:CallCallbackOnce(EHI.CallbackMessage.HUDVisibilityChanged, false)
end)