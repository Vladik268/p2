local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local inspect = 30
local escape = 23 + 7
local triggers = {
    [103132] = { time = 210 + 90 + 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, hint = Hints.Loot }, -- Includes heli refuel (330s)
    [103130] = { time = 90 + 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [103133] = { time = 30 + 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [103630] = { time = 240, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100372] = { time = 150, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100371] = { time = 120, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100363] = { time = 90, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },
    [100355] = { time = 60, id = "HeliArrival", icons = Icon.HeliLootDrop, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Loot },

    [100266] = { time = 30 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [100271] = { time = 45 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [100273] = { time = 60 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.SetTimeOrCreateTracker, hint = Hints.Wait },
    [103319] = { time = 75 + inspect, id = "Inspect", icons = { Icon.Wait }, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.Wait },
    [100265] = { time = 45 + 75 + inspect, id = "Inspect", icons = { Icon.Wait }, hint = Hints.Wait },

    -- Heli escape
    [100898] = { time = 15 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [100902] = { time = 30 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [100904] = { time = 45 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape },
    [100905] = { time = 60 + escape, id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape }
}

local other =
{
    [100531] = EHI:AddAssaultDelay({ control = 35 })
}

EHI:ParseTriggers({ mission = triggers, other = other })

local tbl =
{
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b
    [103320] = { remove_vanilla_waypoint = 100309 },
    [101365] = { remove_vanilla_waypoint = 102499 },
    [101863] = { remove_vanilla_waypoint = 102498 }
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "pc_found" },
        { amount = 6000, name = "pc_hack" },
        { amount = 6000, name = "big_oil2_correct_engine" },
        { escape = 6000 }
    }
})
EHI:SetDeployableIgnorePos("ammo_bag", {
    Vector3(-7350, -3525, 591.541),
    Vector3(-4825, -2175, 1330.36),
    Vector3(-375, 3125, 843.889),
    Vector3(175, 3000, -1216.21),
    Vector3(-1600, -2175, 800),
    Vector3(-2053, -4263, -1046.93),
    Vector3(-5931, 2294, 1394.4),
    Vector3(-5425, 6250, 519.189)
})