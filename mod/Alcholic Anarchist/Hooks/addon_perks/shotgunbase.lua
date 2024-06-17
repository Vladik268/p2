local mvec_temp = Vector3()
local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

Hooks:PostHook(ShotgunBase, "_fire_raycast", "VPPP_ShotgunBase__fire_raycast", function(self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local spread_x, spread_y = self:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	mvector3.set(mvec_direction, direction)

    local hits = 0
    local miss = 0
	for i = 1, shoot_through_data and 1 or self._rays do
		local theta = math.random() * 360
		local ax = math.sin(theta) * math.random() * spread_x * (spread_mul or 1)
		local ay = math.cos(theta) * math.random() * spread_y * (spread_mul or 1)

		mvector3.set(mvec_spread_direction, mvec_direction)
		mvector3.add(mvec_spread_direction, right * math.rad(ax))
		mvector3.add(mvec_spread_direction, up * math.rad(ay))
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 20000)
		mvector3.add(mvec_to, from_pos)

		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

        if col_ray then 
            if col_ray.unit:character_damage() then
                hits = hits + 1
            else
                miss = miss + 1
            end
        else 
            miss = miss + 1
        end
	end

	if user_unit == managers.player:player_unit()  then
		managers.player:update_striker_stacks(managers.player.strikerStackDecrease * miss)
		managers.player:update_striker_stacks(managers.player.strikerStackIncrease * hits)
	end
end)