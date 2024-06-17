Hooks:PostHook(PlayerStandard, "_check_action_melee", "ForceUseAndDeflectStuffHook", function(self, t, input)
	if ( self._state_data and self._state_data.meleeing ) then
		local melee_entry = managers.blackmarket:equipped_melee_weapon()
		local melee_tweak =  tweak_data.blackmarket.melee_weapons[melee_entry]

		if (melee_tweak and melee_tweak.force_use) then
			local lerp_value = self:_get_melee_charge_lerp_value(t)

			if ( lerp_value >= 1 ) then
				self:_do_action_melee(t, input)
			end
		end
	end
end)