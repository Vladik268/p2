local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local Hints = EHI.Hints
local triggers =
{
    [100391] = { id = "HeliEscape", icons = Icon.HeliEscapeNoLoot, special_function = SF.SetTimeByPreplanning, data = { id = 100486, yes = 60 + 25, no = 120 + 25 }, waypoint = { icon = Icon.Escape, position_by_element = 100420 }, hint = Hints.Escape }
}
if EHI:IsClient() then
    triggers[100414] = EHI:ClientCopyTrigger(triggers[100391], { time = 25 }, true)
end

local other =
{
    [100032] = EHI:AddAssaultDelay({ control = 30 })
}
if EHI:GetOption("show_sniper_tracker") and EHI:GetOption("show_sniper_spawned_popup") then
    other[100442] = { special_function = EHI.SpecialFunctions.CustomCode, f = function()
        managers.hud:ShowSnipersSpawned()
    end }
end

EHI:ParseTriggers({
    mission = triggers,
    other = other
})

EHI:ShowLootCounter({
    max = 8,
    offset = managers.job:current_job_id() ~= "constantine_butcher_nar"
})

local tbl =
{
    [EHI:GetInstanceUnitID(100037, 3750)] = { f = function(unit_id, unit_data, unit)
        EHI:HookWithID(unit:timer_gui(), "set_jammed", "EHI_100037_3750_unjammed", function(self, jammed, ...)
            if jammed == false then
                self:_HideWaypoint(EHI:GetInstanceElementID(100017, 3750)) -- Interact (Computer Icon)
            end
        end)
    end}
}
EHI:UpdateUnits(tbl)
local DisableWaypoints =
{
    --levels/instances/mods/Constantine Scores/constantine_mobsterclub_server_computer/world
    --units/payday2/equipment/gen_interactable_hack_computer/gen_interactable_hack_computer_b_002
    [EHI:GetInstanceElementID(100018, 3750)] = true -- Defend
}
EHI:DisableWaypoints(DisableWaypoints)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "china2_warehouse_open" },
        { amount = 2000, name = "custom_opened_security_door" },
        { amount = 2000, name = "custom_pc_powered_on" },
        { amount = 2000, name = "hox2_random_obj" },
        { amount = 2000, name = "pc_hack" },
        { amount = 2000, name = "custom_opened_security_door" },
        { amount = 2000, name = "china2_inject_adrenaline" },
        { amount = 2000, name = "panic_room_killed_all_snipers" },
        { amount = 2000, name = "custom_escort" },
        { escape = 2000 }
    },
    loot_all = 1000,
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 8 }
            }
        }
    }
})