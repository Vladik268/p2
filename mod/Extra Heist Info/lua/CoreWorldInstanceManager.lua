---@class CoreWorldInstanceManager
---@field get_instance_data_by_name fun(self: self, instance_name: string): table?
---@field instance_data fun(self: self): table

---@alias CoreWorldInstanceManager.Instance { folder: string, start_index: number, continent: string, rotation: Rotation }

local EHI = EHI
if EHI:CheckLoadHook("CoreWorldInstanceManager") then
    return
end
EHI:Init()
local debug_instance = EHI.debug.instance
local debug_unit = false
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local used_start_indexes = {}
---@type ParseInstanceTable
local instances =
{
    ["levels/instances/shared/obj_skm/world"] = -- Hostage in the Holdout mode
    {
        [100032] = { time = 7, id = "skm_HostageRescue", icons = { Icon.Kill }, class = TT.Warning, hint = Hints.roberts_GenSecWarning, special_function = SF.SetTimeOrCreateTracker },
        [100036] = { id = "skm_HostageRescue", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/mus_security_barrier/world"] =
    {
        [100033] = { remove_vanilla_waypoint = true }, -- Fix
        [100034] = { remove_vanilla_waypoint = true } -- Defend
    },
    ["levels/instances/unique/hox_breakout_road001/world"] =
    {
        [100000] = { time = 10, id = "hox_1_MovePoliceVehicle", icons = { Icon.Wait }, hint = Hints.hox_1_VehicleMove },
        [100056] = { time = 10, id = "hox_1_MoveSWATVan", icons = { Icon.Wait }, hint = Hints.hox_1_VehicleMove }
    },
    ["levels/instances/unique/holly_2/heli_c4_drop/world"] =
    {
        [100000] = { time = 120 + 25 + 0.25 + 2 + 2, id = "jolly_C4Drop", icons = Icon.HeliDropC4, hint = Hints.C4Delivery, waypoint = { position_by_element = 100021 } }
    },
    ["levels/instances/unique/hlm_reader/world"] =
    {
        [100038] = { time = 90 + 1.5, id = "mia_1_Reader", icons = { Icon.PCHack }, class = TT.Pausable, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100060, restore_on_done = true }, hint = Hints.Process },
        [100039] = { time = 120 + 1.5, id = "mia_1_Reader", icons = { Icon.PCHack }, class = TT.Pausable, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100060, restore_on_done = true }, hint = Hints.Process },
        [100040] = { time = 180 + 1.5, id = "mia_1_Reader", icons = { Icon.PCHack }, class = TT.Pausable, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100060, restore_on_done = true }, hint = Hints.Process },
        [100045] = { id = "mia_1_Reader", special_function = SF.PauseTracker },
        [100051] = { id = "mia_1_Reader", special_function = SF.UnpauseTracker }
    },
    ["levels/instances/unique/are_c4_vault_01/world"] =
    {
        [100067] = { add_runned_unit_sequence_trigger = true, time = 30, icons = { Icon.Glasscutter }, hint = Hints.Cutter }
    },
    ["levels/instances/unique/are_pyro_booth/world"] =
    {
        [100166] = { time = 5, id = "arena_WaitTime", icons = { Icon.Wait }, hint = Hints.Wait },
        [100128] = { time = 10, id = "arena_PressSequence", icons = { Icon.Interact }, class = TT.Warning },
        [100069] = { id = "arena_PressSequence", special_function = SF.RemoveTracker },
        [100090] = { id = "arena_PressSequence", special_function = SF.RemoveTracker },
        [100116] = { max = 3, id = "arena_C4Progress", icons = { Icon.C4 }, class = TT.Progress },
        [100177] = { id = "arena_C4Progress", special_function = SF.IncreaseProgress }
    },
    ["levels/instances/unique/are_security_room/world"] =
    {
        [100050] = { remove_vanilla_waypoint = true } -- PC
    },
    ["levels/instances/unique/kenaz/hackable_keycard_panel/world"] =
    {
        [100022] = { remove_vanilla_waypoint = true, mission = true },
        [100018] = { time = 30, id = "kenaz_SkylightHack", icons = { Icon.Tablet }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Hack, waypoint = { position_by_element = 100003 } },
        [100037] = { id = "kenaz_SkylightHack", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/kenaz/chopper_incoming/world"] =
    {
        [100021] = { time = 60 + 22 + 1 + 1.5, id = "kenaz_HeliWinchDelivery", icons = Icon.HeliDropWinch, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.brb_WinchDelivery },
        [100042] = { time = 30 + 22 + 1 + 1.5, id = "kenaz_HeliWinchDelivery", icons = Icon.HeliDropWinch, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.brb_WinchDelivery }
    },
    ["levels/instances/unique/kenaz/the_drill/world"] =
    {
        [100347] = { remove_vanilla_waypoint = true } -- Defend
    },
    ["levels/instances/unique/kenaz/weak_floor/world"] =
    {
        [100030] = { time = 5, id = "kenaz_C4VaultWall", icons = { Icon.C4 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/cane/cane_trap_flame/world"] =
    {
        [100022] = { time = 60, id = "cane_FireTrap", icons = { Icon.Fire }, class = TT.Warning, hint = Hints.Fire, waypoint = { position_by_unit = 100002 } },
        [100024] = { time = 180, id = "cane_FireTrapRecharge", icons = { Icon.Fire, Icon.Loop }, hint = Hints.FireRecharge, waypoint = { icon = Icon.Loop, position_by_unit = 100002 } }
    },
    ["levels/instances/unique/cane/cane_santa_event/world"] =
    {
        [100135] = { time = 12, id = "cane_SafeEvent", icons = { Icon.Heli, Icon.Goto }, hint = Hints.cane_Safe }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish/world"] =
    {
        [100008] = { time = 5, id = "pbr_SatelliteC4Explosion", icons = { Icon.C4 }, waypoint = { position_by_unit = 100022 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/pbr/pbr_mountain_comm_dish_huge/world"] =
    {
        [100013] = { time = 5, id = "pbr_HugeSatelliteC4Explosion", icons = { Icon.C4 }, waypoint = { position_by_unit = 100000 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/pbr/pbr_mountain_lock/world"] =
    {
        [100108] = { time = 45, id = "pbr_LockOpen", icons = { Icon.Wait }, hint = Hints.Wait },
        [100124] = { id = "pbr_LockOpen", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/pbr/pbr_flare/world"] =
    {
        [100024] = { time = 60, id = "pbr2_Flare", icons = { Icon.Heli, Icon.Winch }, waypoint = { icon = Icon.Winch, position_by_element = 100017 }, hint = Hints.Winch }
    },
    ["levels/instances/unique/red/red_hacking_computer/world"] =
    {
        [100024] = { remove_vanilla_waypoint = true } -- Computer WP
    },
    ["levels/instances/unique/cag_computer/world"] =
    {
        [100012] = { remove_vanilla_waypoint = true } -- Computer WP
    },
    ["levels/instances/unique/pet_lightpole/world"] =
    {
        [100039] = { remove_vanilla_waypoint = true } -- Saw WP
    },
    ["levels/instances/unique/pet_shutter/world"] =
    {
        [100020] = { remove_vanilla_waypoint = true } -- Drill WP
    },
    ["levels/instances/unique/pet_planedrop/world"] =
    {
        [100022] = { time = 180 + 6.9, id = "peta2_BagsDropin", icons = Icon.HeliDropBag, hint = Hints.peta2_LootZoneDelivery }
    },
    ["levels/instances/unique/dark/train_int_murky_emp/world"] =
    {
        [100334] = { add_runned_unit_sequence_trigger = true, time = 10, icons = { Icon.Fire }, hint = Hints.Fire }
    },
    ["levels/instances/unique/mad/mad_anti_air/world"] =
    {
        [100112] = { remove_vanilla_waypoint = true }, -- Defend
        [100113] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/mad/mad_emp/world"] =
    {
        [100013] = { time = 120, id = "mad_EMP", icons = { Icon.Defend }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.mad_EMP, waypoint = { position_by_element_and_remove_vanilla_waypoint = 100112 } },
        [100023] = { id = "mad_EMP", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/mad/mad_scan_bed/world"] =
    {
        [100019] = { time = 90, id = "mad_Scan", icons = { "mad_scan" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.mad_Scan },
        [100049] = { id = "mad_Scan", special_function = SF.PauseTracker },
        [100081] = { id = "mad_Scan", special_function = SF.RemoveTracker } -- Just in case
    },
    ["levels/instances/unique/help/heli_c4_drop_short/world"] =
    {
        [100004] = { special_function = SF.ShowWaypoint, data = { icon = Icon.C4, position_by_element = 100021 } }
    },
    ["levels/instances/unique/help/lottery_wheel/world"] =
    {
        [100093] = { remove_vanilla_waypoint = true }, -- Defend
        [100212] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/dah/dah_keypad/world"] =
    {
        [100176] = { time = 30, id = "dah_KeypadRebootECM", icons = { Icon.Loop }, special_function = SF.SetTimeOrCreateTracker, waypoint = { position_by_unit = 100000 }, hint = Hints.KeypadReset },
        [100210] = { time = 5 + 25, id = "dah_KeypadReset", icons = { Icon.Wait }, waypoint = { position_by_unit = 100000 }, hint = Hints.KeypadReset }
    },
    ["levels/instances/unique/dah/dah_security_box/world"] =
    {
        [100011] = { remove_vanilla_waypoint = true }, -- Defend
        [100036] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/rvd/rvd_hackbox/world"] =
    {
        [100034] = { remove_vanilla_waypoint = true }, -- Defend
        [100031] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/rvd/rvd_escape_door/world"] =
    {
        [100020] = { time = 5, id = "rvd_C4Escape", icons = { Icon.C4 }, waypoint = { position_by_unit = 100008 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/brb/single_door/world"] =
    {
        [100021] = { remove_vanilla_waypoint = true }, -- Defend
        [100022] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/brb/brb_vault/world"] =
    {
        [100004] = { add_runned_unit_sequence_trigger = true, time = 50, time_random = 10, icons = { Icon.Fire }, hint = Hints.Thermite, class = TT.Inaccurate }
    },
    ["levels/instances/unique/brb/office_floor/world"] =
    {
        [100021] = { remove_vanilla_waypoint = true, mission = true }, -- Defend
        [100022] = { remove_vanilla_waypoint = true, mission = true }, -- Fix
        [100077] = { time = 90, id = "brb_Cutter", icons = { Icon.Glasscutter }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint = { position_by_element = 100021 }, hint = Hints.Cutter },
        [100078] = { id = "brb_Cutter", special_function = SF.PauseTracker },
        [100103] = { time = 5, id = "brb_C4", icons = { Icon.C4 }, waypoint = { position_by_element = 100021 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/bph/bph_drill_door/world"] =
    {
        [100037] = { remove_vanilla_waypoint = true } -- Defend
    },
    ["levels/instances/unique/des/des_computer/world"] =
    {
        [100025] = { remove_vanilla_waypoint = true }, -- Defend
        [100026] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/des/des_drill/world"] =
    {
        [100008] = { remove_vanilla_waypoint = true } -- Defend
    },
    ["levels/instances/unique/des/des_hackbox/world"] =
    {
        [100007] = { remove_vanilla_waypoint = true }, -- Defend
        [100008] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/sah/sah_hackbox/world"] =
    {
        [100016] = { remove_vanilla_waypoint = true }, -- Defend
        [100042] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/sah/sah_helicopter/world"] =
    {
        [100003] = { time = 120 + 24 + 5 + 3, id = "sah_HeliEscape", icons = Icon.HeliEscape, waypoint = { icon = Icon.LootDrop, position_by_element = 100013 }, hint = Hints.LootEscape }, -- West
        [100018] = { time = 120 + 24 + 5 + 3, id = "sah_HeliEscape", icons = Icon.HeliEscape, waypoint = { icon = Icon.LootDrop, position_by_element = 100013 }, hint = Hints.LootEscape } -- East
    },
    ["levels/instances/unique/sah/sah_office/world"] =
    {
        [100087] = { remove_vanilla_waypoint = true }, -- PC - Fix; No defend icon, computer icon is disabled after computer unit has been interacted with
        [100320] = { remove_vanilla_waypoint = true } -- Drill - Fix; No defend icon, drill icon is disabled after drill unit has been placed
    },
    ["levels/instances/unique/nmh/nmh_fuge/world"] =
    {
        [100013] = { additional_time = 15 + 15 + 10 + 40/30, random_time = 5, id = "nmh_VialFail", icons = { "equipment_bloodvial", Icon.Loop }, hint = Hints.nmh_VialFail, waypoint = { position_by_unit = 100008 } },
        [100017] = { time = 30, id = "nmh_VialSuccess", icons = { "equipment_bloodvialok" }, hint = Hints.nmh_VialSuccess, waypoint = { position_by_unit = 100008 } },
        [100014] = { time = 15 + 10 + 40/30, id = "nmh_VialFail", icons = { "equipment_bloodvial", Icon.Loop }, special_function = SF.SetTrackerAccurate, hint = Hints.nmh_VialFail, waypoint = { position_by_unit = 100008 } }
    },
    ["levels/instances/unique/vit/vit_targeting_computer/world"] =
    {
        [100002] = { remove_vanilla_waypoint = true }, -- Defend
        [100003] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/vit/vit_wire_box/world"] =
    {
        [100074] = { remove_vanilla_waypoint = true }, -- Defend
        [100050] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/vit/vit_peoc_workstation/world"] =
    {
        [100059] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/bex/bex_computer/world"] =
    {
        [100006] = { time = 30, id = "bex_PCHack", icons = { Icon.PCHack }, waypoint = { position_by_unit = 100000 }, hint = Hints.Hack },
        [100138] = { id = "bex_PCHack", special_function = SF.RemoveTracker } -- Alarm
    },
    ["levels/instances/unique/bex/bex_server/world"] =
    {
        [100015] = { id = "bex_ServerHack", icons = { Icon.PCHack }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExistsAccurate, element = 100014, hint = Hints.Hack },
        [100016] = { id = "bex_ServerHack", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/bex/bex_vehicle_pull_gate/world"] =
    {
        [100108] = { time = 4.8, id = "bex_SuprisePull", icons = { Icon.Wait }, hint = Hints.Wait }
    },
    ["levels/instances/unique/pex/pex_armory_small/world"] =
    {
        [100025] = { time = 120, id = "pex_ArmoryHack", icons = { Icon.Tablet }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, waypoint_f = function(self, trigger)
            self._waypoints:AddWaypoint(trigger.id, {
                time = trigger.time,
                icon = Icon.Tablet,
                position = self:GetElementPositionOrDefault(trigger.element_ids.defend),
                class = EHI.Waypoints.Pausable
            })
            managers.hud:SoftRemoveWaypoint2(trigger.element_ids.defend)
            managers.hud:SoftRemoveWaypoint2(trigger.element_ids.fix)
        end, element_ids = { defend = 100055, fix = 100056 }, hint = Hints.Hack },
        [100026] = { id = "pex_ArmoryHack", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/pex/pex_evidence_room_1/world"] =
    {
        [100080] = { remove_vanilla_waypoint = true }, -- Defend
        [100084] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/pex/pex_evidence_room_2/world"] =
    {
        [100072] = { remove_vanilla_waypoint = true }, -- Defend
        [100079] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/fex/fex_exploding_car/world"] =
    {
        [100026] = { time = 26.5 + 5, id = "fex_CarBurn", icons = { Icon.Car, Icon.Fire }, hint = Hints.Wait }
    },
    ["levels/instances/unique/fex/fex_explosives/world"] =
    {
        [100008] = { time = 60, id = "fex_ExplosivesTimer", icons = { "equipment_timer" }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Explosion },
        [100007] = { id = "fex_ExplosivesTimer", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/fex/fex_front_gate/world"] =
    {
        [100049] = { time = 6, id = "fex_ThermiteFrontGate", icons = { Icon.Fire }, hint = Hints.Thermite }
    },
    ["levels/instances/unique/fex/fex_helicopter_escape/world"] =
    {
        [100016] = { time = 180 + 2, id = "fex_HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape, waypoint = { icon = Icon.Escape, position_by_element_and_remove_vanilla_waypoint = 100023 } }
    },
    ["levels/instances/unique/fex/fex_mayan_door/world"] =
    {
        [100358] = { time = 1 + 210/30, id = "fex_MayanDoorOpen", icons = { Icon.Door }, hint = Hints.Wait }
    },
    ["levels/instances/unique/fex/fex_safe/world"] =
    {
        [100016] = { time = 45, id = "fex_SafeHackStealth", icons = { Icon.Vault }, hint = Hints.Hack },
        [100022] = { remove_vanilla_waypoint = true }, -- Fix
        [100029] = { remove_vanilla_waypoint = true } -- Defend
    },
    ["levels/instances/unique/fex/fex_saw_reinforced_door/world"] =
    {
        [100015] = { remove_vanilla_waypoint = true }, -- Defend
        [100068] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/fex/fex_serverhack/world"] =
    {
        [100039] = { remove_vanilla_waypoint = true } -- Defend
    },
    ["levels/instances/unique/fex/fex_winecellar_gate/world"] =
    {
        [100007] = { time = 6, id = "fex_ThermiteWineCellarDoor", icons = { Icon.Fire }, hint = Hints.Thermite }
    },
    ["levels/instances/unique/chas/chas_auction_room_door_hack/world"] =
    {
        [100031] = { remove_vanilla_waypoint = true }, -- Defend
        [100056] = { remove_vanilla_waypoint = true }, -- Fix
    },
    ["levels/instances/unique/chas/chas_gas_outside_vent/world"] =
    {
        [100018] = { time = 120, id = "chas_Gas", icons = { Icon.Teargas }, hint = Hints.Teargas },
        [100034] = { id = "chas_Gas", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/chas/chas_store_computer/world"] =
    {
        [100018] = { remove_vanilla_waypoint = true } -- Defend; Fix is in WorldDefinition
    },
    ["levels/instances/unique/chas/chas_vault_door/world"] =
    {
        [100029] = { remove_vanilla_waypoint = true }, -- Defend
        [100030] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/sand/sand_control_room_door/world"] =
    {
        [100045] = { time = 5, id = "sand_RoomHack", icons = { Icon.Tablet }, hint = Hints.Hack }
    },
    ["levels/instances/unique/sand/sand_defibrillator/world"] =
    {
        [100051] = { remove_vanilla_waypoint = true } -- Power
    },
    ["levels/instances/unique/sand/sand_helicopter_turret/world"] =
    {
        [100027] = { id = "sand_TurretTimer", icons = { Icon.Heli, Icon.Turret, Icon.Wait }, special_function = SF.GetElementTimerAccurate, element = 100012, hint = Hints.sand_HeliTurretTimer }
    },
    ["levels/instances/unique/sand/sand_chinese_computer_hackable/world"] =
    {
        [100018] = { remove_vanilla_waypoint = true } -- Defend; Interact is in WorldDefinition
    },
    ["levels/instances/unique/sand/sand_server_hack/world"] =
    {
        [100018] = { remove_vanilla_waypoint = true } -- Fix; Interact is in WorldDefinition
    },
    ["levels/instances/unique/chca/chca_casino_hack/world"] =
    {
        [100034] = { remove_vanilla_waypoint = true }, -- Defend
        [100060] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/chca/chca_heli_drop/world"] =
    {
        [100096] = { time = 5 + 15, id = "chca_HeliRaise", icons = { Icon.Heli, Icon.Wait }, hint = Hints.Wait },
        [100097] = { time = 150, id = "chca_Winch", icons = { Icon.Winch }, class = TT.Pausable, hint = Hints.Winch },
        [100104] = { id = "chca_Winch", special_function = SF.UnpauseTracker },
        [100105] = { id = "chca_Winch", special_function = SF.PauseTracker },
        -- DON'T REMOVE THIS, because OVK's scripting skills suck
        -- They pause the timer when it reaches zero for no reason. But the timer is already stopped via Lua...
        [100101] = { id = "chca_Winch", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/chca/chca_meeting_room/world"] =
    {
        [100025] = { time = 5, id = "chca_C4MeetingRoom", icons = { Icon.C4 }, hint = Hints.Explosion },
        [100137] = { time = 10 + 1 + 52/30, id = "chca_Swing", icons = { Icon.Wait }, hint = Hints.Wait }
    },
    ["levels/instances/unique/chca/chca_spa_1/world"] =
    {
        [100125] = { remove_vanilla_waypoint = true }, -- Defend
        [100126] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/chca/chca_spa_2/world"] =
    {
        [100128] = { remove_vanilla_waypoint = true }, -- Defend
        [100129] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/chca/chca_c4_vault_wall/world"] =
    {
        [100022] = { time = 5, id = "chca_C4VaultWall", icons = { Icon.C4 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/pent/pent_car_platform/world"] =
    {
        [100002] = { time = 300/30, id = "pent_CarLiftUp", icons = { Icon.Car, Icon.Wait }, hint = Hints.Wait },
        [100034] = { time = 5, id = "pent_CarSpeedUp", icons = { Icon.Car, Icon.Wait }, hint = Hints.Wait },
        [100133] = { time = 1200/30, id = "pent_CarRotate", icons = { Icon.Car, Icon.Wait }, hint = Hints.Wait }
    },
    ["levels/instances/unique/pent/pent_editing_room/world"] =
    {
        [100016] = { remove_vanilla_waypoint = true }, -- Defend
        [100093] = { remove_vanilla_waypoint = true }, -- Defend
        [100044] = { remove_vanilla_waypoint = true }, -- Fix
        [100107] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/pent/pent_generator/world"] =
    {
        [100066] = { id = "pent_GeneratorStartChance", icons = { Icon.Power }, class = TT.Chance, hint = Hints.pent_Chance },
        [100018] = { id = "pent_GeneratorStartChance", special_function = SF.IncreaseChanceFromElement }, -- +33%
        [100016] = { id = "pent_GeneratorStartChance", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/pent/pent_keyboard/world"] =
    {
        [100014] = { time = 10 + 3, id = "pent_PCHack", icons = { Icon.PCHack }, hint = Hints.Hack, waypoint = { position_by_unit = 100012, remove_vanilla_waypoint = 102955, remove_vanilla_waypoint_no_instance = true } }
    },
    ["levels/instances/unique/pent/pent_meeting_room_door_thermite/world"] =
    {
        [100035] = { time = 22.5 * 3, id = "pent_DoorThermite", icons = { Icon.Fire }, hint = Hints.Thermite }
    },
    ["levels/instances/unique/pent/pent_security_box/world"] =
    {
        [100081] = { remove_vanilla_waypoint = true }, -- Defend
        [100082] = { remove_vanilla_waypoint = true } -- Fix
    },
    ["levels/instances/unique/pent/pent_window_cleaning_platform/world"] =
    {
        [100047] = { time = 20, id = "pent_PlatformLoweringDown", icons = { Icon.Wait }, hint = Hints.Wait }
    },
    ["levels/instances/unique/trai/trai_crane/world"] =
    {
        [0] = { create_tracker_class = function()
            ---@class EHICraneFixChanceTracker : EHITimedWarningChanceTracker
            ---@field super EHITimedWarningChanceTracker
            EHICraneFixChanceTracker = class(EHITimedWarningChanceTracker)
            EHICraneFixChanceTracker._forced_icons = EHICraneFixChanceTracker._ONE_ICON and { Icon.Fix } or { Icon.Winch, Icon.Fix }
            EHICraneFixChanceTracker._show_completion_color = true
            EHICraneFixChanceTracker.SetFailed = EHIAchievementTracker.SetFailed
            EHICraneFixChanceTracker.ShowFailedPopup = function(...) end
            function EHICraneFixChanceTracker:OverridePanel()
                EHICraneFixChanceTracker.super.OverridePanel(self)
                self._text:set_x(0)
                self._chance_text:set_left(self._text:right())
                self._refresh_on_delete = false
            end
        end },
        [100089] = { time = 0.1 + 400/30, id = "trai_CraneLowerHooks", icons = { Icon.Winch }, hint = Hints.des_Crane },
        [100010] = { time = 400/30 + 91.5 + 2 + 400/30, id = "trai_CraneMove", icons = { Icon.Winch }, class = TT.Pausable, hint = Hints.des_Crane },
        [100047] = { id = "trai_CraneMove", special_function = SF.PauseTracker },
        [100059] = { id = "trai_CraneMove", special_function = SF.UnpauseTracker },
        [100060] = { id = "trai_CraneMove", special_function = SF.PauseTracker },
        [100046] = { time = 20, chance = 30, id = "trai_CraneFixChance", class = "EHICraneFixChanceTracker", trigger_times = 1, start_opened = true, hint = Hints.trai_Crane },
        [100035] = { id = "trai_CraneFixChance", special_function = SF.IncreaseChanceFromElement }, -- +10%
        [100039] = { id = "trai_CraneFixChance", special_function = SF.SetAchievementFailed }, -- Players need to fix the crane, runs once (Won't trigger "ACHIEVEMENT FAILED!" popup)
        [100220] = { chance = 33, id = "trai_LocomotiveStartChance", icons = { Icon.Power }, class = TT.Chance, hint = Hints.trai_LocoStart },
        [100193] = { id = "trai_LocomotiveStartChance", special_function = SF.IncreaseChanceFromElement }, -- +34%
        [100187] = { id = "trai_LocomotiveStartChance", special_function = SF.RemoveTracker }
    },
    ["levels/instances/unique/trai/trai_locomotive/world"] =
    {
        [100031] = { time = 1175/30, id = "trai_LocomotiveMoveToTurntable", icons = { Icon.Train }, hint = Hints.Wait }
    },
    ["levels/instances/unique/trai/trai_locomotive_turntable/world"] =
    {
        [100024] = { time = 25, id = "trai_Turntable", icons = { Icon.Train, Icon.Loop }, class = TT.Pausable, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Wait },
        [100025] = { id = "trai_Turntable", special_function = SF.PauseTracker }
    },
    ["levels/instances/unique/corp/corp_display_case/world"] =
    {
        [100018] = { time = 10, id = "corp_DisplayCaseThermite", icons = { Icon.Fire }, hint = Hints.Thermite, waypoint = { position_by_unit = 100095 } }
    },
    ["levels/instances/unique/corp/corp_wall_hack/world"] =
    {
        [100031] = { remove_vanilla_waypoint = true }, -- Defend
        [100056] = { remove_vanilla_waypoint = true } -- Fix
    }
}
instances["levels/instances/unique/are_c4_vault_01/world"][100093] = instances["levels/instances/unique/are_c4_vault_01/world"][100067]
instances["levels/instances/unique/are_c4_vault_01/world"][100094] = instances["levels/instances/unique/are_c4_vault_01/world"][100067]
instances["levels/instances/unique/brb/single_door_large/world"] = instances["levels/instances/unique/brb/single_door/world"]
instances["levels/instances/unique/brb/brb_vault/world"][100010] = instances["levels/instances/unique/brb/brb_vault/world"][100004]
instances["levels/instances/unique/brb/brb_vault/world"][100034] = instances["levels/instances/unique/brb/brb_vault/world"][100004]
instances["levels/instances/unique/brb/brb_vault/world"][100039] = instances["levels/instances/unique/brb/brb_vault/world"][100004]
instances["levels/instances/unique/tag/tag_keypad/world"] = deep_clone(instances["levels/instances/unique/dah/dah_keypad/world"])
instances["levels/instances/unique/tag/tag_keypad/world"][100176].waypoint.position_by_unit = 100279
instances["levels/instances/unique/tag/tag_keypad/world"][100210].time = 5 + EHI:GetKeypadResetTimer({ normal = 10 })
instances["levels/instances/unique/tag/tag_keypad/world"][100210].waypoint.position_by_unit = 100279
instances["levels/instances/unique/des/des_computer_001/world"] = instances["levels/instances/unique/des/des_computer/world"]
instances["levels/instances/unique/des/des_computer_002/world"] = instances["levels/instances/unique/des/des_computer/world"]
instances["levels/instances/unique/pex/pex_armory_medium/world"] = instances["levels/instances/unique/pex/pex_armory_small/world"]
instances["levels/instances/unique/pex/pex_armory_large/world"] = instances["levels/instances/unique/pex/pex_armory_small/world"]
instances["levels/instances/unique/sand/sand_rotating_keypad/world"] = deep_clone(instances["levels/instances/unique/tag/tag_keypad/world"])
instances["levels/instances/unique/sand/sand_rotating_keypad/world"][100210].time = 3 + EHI:GetKeypadResetTimer()
instances["levels/instances/unique/chca/chca_keypad/world"] = instances["levels/instances/unique/sand/sand_rotating_keypad/world"]
instances["levels/instances/unique/xmn/xmn_breakout_road001/world"] = instances["levels/instances/unique/hox_breakout_road001/world"]

if EHI:IsClient() then
    instances["levels/instances/unique/pbr/pbr_flare/world"][100025] = EHI:ClientCopyTrigger(instances["levels/instances/unique/pbr/pbr_flare/world"][100024], { time = 27 })
    instances["levels/instances/unique/mad/mad_emp/world"][100017] = EHI:CopyTrigger(instances["levels/instances/unique/mad/mad_emp/world"][100013], { time = 90 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/mad/mad_emp/world"][100019] = EHI:CopyTrigger(instances["levels/instances/unique/mad/mad_emp/world"][100013], { time = 60 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/mad/mad_emp/world"][100021] = EHI:CopyTrigger(instances["levels/instances/unique/mad/mad_emp/world"][100013], { time = 30 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/mad/mad_emp/world"][100028] = EHI:CopyTrigger(instances["levels/instances/unique/mad/mad_emp/world"][100013], { time = 10 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/sah/sah_helicopter/world"][100030] = EHI:ClientCopyTrigger(instances["levels/instances/unique/sah/sah_helicopter/world"][100003], { time = 113 + 24 + 5 + 3 })
    instances["levels/instances/unique/sah/sah_helicopter/world"][100033] = EHI:ClientCopyTrigger(instances["levels/instances/unique/sah/sah_helicopter/world"][100003], { time = 107 + 24 + 5 + 3 })
    instances["levels/instances/unique/sah/sah_helicopter/world"][100034] = EHI:ClientCopyTrigger(instances["levels/instances/unique/sah/sah_helicopter/world"][100003], { time = 47 + 24 + 5 + 3 })
    instances["levels/instances/unique/sah/sah_helicopter/world"][100035] = EHI:ClientCopyTrigger(instances["levels/instances/unique/sah/sah_helicopter/world"][100003], { time = 17 + 24 + 5 + 3 })
    instances["levels/instances/unique/bex/bex_server/world"][100015].client = { time = 90, random_time = 10, special_function = SF.UnpauseTrackerIfExists }
    instances["levels/instances/unique/bex/bex_server/world"][100011] = { id = "bex_ServerHack", special_function = SF.RemoveTracker }
    instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100024] = EHI:CopyTrigger(instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100016], { time = 60 + 2 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100030] = EHI:CopyTrigger(instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100016], { time = 25 + 2 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100035] = EHI:CopyTrigger(instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100016], { time = 38 + 2 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100036] = EHI:CopyTrigger(instances["levels/instances/unique/fex/fex_helicopter_escape/world"][100016], { time = 120 + 2 }, SF.SetTimeOrCreateTracker)
    instances["levels/instances/unique/chca/chca_heli_drop/world"][100099] = EHI:ClientCopyTrigger(instances["levels/instances/unique/chca/chca_heli_drop/world"][100097], { time = 80 }) -- "pulling_timer_trigger_120sec" but the time is set to 80s...
    instances["levels/instances/unique/chca/chca_heli_drop/world"][100100] = EHI:ClientCopyTrigger(instances["levels/instances/unique/chca/chca_heli_drop/world"][100097], { time = 90 })
    instances["levels/instances/unique/chca/chca_heli_drop/world"][100060] = EHI:ClientCopyTrigger(instances["levels/instances/unique/chca/chca_heli_drop/world"][100097], { time = 20 })
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100027].client = { time = EHI:IsDifficulty(EHI.Difficulties.DeathSentence) and 90 or 60, random_time = 30 }
    instances["levels/instances/unique/sand/sand_helicopter_turret/world"][100024] = { id = "sand_TurretTimer", special_function = SF.RemoveTracker }
    instances["levels/instances/unique/pent/pent_meeting_room_door_thermite/world"][100036] = EHI:ClientCopyTrigger(instances["levels/instances/unique/pent/pent_meeting_room_door_thermite/world"][100035], { time = 22.5 * 2 })
    -- 100037 has 0s delay for some reason...
    instances["levels/instances/unique/pent/pent_meeting_room_door_thermite/world"][100038] = EHI:ClientCopyTrigger(instances["levels/instances/unique/pent/pent_meeting_room_door_thermite/world"][100035], { time = 22.5 })
end

local original =
{
    prepare_mission_data = CoreWorldInstanceManager.prepare_mission_data,
    prepare_unit_data = CoreWorldInstanceManager.prepare_unit_data,
    custom_create_instance = CoreWorldInstanceManager.custom_create_instance
}

local EHIConfig =
{
    mission_trackers = EHI:GetOption("show_mission_trackers"),
    show_waypoints = EHI:GetWaypointOption("show_waypoints_mission"),
    show_waypoints_only = EHI:GetWaypointOption("show_waypoints_only"),
    escape_waypoints = EHI:GetWaypointOption("show_waypoints_escape")
}

---@param instance CoreWorldInstanceManager.Instance
function CoreWorldInstanceManager:prepare_mission_data(instance, ...)
    local instance_data = original.prepare_mission_data(self, instance, ...)
    local folder = instance.folder
    if instances[folder] then
        local start_index = instance.start_index
        -- Don't compute the indexes again if the instance on this start_index has been computed already  
        -- `start_index` is unique for each instance in a heist, so this shouldn't break anything
        if not used_start_indexes[start_index] then
            local continent_data = managers.worlddefinition._continents[instance.continent]
            local triggers = {}
            local waypoints = {}
            local mission_waypoints = {}
            local defer_loading_waypoints = false
            for id, trigger in pairs(instances[folder]) do
                local final_index = EHI:GetInstanceElementID(id, start_index, continent_data.base_id)
                if trigger.create_tracker_class and EHIConfig.mission_trackers then
                    trigger.create_tracker_class()
                elseif trigger.add_runned_unit_sequence_trigger and EHIConfig.mission_trackers then
                    managers.mission:add_runned_unit_sequence_trigger(final_index, "interact", function(unit)
                        local time_random = trigger.time_random and math.rand(trigger.time_random) or 0
                        if not EHIConfig.show_waypoints_only then
                            managers.ehi_tracker:AddTracker({
                                id = tostring(final_index),
                                time = trigger.time + time_random,
                                icons = trigger.icons,
                                hint = trigger.hint,
                                class = trigger.class
                            })
                        end
                        if EHIConfig.show_waypoints then
                            managers.ehi_waypoint:AddWaypoint(tostring(final_index), {
                                time = trigger.time + time_random,
                                icon = trigger.icons[1],
                                position = managers.ehi_manager:GetUnitPositionOrDefault(final_index),
                                class = trigger.class and managers.ehi_manager.TrackerWaypointsClass[trigger.class]
                            })
                        end
                    end)
                elseif trigger.remove_vanilla_waypoint then
                    if trigger.mission then
                        mission_waypoints[final_index] = true
                    else
                        waypoints[final_index] = true
                    end
                else
                    local new_trigger = deep_clone(trigger)
                    if new_trigger.id then
                        new_trigger.id = new_trigger.id .. start_index
                    end
                    if trigger.element then
                        new_trigger.element = EHI:GetInstanceElementID(trigger.element, start_index, continent_data.base_id)
                    end
                    if trigger.waypoint then
                        if trigger.waypoint.position_by_element_and_remove_vanilla_waypoint then
                            local wp_id = EHI:GetInstanceElementID(trigger.waypoint.position_by_element_and_remove_vanilla_waypoint, start_index, continent_data.base_id)
                            new_trigger.waypoint.position_by_element = wp_id
                            new_trigger.waypoint.remove_vanilla_waypoint = wp_id
                            new_trigger.waypoint.position_by_element_and_remove_vanilla_waypoint = nil
                            defer_loading_waypoints = true
                        end
                        if trigger.waypoint.position_by_element then
                            new_trigger.waypoint.position_by_element = EHI:GetInstanceElementID(trigger.waypoint.position_by_element, start_index, continent_data.base_id)
                            defer_loading_waypoints = true
                        end
                        if trigger.waypoint.position_by_unit then
                            new_trigger.waypoint.position_by_unit = EHI:GetInstanceUnitID(trigger.waypoint.position_by_unit, start_index, continent_data.base_id)
                            defer_loading_waypoints = true
                        end
                        if trigger.waypoint.remove_vanilla_waypoint and not trigger.waypoint.remove_vanilla_waypoint_no_instance then
                            new_trigger.waypoint.remove_vanilla_waypoint = EHI:GetInstanceElementID(trigger.waypoint.remove_vanilla_waypoint, start_index, continent_data.base_id)
                        end
                    end
                    if trigger.special_function and trigger.special_function == SF.ShowWaypoint and trigger.data and trigger.data.position_by_element and EHIConfig.escape_waypoints then
                        new_trigger.data.position_by_element = EHI:GetInstanceElementID(trigger.data.position_by_element, start_index, continent_data.base_id)
                        defer_loading_waypoints = true
                    end
                    if trigger.element_ids then
                        for key, element_id in pairs(trigger.element_ids) do
                            new_trigger.element_ids[key] = EHI:GetInstanceElementID(element_id, start_index, continent_data.base_id)
                        end
                    end
                    triggers[final_index] = new_trigger
                end
            end
            EHI:ParseMissionInstanceTriggers(triggers, defer_loading_waypoints)
            if next(waypoints) then
                EHI:DisableWaypoints(waypoints)
            end
            if next(mission_waypoints) then
                EHI:DisableMissionWaypoints(mission_waypoints)
            end
            used_start_indexes[start_index] = true
        end
    end
    if debug_instance then
        EHI:Log("---------------SEPARATOR---------------")
        EHI:Log("Instance Folder: " .. tostring(folder))
        EHI:Log("Instance Start Index: " .. tostring(instance.start_index))
        EHI:Log("Instance Rotation: " .. tostring(instance.rotation))
    end
    return instance_data
end

local units = {}
---@param instance { folder: string, start_index: number, continent: string, rotation: Rotation }
---@param continent_data { base_id: number }
function CoreWorldInstanceManager:prepare_unit_data(instance, continent_data, ...)
    local instance_data = original.prepare_unit_data(self, instance, continent_data, ...)
    for _, entry in ipairs(instance_data.statics or {}) do
        local unit = units[entry.unit_data.name]
        if unit then
            local unit_data = deep_clone(unit)
            unit_data.instance = instance
            unit_data.continent_index = continent_data.base_id
            if unit.remove_vanilla_waypoint then
                unit_data.remove_vanilla_waypoint = EHI:GetInstanceElementID(unit.remove_vanilla_waypoint, instance.start_index, continent_data.base_id)
            end
            EHI._cache.InstanceUnits[entry.unit_data.unit_id] = unit_data
        end
    end
    return instance_data
end

function CoreWorldInstanceManager:custom_create_instance(instance_name, ...)
    original.custom_create_instance(self, instance_name, ...)
    local instance = self:get_instance_data_by_name(instance_name)
    if instance then
        managers.worlddefinition:OverrideUnitsInMissionPlacedInstance(instance)
        EHI:FinalizeUnits(EHI._cache.InstanceMissionUnits)
        EHI:FinalizeUnits(EHI._cache.InstanceUnits)
    end
end

EHI:HookWithID(CoreWorldInstanceManager, "init", "EHI_CoreWorldInstanceManager_init", function(...)
    units = tweak_data.ehi.units
end)