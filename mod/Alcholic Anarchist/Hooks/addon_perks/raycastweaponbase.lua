local old_RaycastWeaponBase_fire = RaycastWeaponBase.fire
function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if managers.player:has_category_upgrade("player", "striker_accuracy_to_damage") then
		dmg_mul = dmg_mul + managers.player:get_striker_stacks()
	end

	if managers.player:has_category_upgrade("player", "redacted_pain") then
		local stacks_count = managers.player.redacted_boost_stacks or 0
		dmg_mul = dmg_mul * (1 + math.min(stacks_count * 0.015, 1)) 
	end

	return old_RaycastWeaponBase_fire(self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
end

local old_RaycastWeaponBase__fire_raycast = RaycastWeaponBase._fire_raycast
function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	local result = old_RaycastWeaponBase__fire_raycast(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if user_unit == managers.player:player_unit() and managers.player:has_category_upgrade("player", "striker_accuracy_to_damage") then
		managers.player:update_striker_stacks(result.hit_enemy and managers.player.strikerStackIncrease or managers.player.strikerStackDecrease)
	end
	return result
end
