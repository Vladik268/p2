Hooks:PostHook(PlayerMaskOff, "init", "CasingModeCoughing_PMO_Init", function(self, unit)
	self._next_cough_t = 0
end)

Hooks:PostHook(PlayerMaskOff, "_update_check_actions", "CasingModeCoughing_PMO_Actions", function(self, t, dt)
	local input = self:_get_input(t, dt)

	self:_check_action_cough(t, input)
end)

local empty_vel_overshot = {
	pivot = Vector3(0, 0, 0),
	yaw_neg = 0,
	yaw_pos = 0,
	pitch_neg = 0,
	pitch_pos = 0
}

function PlayerMaskOff:_check_action_cough(t, input)
	if not input.btn_steelsight_press then return end
	if self._next_cough_t > t then return end

	self._next_cough_t = t + 1--math.random(45, 60)

	local new_shoulder_stance = {
		translation = Vector3(0,0,-5),
		rotation = Rotation()
	}

	self._camera_unit:base():clbk_stance_entered(new_shoulder_stance, nil, empty_vel_overshot, nil, nil, {}, 1, 0.01, 0, 0)
	self._unit:camera():play_redirect(Idstring("elevator_cough"))
end