if Network:is_client() then
	return
end

function DrivingInteractionExt:can_interact(player)
	local can_interact = DrivingInteractionExt.super.can_interact(self, player)
	if can_interact and managers.player:is_berserker() then
		can_interact = false
		managers.hud:show_hint({
			text = managers.localization:text("hud_vehicle_no_enter_berserker"),
			time = 2
		})
	elseif can_interact and managers.player:is_carrying() then
		if self._action == VehicleDrivingExt.INTERACT_ENTER or self._action == VehicleDrivingExt.INTERACT_DRIVE then
			can_interact = true
		elseif self._action == VehicleDrivingExt.INTERACT_LOOT then
			can_interact = false
		end
	end
	return can_interact
end