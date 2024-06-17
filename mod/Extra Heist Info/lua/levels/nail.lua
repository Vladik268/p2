local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local triggers = {
    [101505] = { time = 10, id = "TruckDoorOpens", icons = { Icon.Door }, hint = Hints.Wait },
    -- There are a lot of delays in the ID. Using average instead (5.2)
    [101806] = { time = 20 + 5.2, id = "ChemicalsDrop", icons = { Icon.Heli, Icon.Methlab, Icon.Goto }, hint = Hints.nail_ChemicalsEnRoute },

    [101936] = { time = 30 + 12, id = "Escape", icons = Icon.HeliEscapeNoLoot, hint = Hints.Escape }
}

local other =
{
    [101612] = EHI:AddAssaultDelay({ control = 30 }),
    [101613] = EHI:AddAssaultDelay({ special_function = SF.SetTimeOrCreateTracker }) -- 30s
}

EHI:ParseTriggers({ mission = triggers, other = other })
EHI:ShowLootCounter({
    max_bags_for_level =
    {
        mission_xp = 5000,
        xp_per_loot = { meth_half = 500 },
        objective_triggers = { 100187, 100188, 100189,
            EHI:GetInstanceElementID(100504, 5020),
            EHI:GetInstanceElementID(100505, 5020),
            EHI:GetInstanceElementID(100506, 5020)
        },
        custom_counter =
        {
            counter =
            {
                check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
                loot_type = "meth_half"
            }
        }
    },
    no_max = true
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "lab_rats_added_ephedrin_pill" },
        { amount = 1000, name = "lab_rats_added_correct_ingredient" },
        { amount = 500, name = "lab_rats_bagged_meth" },
        { amount = 30000, name = "lab_rats_safe_event_1", optional = true },
        { amount = 22500, name = "lab_rats_safe_event_2", optional = true },
        { amount = 15000, name = "lab_rats_safe_event_3", optional = true },
        { escape = 5000 }
    },
    loot =
    {
        meth_half = 500,
    },
    no_total_xp = true
})