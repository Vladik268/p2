local VPPP_NewRaycastWeaponBase_reload_speed_multiplier = NewRaycastWeaponBase.reload_speed_multiplier
function NewRaycastWeaponBase:reload_speed_multiplier()
    local multiplier = VPPP_NewRaycastWeaponBase_reload_speed_multiplier(self)
    multiplier = managers.player:give_temporary_value_boost(multiplier, "adrenaline_shot", 0.80)
    multiplier = managers.player:give_temporary_value_boost(multiplier, "whiff", 0.80)

	mx_log_chat('multiplier', multiplier)
	if managers.player:has_category_upgrade("player", "redacted_pain") then
		local stacks_count = managers.player.redacted_boost_stacks or 0
		multiplier = multiplier * (1 + math.min(stacks_count * 0.015, 1))
	end
	mx_log_chat('multiplier2', multiplier)

    return multiplier
end     

function NewRaycastWeaponBase:mx_fire_rate_multiplier()
	local multiplier = self:fire_rate_multiplier()
	if not self._projectile_type then
		multiplier = managers.player:multiply_by_temporary_value_boost(multiplier, "wick_mode", 1.5)
		multiplier = managers.player:multiply_by_temporary_value_boost(multiplier, "lonestar_rage", 1.3)
	end
	return multiplier
end

-- Listen, I know this sucks, I know this overrides the vanilla code, but seriously, it's not my fault if overkill does not use Super in their function inside shotgun base
function RaycastWeaponBase:update_next_shooting_time()
	local next_fire = (tweak_data.weapon[self._name_id].fire_mode_data and tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:mx_fire_rate_multiplier()
	self._next_fire_allowed = self._next_fire_allowed + next_fire
end