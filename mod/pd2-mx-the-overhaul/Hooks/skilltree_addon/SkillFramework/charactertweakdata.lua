_G = _G or {}
-- So, I had to make my own global, since I cant trush OVK to do shit properly, and I can't trust other modder to NOT FUCKING OVERRIDE EVERYTHING IN THEIR PATH. Rant over
_G.ORIGINAL_HEALTH_MAP = {}
Hooks:PostHook(CharacterTweakData, "init", "SF2_CharacterTweakData_init", function (self)
    for k, v in pairs(self) do
        if type(v) == "table" and v.HEALTH_INIT and v.weapon then
            _G.ORIGINAL_HEALTH_MAP[k] = v.HEALTH_INIT
        end
    end
end)