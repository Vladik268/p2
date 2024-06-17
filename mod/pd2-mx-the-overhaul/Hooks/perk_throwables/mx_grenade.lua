MxGrenade = MxGrenade or class(GrenadeBase)

function MxGrenade:init(unit)
	MxGrenade.super.init(self, unit)

	self._detonated = false
end

function MxGrenade:clbk_impact(tag, unit, body, other_unit, other_body, position, normal, collision_velocity, velocity, other_velocity, new_velocity, direction, damage, ...)
	local reflect = other_unit and other_unit:character_damage()

	if reflect then
		return
	end

	local pos, rot = self:valid_impact_placement(position, direction)
	if not self._detonated and pos and rot then
		self:spawn_tripmine_on_impact(pos, rot)
		self._detonated = true
		self._unit:set_slot(0)
	end
end

function MxGrenade:valid_impact_placement(position, direction)
	local from =  position - (direction * 10)
	local to = position + (direction * 5)
	local ray = self._unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {}, "ray_type", "equipment_placement")

	if not ray then
		return
	end

	local pos = ray.position
	local rot = Rotation(ray.normal, math.UP)

	return pos, rot
end

function MxGrenade:spawn_tripmine_on_impact(position, rotation)
	local sensor_upgrade = managers.player:has_category_upgrade("trip_mine", "sensor_toggle")

	local unit = TripMineBase.spawn(position, rotation, sensor_upgrade, managers.network:session():local_peer():id(), true)

	unit:base():set_active(true, managers.player:player_unit())
end