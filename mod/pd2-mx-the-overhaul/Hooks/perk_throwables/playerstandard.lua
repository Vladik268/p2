local VPPP_PlayerStandard_do_melee_damage = PlayerStandard._do_melee_damage
function PlayerStandard:_do_melee_damage(t, bayonet_melee, melee_hit_ray, melee_entry, hand_id)
    local col_ray = VPPP_PlayerStandard_do_melee_damage(self, t, bayonet_melee, melee_hit_ray, melee_entry, hand_id)
    if not col_ray and managers.player:has_activate_temporary_upgrade("temporary", "yakuza_injector") then
        local player = managers.player:player_unit()

        if player then
            -- Do self damage to health
            local max_10_perc = player:character_damage():_max_health() * 0.10
            player:character_damage():set_health(math.max(1, player:character_damage():get_real_health() - max_10_perc))
        end
    end
    return col_ray
end


local VPPP_PlayerStandard_get_swap_speed_multiplier = PlayerStandard._get_swap_speed_multiplier
function PlayerStandard:_get_swap_speed_multiplier()
	local multiplier = VPPP_PlayerStandard_get_swap_speed_multiplier(self)
	multiplier = managers.player:give_temporary_value_boost(multiplier, "adrenaline_shot", 0.80)
	multiplier = managers.player:give_temporary_value_boost(multiplier, "whiff", 0.80)
    multiplier = managers.player:has_category_upgrade("player", "lonestar_extra_ammo_multiplier") and (multiplier * (1 + 0.40)) or multiplier

	return multiplier
end


local old_PlayerStandard__find_pickups = PlayerStandard._find_pickups
function PlayerStandard:_find_pickups(t)
    local default_pickup = 200 * managers.player:upgrade_value("player", "increased_pickup_area", 1)
    self._pickup_area = managers.player:has_activate_temporary_upgrade("temporary", "emergency_requisition") and 30000 or default_pickup
	local result = old_PlayerStandard__find_pickups(self, t)
	return result
end
