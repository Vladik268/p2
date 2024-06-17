function FPCameraPlayerBase:clbk_cough_shake()
	if self._parent_unit and self._parent_unit:camera() then
		local cough_rng = (math.random() * -0.05) - 0.1
		self._parent_unit:camera():play_shaker("melee_hit", cough_rng)
	end
end
