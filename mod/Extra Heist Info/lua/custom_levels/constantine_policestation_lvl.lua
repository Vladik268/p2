local EHI = EHI

local other =
{
    [100193] = EHI:AddAssaultDelay({ control = 30 })
}

EHI:ParseTriggers({
    other = other
})

EHI:ShowLootCounter({
    max = 10,
    offset = managers.job:current_job_id() ~= "constantine_policestation_nar"
})
local function AdjustServerHackInstance(unit_id, unit_data, unit)
    EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100037_" .. tostring(unit_data.instance_id) .. "_unjammed", function(self, jammed, ...)
        if jammed == false then
            self:_HideWaypoint(EHI:GetInstanceElementID(100017, unit_data.instance_id)) -- Interact (Computer Icon)
        end
    end)
end

local tbl =
{
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b_002
    --levels/instances/mods/Constantine Scores/constantine_mobsterclub_server_computer/world
    [EHI:GetInstanceUnitID(100037, 5750)] = { f = AdjustServerHackInstance, instance_id = 5750 },
    [EHI:GetInstanceUnitID(100037, 6000)] = { f = AdjustServerHackInstance, instance_id = 6000 }
}
EHI:UpdateUnits(tbl)
local DisableWaypoints =
{
    --levels/instances/mods/Constantine Scores/constantine_mobsterclub_server_computer/world
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b_002
    [EHI:GetInstanceElementID(100018, 5750)] = true, -- Defend
    [EHI:GetInstanceElementID(100018, 6000)] = true -- Defend
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "saw_done" },
        { amount = 2000, name = "ed1_hack_1" },
        { amount = 2000, name = "hox2_random_obj" },
        { amount = 2000, name = "ed1_hack_2" },
        { amount = 2000, name = "hox2_random_obj" },
        { amount = 1000, name = "custom_informant_killed" },
        { amount = 2000, name = "custom_defeated_backup_enemies" },
        { escape = 4000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 10 }
            }
        }
    }
})