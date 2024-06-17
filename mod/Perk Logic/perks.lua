local loc = _G["g_stoic_logic_and_kingpin_auto_injector_loc"]

--leech
local auto_use_leech_ampule = loc.config.auto_use_leech_ampule					-- set to true/false

--kingpin
local auto_use_king_injector = loc.config.auto_use_king_injector				--set to true to auto use kingpin injector

--stoic
local auto_use_stoic_flash = loc.config.auto_use_stoic_flash 					--auto uses stoic flask at 45% of remaining armor when damage over time is active
local damage_over_time_percentage = loc.config.damage_over_time_percentage		--percentage of when flask will be used. Lower meaning later flask use value between 0 and 1
local prevent_miss_press = loc.config.prevent_miss_press						--set to true so you cant use stoic flask when damage over time is not active
local use_armor_for_Stoic = loc.config.use_armor_for_Stoic						--set this to true to use armor for stoic or false to use health

--both
local bullseye_restore_health = loc.config.bullseye_restore_health				--set to true, to regen health instead of armor from the bullseye skill
local bullseye_restore_percentage = loc.config.bullseye_restore_percentage





-------------------------------------------------------------
-- CODE
-------------------------------------------------------------

local req_script = table.remove(RequiredScript:split("/"))
if string.lower(req_script) == string.lower("copbrain") or string.lower(req_script) == string.lower("huskcopbrain") then
	--leech
	local function try_leech()
		if auto_use_leech_ampule and managers.player:has_category_upgrade("player", "copr_kill_life_leech") and managers.player:can_throw_grenade() then
			managers.player:attempt_ability("copr_ability")
		end
	end

	if CopBrain then
		local orig_func_clbk_death = CopBrain.clbk_death
		function CopBrain:clbk_death(...)
			try_leech(); orig_func_clbk_death(self, ...)
		end
	end
	
	if HuskCopBrain then
		local orig_func_HuskCopBrain = HuskCopBrain.clbk_death
		function HuskCopBrain:clbk_death(...)
			try_leech(); orig_func_HuskCopBrain(self, ...)
		end
	end
elseif string.lower(req_script) == string.lower("PlayerManager") then
	--kingpin and stoic
	function PlayerManager:on_headshot_dealt()
		local player_unit = self:player_unit()

		if not player_unit then
			return
		end

		local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
		local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")
		
		if is_downed or swan_song_active then
			return
		end

		self._message_system:notify(Message.OnHeadShot, nil, nil)

		local t = Application:time()

		if self._on_headshot_dealt_t and t < self._on_headshot_dealt_t then
			return
		end

		self._on_headshot_dealt_t = t + (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)
		local damage_ext = player_unit:character_damage()
		local regen_armor_bonus = managers.player:upgrade_value("player", "headshot_regen_armor_bonus", 0)

		if damage_ext and regen_armor_bonus > 0 then
			if bullseye_restore_health and (managers.player:has_category_upgrade("temporary", "chico_injector") or (managers.player:has_category_upgrade("player", "damage_control_passive") and not use_armor_for_Stoic) or managers.player:has_category_upgrade("player", "copr_kill_life_leech")) then
				local max_health = damage_ext:_max_health()
				local health = damage_ext:get_real_health()
				local new_regen = (regen_armor_bonus > 0.5) and bullseye_restore_percentage * regen_armor_bonus or regen_armor_bonus
				local new_health = math.min(health + new_regen, max_health)

				damage_ext:_check_update_max_health()
				damage_ext:set_health(new_health)
			else
				damage_ext:restore_armor(regen_armor_bonus)
			end
		end
	end
	
	--stoic
	local orig_func_attempt_ability = PlayerManager.attempt_ability
	function PlayerManager:attempt_ability(...)
		local remaining = managers.player:player_unit():character_damage():remaining_delayed_damage()
		if not prevent_miss_press or not managers.player:has_category_upgrade("player", "damage_control_passive") or remaining > 0 then
			orig_func_attempt_ability(self, ...)
		end
	end
elseif string.lower(req_script) == string.lower("PlayerDamage") then
	--kingpin
	local fov_width = 2
	local distance = 10000
	local function enemies_in_unit_camera_range(player_unit, max_count)
		local count = 0
		for _, unit in pairs(max_count > 0 and World:find_units("camera_cone", player_unit:camera():camera_object(), Vector3(0, 0), fov_width, distance, World:make_slot_mask(12, 33)) or {}) do
			count = count + 1
			local obstructed = unit:raycast("ray", unit:position(), player_unit:camera():position(), "slot_mask", managers.slot:get_mask("world_geometry", "vehicles"))
			if obstructed then
				count = count - 1
			end
		end
		return max_count > 0 and count >= max_count and count or max_count == 0 and true or false
    end

	local orig_func_send_damage_drama = PlayerDamage._send_damage_drama
	function PlayerDamage:_send_damage_drama(...)
		if self._unit == managers.player:player_unit() and managers.player:has_category_upgrade("temporary", "chico_injector") and auto_use_king_injector and enemies_in_unit_camera_range(self._unit, tonumber(loc.config.enemies_in_unit_camera_range)) then
			local armor_broken = self:_max_armor() > 0 and self:get_real_armor() <= 0
			local half_life = self:get_real_health() <= (loc.config.kingpin_health_activation_percentage * self:_max_health())
			if half_life and armor_broken and managers.player:can_throw_grenade() then
				managers.player:attempt_ability("chico_injector")
			end
		end
		orig_func_send_damage_drama(self, ...)
	end
	
	--stoic
	local orig_func_max_armor = PlayerDamage._max_armor
	function PlayerDamage:_max_armor(...)
		if use_armor_for_Stoic then
			local max_armor = self:_raw_max_armor()
			if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
				pre_max_health = self:_raw_max_health() + max_armor
				max_armor = pre_max_health
			end

			return max_armor
		end
		return orig_func_max_armor(self, ...)
	end

	local orig_func_max_health = PlayerDamage._max_health
	local stack = false
	function PlayerDamage:_max_health(...)
		if use_armor_for_Stoic then
			local max_health = self:_raw_max_health()
			if not stack and managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
				stack = true
				max_health = 0.000001
				self._max_health_reduction = 0.000001
				self:set_health(Application:digest_value(self._health, false))
			end

			return max_health
		end
		return orig_func_max_health(self, ...) 
	end
elseif string.lower(req_script) == string.lower("LocalizationManager") then
	--stoic
	local orig_func_LocalizationManager_init = LocalizationManager.init
	function LocalizationManager:init(...)
		orig_func_LocalizationManager_init(self, ...)
		if use_armor_for_Stoic then
			LocalizationManager:add_localized_strings({
				["menu_deck19_3_desc"] = "All of your health is converted and applied to your armor.",
				["menu_deck19_9_desc"] = "When damage-over-time is removed you will be gaining armor for additional ##50%## of the damage-over-time remaining at that point.",
			})
		end
	end
elseif string.lower(req_script) == string.lower("playeractiondamagecontrol") then
	--stoic
	local stoic_cooldown, stoic_data = 6, {average_tb = {1}, average_kills = 0, kills = 0}
	local average_kills_by_time = stoic_cooldown

	PlayerAction.DamageControl = {
		Priority = 1,
		Function = function ()
			local timer = TimerManager:game()
			local auto_shrug_time = nil
			local cooldown_drain = managers.player:upgrade_value("player", "damage_control_cooldown_drain")
			local damage_delay_values = managers.player:has_category_upgrade("player", "damage_control_passive") and managers.player:upgrade_value("player", "damage_control_passive")
			local auto_shrug_delay = managers.player:has_category_upgrade("player", "damage_control_auto_shrug") and managers.player:upgrade_value("player", "damage_control_auto_shrug")
			local shrug_healing = managers.player:has_category_upgrade("player", "damage_control_healing") and managers.player:upgrade_value("player", "damage_control_healing") * 0.01

			if not damage_delay_values then
				return
			end

			damage_delay_values = {
				delay_ratio = damage_delay_values[1] * 0.01,
				tick_ratio = damage_delay_values[2] * 0.01
			}
			cooldown_drain = {
				health_ratio = cooldown_drain[1] * 0.01,
				seconds_below = cooldown_drain[2],
				seconds_above = managers.player:upgrade_value_by_level("player", "damage_control_cooldown_drain", 1)[2]
			}

			local function shrug_off_damage()
				local player_unit = managers.player:player_unit()

				if player_unit then
					local player_damage = player_unit:character_damage()
					local remaining_damage = player_damage:clear_delayed_damage()
					local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)
					local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

					if is_downed or swan_song_active then
						return
					end
					
					if shrug_healing then
						if use_armor_for_Stoic then
							player_damage:restore_armor(remaining_damage * shrug_healing, true)
						else
							player_damage:restore_health(remaining_damage * shrug_healing, true)
						end
					end
				end

				auto_shrug_time = nil
			end

			local function modify_damage_taken(amount, attack_data)
				local is_downed = game_state_machine:verify_game_state(GameStateFilters.downed)

				if attack_data.variant == "delayed_tick" or is_downed then
					return
				end

				local player_unit = managers.player:player_unit()
				local player_damage = player_unit:character_damage()
				local removed = amount * damage_delay_values.delay_ratio
				local duration = 1 / damage_delay_values.tick_ratio
				local remaining = player_damage:remaining_delayed_damage()
				local health_percentage = damage_over_time_percentage * (use_armor_for_Stoic and player_damage:get_real_armor() or player_damage:get_real_health())
				
				if auto_use_stoic_flash then
					if managers.player:can_throw_grenade() then
						stoic_data.start_time = timer:time()
						local mission_listener = managers.mission._global_event_listener
						
						if mission_listener and mission_listener._listener_keys and not mission_listener._listener_keys["average_kills_within_stoic_cooldown"] then
							managers.mission:add_global_event_listener("average_kills_within_stoic_cooldown", "enemy_killed", function()
								average_kills_by_time = stoic_cooldown - math.min(stoic_data.kills, stoic_cooldown)

								if (timer:time() - stoic_data.start_time) <= stoic_cooldown then
									stoic_data.kills = stoic_data.kills + 1
								end
							end)
						end

						local kill_count = 0

						for _, kills in pairs(stoic_data.average_tb) do
							kill_count = kill_count + kills
						end

						stoic_data.average_kills = kill_count / #stoic_data.average_tb

						if (stoic_data.average_kills >= average_kills_by_time or remaining >= health_percentage) then
							managers.player:attempt_ability("damage_control")
							table.insert(stoic_data.average_tb, stoic_data.kills)
							stoic_data.kills = 0
						end
					end
				end

				player_damage:delay_damage(removed, duration)

				if auto_shrug_delay then
					auto_shrug_time = timer:time() + auto_shrug_delay
				end

				return -removed
			end

			local function on_ability_activated(ability_name)
				if ability_name == "damage_control" then
					shrug_off_damage()
				end
			end

			local function on_enemy_killed(weapon_unit, variant, enemy_unit)
				local player = managers.player:player_unit()
				local low_health = player:character_damage():health_ratio() <= cooldown_drain.health_ratio
				local seconds = low_health and cooldown_drain.seconds_below or cooldown_drain.seconds_above

				if player then
					managers.player:speed_up_grenade_cooldown(seconds)
				end
			end

			local on_check_skills_key = {}
			local on_enemy_killed_key = {}
			local on_ability_activated_key = {}

			managers.player:register_message(Message.OnEnemyKilled, on_enemy_killed_key, on_enemy_killed)
			managers.player:register_message("ability_activated", on_ability_activated_key, on_ability_activated)

			local damage_taken_key = managers.player:add_modifier("damage_taken", modify_damage_taken)

			local function remove_listeners()
				managers.player:unregister_message("check_skills", on_check_skills_key)
				managers.player:unregister_message(Message.OnEnemyKilled, on_enemy_killed_key)
				managers.player:unregister_message("ability_activated", on_ability_activated_key)
				managers.player:remove_modifier("damage_taken", damage_taken_key)
			end

			managers.player:register_message("check_skills", on_check_skills_key, remove_listeners)

			while true do
				coroutine.yield()

				local now = timer:time()
				stoic_data.start_time = timer:time() -- might function a tad better including it here too

				if auto_shrug_time and auto_shrug_time <= now then
					shrug_off_damage()
				end
			end
		end
	}
end