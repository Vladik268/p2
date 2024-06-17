local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local EscapeArrivalDelay = 674/30
local triggers = {
    [100006] = { time = 120, id = "LiquidNitrogen", icons = { Icon.LiquidNitrogen }, hint = Hints.rvd2_LiquidNitrogen },
    [100075] = { time = 120 + EscapeArrivalDelay, id = "Escape", icons = Icon.CarEscape, waypoint = { position_by_element = 100209 }, hint = Hints.LootEscape }
}
if EHI:IsClient() then
    triggers[100082] = EHI:ClientCopyTrigger(triggers[100075], { time = EscapeArrivalDelay })
end

local other = {
    [100032] = EHI:AddAssaultDelay({ control = 1, trigger_times = 1 })
}

local function ReplaceWaypointAddFunction(unit_id, unit_data, unit)
    unit:waypoint():ReplaceWaypointFunction()
end
local tbl =
{
    [101975] = { f = ReplaceWaypointAddFunction },
    [101980] = { f = ReplaceWaypointAddFunction },
    [101981] = { f = ReplaceWaypointAddFunction },
    [101982] = { f = ReplaceWaypointAddFunction },
    [102184] = { f = ReplaceWaypointAddFunction },
    [102185] = { f = ReplaceWaypointAddFunction },
    [102186] = { f = ReplaceWaypointAddFunction },
    [102187] = { f = ReplaceWaypointAddFunction },
    [102188] = { f = ReplaceWaypointAddFunction }
}
EHI:UpdateUnits(tbl)

EHI:ParseTriggers({
    mission = triggers,
    other = other
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1000, name = "hm2_enter_building" }, -- Entered the bank
        { amount = 2000, name = "vault_found" },
        { amount = 2500, name = "vault_drills_done" },
        { amount = 3500, name = "rvd2_vault_frozen" },
        { amount = 5000, name = "vault_open" },
        { amount = 3500, name = "fs_secured_required_bags" }
    },
    loot =
    {
        trai_printing_plates = 1250,
        _else = 1000
    }
})