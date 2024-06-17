function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.bullet_class == "FlameBulletBase" then
		fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			fire_dot_data = tweak_data.weapon[weapon_name_id].fire_dot_data
		end
	end

	if fire_dot_data and fire_dot_data.start_dot_dance_antimation then
		self._can_shoot_through_enemy = managers.player:upgrade_value("flamethrower", "dot_damage_addend", 0) < 0 and true or false
		local dot_damage_addend = managers.player:upgrade_value("flamethrower", "dot_damage_addend", 0)
		local dot_length_addend = managers.player:upgrade_value("flamethrower", "dot_length_addend", 0)
		local dot_trigger_chance = managers.player:upgrade_value("flamethrower", "dot_trigger_chance", 0)
		fire_dot_data.dot_damage = fire_dot_data.dot_damage + dot_damage_addend
		fire_dot_data.dot_length = fire_dot_data.dot_length + dot_length_addend
		fire_dot_data.dot_trigger_chance = fire_dot_data.dot_trigger_chance + dot_trigger_chance
	end

	-- Money thrower
	--  {
    --     ['dot_tick_period'] = 0.5,
    --     ['start_dot_dance_antimation'] = false,
    --     ['dot_trigger_chance'] = 0.75,
    --     ['dot_length'] = 1,
    --     ['dot_damage'] = 10,
    --     ['dot_trigger_max_distance'] = 1300
	-- }

	-- Flamer
	-- {
	--         ['dot_tick_period'] = 0.5,
	--         ['start_dot_dance_antimation'] = true,
	--         ['dot_trigger_chance'] = 75,
	--         ['dot_length'] = 1.6,
	--         ['dot_damage'] = 30,
	--         ['dot_trigger_max_distance'] = 3000
	-- }

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end