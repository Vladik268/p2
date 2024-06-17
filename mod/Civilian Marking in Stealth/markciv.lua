if RequiredScript == "lib/units/beings/player/states/playerstandard" then

	PlayerStandard.MARK_CIVILIANS_VOCAL = false

	local _get_interaction_target_original = PlayerStandard._get_interaction_target
	local _get_intimidation_action_original = PlayerStandard._get_intimidation_action

	function PlayerStandard:_get_interaction_target(char_table, my_head_pos, cam_fwd, ...)
		local range = tweak_data.player.long_dis_interaction.highlight_range * managers.player:upgrade_value("player", "intimidate_range_mul", 1) * managers.player:upgrade_value("player", "passive_intimidate_range_mul", 1)

		for u_key, u_data in pairs(managers.enemy:all_civilians()) do
			if u_data.unit:movement():cool() then
				self:_add_unit_to_char_table(char_table, u_data.unit, 1, range, false, false, 0.001, my_head_pos, cam_fwd)
			end
		end

		return _get_interaction_target_original(self, char_table, my_head_pos, cam_fwd, ...)
	end

	function PlayerStandard:_get_intimidation_action(prime_target, ...)
		if prime_target and prime_target.unit_type == 1 and prime_target.unit:movement():cool() and managers.player:has_category_upgrade("player", "sec_camera_highlight_mask_off") then
			if not PlayerStandard.MARK_CIVILIANS_VOCAL then
				prime_target.unit:contour():add(managers.player:has_category_upgrade("player", "marked_enemy_extra_damage") and "mark_enemy_damage_bonus" or "mark_enemy", true, managers.player:upgrade_value("player", "mark_enemy_time_multiplier", 1))
			end

			return PlayerStandard.MARK_CIVILIANS_VOCAL and "mark_cop_quiet" or nil, false, prime_target
		end

		return _get_intimidation_action_original(self, prime_target, ...)
	end

elseif RequiredScript == "lib/tweak_data/charactertweakdata" then

	local _init_civilian_original = CharacterTweakData._init_civilian
	
	function CharacterTweakData:_init_civilian(...)
		_init_civilian_original(self, ...)
		self.civilian.silent_priority_shout = "f37"
		self.civilian_female.silent_priority_shout = "f37"
	end
	
end