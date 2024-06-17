-- I'm using this to enforce the custom correct nade max amounts if you are the client or host without having to worry about the spoofed outfit_string
local VPPP_PlayerManager_get_max_grenades_by_peer_id = PlayerManager.get_max_grenades_by_peer_id
function PlayerManager:get_max_grenades_by_peer_id(peer_id)
	local peer = managers.network:session() and managers.network:session():peer(peer_id)
	local is_local_player = managers.network:session():local_peer() == peer
	if is_local_player then
		return self:get_max_grenades()
	end
	return VPPP_PlayerManager_get_max_grenades_by_peer_id(self, peer_id)
end

local VPPP_PlayerManager_attempt_ability = PlayerManager.attempt_ability
function PlayerManager:attempt_ability(ability)
	if managers.blackmarket:equipped_grenade() == "auto_inject_super_stimpak" then
		-- Sadly I had to duplicated the code to allow the usage of abilities when downed
		-- If you read this and know how to avoid it, PLEASE tell me how
		-- I was thinking about the function override used in Beardlib fixes, to override game_state_machine:verify_game_state but I'm unsure
		if not self:player_unit() then
			return
		end
	
		local local_peer_id = managers.network:session():local_peer():id()
		local has_no_grenades = self:get_grenade_amount(local_peer_id) == 0
		local is_downed = false
		local swan_song_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")
	
		if has_no_grenades or is_downed or swan_song_active then
			return
		end
	
		local attempt_func = self["_attempt_" .. ability]
	
		if attempt_func and not attempt_func(self) then
			return
		end
	
		local tweak = tweak_data.blackmarket.projectiles[ability]
	
		if tweak and tweak.sounds and tweak.sounds.activate then
			self:player_unit():sound():play(tweak.sounds.activate)
		end
	
		self:add_grenade_amount(-1)
		self._message_system:notify("ability_activated", nil, ability)
	else 
		return VPPP_PlayerManager_attempt_ability(self, ability)
	end
end

--[[ Common functions ]] --

function PlayerManager:give_temporary_value_boost(starting_value, temporay_nameid, boost)
	return managers.player:has_activate_temporary_upgrade("temporary", temporay_nameid) and (starting_value + boost) or starting_value
end

function PlayerManager:multiply_by_temporary_value_boost(starting_value, temporay_nameid, boost)
	return managers.player:has_activate_temporary_upgrade("temporary", temporay_nameid) and (starting_value * boost) or starting_value
end

function PlayerManager:multiply_by_temporary_value_boost_v2(starting_value, temporay_nameid)
	local boost = self:temporary_upgrade_value("temporary", temporay_nameid)
	return managers.player:has_activate_temporary_upgrade("temporary", temporay_nameid) and (starting_value * boost) or starting_value
end

function PlayerManager:generic_attempt(name_id)
	if self:has_activate_temporary_upgrade("temporary", name_id) then
		return false
	end
	local upgrade_values = self:upgrade_value("temporary", name_id)
	-- mx_print_table(data)
	local cooldown_reduction = upgrade_values[1]
	local duration = upgrade_values[2]

	local now = managers.game_play_central:get_heist_timer()
	managers.network:session():send_to_peers("sync_ability_hud", now + duration, duration)

	self:activate_temporary_upgrade("temporary", name_id)

	local function speed_up_on_kill()
		managers.player:speed_up_grenade_cooldown(cooldown_reduction)
	end

	self:register_message(Message.OnEnemyKilled, "speed_up_"..name_id, speed_up_on_kill)
	managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, duration)
	-- managers.hud:activate_local_ability_radial_with_fullscreen(duration)
	return true
end


Hooks:PostHook(PlayerManager, "check_skills", "MXTO_PlayerManager_check_skills", function(self)
	if managers.blackmarket:equipped_grenade() == "throwable_trip_mine" then
		local function speed_up_on_kill(weapon_unit, variant)
			managers.player:speed_up_grenade_cooldown(1)
			if variant == "explosion" then
				managers.player:speed_up_grenade_cooldown(1)
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_throwable_trip_mine", speed_up_on_kill)
	else
		self:unregister_message(Message.OnEnemyKilled, "speed_up_throwable_trip_mine")
	end
end)

--[[ Common functions END ]] --

function PlayerManager:_attempt_yakuza_injector()
	local activated = self:generic_attempt("yakuza_injector", 2)
	if activated then
		local player_unit = self:player_unit()
		local stamina_regen = player_unit:movement():_max_stamina() * 1
		player_unit:movement():add_stamina(stamina_regen)
	end
	return activated
end


local VPPP_PlayerManager_movement_speed_multiplier = PlayerManager.movement_speed_multiplier
function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
	local multiplier = VPPP_PlayerManager_movement_speed_multiplier(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)
	-- Changed to be a multiplicative buff
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "yakuza_injector", 1.5)
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "the_mixtape", 1.30)
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "jet", 1.30)
	return multiplier
end

local VPPP_PlayerManager_body_armor_regen_multiplier = PlayerManager.body_armor_regen_multiplier
function PlayerManager:body_armor_regen_multiplier(moving, health_ratio)
	local multiplier = VPPP_PlayerManager_body_armor_regen_multiplier(self, moving, health_ratio)
	multiplier = self:give_temporary_value_boost(multiplier, "yakuza_injector", 0.50)
	
	return multiplier
end

function PlayerManager:_attempt_burglar_luck()
	return self:generic_attempt("burglar_luck")
end

local VPPP_PlayerManager_skill_dodge_chance = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = VPPP_PlayerManager_skill_dodge_chance(self, running, crouching, on_zipline, override_armor, detection_risk)
	chance = self:give_temporary_value_boost(chance, "burglar_luck", 0.30)
	chance = self:give_temporary_value_boost(chance, "crooks_con", 0.20)
	return chance
end

function PlayerManager:_attempt_auto_inject_super_stimpak()
	if game_state_machine:verify_game_state(GameStateFilters.downed) then
		self:send_message(Message.RevivePlayer, nil, nil)
		local function speed_up_on_kill()
			managers.player:speed_up_grenade_cooldown(reduction or 1)
		end
	
		self:register_message(Message.OnEnemyKilled, "speed_up_auto_inject_super_stimpak", speed_up_on_kill)
		return true
	end
	return false -- false Does not allow the attempt_ability() to remove 1 nade
end

function PlayerManager:_attempt_adrenaline_shot()
	local activated = self:generic_attempt("adrenaline_shot")
	if activated then
		local player_unit = self:player_unit()
		local stamina_regen = player_unit:movement():_max_stamina() * 0.5
		player_unit:movement():add_stamina(stamina_regen)
	end
	return activated
end

function PlayerManager:_attempt_med_x()
	return self:generic_attempt("med_x")
end

local VPPP_PlayerManager_damage_reduction_skill_multiplier = PlayerManager.damage_reduction_skill_multiplier
function PlayerManager:damage_reduction_skill_multiplier(damage_type)
	local multiplier = VPPP_PlayerManager_damage_reduction_skill_multiplier(self, damage_type)
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "med_x", 0.70)
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "the_mixtape", 0.30)
	-- mx_log_chat('multiplier', multiplier)
	multiplier = multiplier * self:upgrade_value("player", "redacted_damage_reduction", 1)
	-- mx_log_chat('multiplier2', multiplier)

	return multiplier
end

function PlayerManager:_attempt_crooks_con()
	local activated = self:generic_attempt("crooks_con")
	if activated then
		local char_damage = managers.player:player_unit():character_damage()
		char_damage:change_armor(char_damage:_max_armor() * 0.40)
	end
	return activated
end

function PlayerManager:_attempt_spare_armor_plate()
	local activated = self:generic_attempt("spare_armor_plate")
	if activated then
		local char_damage = managers.player:player_unit():character_damage()
		char_damage:_regenerate_armor(false)
	end
	return activated
end

function PlayerManager:_attempt_liquid_armor()
	return self:generic_attempt("liquid_armor")
end


local VPPP_PlayerManager_body_armor_skill_multiplier = PlayerManager.body_armor_skill_multiplier
function PlayerManager:body_armor_skill_multiplier(override_armor)
	local multiplier = VPPP_PlayerManager_body_armor_skill_multiplier(self, override_armor)
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "liquid_armor", 2)
	return multiplier
end

function PlayerManager:_attempt_blood_transfusion()
	local activated = self:generic_attempt("blood_transfusion")
	if activated then
		local char_damage = managers.player:player_unit():character_damage()
		char_damage._armor_stored_health = char_damage._armor_stored_health * 1.5
		char_damage:consume_armor_stored_health()
		char_damage:_regenerate_armor(false)
	end
	return activated
end

function PlayerManager:_attempt_wick_mode()
	local activated = self:generic_attempt("wick_mode")
	if activated then
		managers.player:add_to_temporary_property("bullet_storm", self:upgrade_value("temporary", "wick_mode")[2], 1)
	end
	return activated
end

function PlayerManager:_attempt_emergency_requisition()
	local activated = self:generic_attempt("emergency_requisition")
	if activated then
		-- Well, it's activated, duh
	end
	return activated
end

function PlayerManager:mixtape_panic()
	local slotmask = managers.slot:get_mask("enemies")
	local units = World:find_units_quick("sphere", self:player_unit():movement():m_pos(), 1000, slotmask)

	for e_key, unit in pairs(units) do
		if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
			unit:character_damage():build_suppression("panic", 1)
			unit:movement():on_suppressed("panic")
		end
	end
end

function PlayerManager:_attempt_the_mixtape()
	local activated = self:generic_attempt("the_mixtape")
	if activated then	
		local function speed_up_on_melee_kill(weapon_unit, variant)
			if variant == "melee" then
				managers.player:speed_up_grenade_cooldown(2)
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_on_melee_kill_the_mixtape", speed_up_on_melee_kill)
		
		local triggers = {
			0.5,
			1,
			1.5,
			2,
			2.5,
			3,
			3.5,
		}
		
		self:mixtape_panic()
		for i,v in ipairs(triggers) do
			DelayedCalls:Add("Mixtape_Panic_Burst_"..i, v, function()
				self:mixtape_panic()
			end)
		end
	end
	return activated
end

-- If I'm editing an object like in the case of the values of "loose_ammo_restore_health" 
-- I must make a deep copy or it can happen that the values can overflow since it's changing the referenced value in the tweak_data
-- Just like the bug I had with "The Fixes Mod"
Hooks:AddHook( "PlayerManager_upgrade_value_overrides", "PlayerManager_upgrade_value_overrides_perkthrowables", function(self, category, upgrade, default, result)
    local _result = nil
	local is_gambler = category == "temporary" and upgrade == "loose_ammo_restore_health"
	if is_gambler and self:has_activate_temporary_upgrade("temporary", "emergency_requisition") then
		-- 04:52:27 PM Lua: {
		-- 	[1] = {
		-- 		[1] = 16, Healing min
		-- 		[2] = 20 Healing max
		-- 	},
		-- 	[2] = 3 -- Cooldown
		-- }
		local new_result = deep_clone(result)
		new_result[1][1] = new_result[1][1] * 1.5
		new_result[1][2] = new_result[1][2] * 1.5
		_result = new_result
	end
	local is_cocaine = category == "player" and upgrade == "cocaine_stacks_decay_multiplier"
	if is_cocaine and self:has_activate_temporary_upgrade("temporary", "whiff") then
		_result = 0
	end
	return _result
end)

function PlayerManager:_attempt_jet()
	local activated = self:generic_attempt("jet")
	if activated then
		local player_unit = self:player_unit()
		local stamina_regen = player_unit:movement():_max_stamina() * 0.5
		player_unit:movement():add_stamina(stamina_regen)
	end
	return activated
end

function PlayerManager:_attempt_whiff()
	local activated = self:generic_attempt("whiff")
	managers.player._damage_dealt_to_cops_decay_t = managers.player._damage_dealt_to_cops_decay_t + 8
	return activated
end

function PlayerManager:_attempt_crew_synchrony()
	local activated = self:_attempt_tag_team()
	-- Easy peasy copy paste and works lmao
	-- mx_log_chat('activated', activated)
	return activated
end

BuffBannerCoRoutine = {
	Priority = 1,
	Function = function (player)
		local base_values = managers.player:upgrade_value("temporary", "buff_banner")
		local timer = TimerManager:game()
		local end_time = timer:time() + base_values[2]
		local on_damage_key = {}
		local function on_damage(damage_info)
			local was_killed = damage_info.result.type == "death"
			local valid_player = damage_info.attacker_unit == player
			if not valid_player then -- then look if the damage was dealt by a player, and check if it's also if he is a 10m radius from you
				-- Thx to DrNewbie for the social distance find_units code
				local __units = World:find_units("sphere", player:position(), 1000, managers.slot:get_mask("players"))
				for _, _unit in pairs(__units) do 
					if _unit and alive(_unit) and _unit ~= player then
						valid_player = valid_player or damage_info.attacker_unit == _unit
						break
					end
				end
			end
			-- mx_print(damage_info)
			-- TODO: If too strong, limit this to a specific damage type? Like only bullets? Idks
			if not was_killed and valid_player and damage_info.damage and damage_info.variant ~= "mx_damage" then
				local damage = damage_info.damage * 0.4 
				-- Also this is copied from the graze coroutine
				damage_info._unit:character_damage():damage_simple({
					variant = "mx_damage",
					damage = damage,
					attacker_unit = managers.player:player_unit(),
					pos = damage_info.pos,
					attack_dir = Vector3(0, 0, 0)
				})
				-- mx_log_chat('damage_info.damage', damage_info.damage)
				-- mx_log_chat('damage', damage)
			end
		end

		CopDamage.register_listener(on_damage_key, {
			"SF2_on_damage"
		}, on_damage)

		while alive(player) and timer:time() < end_time do
			coroutine.yield()
		end

		CopDamage.unregister_listener(on_damage_key)

		while not managers.player:got_max_grenades() do
			coroutine.yield()
		end		
	end
}

function PlayerManager:_attempt_buff_banner()
	local activated = self:generic_attempt("buff_banner")
	if activated then
		log("add_coroutine") 
		self:add_coroutine("buff_banner", BuffBannerCoRoutine, managers.player:player_unit())
	end
	return activated
end