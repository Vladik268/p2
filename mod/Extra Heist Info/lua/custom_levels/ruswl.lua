local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local obj_delay = { time = 30, id = "ObjectiveDelay", icons = { Icon.Wait }, hint = Hints.Wait }
local triggers = {
    [100404] = obj_delay,
    [100405] = obj_delay,
    [101181] = { time = 30, id = "ChemSetReset", icons = { Icon.Loop }, hint = Hints.des_ChemSetRestart },
    [101182] = { time = 30, id = "ChemSetCooking", icons = { Icon.Methlab }, hint = Hints.des_ChemSetCooking },
    [101088] = { time = 84, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape }
}

EHI:ParseTriggers({ mission = triggers })