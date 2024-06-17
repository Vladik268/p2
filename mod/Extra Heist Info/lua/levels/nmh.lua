local EHI = EHI
local Icon = EHI.Icons
---@class EHIElevatorTimerTracker : EHIPausableTracker
---@field super EHIPausableTracker
EHIElevatorTimerTracker = class(EHIPausableTracker)
EHIElevatorTimerTracker._forced_icons = { Icon.Door }
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIElevatorTimerTracker:init(panel, params, parent_class)
    self._floors = params.floors or 26
    params.time = self:GetElevatorTime()
    EHIElevatorTimerTracker.super.init(self, panel, params, parent_class)
end

function EHIElevatorTimerTracker:GetElevatorTime()
    return self._floors * 8
end

---@param floors number
function EHIElevatorTimerTracker:SetFloors(floors)
    self._floors = floors
    local new_time = self:GetElevatorTime()
    if math.abs(self._time - new_time) >= 1 then -- If the difference in the new time is higher than 1s, use the new time to stay accurate
        self._time = new_time
    end
end

function EHIElevatorTimerTracker:LowerFloor()
    self:SetFloors(self._floors - 1)
end

---@class EHIElevatorTimerWaypoint : EHIPausableWaypoint, EHIElevatorTimerTracker
---@field super EHIPausableWaypoint
EHIElevatorTimerWaypoint = class(EHIPausableWaypoint)
EHIElevatorTimerWaypoint.GetElevatorTime = EHIElevatorTimerTracker.GetElevatorTime
EHIElevatorTimerWaypoint.SetFloors = EHIElevatorTimerTracker.SetFloors
EHIElevatorTimerWaypoint.LowerFloor = EHIElevatorTimerTracker.LowerFloor
---@param panel WaypointDataTable
---@param params table
---@param parent_class EHIWaypointManager
function EHIElevatorTimerWaypoint:init(panel, params, parent_class)
    self._floors = params.floors or 26
    params.time = self:GetElevatorTime()
    EHIElevatorTimerWaypoint.super.init(self, panel, params, parent_class)
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@type ParseTriggerTable
local triggers = {
    [102460] = { time = 7, id = "Countdown", icons = { Icon.Alarm }, class = TT.Warning, hint = Hints.Alarm },
    [102606] = { id = "Countdown", special_function = SF.RemoveTracker },

    [102701] = { time = 13, id = "Patrol", icons = { "pd2_generic_look" }, class = TT.Warning, hint = Hints.nmh_IncomingPolicePatrol, remove_on_alarm = true },

    [103443] = { id = "EscapeElevator", class = "EHIElevatorTimerTracker", special_function = SF.UnpauseTrackerIfExists, waypoint = { icon = EHIElevatorTimerTracker._forced_icons[1], position_by_unit = 102296, class = "EHIElevatorTimerWaypoint" }, hint = Hints.Wait },
    [102620] = { id = "EscapeElevator", special_function = SF.PauseTracker },
    [104072] = { id = "EscapeElevator", special_function = SF.UnpauseTracker },
    [103439] = { id = "EscapeElevator", special_function = SF.RemoveTracker },
    [100186] = { id = "EscapeElevator", special_function = SF.CallCustomFunction, f = "LowerFloor" },

    [102682] = { time = 20, id = "AnswerPhone", icons = { Icon.Phone }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.PickUpPhone, remove_on_alarm = true },
    [102683] = { id = "AnswerPhone", special_function = SF.RemoveTracker },

    [103743] = { time = 25, id = "ExtraCivilianElevatorLeft", icons = { Icon.Door, "hostage" }, class = TT.Warning, hint = Hints.nmh_IncomingCivilian, remove_on_alarm = true },
    [103744] = { time = 35, id = "ExtraCivilianElevatorLeft", icons = { Icon.Door, "hostage" }, class = TT.Warning, hint = Hints.nmh_IncomingCivilian, remove_on_alarm = true },
    [103746] = { time = 15, id = "ExtraCivilianElevatorLeft", icons = { Icon.Door, "hostage" }, class = TT.Warning, hint = Hints.nmh_IncomingCivilian, remove_on_alarm = true },

    [103745] = { time = 10, id = "ExtraCivilianElevatorRight", icons = { Icon.Door, "hostage" }, class = TT.Warning, hint = Hints.nmh_IncomingCivilian, remove_on_alarm = true },
    [103749] = { time = 19, id = "ExtraCivilianElevatorRight", icons = { Icon.Door, "hostage" }, class = TT.Warning, hint = Hints.nmh_IncomingCivilian, remove_on_alarm = true },
    [103750] = { time = 30, id = "ExtraCivilianElevatorRight", icons = { Icon.Door, "hostage" }, class = TT.Warning, hint = Hints.nmh_IncomingCivilian, remove_on_alarm = true },

    [102992] = { chance = 1, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance, hint = Hints.nmh_PatientFileChance, remove_on_alarm = true },
    [103013] = { amount = 1, id = "CorrectPaperChance", special_function = SF.IncreaseChance },
    [103006] = { chance = 100, id = "CorrectPaperChance", icons = { "equipment_files" }, class = TT.Chance, special_function = SF.SetChanceWhenTrackerExists, hint = Hints.nmh_PatientFileChance, remove_on_alarm = true },
    [104752] = { id = "CorrectPaperChance", special_function = SF.RemoveTracker },

    [104721] = { special_function = SF.CustomCode, f = function()
        managers.ehi_assault:SetAssaultBlock(true)
    end }
}

---@type ParseAchievementTable
local achievements =
{
    nmh_11 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.Hard),
        elements =
        {
            -- Looks like a bug, OVK thinks the timer resets but the achievement is already disabled... -> you have 1 shot before mission restart
            -- Reported in:
            -- https://steamcommunity.com/app/218620/discussions/14/3048357185564293898/
            [103456] = { time = 5, class = TT.Achievement.Base, special_function = SF.ShowAchievementFromStart, trigger_times = 1 },
            [103460] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:AddLoadSyncFunction(function(self)
    local elevator_counter = managers.worlddefinition:get_unit(102296) --[[@as UnitDigitalTimer?]]
    local o = elevator_counter and elevator_counter:digital_gui()
    if o and o._timer and o._timer ~= 30 then
        self:Trigger(103443)
        self:Call("EscapeElevator", "SetFloors", o._timer - 4)
        if self:InteractionExists("circuit_breaker") or self:InteractionExists("press_call_elevator") then
            self:Pause("EscapeElevator")
        end
    end
end)

--units/pd2_dlc_nmh/props/nmh_interactable_teddy_saw/nmh_interactable_teddy_saw
EHI:UpdateUnits({ [101387] = { remove_vanilla_waypoint = 104494 } })
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 2000, name = "nmh_cameras_taken_out" },
                { amount = 7000, name = "nmh_keep_hostages_down" },
                { amount = 2000, name = "nmh_found_patients_file" },
                { amount = 1000, name = "nmh_set_up_fake_sentries" },
                { amount = 3000, name = "nmh_found_correct_patient" },
                { amount = 3000, name = "nmh_valid_sample" },
                { amount = 8000, name = "nmh_elevator_arrived" },
                { amount = 2000, name = "nmh_exit_elevator" }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 2000, name = "nmh_cameras_taken_out", optional = true },
                { amount = 7000, name = "nmh_icu_open" },
                { amount = 3000, name = "nmh_saw_patient_room" },
                { amount = 3000, name = "nmh_valid_sample" },
                { amount = 8000, name = "nmh_elevator_arrived" },
                { amount = 2000, name = "nmh_exit_elevator" }
            },
            total_xp_override =
            {
                params =
                {
                    min_max =
                    {
                        objectives =
                        {
                            nmh_cameras_taken_out = { min = 0, max = 1 },
                            nmh_saw_patient_room = { max = 3 }
                        }
                    }
                }
            }
        }
    }
})