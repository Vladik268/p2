function PlayerEquipment:use_trip_mine_mx()
	local ray = self:valid_look_at_placement()

	if ray then
		managers.statistics:use_trip_mine()

		local sensor_upgrade = managers.player:has_category_upgrade("trip_mine", "sensor_toggle")

		-- if Network:is_client() then
		-- 	managers.network:session():send_to_host("place_trip_mine", ray.position, ray.normal, sensor_upgrade)
		-- else
        local rot = Rotation(ray.normal, math.UP)
        local unit = TripMineBase.spawn(ray.position, rot, sensor_upgrade, managers.network:session():local_peer():id(), true)

        unit:base():set_active(true, self._unit)
		-- end

		return true
	end

	return false
end
