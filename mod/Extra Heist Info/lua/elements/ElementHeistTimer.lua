local EHI = EHI
if EHI:CheckLoadHook("ElementHeistTimer") then
    return
end
local original = ElementHeistTimer.init
function ElementHeistTimer:init(...)
    original(self, ...)
    EHI._cache._heist_timer_inverted = true
end