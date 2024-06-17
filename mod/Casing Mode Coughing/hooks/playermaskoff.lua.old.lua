Hooks:PostHook(PlayerMaskOff, "init", "ElevatorSourcePack_PMO_Init", function(self, unit)
	self._next_cough_t = 0

	self._watch_out = false
	self._watch_delay_t = 0
end)

Hooks:PostHook(PlayerMaskOff, "_update_check_actions", "ElevatorSourcePack_PMO_Actions", function(self, t, dt)
	local input = self:_get_input(t, dt)

	self:_check_action_cough(t, input)
	self:_check_action_watch(t, input)
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
	--if self._watch_out then return end

	self._next_cough_t = t + math.random(45, 60)

	local new_shoulder_stance = {
		translation = Vector3(),
		rotation = Rotation()
	}

	self._camera_unit:base():clbk_stance_entered(new_shoulder_stance, nil, empty_vel_overshot, nil, nil, {}, 1, 0.01)
	self._unit:camera():play_redirect(Idstring("elevator_cough"))
end

function PlayerMaskOff:_check_action_watch(t, input)
	if not input.btn_primary_attack_press then return end
	if self._watch_delay_t > t then return end
	if self._start_standard_expire_t then return end -- Don't show the watch whilst masking up.

	if self._watch_out then
		self:_stop_watch(t)
	else
		self:_start_watch(t)
	end
end

Hooks:PostHook(PlayerMaskOff, "_start_action_state_standard", "ElevatorSourcePack_PMO_MaskUp", function(self, t)
	if self._watch_out then
		self:_stop_watch(t)
	end
end)

function PlayerMaskOff:_start_watch(t)
	self._watch_delay_t = t + 1
	self._watch_out = true

	local new_shoulder_stance = {
		translation = Vector3(5,0,0),
		rotation = Rotation(0,40,0)
	}

	self._camera_unit:base():clbk_stance_entered(new_shoulder_stance, nil, empty_vel_overshot, nil, nil, {}, 1, 1)
	self._unit:camera():play_redirect(Idstring("elevator_watch_enter"))
end

function PlayerMaskOff:_stop_watch(t)
	self._watch_delay_t = t + 1

	self._watch_out = false

	local new_shoulder_stance = {
		translation = Vector3(),
		rotation = Rotation()
	}

	self._camera_unit:base():clbk_stance_entered(new_shoulder_stance, nil, empty_vel_overshot, nil, nil, {}, 1, 1)
	self._unit:camera():play_redirect(Idstring("elevator_watch_exit"))
end