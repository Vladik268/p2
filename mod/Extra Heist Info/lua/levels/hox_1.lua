local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local car = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue } }
local triggers = {
    [100562] = { time = 1 + 5, id = "C4", icons = { Icon.C4 }, hint = Hints.Explosion },

    [101595] = { time = 6, id = "Wait", icons = { Icon.Wait }, hint = Hints.Wait },

    [102191] = { time = 10, id = "MoveVehicle", icons = { Icon.Wait }, hint = Hints.hox_1_VehicleMove }, -- First Police Car

    -- Time for animated car (nothing in the mission script, time was debugged with custom code => using rounded number, which should be accurate enough)
    [102626] = { time = 36.2, id = "CarMoveForward", icons = car, hint = Hints.hox_1_Car },
    [102627] = { time = 34.5, id = "CarMoveLeft", icons = car, hint = Hints.hox_1_Car },
    [102628] = { time = 34.5, id = "CarMoveRight", icons = car, hint = Hints.hox_1_Car },
    -- In Garage
    [101383] = { time = 44.3, id = "CarGoingIntoGarage", icons = car, hint = Hints.hox_1_Car },
    [101397] = { time = 22.6, id = "CarMoveRightFinal", icons = car, hint = Hints.hox_1_Car }
}
local other = {}
if EHI:GetOption("show_sniper_tracker") and EHI:GetOption("show_sniper_spawned_popup") then
    other[100332] = { special_function = EHI.SpecialFunctions.CustomCode, f = function()
        managers.hud:ShowSnipersSpawned(true)
    end, trigger_times = 1 }
end

EHI:ParseTriggers({ mission = triggers, other = other, assault = { diff = 1 } })

local tbl =
{
    --units/payday2/vehicles/anim_vehicle_pickup_sportcab_armored/anim_vehicle_pickup_sportcab_armored/the_car
    [102482] = { f = function(id, unit_data, unit)
        if not EHI:GetOption("show_waypoints") then
            return
        end
        local t = { unit = unit }
        EHI:AddWaypointToTrigger(102626, t)
        EHI:AddWaypointToTrigger(102627, t)
        EHI:AddWaypointToTrigger(102628, t)
        EHI:AddWaypointToTrigger(101383, t)
        EHI:AddWaypointToTrigger(101397, t)
        unit:unit_data():add_destroy_listener("EHIDestroy", function(...)
            managers.ehi_waypoint:RemoveWaypoint("CarMoveForward")
            managers.ehi_waypoint:RemoveWaypoint("CarMoveLeft")
            managers.ehi_waypoint:RemoveWaypoint("CarMoveRight")
            managers.ehi_waypoint:RemoveWaypoint("CarGoingIntoGarage")
            managers.ehi_waypoint:RemoveWaypoint("CarMoveRightFinal")
        end)
    end}
}
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "hox1_first_corner" },
        { amount = 4000, name = "hox1_second_corner" },
        { amount = 200, name = "hox1_blockade_cleared" },
        { amount = 2000, name = "hox1_parking_gate_open" },
        { amount = 4000, name = "hox1_parking_car_reached_garages" },
        { amount = 3000, name = "pc_hack" },
        { escape = 2000 }
    },
    total_xp_override =
    {
        objectives =
        {
            hox1_blockade_cleared = { times = 2 }
        }
    }
})