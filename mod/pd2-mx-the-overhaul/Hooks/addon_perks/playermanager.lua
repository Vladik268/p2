Hooks:PostHook(PlayerManager, "check_skills", "Addon_Perks_PlayerManager_check_skills", function(self)
	if self:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then -- Fix here to avoid skill being triggered by other perkdecks
		local function speed_up_on_melee_kill(weapon_unit, variant)
			if variant == "melee" or weapon_unit:base():is_category("saw") then
				self:activate_temporary_upgrade("temporary", "dodgeopath_speed")
				self:activate_temporary_upgrade("temporary", "dodgeopath_invulnerability_on_kill")
				managers.hud:activate_local_ability_radial_with_fullscreen(3)
				local player_unit = self:player_unit()
				local stamina_regen = player_unit:movement():_max_stamina()
				player_unit:movement():add_stamina(stamina_regen)
			end
		end

		self:register_message(Message.OnEnemyKilled, "speed_up_on_melee_kill_dodgeopath", speed_up_on_melee_kill)
	else
		self:unregister_message(Message.OnEnemyKilled, "speed_up_on_melee_kill_dodgeopath")
	end

	if self:has_category_upgrade("player", "redacted_pain") then
		local function redacted_on_kill(weapon_unit, variant)
			local player_unit = self:player_unit()
			local char_damage = managers.player and managers.player:player_unit() and managers.player:player_unit():character_damage()
			if char_damage then
				local healing = char_damage:_max_health() * 0.04
				char_damage:restore_health(healing, true)
			end
		end

		self:register_message(Message.OnEnemyKilled, "redacted_on_kill", redacted_on_kill)
	else
		self:unregister_message(Message.OnEnemyKilled, "redacted_on_kill")
	end
end)

local VPPP_PlayerManager_movement_speed_multiplier = PlayerManager.movement_speed_multiplier
function PlayerManager:movement_speed_multiplier(speed_state, bonus_multiplier, upgrade_level, health_ratio)
	local multiplier = VPPP_PlayerManager_movement_speed_multiplier(self, speed_state, bonus_multiplier, upgrade_level, health_ratio)
	multiplier = self:multiply_by_temporary_value_boost(multiplier, "dodgeopath_speed", 1.5)
	return multiplier
end

local VPPP_PlayerManager_skill_dodge_chance = PlayerManager.skill_dodge_chance
function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = VPPP_PlayerManager_skill_dodge_chance(self, running, crouching, on_zipline, override_armor, detection_risk)
	-- local player = managers.player:player_unit()
	chance = self:give_temporary_value_boost(chance, "dodgeopath_invulnerability_on_kill", 1)

	return chance
end

function PlayerManager:get_striker_stacks()
	return self._decaying_stacks.striker_stacks or 0
end

function PlayerManager:update_striker_stacks(value)
	local newValue = self._decaying_stacks.striker_stacks + value
	self._decaying_stacks.striker_stacks = math.min(math.max(newValue, 0), 1);
end

Hooks:PostHook(PlayerManager, "_setup", "VPPP_PlayerManager__setup", function(self)
	self._decaying_stacks = self._decaying_stacks or {}
	self._decaying_stacks.striker_stacks = 0
end)

local strikerDecayInterval = 1 -- 1s between one decay and the other
PlayerManager.strikerStackIncrease = 0.015
PlayerManager.strikerStackDecrease = -0.02

function PlayerManager:striker_decay_update(player, t)
	if not self:has_category_upgrade("player", "striker_accuracy_to_damage") or not player then
		return
	end
	
	self._striker_stack_decay_t = self._striker_stack_decay_t or t + strikerDecayInterval
	if self._striker_stack_decay_t <= t and managers and managers.hud then
		self._striker_stack_decay_t = self._striker_stack_decay_t + strikerDecayInterval
		self:update_striker_stacks(-managers.player.strikerStackIncrease)
		local char_damage = managers.player and managers.player:player_unit() and managers.player:player_unit():character_damage()

		if char_damage and self:get_striker_stacks() > 0 then
			local healing = char_damage:_max_health() * managers.player.strikerStackIncrease * self:get_striker_stacks()
			-- mx_log("healing:"..tostring(healing).."_max_health"..tostring(char_damage:_max_health()))
			char_damage:restore_health(healing, true)
		end

		managers.hud:set_info_meter_fast(nil, {
			icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
			max = 1,
			current = self:get_striker_stacks(),
			total = 1
		})
	end
end

Hooks:PostHook(PlayerManager, "_internal_load", "Striker_PlayerManager__internal_load", function(self)
	if self:has_category_upgrade("player", "striker_accuracy_to_damage") and managers and managers.hud then
		managers.hud:set_info_meter(nil, {
			icon = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_icon_01",
			max = 1,
			current = self:get_striker_stacks(),
			total = self:get_striker_stacks()
		})
		self:update_cocaine_hud()
	end	
end)

local redactedDecayInterval = 1 -- 1s between one decay and the other
function PlayerManager:redacted_decay_update(player, t)
	if not self:has_category_upgrade("player", "redacted_pain") or not player and managers.groupai and not managers.groupai:state():whisper_mode()then
		return
	end
	
	self._redacted_decay_t = self._redacted_decay_t or t + redactedDecayInterval
	if self._redacted_decay_t <= t then
		self._redacted_decay_t = self._redacted_decay_t + redactedDecayInterval
		local char_damage = managers.player and managers.player:player_unit() and managers.player:player_unit():character_damage()
		
		if char_damage and not char_damage._dead and not char_damage._bleed_out and not char_damage._check_berserker_done then
			local damage = (char_damage:_max_health() * 0.01)
			char_damage:stealth_set_health(char_damage:get_real_health() - damage)
			char_damage:_check_bleed_out(true) -- To avoid the "walking around with 0HP" shit
		end
	end
end

local redactedBoostInterval = 30 -- 30s
function PlayerManager:redacted_boosts_update(player, t)
	self.redacted_boost_stacks = self.redacted_boost_stacks or 0
	self.redacted_boost_stacks = self.redacted_boost_stacks + 1
	mx_log_chat('redacted_boost_stacks', self.redacted_boost_stacks)
end

Hooks:PostHook(PlayerManager, "update", "VPPP_PlayerManager_update", function(self, t, dt)
	local player = self:player_unit()
	self:striker_decay_update(player, t)
	self:redacted_decay_update(player, t)
	self:generic_decay_update(t, 'redacted_boosts', redactedBoostInterval, self.redacted_boosts_update)
end)

function PlayerManager:generic_decay_update(t, decay_key, decayInterval, callback)
	local player = self:player_unit()
	self[decay_key] = self[decay_key] or t + decayInterval
	if self[decay_key] <= t then
		self[decay_key] = self[decay_key] + decayInterval
		callback(self, player, t)
	end
end

Hooks:AddHook("PlayerManager_upgrade_value_overrides", "PlayerManager_upgrade_value_overrides_perkthrowables", function(self, category, upgrade, default, result)
    local new_result = nil
	local player_extra_ammo_multiplier = category == "player" and upgrade == "extra_ammo_multiplier"
	
	if player_extra_ammo_multiplier and self:has_category_upgrade("player", "lonestar_extra_ammo_multiplier") then
		new_result = self:upgrade_value("player", "lonestar_extra_ammo_multiplier") + result -- Add +X% ammo
	end
	
	return new_result
end)

function PlayerManager:_attempt_lonestar_rage()
	local activated = self:generic_attempt("lonestar_rage")
	if activated then
		self:player_unit():movement():current_state()._equipped_unit:base():on_reload()
		managers.hud:set_ammo_amount(self:player_unit():movement():current_state()._equipped_unit:base():selection_index(), self:player_unit():movement():current_state()._equipped_unit:base():ammo_info())
	end
	return activated
end
