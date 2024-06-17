local EHI = EHI
local SF = EHI.SpecialFunctions
local Icon = EHI.Icons
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers =
{
    [100371] = { time = 8.25, id = "Wait", icons = { Icon.Wait }, hint = Hints.Wait },

    [100534] = { time = 4, id = "Thermite", icons = { Icon.Fire }, waypoint = { position_by_unit = 100828 }, hint = Hints.Thermite },

    [100083] = { time = 12, id = "Thermite2", icons = { Icon.Fire }, waypoint = { position_by_unit = 100606 }, hint = Hints.Thermite },

    [100374] = { time = 12 + 5, id = "Wait2", icons = { Icon.Wait }, hint = Hints.Wait },

    [100376] = { time = 7, id = "Wait3", icons = { Icon.Wait }, hint = Hints.Wait },

    [100689] = { time = 7 + 1, id = "Wait4", icons = { Icon.Wait }, hint = Hints.Wait },

    [100137] = { chance = 13, id = "USBChance", icons = { Icon.USB }, class = TT.Chance, hint = Hints.Chance },
    [100117] = { id = "USBChance", special_function = SF.IncreaseChanceFromElement }, -- +13%
    [100138] = { id = "USBChance", special_function = SF.RemoveTracker },

    [100193] = { time = 20, id = "MotionSensorHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 102324 }, hint = Hints.Hack },

    [100236] = { time = 12, id = "Thermite3", icons = { Icon.Fire }, waypoint = { position_by_unit = 100722 }, hint = Hints.Thermite },
    [100238] = { time = 12, id = "Thermite4", icons = { Icon.Fire }, waypoint = { position_by_unit = 100704 }, hint = Hints.Thermite },
    [100239] = { time = 12, id = "Thermite5", icons = { Icon.Fire }, waypoint = { position_by_unit = 100717 }, hint = Hints.Thermite },
    [100242] = { time = 12, id = "Thermite6", icons = { Icon.Fire }, waypoint = { position_by_unit = 100712 }, hint = Hints.Thermite },

    [100087] = { time = 12, id = "Thermite7", icons = { Icon.Fire }, waypoint = { position_by_unit = 102346 }, hint = Hints.Thermite }
}

local other =
{
    [100028] = EHI:AddAssaultDelay({ control = 20 })
}

EHI:ShowLootCounter({ max = 10 })

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

EHI:UpdateUnits({
    -- units/payday2/equipment/gen_interactable_objective_laptop/mcm_laptop/014 (3405, 780, -312)
    [102850] = { remove_vanilla_waypoint = 100459 },

    -- units/pd2_indiana/props/gen_prop_security_timer/gen_prop_security_timer
    [102327] = { icons = { Icon.Vault } },
    [103946] = { ignore = true }
})

local DisableWaypoints =
{
    --levels/instances/mods/Branch Bank Initiative/SJamB_HackBox/world
    [EHI:GetInstanceElementID(100034, 500)] = true, -- Defend
    [EHI:GetInstanceElementID(100031, 500)] = true, -- Fix
    [EHI:GetInstanceElementID(100034, 750)] = true, -- Defend
    [EHI:GetInstanceElementID(100031, 750)] = true -- Fix
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1500, name = "diamond_heist_boxes_hack" },
        { amount = 2000, name = "thermite_done" },
        { amount = 1500 * 4, name = "biker_tools_collected" },
        { amount = 2000, name = "ed1_hack_1" },
        { amount = 2000, name = "ed1_hack_2" },
        { amount = 2000, name = "hox3_vault_objective" },
        { amount = 2500, name_format = { id = "all_bags_destroyed", macros = { carry = tweak_data.carry:FormatCarryNameID("money") }}},
        { amount = 1500, name = "custom_removed_gps_tracker" },
        { escape = 2500 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { min = 4, max = 10 }
            }
        }
    }
})