local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local triggers = {
    [100114] = { time = 17 * 18, id = "Thermite", icons = { Icon.Fire }, hint = Hints.Thermite },
    [100138] = { time = 20, id = "ObjectiveWait", icons = { Icon.Wait }, hint = Hints.Wait }
}

EHI:ParseTriggers({ mission = triggers })
EHI:ShowLootCounter({ max = 20 })