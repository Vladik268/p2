-----------------------------------------
---     Waypoints by gir489 v4.04     ---
-----------------------------------------
--Credits: zephirot for Waypoints - All In One v11.2.5.
--         Sirgoodsmoke for an updated version for MVP.
--
--Changelog:    v1.0: Initial Release
--              v1.1: Fixed cash bags on Miami Heat Day 1 being too dark to see.
--                    Fixed error showing in the console when using showHUDMessages = false
--              v1.2: Fixed crash related to showHUDMessages = false when finishing a job.
--              v1.3: Removed duplicate code block for 8th index since we're no longer doing that stupid nonsense. (Forgot to do this in 1.1 and 1.2)
--                    Added Murky Station waypoints.
--                    Refactored the way doors are shown as waypoints.
--                    Refactored thermite waypoint to be on every map.
--                    Added option to show where the camera computers were as a waypoint.
--                    Refactored redundant current_level_id calls with a local level variable.
--              v1.4: Refactored Add/Remove waypoint logic to use a look up table instead of a bunch of or statements.
--                    Fixed some Door waypoints not respecting showDoors.
--                    Added Aftershock waypoints.
--              v1.5: Refactored the entire project to use additive waypoints. This will reduce flicker and increase performance.
--              v1.6: Fixed keycards attached to Civilians not being removed.
--                    Removed unncessary for loop in remove_waypoint.
--                    Fixed some special events in remove_unit callback not properly refreshing.
--                    Fixed torch/thermite not showing if the civilian was frightened or cuffed.
--             v1.61: Reverted Civilian alive check since it didn't work.
--             v1.62: Fixed civilian keycard waypoint not working.
--             v1.63: Fixed civilian keycard waypoint not being removed properly when cuffing them.
--              v1.7: Added drills for the showDrills boolean.
--             v1.71: Fixed chems not working.
--             v1.72: Fixed dockyard causing a crash.
--              v1.8: Fixed Big Bank showing too many keyboards for the host.
--                    Fixed hard drive place location still showing on Murky Station after placing the hard drive.
--                    Fixed Framing Frame Day 3 waypoints not working properly.
--                    Added pig for slaughterhouse.
--              v1.9: Reduxed Alesso heist C4 waypoint in to an X icon where the doors are.
--                    Fixed remove_all_waypoints using a redundant waypoint member when it could've been using it from the for loop variables.
--              v2.0: Added door waypoint to Alesso heist instead of a cross that removes itself when you open the door.
--                    Added Counterfeit waypoints.
--                    Fixed spelling errors in the changelog.
--              v2.1: Added support to see the goats on Day 1 Goat Simulator heist if you are the host.
--            v2.1.1: Added support to see the goats on Day 1 Goat Simulator heist when the user is a client.
--              v2.2: Fixed garbage Meltdown waypoints from predecessor.
--                    Fixed a crash with Big Oil Day 2 when not the host.
--                    Added code to update the waypoint of a vehicle as it moves.
--                    Added more meaningful comments.
--              v2.3: Added support for Beneath The Mountain.
--                    Fixed some waypoints showing as money when they were mission items.
--                    Genericized some waypoints to only look for a partial name.
--              v2.4: Fixed carpet waypoint on Miami Heat Day 1.
--                    Genericized gas can waypoint.
--              v2.5: Fixed Miami Heat Day 1 showing the door and Big Bank showing the keyboard after it was relevant.
--                    Changed some crosshair icons to relevant icons.
--              v2.6: Added support to show where the voting machines for Election Day 2 are at the cost of everyone seeing them.
--                    Added sheaterNewb boolean which will let the user determine if they want to be risque with Goat Simulator/Election Day 2.
--                    Added comments next to the configuration booleans.
--                    Fixed some grammatical errors with the comments and change log.
--              v2.7: Removed The Diamond stepping stone waypoints since they didn't work at all for me.
--                    Refactored some of the logic to ignore ungrabbales from The Diamond.
--                    Fixed a crash when the user was the host on Big Oil Day 2 and they dropped the engine.
--             v2.71: Fixed a crash caused by dead units still being in the _interactive_units array.
--              v2.8: Added Gage Specops Cases and Keys to Gage Packages.
--                    Added support for BLT Mod Options configuration instead of relying on the user to edit the Lua file.
--                    Added waypoints for Stealing Xmas.
--                    Changed Planks to be orange instead of green.
--             v2.81: Added support for the Scarface Heist.
--             v2.82: Removed Big Oil Day 2 waypoints, because they were unreliable, even as host.
--             v2.83: Added giant toothbrush to the waypoints.
--             v2.84: Added waypoints for Heat Street.
--             v3.00: Refactored entity iteration to be more efficent and hopefully fix missing waypoints.
--                    Added waypoints for Green Bridge.
--                    Fixed keycard waypoints not being removed from attached civilians/guards when they RIP in spaghetti noodles microwaved for 10 minutes, then poured on the floor. #ThatsFuckingMetalDude #IRespectYouDawg
--                    Added sheaterNewb scenario for Firestarter day 2's boxes.
--                    Reworked all of the mission script-relevant waypoints as host to be removed once that mission item has been completed.
--                    Fixed Goat Simulator heist sheaterNewb scenario highlighting random boxes.
--                    Reworked Transport: Train Heist waypoints to use the hard drive icon for the location of valid drill spots, and to also not to show irrelevant camera computer positions.
--                    Reworked Hoxton Breakout Day 1 to show the correct keyboard for both host and client.
--             v3.01: Fixed nukes not being shown in Meltdown.
--                    Fixed some waypoints being shown in the incorrect location.
--             v3.10: Fixed a crash caused by using unit_data instead of interaction when assigning waypoint_id to the unit.
--             v3.15: Reworked cop/civ keycard code to not crash and to only remove the single cop/civ waypoint attached to the card dropped.
--                    Changed the locked doors waypoint icon to be less of an eyesore.
--                    Changed the ammo on train heist to use the ammo bag icon instead of the sentry icon.
--             v3.16: Fixed waypoints for First World Bank.
--             v3.17: Added support for BLT 2.
--             v3.18: Added fixes in MURKY STATION by [P3DHack]Vlad-00003
--             v3.19: Fixed a crash stemming from dead NPCs.
--             v3.20: Modernized waypoints to add more interactables for the current version of PAYDAY 2 v240.5.
--                    Removed iterative toggle, as it was depricated ages ago by enabling the user to determine what they want to see via config from Super BLT.
--                    Removed showHUDMessages.
--                    Added showSecretLoot and showLocks.
--                    Added debug variable, which will be implemented at a later date to assist in dumping map-specific information.
--              v4.0: Complete rewrite.
--             v4.01: Replaced legacy checks with Super BLT checks.
--                    Fixed pd2_nuke showing parts of the card.
--                    Added pd2_safe icon for pku_safe.
--                    Factored out some useless code.
--             v4.02: Factored out useless inHeist checks.
--                    Factored out civilian/guard keycard checks into a single IsHost check, rather than checking it O(N) times for each civilian and guard.
--             v4.03: Fixed flammable liquid sometimes showing the wrong entity on Breakfast in Tijuana.
--             v4.04: Finished implementing Mountain Master.

--Define various colors
local white = Color( 100, 255, 255, 255 ) / 255
local magenta = Color( 200, 255, 000, 255 ) / 255
local orange = Color( 200, 255, 094, 015 ) / 255
local gold = Color( 255, 255, 215, 000 ) / 255
local yellow = Color( 200, 255, 255, 000 ) / 255
local red = Color( 200, 255, 000, 000 ) / 255
local blood_red = Color( 200, 138, 017, 009 ) / 255
local blue = Color( 200, 000, 000, 255 ) / 255
local cobalt_blue = Color( 200, 000, 093, 199 ) / 255
local cyan = Color( 200, 000, 255, 255 ) / 255
local green = Color( 200, 000, 255, 000 ) / 255
local dark_green = Color( 200, 007, 061, 009 ) / 255

local level = managers.job:current_level_id()

function set_waypoint_color(waypoint, waypoint_id)
	-- BASE COLOR
	if waypoint_id:sub(1,10) == 'hudz_base_' or waypoint_id:sub(1,9) == 'hudz_car_' then
		waypoint.bitmap:set_color(white)
	end
	-- KEYCARD FLOOR
	if waypoint_id:sub(1,9) == 'hudz_key_' then
		waypoint.bitmap:set_color( yellow )
	end
	-- KEYCARD CIV
	if waypoint_id:sub(1,9) == 'hudz_civ_' then
		waypoint.bitmap:set_color( orange )
	end
	-- KEYCARD COP
	if waypoint_id:sub(1,9) == 'hudz_cop_' then
		waypoint.bitmap:set_color( cobalt_blue )
	end
	-- WEAPON
	if waypoint_id:sub(1,9) == 'hudz_wpn_' then
		waypoint.bitmap:set_color( magenta )
	end
	-- GOLD/JEWEL
	if waypoint_id:sub(1,10) == 'hudz_gold_' then
		waypoint.bitmap:set_color( gold )
	end
	-- SMALL LOOT
	if waypoint_id:sub(1,10) == 'hudz_cash_' then
		waypoint.bitmap:set_color( dark_green )
	end
	-- MONEY (BAG)
	if waypoint_id:sub(1,11) == 'hudz_cashB_' then
		waypoint.bitmap:set_color( green )
	end
	-- PAINTING
	if waypoint_id:sub(1,9) == 'hudz_ptn_' then
		waypoint.bitmap:set_color( green )
	end
	-- PACKAGE
	if waypoint_id:sub(1,10) == 'hudz_pkgY_' then
		waypoint.bitmap:set_color( yellow )
	elseif waypoint_id:sub(1,10) == 'hudz_pkgB_' then
		waypoint.bitmap:set_color( blue )
	elseif waypoint_id:sub(1,10) == 'hudz_pkgP_' then
		waypoint.bitmap:set_color( magenta )
	elseif waypoint_id:sub(1,10) == 'hudz_pkgR_' then
		waypoint.bitmap:set_color( red )
	elseif waypoint_id:sub(1,10) == 'hudz_pkgG_' then
		waypoint.bitmap:set_color( green )
	end
	if waypoint_id:sub(1,11) == 'hudz_drill_' then
		waypoint.bitmap:set_color( green )
	end
	-- PLANK
	if waypoint_id:sub(1,9) == 'hudz_plk_' then
		waypoint.bitmap:set_color( orange )
	end
	-- METHLAB
	if waypoint_id:sub(1,11) == 'hudz_coke1_' then
		waypoint.bitmap:set_color( white )
	elseif waypoint_id:sub(1,11) == 'hudz_coke2_' then
		waypoint.bitmap:set_color( green )
	elseif waypoint_id:sub(1,11) == 'hudz_coke3_' then
		waypoint.bitmap:set_color( yellow )
	end
	-- ATM
	if waypoint_id:sub(1,9) == 'hudz_atm_' then
		waypoint.bitmap:set_color( blood_red )
	end
	-- DOOR
	if waypoint_id:sub(1,10) == 'hudz_door_' then
		waypoint.bitmap:set_color( cyan )
	end
	if waypoint_id:sub(1,10) == 'hudz_Robj_' then
		waypoint.bitmap:set_color( green )
	end
end

function add_waypoint_npc(unit, prefab, appendage, icon)
	if (unit:unit_data()._waypoint_id == nil ) then
		local waypoint_id = prefab .. appendage
		local position = unit:movement():m_head_pos()
		unit:unit_data()._waypoint_id = waypoint_id
		managers.hud:add_waypoint( unit:unit_data()._waypoint_id, { icon = icon, distance = Waypoints.settings["showDistance"], position = position, no_sync = true,  present_timer = 0, state = "present", radius = 800, color = Color.orange, blend_mode = "add" }  )
		local waypoint = managers.hud._hud.waypoints[waypoint_id]
		if ( waypoint ) then
			waypoint.npc_unit = unit
			waypoint.move_speed = 0
			set_waypoint_color(waypoint, waypoint_id)
		end
	end
end

function add_waypoint(unit, prefab, appendage, icon)
	if ( unit:interaction()._waypoint_id == nil ) then
		local waypoint_id = prefab .. appendage
		local position = unit:interaction():interact_position()
		unit:interaction()._waypoint_id = waypoint_id
		managers.hud:add_waypoint( unit:interaction()._waypoint_id, { icon = icon, distance = Waypoints.settings["showDistance"], position = position, no_sync = true, present_timer = 0, state = "present", radius = 800, color = Color.white, blend_mode = "add" }  )
		local waypoint = managers.hud._hud.waypoints[waypoint_id]
		if ( waypoint ) then
			waypoint._unit = unit
			waypoint.move_speed = 0
			set_waypoint_color(waypoint, waypoint_id)
		end
	end
end

function remove_waypoint(unit)
	local waypoint_id = unit:interaction()._waypoint_id
	local waypoint = managers.hud._hud.waypoints[waypoint_id]
	if ( waypoint ) then
		waypoint._unit:interaction()._waypoint_id = nil
		managers.hud:remove_waypoint( waypoint_id )
	end
end

function remove_all_waypoints()
	for id,waypoint in pairs( managers.hud._hud.waypoints ) do
		id = tostring(id)
		if id:sub(1,5) == 'hudz_' then
			if ( waypoint._unit and waypoint._unit:interaction() ) then
				waypoint._unit:interaction()._waypoint_id = nil
			elseif ( alive(waypoint.npc_unit) and waypoint.npc_unit:unit_data() ) then
				waypoint.npc_unit:unit_data()._waypoint_id = nil
			end
			managers.hud:remove_waypoint( id )
		end
	end
end

function remove_associated_npc_waypoint(keycard_unit)
	for id, waypoint in pairs( managers.hud._hud.waypoints ) do
		local waypoint_id = tostring(id)
		if ( waypoint_id:sub(1,9) == 'hudz_civ_' or waypoint_id:sub(1,9) == 'hudz_cop_' ) then
			local position = keycard_unit:position() - waypoint.position
			if ( position:length() < 200 ) then
				managers.hud:remove_waypoint( id )
			end
		end
	end
end

function determine_waypoint(unit, key, force)
	local unit_name_idstring = tostring(unit:name())
	local tweak_data_string = (unit:interaction() ~= nil and (unit:interaction():active() or force)) and unit:interaction().tweak_data or nil
	if ( unit_name_idstring == "Idstring(@ID5422d8b99c7c1b57@)" or unit_name_idstring == "Idstring(@ID8a91392271626301@)" or  --Normal Keycard
		 unit_name_idstring == "Idstring(@ID7778a17af629d64c@)" --[[Keycard A]] or unit_name_idstring == "Idstring(@IDd05a7d53ca94e597@)" --[[Keycard B]] ) then 
		if ( force or (unit:interaction()._is_selected == nil and (unit:interaction():active() or level == 'dark')) ) then
			if level == 'roberts' and unit:position() == Vector3(250, 6750, -64.2354) then
			elseif level == 'big' and unit:position() == Vector3(3000, -3500, 949.99) then
			elseif level == 'firestarter_2' and unit:position() == Vector3(-1800, -3600, 400) then
			else
				add_waypoint(unit, 'hudz_key_', key, 'equipment_bank_manager_key')
			end
		end
	end
	if ( unit_name_idstring == "Idstring(@IDf9eec8f0e3dcf063@)" --[[Keyfob]] ) then
		add_waypoint(unit, 'hudz_key_', key, 'equipment_bank_manager_key')
	end
	if ( level == 'hox_1' ) then --HOXTON BREAKOUT DAY 1 BOLLARDS COMPUTER
		if ( unit_name_idstring == 'Idstring(@IDfc4ce94e587a7516@)' ) then
			local foundUnits = World:find_units_quick( "sphere", unit:position(), 200, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( foundUnits ) do
				if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == 'security_station_keyboard' ) then
					add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'interaction_keyboard')
				end
			end
		end
	elseif ( level == 'mia_1' and _missionId ) then --HOTLINE DAY 1 CARPETED DOOR
		if ( _missionId == 19 or _missionId < 6 ) then
			if (unit:interaction().tweak_data == "hlm_roll_carpet" ) then
				_carpetAlreadyFound = true
			end
			if ( unit_name_idstring == "Idstring(@ID0ff3ba27d5862ba2@)" and _carpetAlreadyFound == false ) then --Hatch
				local foundUnits = World:find_units_quick( "sphere", unit:position(), 200, managers.slot:get_mask("all") )
				for foundKey,foundUnit in ipairs( foundUnits ) do
					if ( tostring(foundUnit:name()) == "Idstring(@ID2c1e5738c0ad2f85@)") then --Door
						managers.hud:add_waypoint( 'hudz_base_hlm1door', { icon = 'pd2_door', distance = Waypoints.settings["showDistance"], position = foundUnit:position(), no_sync = true, present_timer = 0, state = "present", radius = 800, color = Color.white, blend_mode = "add" }  )
						local waypoint = managers.hud._hud.waypoints['hudz_base_hlm1door']
						waypoint.move_speed = 0
					end
				end
			end
		end
	elseif ( level == 'pbr' ) then --BENEETH THE MOUTIAN
		if ( unit_name_idstring == "Idstring(@IDf11234ccd3e2d814@)") then --Bars in front of the paintings
			local foundUnits = World:find_units_quick( "sphere", unit:position(), 200, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( foundUnits ) do
				if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "hold_take_painting" ) then
					add_waypoint(foundUnit, 'hudz_ptn_', foundKey, 'equipment_ticket')
				end
			end
		end
	elseif ( level == 'arena' ) then --ALLESO HEIST
		if ( unit_name_idstring == "Idstring(@IDcbae338a885f1432@)") then --X mark on the wall near the mission doors
			local foundUnits = World:find_units_quick( "sphere", unit:position(), 200, managers.slot:get_mask("all") )
			for _,foundUnit in ipairs( foundUnits ) do
				if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "pick_lock_hard_no_skill_deactivated" ) then
					if (foundUnit:interaction()._active == true) then
						add_waypoint(foundUnit, 'hudz_pkgR_', key, 'wp_door')
					end
				end
			end
		end
	elseif ( level == "dark" ) then --MURKY STATION
		if ( unit_name_idstring == "Idstring(@IDc93d932bbb0d9d13@)" ) then	 --Blow torch
			local foundUnits = World:find_units_quick( "sphere", unit:interaction():interact_position(), 100, managers.slot:get_mask("civilians") )
			for _,civilian in ipairs( foundUnits ) do
				if (civilian:brain() and civilian:brain():is_active()) then
					if ( unit:interaction()._is_selected == nil ) then
						add_waypoint(unit, 'hudz_base_', key, 'equipment_blow_torch')
					end
				end
			end
		end
		if ( unit_name_idstring == "Idstring(@ID29c64eba7ea1bb4f@)" ) then	 --Thermite
			local foundUnits = World:find_units_quick( "sphere", unit:interaction():interact_position(), 100, managers.slot:get_mask("civilians") )
			for _,civilian in ipairs( foundUnits ) do
				if (civilian:brain() and civilian:brain():is_active()) then
					if ( unit:interaction()._is_selected == nil ) then
						add_waypoint(unit, 'hudz_base_', key, 'equipment_thermite')
					end
				end
			end
		end
	elseif level == "ukrainian_job" then --UKRAINIAN JOB
		if unit_name_idstring == "Idstring(@ID077636ce1f33c8d0@)" --[[TIARA]] then
			add_waypoint(unit, 'hudz_Robj_', key, 'pd2_loot')
		end
	elseif ( level == 'shoutout_raid' ) then --MELTDOWN
		if ( unit_name_idstring == "Idstring(@IDaec3f706a76625a8@)" and _missionId < 5) then --Nukes
			add_waypoint(unit, 'hudz_pkgR_', key, 'pd2_nuke')
		end
	elseif ( level == 'pex' ) then --BREAKFAST IN TIJUANA
		if ( unit_name_idstring == "Idstring(@IDf7beae7fb86c90b9@)") then
			if unit:position() ~= Vector3(-2327, 3262, 100) then
				add_waypoint(unit, 'hudz_base_', key, 'pd2_lootdrop')
			end
		elseif ( unit_name_idstring == 'Idstring(@IDea1125db8a7d5673@)' ) then
			if managers.mission:script("default")._elements[103255]._values.enabled then
				if unit:position() == Vector3(-1925, 750, 202.255)  then
					add_waypoint(unit, 'hudz_fire_', key, 'equipment_flammable')
				end
			elseif managers.mission:script("default")._elements[103256]._values.enabled then
				if unit:position() == Vector3(-675, 1225, 202.5) then
					add_waypoint(unit, 'hudz_fire_', key, 'equipment_flammable')
				end
			elseif managers.mission:script("default")._elements[103257]._values.enabled then
				if unit:position() == Vector3(-1731, 2599, 249) then
					add_waypoint(unit, 'hudz_fire_', key, 'equipment_flammable')
				end
			elseif unit:position() == Vector3(-399.612, 2573.26, 192) then
				add_waypoint(unit, 'hudz_fire_', key, 'equipment_flammable')
			end
		elseif unit_name_idstring == 'Idstring(@ID6f9ec89e84b76f51@)' then
			add_waypoint(unit, 'hudz_pkgR_', key, 'equipment_boltcutter')
		elseif unit_name_idstring == 'Idstring(@ID2425d4cd99758856@)' then
			if managers.mission:script("default")._elements[101507]._values.enabled and unit:position() == Vector3(-1965.1, 2584.9, 576.407) then
				add_waypoint(unit, 'hudz_cop_', key, 'equipment_rfid_tag_01')
			elseif managers.mission:script("default")._elements[101638]._values.enabled and unit:position() == Vector3(-1958.66, 760.533, 552.612) then
				add_waypoint(unit, 'hudz_cop_', key, 'equipment_rfid_tag_01')
			elseif managers.mission:script("default")._elements[102505]._values.enabled and unit:position() == Vector3(796.822, 1656.55, 574.96) then
				add_waypoint(unit, 'hudz_cop_', key, 'equipment_rfid_tag_01')
			elseif managers.mission:script("default")._elements[102847]._values.enabled and unit:position() == Vector3(823, 1236, 601.485) then
				add_waypoint(unit, 'hudz_cop_', key, 'equipment_rfid_tag_01')
			end
		end
	elseif ( level == 'pent' ) then --MOUNTAIN MASTER
		if ( unit_name_idstring == "Idstring(@ID01ace2341fcad8db@)") then
			if managers.mission:script("default")._elements[102260]._values.enabled and tostring(unit:position()) == 'Vector3(-971.615, -2844.16, -350)' then
				add_waypoint(unit, 'hudz_pkgR_', 'pent_crowbar', 'equipment_crowbar')
			elseif managers.mission:script("default")._elements[102261]._values.enabled and tostring(unit:position()) == 'Vector3(-319.896, -2469.32, -350)' then
				add_waypoint(unit, 'hudz_pkgR_', 'pent_crowbar', 'equipment_crowbar')
			elseif managers.mission:script("default")._elements[102262]._values.enabled and tostring(unit:position()) == 'Vector3(300, -1825, -350)' then
				add_waypoint(unit, 'hudz_pkgR_', 'pent_crowbar', 'equipment_crowbar')
			end
		elseif ( unit_name_idstring == "Idstring(@ID1c90fc67cc07f86e@)") then
			add_waypoint(unit, 'hudz_key_', key, 'wp_powersupply')
		elseif ( unit_name_idstring == "Idstring(@IDe450c4ff634cecf3@)") then --sand_place_note/pent_chinese_notepad
			local foundUnits = World:find_units_quick( "sphere", unit:interaction():interact_position(), 600, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( foundUnits ) do
				if foundUnit:interaction() then
					if ( foundUnit:interaction().tweak_data == 'shelf_sliding_suburbia' ) then
						add_waypoint(foundUnit, 'hudz_door_', foundUnit:id(), 'wp_door')
					elseif ( foundUnit:interaction().tweak_data == 'sand_pickup_harddrive' ) then
						add_waypoint(foundUnit, 'hudz_base_', foundUnit:id(), 'equipment_harddrive')
					end
				end
			end
		elseif ( unit_name_idstring == "Idstring(@IDe6cb9c89de94273d@)") then
			local foundUnits = World:find_units_quick( "sphere", unit:interaction():interact_position(), 300, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( foundUnits ) do
				if foundUnit:interaction() then
					if ( foundUnit:interaction().tweak_data == 'timelock_panel' ) then
						add_waypoint(unit, 'hudz_gold_', key, 'interaction_gold')
					end
				end
			end
		elseif ( unit_name_idstring == "Idstring(@ID1b34b9c430eab610@)") then
			add_waypoint(unit, 'hudz_pkgR_', key, 'wp_door')
		end
	end
	if ( unit_name_idstring == "Idstring(@ID9c0e4f7e2193a163@)" ) then --Hard drive place point
		local foundUnits = World:find_units_quick( "sphere", unit:interaction():interact_position(), 35, managers.slot:get_mask("all") )
		for _,camera in ipairs( foundUnits ) do
			if ( camera:interaction() and camera:interaction():active() == true and camera:interaction().tweak_data == 'access_camera_y_axis' )then
				if (unit:interaction():active() == true) then
					add_waypoint(unit, 'hudz_door_', key, 'equipment_harddrive')
				end
			end
		end
	end
	if tweak_data_string ~= nil then --If the entity is an interactable entity.
		if ( level == "arm_for" ) then --TRAIN HEIST
			if tweak_data_string == 'take_ammo' then
				add_waypoint(unit, 'hudz_base_', key, 'equipment_ammo_bag')
			end
		end
		if level == "dark" and tweak_data_string == 'hold_open' then
			add_waypoint(unit, 'hudz_key_', key, 'pd2_computer')
		end
		if level == 'hox_2' then
			if tweak_data_string == 'firstaid_box' or tweak_data_string == 'invisible_interaction_open' then
				add_waypoint(unit, 'hudz_base_', key, 'equipment_doctor_bag')
			end
			if tweak_data_string == 'grenade_crate' or tweak_data_string == 'ammo_bag' then
				add_waypoint(unit, 'hudz_base_', key, 'equipment_ammo_bag')
			end
		elseif level == 'mad' then
			if tweak_data_string == 'gen_pku_body' then
				add_waypoint(unit, 'hudz_base_', key, 'wp_bag')
			end
		end
		if (tweak_data_string == 'take_keys') then
			add_waypoint(unit, 'hudz_key_', key, 'equipment_chavez_key')
		end
		if (tweak_data_string == 'rewire_electric_box' or tweak_data_string == 'hack_electric_box' or tweak_data_string == 'pick_lock_easy_no_skill_pent') then
			if ( unit:interaction():interact_position() ~= Vector3(6150, 549, -500) and unit_name_idstring ~= 'Idstring(@ID44ceafc05621d4a2@)' ) then --ATM Money
				add_waypoint(unit, 'hudz_base_', key, 'wp_powersupply')
			end
		end
		if Waypoints.settings["showGagePickups"] then
			if tweak_data_string == 'gage_assignment' then
				if not (level == 'hox_2' and unit:interaction():interact_position() == Vector3(-200, -200, 4102.5)) then
					if unit_name_idstring == "Idstring(@IDe8088e3bdae0ab9e@)" then
						add_waypoint(unit, 'hudz_pkgY_', key, 'interaction_christmas_present')
					elseif unit_name_idstring == "Idstring(@ID05956ff396f3c58e@)" then
						add_waypoint(unit, 'hudz_pkgB_', key, 'interaction_christmas_present')
					elseif unit_name_idstring == "Idstring(@IDc90378ad89058c7d@)" then
						add_waypoint(unit, 'hudz_pkgP_', key, 'interaction_christmas_present')
					elseif unit_name_idstring == "Idstring(@ID96504ebd40f8cf98@)" then
						add_waypoint(unit, 'hudz_pkgR_', key, 'interaction_christmas_present')
					elseif unit_name_idstring == "Idstring(@IDb3cc2abe1734636c@)" then
						add_waypoint(unit, 'hudz_pkgG_', key, 'interaction_christmas_present')
					else
						add_waypoint(unit, 'hudz_base_', key, 'interaction_christmas_present')
					end
				end
			end
			if tweak_data_string == 'pickup_case' then
				add_waypoint(unit, 'hudz_pkgP_', key, 'equipment_briefcase')
			end
			if tweak_data_string == 'pickup_keys' then
				add_waypoint(unit, 'hudz_pkgY_', key, 'wp_key')
			end
		end
		if Waypoints.settings["showDoors"] then
			if ( level ~= 'red2' ) then
				if (tweak_data_string == 'key' or tweak_data_string == 'key_double' or tweak_data_string == 'hold_close_keycard' or tweak_data_string == 'numpad_keycard' or tweak_data_string == 'timelock_panel' or tweak_data_string == 'hack_suburbia') then
					add_waypoint(unit, 'hudz_door_', key, 'icon_locked')
				end
			end
			if (tweak_data_string == 'open_train_cargo_door' or tweak_data_string == 'pick_lock_hard_no_skill_deactivated') then
				add_waypoint(unit, 'hudz_door_', key, 'wp_door')
			end
			if (tweak_data_string == 'glc_open_door' ) then
				add_waypoint(unit, 'hudz_door_', key, 'wp_door')
			end
		end
		if Waypoints.settings["showCameraComputers"] then
			if ( tweak_data_string == 'access_camera' or tweak_data_string == 'access_camera_y_axis' ) then
				if ( level == 'arm_for' ) then
					local badWallSearch = World:find_units_quick( "sphere", unit:interaction():interact_position(), 500, managers.slot:get_mask("all") )
					local foundBadWall = false
					for foundKey,foundUnit in ipairs(badWallSearch) do
						if ( tostring(foundUnit:name()) == 'Idstring(@ID0018274d196d8432@)' and foundUnit:rotation() == Rotation(90, -0, -0) ) then
							foundBadWall = true
						end
					end
					if ( foundBadWall == false ) then
						add_waypoint(unit, 'hudz_door_', key, 'pd2_computer')
					end
				elseif ( level == 'pent' ) then
					if unit:interaction()._interact_object ~= "rp_pent_int_window_cleaning_lift" then
						add_waypoint(unit, 'hudz_door_', key, 'pd2_computer')
					end
				else
					add_waypoint(unit, 'hudz_door_', key, 'pd2_computer')
				end
			end
		end
		if ( Waypoints.settings["showPlanks"] ) then
			if string.find(tweak_data_string, 'planks') or tweak_data_string == 'pickup_boards' then
				add_waypoint(unit, 'hudz_plk_', key, 'equipment_planks')
			end
		end
		if ( Waypoints.settings["showDrills"] ) then
			if tweak_data_string == 'drill' then
				add_waypoint(unit, 'hudz_drill_', key, 'pd2_drill')
			elseif (tweak_data_string == 'gen_int_saw') then
				add_waypoint(unit, 'hudz_base_', key, 'equipment_saw')
			end
		end
		if ( Waypoints.settings["showLocks"] ) then
			if unit_name_idstring == 'Idstring(@ID79991727a2679722@)' or unit_name_idstring == 'Idstring(@IDa95e021324bc842a@)'  then
				add_waypoint(unit, 'hudz_base_', key, 'icon_locked')
			end
		end
		if ( Waypoints.settings["showCrates"] ) then
			if string.find(tweak_data_string, 'crate_loot') or tweak_data_string == 'open_slash_close_act' then
				add_waypoint(unit, 'hudz_base_', key, 'pd2_lootdrop')
			end
		end
		if ( Waypoints.settings["showSecretLoot"] ) then
			if (tweak_data_string == 'press_pick_up' or tweak_data_string == 'ring_band' or tweak_data_string == 'pex_medal' or tweak_data_string == 'pick_up_item' or tweak_data_string == 'mex_pickup_murky_uniforms') then
				add_waypoint(unit, 'hudz_pkgG_', key, 'interaction_christmas_present')
			end
		end
		if ( Waypoints.settings["showSmallLoot"] ) then
			if tweak_data_string == 'money_wrap_single_bundle' then
				add_waypoint(unit, 'hudz_cash_', key, 'interaction_money_wrap')
			elseif tweak_data_string == 'cash_register' then
				if level == "jewelry_store" or level == "ukrainian_job" then
					if unit:position() ~= Vector3(1844, 665, 117.732) then
						add_waypoint(unit, 'hudz_cash_', key, 'interaction_money_wrap')
					end
				else
					add_waypoint(unit, 'hudz_cash_', key, 'interaction_money_wrap')
				end
			elseif tweak_data_string == 'money_small' then
				add_waypoint(unit, 'hudz_cashB_', key, 'interaction_money_wrap')
			elseif tweak_data_string == 'diamond_pickup' then
				add_waypoint(unit, 'hudz_gold_', key, 'interaction_diamond')
			elseif tweak_data_string == 'requires_ecm_jammer_atm' then
				add_waypoint(unit, 'hudz_atm_', key, 'equipment_ecm_jammer')
			elseif tweak_data_string == 'safe_loot_pickup' then
				if level == "family" then
					if unit:position().z < 1000 then	-- Vector3(1400, 100, 1100)
						add_waypoint(unit, 'hudz_cash_', key, 'interaction_money_wrap')
					end
				else
					add_waypoint(unit, 'hudz_cash_', key, 'interaction_money_wrap')
				end
			end
		end
		if Waypoints.settings["showSewerManhole"] then
			if tweak_data_string == 'sewer_manhole' then
				add_waypoint(unit, 'hudz_door_', key, 'interaction_open_door')
			end
		end						
		if Waypoints.settings["showThermite"] then
			if tweak_data_string == 'apply_thermite_paste' then
				add_waypoint(unit, 'hudz_fire_', key, 'equipment_thermite')
			end
		end
		
		--Switch table of interactables.
		if tweak_data_string == 'gold_pile' then
			if level == "welcome_to_the_jungle_1" then
				if unit:position() ~= Vector3(9200, -4400, 100) then
					add_waypoint(unit, 'hudz_gold_', key, 'interaction_gold')
				end
			else
				add_waypoint(unit, 'hudz_gold_', key, 'interaction_gold')
			end
		elseif tweak_data_string == 'money_wrap' or tweak_data_string == 'money_briefcase' then
			if level == "welcome_to_the_jungle_1" then
				if unit:position() ~= Vector3(9200, -4300, 100) then
					add_waypoint(unit, 'hudz_cashB_', key, 'equipment_money_bag')
				end
			elseif level == "family" then
				if unit:position() ~= Vector3(1400, 200, 1100) then
					add_waypoint(unit, 'hudz_cashB_', key, 'equipment_money_bag')
				end
			elseif level == "mia_1" then
				if unit:position() ~= Vector3(5400, 1400, -300) then
					add_waypoint(unit, 'hudz_cashB_', key, 'equipment_money_bag')
				end
			else
				add_waypoint(unit, 'hudz_cashB_', key, 'equipment_money_bag')
			end
		elseif tweak_data_string == 'weapon_case' then
			if ( level == "dark" ) then
				if ( unit_name_idstring == "Idstring(@ID86c151669b930ef0@)" or unit_name_idstring == "Idstring(@ID814d28338da0dcdc@)" ) then
					add_waypoint(unit, 'hudz_wpn_', key, 'hk21')
				else
					add_waypoint(unit, 'hudz_wpn_', key, 'glock')
				end
			else
				add_waypoint(unit, 'hudz_wpn_', key, 'ak')
			end
		elseif tweak_data_string == 'gen_pku_jewelry' then
			add_waypoint(unit, 'hudz_cashB_', key, 'wp_bag')
		elseif tweak_data_string == 'pku_toothbrush' then
			add_waypoint(unit, 'hudz_pkgR_', key, 'pd2_water_tap')
		elseif tweak_data_string == 'hold_take_painting' then
			add_waypoint(unit, 'hudz_ptn_', key, 'equipment_ticket')
		elseif tweak_data_string == 'use_computer' or tweak_data_string == 'mcm_laptop' then
			add_waypoint(unit, 'hudz_base_', key, 'laptop_objective')
		elseif tweak_data_string == 'pickup_phone' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_phone')
		elseif tweak_data_string == 'pickup_tablet' or tweak_data_string == 'sand_ipad' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_hack_ipad')
		elseif tweak_data_string == 'caustic_soda' then
			add_waypoint(unit, 'hudz_coke1_', key, 'pd2_methlab')
		elseif tweak_data_string == 'hydrogen_chloride' or tweak_data_string == 'hold_turn_off_gas' then
			add_waypoint(unit, 'hudz_coke2_', key, 'pd2_methlab')
		elseif tweak_data_string == 'muriatic_acid' then
			add_waypoint(unit, 'hudz_coke3_', key, 'pd2_methlab')
		elseif tweak_data_string == 'hold_pku_drk_bomb_part' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_nuke')
		elseif tweak_data_string == 'hold_pku_briefcase' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_briefcase')
		elseif tweak_data_string == 'hold_remove_hand' then
			add_waypoint(unit, 'hudz_cop_', key, 'equipment_hand')
		elseif (tweak_data_string == 'press_printer_ink') then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_printer_ink')
		elseif (tweak_data_string == 'press_printer_paper') then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_paper_roll')
		elseif tweak_data_string == 'hold_grab_goat' then
			add_waypoint(unit, 'hudz_cashB_', key, 'equipment_briefcase')
		elseif tweak_data_string == 'driving_drive' then
			add_waypoint(unit, 'hudz_car_', key, unit:interaction()._ray_object_names[6] ~= nil and 'pd2_car' or 'equipment_ejection_seat')
		elseif tweak_data_string == 'mcm_fbi_taperecorder' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_talk')
		elseif tweak_data_string == 'gen_pku_evidence_bag' or tweak_data_string == 'invisible_interaction_gathering' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_evidence')
		elseif tweak_data_string == 'hospital_security_cable' or tweak_data_string == 'security_cable_grey' or tweak_data_string == 'hack_suburbia_outline' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_wirecutter')
		elseif tweak_data_string == 'hospital_security_cable_red' then
			add_waypoint(unit, 'hudz_atm_', key, 'pd2_wirecutter')
		elseif tweak_data_string == 'hospital_security_cable_blue' then
			add_waypoint(unit, 'hudz_pkgB_', key, 'pd2_wirecutter')
		elseif tweak_data_string == 'hospital_security_cable_green' then
			add_waypoint(unit, 'hudz_pkgG_', key, 'pd2_wirecutter')
		elseif tweak_data_string == 'hospital_security_cable_yellow' then
			add_waypoint(unit, 'hudz_pkgY_', key, 'pd2_wirecutter')
		elseif tweak_data_string == 'mcm_break_planks' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_planks')
		elseif tweak_data_string == 'mcm_panicroom_keycard_1' or tweak_data_string == 'mcm_panicroom_keycard_2' or tweak_data_string == 'vit_keycard_use' or tweak_data_string == 'shelf_sliding_suburbia' then
			if level ~= 'pent' then
				add_waypoint(unit, 'hudz_door_', key, 'wp_powerbutton')
			end
		elseif tweak_data_string == 'take_chainsaw' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_chainsaw')
		elseif tweak_data_string == 'use_chainsaw' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_chainsaw')
		elseif tweak_data_string == 'hold_remove_ladder' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_ladder')
		elseif tweak_data_string == 'hold_open_xmas_present' or tweak_data_string == 'hold_take_vr_headset' then
			add_waypoint(unit, 'hudz_base_', key, 'interaction_christmas_present')
		elseif tweak_data_string == 'hold_open_shopping_bag' then
			add_waypoint(unit, 'hudz_base_', key, 'wp_bag')
		elseif tweak_data_string == 'hold_take_mask' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_chrome_mask')
		elseif tweak_data_string == 'gen_pku_sandwich' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_loot')
		elseif tweak_data_string == 'invisible_interaction_searching' then
			add_waypoint(unit, 'hudz_Robj_', key, 'equipment_files')
		elseif tweak_data_string == 'hold_download_keys' or tweak_data_string == 'security_station_keyboard' then
			add_waypoint(unit, 'hudz_base_', key, 'interaction_keyboard')
		elseif tweak_data_string == 'c4_bag' then
			add_waypoint(unit, 'hudz_key_', key, 'equipment_c4')
		elseif tweak_data_string == 'c4_mission_door' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_c4')
		elseif tweak_data_string == 'disassemble_turret' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_sentry')
		elseif tweak_data_string == 'take_confidential_folder_event' or tweak_data_string == 'take_confidential_folder' or tweak_data_string == 'hold_take_blueprints' or tweak_data_string == 'pickup_asset' then
			add_waypoint(unit, 'hudz_base_', key, 'interaction_patientfile')
		elseif tweak_data_string == 'hold_blow_torch' or tweak_data_string == 'gen_pku_blow_torch' then
			add_waypoint(unit, 'hudz_fire_', key, 'equipment_blow_torch')
		elseif tweak_data_string == 'hold_circle_cutter' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_cutter')
		elseif tweak_data_string == 'cut_glass' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_cutter')
		elseif tweak_data_string == 'votingmachine2' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_computer')
		elseif tweak_data_string == 'pku_safe' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_safe')
		elseif tweak_data_string == 'chas_tea_set' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_loot')
		elseif tweak_data_string == 'use_server_device' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_harddrive')
		elseif tweak_data_string == 'uload_database' then
			add_waypoint(unit, 'hudz_base_', key, 'pd2_computer')
		elseif tweak_data_string == 'pku_pig' then
			add_waypoint(unit, 'hudz_cashB_', key, 'equipment_briefcase')
		elseif tweak_data_string == 'mex_red_room_key' then
			add_waypoint(unit, 'hudz_key_', key, 'wp_key')
		elseif tweak_data_string == 'pickup_evidence_pex' or string.find(tweak_data_string, 'destroy_evidence') then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_evidence')
		elseif tweak_data_string == 'gen_pku_cocaine' or tweak_data_string == 'gen_pku_cocaine_pure' or tweak_data_string == 'friend_pku_yayo_cocaine' or tweak_data_string == 'gen_pku_cocaine_directional' or tweak_data_string == 'steal_methbag' or tweak_data_string == 'mex_pickup_meth_bag' then
			add_waypoint(unit, 'hudz_coke_', key, 'wp_vial')
		elseif tweak_data_string == 'gen_pku_crowbar' or tweak_data_string == 'gen_pku_crowbar_stack' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_crowbar')
		elseif tweak_data_string == 'pickup_police_uniform' then
			add_waypoint(unit, 'hudz_cop_', key, 'wp_bag')
		elseif tweak_data_string == 'gen_pku_artifact_painting' then
			if not (level == "mus" and unit:interaction()._interact_object == 'rp_mus_prop_roman_script_1') then --Extraneous painting that can't be grabbed on The Diamond.
				add_waypoint(unit, 'hudz_ptn_', key, 'equipment_ticket')
			end
		elseif tweak_data_string == 'gen_pku_artifact' or tweak_data_string == 'gen_pku_artifact_statue' or tweak_data_string == 'samurai_armor' or tweak_data_string == 'roman_armor' or tweak_data_string == 'chas_pku_dragon_statue' then
			if level ~= 'pent' then
				add_waypoint(unit, 'hudz_cashB_', key, 'wp_scrubs')
			end
		elseif string.find(tweak_data_string, 'server') or tweak_data_string == 'pickup_harddrive' then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_harddrive')
		elseif string.find(tweak_data_string, 'circuit') or tweak_data_string == 'hold_remove_cover' or tweak_data_string == 'hold_cut_cable' then
			add_waypoint(unit, 'hudz_base_', key, 'wp_powersupply')
		elseif string.find(tweak_data_string, 'gas') then
			add_waypoint(unit, 'hudz_fire_', key, 'equipment_thermite')
		elseif string.find(tweak_data_string, 'take_usb') then
			add_waypoint(unit, 'hudz_base_', key, 'equipment_usb_with_data')
		end
	end
end

--Setup custom icons for extra 420 dank memeage. (IF you know what I meme.)
if ( tweak_data.hud_icons.pd2_nuke == nil ) then
	tweak_data.hud_icons.pd2_nuke = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			55,
			71,
			18,
			38
		}
	}
	tweak_data.hud_icons.pd2_safe = {
		texture = "guis/textures/pd2/lootscreen/loot_cards",
		texture_rect = {
			547,
			50,
			57,
			77
		}
	}
	tweak_data.hud_icons.equipment_handcuffs = {
	texture = "guis/textures/hud_icons",
	texture_rect = {
		56,
		201,
		32,
		32
		}
	}
end

if not _render_waypoints then _render_waypoints = false end
_render_waypoints = not _render_waypoints

-- BEEP
if Input:keyboard():pressed() ~= nil then
	if Waypoints.settings["makeNoise"] then
		if managers and managers.menu_component then
			managers.menu_component:post_event("menu_enter")
		end
	end
end

--Do time-based code for the waypoints here.
managers.hud.__update_waypoints = managers.hud.__update_waypoints or managers.hud._update_waypoints
function HUDManager:_update_waypoints( t, dt )
	local result = self:__update_waypoints(t,dt)
	for id, data in pairs( self._hud.waypoints ) do
		if type(id) == 'string' then
			if ( id:sub(1,9) == 'hudz_car_' ) then
				data.position = data._unit:interaction():interact_position() --[[This will keep the waypoint on the vehicle]]
			end
			----------- FRAME COLORED WAYPOINTS ---------------
			-- COKE
			if id:sub(1,10) == 'hudz_coke_' then
				local LSD = Color(1,math.sin(140 * os.clock() + 0) / 2 + 0.5, math.sin(140 * os.clock() + 60) / 2 + 0.5, math.sin(140 * os.clock() + 120) / 2 + 0.5)
				data.bitmap:set_color( LSD )
			end
			-- THERMITE/GASCAN
			if id:sub(1,10) == 'hudz_fire_' then
				local FIRE = Color(1,math.sin(135 * os.clock() + 0) / 2 + 1.5, math.sin(140 * os.clock() + 60) / 2 + 0.5, 0)
				data.bitmap:set_color( FIRE )
			end
		end
	end
	return result
end

remove_all_waypoints()
if _render_waypoints then
	if ( _missionId == nil ) then
		_missionId = 0
	end
	for key,_ in pairs(managers.objectives:get_active_objectives()) do
		for numberMatch in key:gmatch("%d+") do --Only match last number in the string, which is usually the mission ID.
			_missionId = tonumber(numberMatch)
		end
	end
	if LuaNetworking:IsHost() then
		-- CIVS WITH KEYCARDS	
		for u_key, u_data in pairs(managers.enemy:all_civilians()) do
			if u_data.unit.contour and alive(u_data.unit) and u_data.unit:character_damage():pickup() then
				if (not u_data.unit:character_damage() or not u_data.unit:character_damage():dead()) then
					add_waypoint_npc( u_data.unit, 'hudz_civ_', u_data.unit:id(), level == "jolly" and 'equipment_briefcase' or 'equipment_bank_manager_key' )
				end
			end
		end
		-- COPS WITH KEYCARDS
		for u_key, u_data in pairs(managers.enemy:all_enemies()) do
			if u_data.unit.contour and alive(u_data.unit) and u_data.unit:character_damage():pickup() and u_data.unit:character_damage():pickup() ~= "ammo" then
				if (not u_data.unit:character_damage() or not u_data.unit:character_damage():dead()) then
					add_waypoint_npc( u_data.unit, 'hudz_cop_', u_data.unit:id(), 'equipment_bank_manager_key' )
				end
			end
		end
	end
	if Waypoints.settings["sheaterNewb"] then --https://youtu.be/4aEI0HEvgEQ
		if ( level == 'peta' ) then
			local mission_script = managers.mission:script("default")._elements[100673]
			if ( LuaNetworking:IsHost() ) then
				mission_script:on_executed(managers.player:player_unit())
			else
				managers.network:session():send_to_host("to_server_mission_element_trigger", mission_script:id(), nil)
			end
		end
		if ( level == 'election_day_2' ) then
			for _, script in pairs(managers.mission:scripts()) do
				for _,element in pairs(script:elements()) do
					local name = element:editor_name()
					if ( string.find(name, "voting_machine_crate_opened" ) ) then
						--This mission script has code to unhide the voting machines.
						if ( LuaNetworking:IsHost() ) then
							element:on_executed(managers.player:player_unit())
						else
							managers.network:session():send_to_host("to_server_mission_element_trigger", element:id(), managers.player:player_unit())
						end
					end
				end
			end
		end
		if level == "arm_for" then
			local vault1Search = World:find_units_quick( "sphere", Vector3(-1707, -1157, 667), 200, managers.slot:get_mask("all") )
			local found1 = false
			for foundKey,foundUnit in ipairs( vault1Search ) do
				if ( tostring(foundUnit:name()) == 'Idstring(@ID0018274d196d8432@)' and foundUnit:rotation() == Rotation(90, -0, -0) ) then
					found1 = true
				end
			end
			local locationToSearch1 = found1 == false and Vector3(-1707, -1157, 667) or Vector3(-2710, -1152, 666)
			vault1Search = World:find_units_quick( "sphere", locationToSearch1, 200, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( vault1Search ) do
				if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == 'pickup_harddrive' ) then
					add_waypoint(foundUnit, 'hudz_Robj_', 'vault1', 'equipment_harddrive')
				end
			end
			local vault2Search = World:find_units_quick( "sphere", Vector3(-192, -1152, 668), 200, managers.slot:get_mask("all") )
			local found2 = false
			for foundKey,foundUnit in ipairs( vault2Search ) do
				if ( tostring(foundUnit:name()) == 'Idstring(@ID0018274d196d8432@)' and foundUnit:rotation() == Rotation(90, -0, -0) ) then
					found2 = true
				end
			end
			local locationToSearch2 = found2 == false and Vector3(-192, -1152, 668) or Vector3(794, -1161, 668)
			vault2Search = World:find_units_quick( "sphere", locationToSearch2, 200, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( vault2Search ) do
				if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == 'pickup_harddrive' ) then
					add_waypoint(foundUnit, 'hudz_Robj_', 'vault2', 'equipment_harddrive')
				end
			end
			local vault3Search = World:find_units_quick( "sphere", Vector3(2291, -1155, 667), 200, managers.slot:get_mask("all") )
			local found3 = false
			for foundKey,foundUnit in ipairs( vault3Search ) do
				if ( tostring(foundUnit:name()) == 'Idstring(@ID0018274d196d8432@)' and foundUnit:rotation() == Rotation(90, -0, -0) ) then
					found3 = true
				end
			end
			local locationToSearch3 = found3 == false and Vector3(2291, -1155, 667) or Vector3(3308, -1151, 667)
			vault3Search = World:find_units_quick( "sphere", locationToSearch3, 200, managers.slot:get_mask("all") )
			for foundKey,foundUnit in ipairs( vault3Search ) do
				if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == 'pickup_harddrive' ) then
					add_waypoint(foundUnit, 'hudz_Robj_', 'vault3', 'equipment_harddrive')
				end
			end
		end
		if LuaNetworking:IsHost() then --Host only access mission script waypoints.
			if level == 'framing_frame_3' then
				local serverVectors = { ["105507"] = Vector3(-3937.26, 5644.73, 3474.5),["105508"] = Vector3(-3169.57, 4563.03, 3074.5), ["100650"] = Vector3(-4920, 3737, 3074.5) }
				local serverId = tostring(managers.mission:script("default")._elements[105506]._values.on_executed[1].id)
				local foundUnits = World:find_units_quick( "sphere", serverVectors[serverId], 100, managers.slot:get_mask("all") )
				for foundKey,foundUnit in ipairs( foundUnits ) do
					if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "big_computer_hackable" ) then
						add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'interaction_keyboard')
					end
				end
			end
			if level == 'cage' then -- CAR SHOP
				local keyboardVectors = { ["104797"] = Vector3(2465.98, 660.75, -149.996), ["104804"] = Vector3(2615.98, 660.75, -149.996), ["104811"] = Vector3(2890.98, 660.75, -149.996), ["104818"] = Vector3(3040.98, 660.75, -149.996), ["104826"] = Vector3(3045.98, 405.75, -149.996), ["104833"] = Vector3(2887.98, 407.75, -149.996), ["104841"] = Vector3(2615.98, 410.75, -149.996), ["104848"] = Vector3(2465.98, 407.75, -149.996), ["104857"] = Vector3(1077.98, 255.751, 250.004), ["104866"] = Vector3(924.978, 255.75, 250.004), ["104873"] = Vector3(617.978, 255.75, 250.004), ["104880"] = Vector3(468.978, 255.749, 250.004), ["104887"] = Vector3(423.024, 142.249, 250.004), ["104899"] = Vector3(590.024, 142.25, 250.004), ["104907"] = Vector3(880.024, 142.25, 250.004), ["104919"] = Vector3(1049.02, 142.251, 250.004), ["104927"] = Vector3(254.75, -1490.98, 249.503) }
				local keyboardId = tostring(managers.mission:script("default")._elements[104929]._values.on_executed[1].id)
				local foundUnits = World:find_units_quick( "sphere", keyboardVectors[keyboardId], 100, managers.slot:get_mask("all") )
				for foundKey,foundUnit in ipairs( foundUnits ) do
					if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "security_station_keyboard" and (_missionId < 5 or foundUnit:interaction()._active == true) ) then
						add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'interaction_keyboard')
					end
				end
			end
			if level == 'big' and _missionId and (_missionId == 28 or _missionId < 4) then
				local big1 = tostring(managers.mission:script("default")._elements[103246]._values.on_executed[1].id)
				local stfcmpts = { ["103250"] = Vector3(2754, 1420, -923), ["103229"] = Vector3(2083, 1412, -922.772), ["103569"] = Vector3(1941, 1345, -922.772), ["103604"] = Vector3(1589, 1419, -922.772), ["103647"] = Vector3(2558, 1847, -922.772), ["103709"] = Vector3(2448.08, 1849.07, -922.772), ["103749"] = Vector3(1859.2, 1832.25, -922.772), ["103788"] = Vector3(1732, 1812, -923), ["103898"] = Vector3(1090, 1220, -522.772), ["103916"] = Vector3(1293.46, 1221.04, -522.772), ["103927"] = Vector3(1909, 1389, -522.762), ["103948"] = Vector3(1917.69, 1583.79, -522.762), ["103966"] = Vector3(2318, 1608, -522.762), ["103984"] = Vector3(2319.79, 1407.8, -522.762), ["104006"] = Vector3(2716, 1220, -522.772), ["104024"] = Vector3(2895.76, 1782.56, -522.772), ["104042"] = Vector3(2922, 1218.89, -522.772), ["104080"] = nil, ["104127"] = nil, ["104315"] = nil }
				if tostring(stfcmpts[big1]) ~= 'nil' then
					local foundUnits = World:find_units_quick( "sphere", stfcmpts[big1], 100, managers.slot:get_mask("all") )
					for foundKey,foundUnit in ipairs( foundUnits ) do
						if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "big_computer_hackable" ) then
							add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'interaction_keyboard')
						end
					end
				end
			end
			if level == 'firestarter_2' and managers.groupai:state():whisper_mode() then
				local bo_boxes = { ["105819"] = Vector3(-2710, -2830, 552), ["105794"] = Vector3(-1840, -3195, 552), ["105810"] = Vector3(-1540, -2195, 552), ["105824"] = Vector3(-1005, -3365, 552), ["105837"] = Vector3(-635, -1705, 552), ["105851"] = Vector3(-1095, -210, 152), ["106183"] = Vector3(-1230, 1510, 152), ["106529"] = Vector3(-1415, -795, 152), ["106543"] = Vector3(-1160, 395, 152), ["106556"] = Vector3(-5, 735, 152),  ["106594"] = Vector3(795, -898, 552), ["106607"] = Vector3(795, -3240, 552), ["106620"] = Vector3(1060, -2195, 552), ["106633"] = Vector3(204, 540, 578), ["106646"] = Vector3(-1085, -1205, 552), ["106659"] = Vector3(-2135, 395, 552), ["106672"] = Vector3(-2405, -840, 552), ["106685"] = Vector3(-2005, -1640, 552), ["106698"] = Vector3(-2715, -1595, 552), ["106711"] = Vector3(-500, -650, 1300), ["106724"] = Vector3(-400, -650, 1300), ["106737"] = Vector3(-300, -650, 1300), ["106750"] = Vector3(-200, -650, 1300), ["106763"] = Vector3(-100, -650, 1300), ["106776"] = Vector3(-635, -1205, 152), ["106789"] = Vector3(-1040, -95, 552), ["106802"] = Vector3(615, 395, 152), ["106815"] = Vector3(1890, -1805, 152), ["106828"] = Vector3(215, -1805, 152) }
				local SecBox1 = tostring(managers.mission:script("default")._elements[106836]._values.on_executed[1].id)
				local SecBox2 = tostring(managers.mission:script("default")._elements[106836]._values.on_executed[2].id)
				local foundUnits = World:find_units_quick( "sphere", bo_boxes[SecBox1], 100, managers.slot:get_mask("all") )
				for foundKey,foundUnit in ipairs( foundUnits ) do
					if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "hospital_security_cable" ) then
						add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'pd2_wirecutter')
					end
				end
				foundUnits = World:find_units_quick( "sphere", bo_boxes[SecBox2], 100, managers.slot:get_mask("all") )
				for foundKey,foundUnit in ipairs( foundUnits ) do
					if ( foundUnit:interaction() and foundUnit:interaction().tweak_data == "hospital_security_cable" ) then
						add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'pd2_wirecutter')
					end
				end
			end
			if level == 'election_day_1' then
				managers.network:session():send_to_host("to_server_mission_element_trigger", mission_script:id(), nil)
				local truck_vectors = { ["100636"] = Vector3(150, -3900, 0), ["100633"] = Vector3(878.392, -3360.24, 0), ["100637"] = Vector3(149.999, -2775, 0), ["100634"] = Vector3(828.07, -2222.45, 0), ["100639"] = Vector3(149.998, -1625, 0), ["100635"] = Vector3(848.961, -1084.9, 0) }
				local truckv = tostring(managers.mission:script("default")._elements[100631]._values.on_executed[1].id) --pickTruck
				local foundUnits = World:find_units_quick( "sphere", truck_vectors[truckv], 100, managers.slot:get_mask("all") )
				for foundKey,foundUnit in ipairs( foundUnits ) do
					if ( foundUnit:interaction() and foundUnit:interaction():active() and foundUnit:interaction().tweak_data == "hold_place_gps_tracker" ) then
						add_waypoint(foundUnit, 'hudz_Robj_', foundKey, 'equipment_ecm_jammer')
					end
				end
			end
		elseif level == 'firestarter_2' and managers.groupai:state():whisper_mode() then
			managers.network:session():send_to_host("to_server_mission_element_trigger", 103514, managers.player:player_unit())
		end
	end
	for key, unit in ipairs( World:find_units_quick( "all" ) ) do --Main loop
		determine_waypoint(unit, key, false)
	end
end

--This function is called when an item is removed from the session.
managers.interaction._remove_unit = managers.interaction._remove_unit or managers.interaction.remove_unit
function ObjectInteractionManager:remove_unit( unit )
	local result = self:_remove_unit(unit)
	
	if game_state_machine:current_state_name() == "victoryscreen" or game_state_machine:current_state_name() == "gameoverscreen" then
		_render_waypoints = false
		return result
	end
	
	if ( unit:interaction()._waypoint_id ~= nil ) then
		remove_waypoint(unit)
	end

	return result
end

managers.interaction._add_unit = managers.interaction._add_unit or managers.interaction.add_unit
function ObjectInteractionManager:add_unit( unit )
	local spawned = unit:interaction().tweak_data
	local result = self:_add_unit(unit)
	local level = managers.job:current_level_id()
	
	if not unit:unit_data() then --Discard mission waypoint callbacks.
		return result
	end
	
	if ( spawned == "hostage_move" or spawned == "intimidate" ) then
		return result
	end
	
	if spawned == "hlm_roll_carpet" then
		managers.hud:remove_waypoint( "hudz_base_hlm1door" )
		return result
	end
	
	-- KEYCARD COP/CIV : REMOVE WAYPOINT OF THE UNIT WHEN KEYCARD IS DROPPED
	if spawned == 'pickup_keycard' or spawned == 'hold_pku_knife' or spawned == 'sfm_take_usb_key' or spawned == 'corp_key_fob' then
		remove_associated_npc_waypoint(unit)
	end
	
	--log(spawned)
	
	determine_waypoint(unit, unit:id(), true)
	
	return result
end