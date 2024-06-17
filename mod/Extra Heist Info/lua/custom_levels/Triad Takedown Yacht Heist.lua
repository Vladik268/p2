local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local bag_delay = 24.700000762939 -- I'm not even kidding
local triggers = {
    [100285] = { time = 125 + bag_delay, id = "HeliDrillDrop", icons = Icon.HeliDropDrill, hint = Hints.DrillDelivery },
    [100286] = { time = 130 + bag_delay, id = "HeliDrillDrop", icons = Icon.HeliDropDrill, hint = Hints.DrillDelivery },
    [100297] = { time = 65 + 23, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape }
}

EHI:ParseTriggers({ mission = triggers })