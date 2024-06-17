Hooks:PostHook(PlayerMaskOff, "init", "CasingModeSmoking_PMO_Init", function(self, unit)
	self._smoking_transition_t = 0
	self._smoking_state = false
end)

Hooks:PostHook(PlayerMaskOff, "_update_check_actions", "CasingModeSmoking_PMO_Actions", function(self, t, dt)
	local input = self:_get_input(t, dt)

	self:_check_action_smoke(t, input)
end)

local shoulder_stance = {
	translation = Vector3(0, -5, 0),
	rotation = Rotation()
}

local empty_vel_overshot = {
	pivot = Vector3(0, 0, 0),
	yaw_neg = 0,
	yaw_pos = 0,
	pitch_neg = 0,
	pitch_pos = 0
}

function PlayerMaskOff:_check_action_smoke(t, input)
	if input.btn_primary_attack_press then
		self._smoking_wanted = true
	elseif input.btn_primary_attack_release then
		self._smoking_wanted = false
	end

	if self._next_cough_t and self._next_cough_t > t then return end
	if self._smoking_transition_t > t then return end
	local state_changed = false

	if self._smoking_wanted and not self._smoking_state then
		self._unit:camera():play_redirect(Idstring("smoking_enter"))
		self._smoking_state = true

		state_changed = true
	elseif not self._smoking_wanted and self._smoking_state then
		self._unit:camera():play_redirect(Idstring("smoking_exit"))
		self._smoking_state = false

		state_changed = true
	end

	if state_changed then
		self._camera_unit:base():clbk_stance_entered(shoulder_stance, nil, empty_vel_overshot, nil, nil, {}, 1, 0.01, 0, 0)
		self._smoking_transition_t = t + 1.5
	end

	-- High quality compatibility jank.
	if self._smoking_state then
		self._next_cough_t = t + 1.5
	end
end