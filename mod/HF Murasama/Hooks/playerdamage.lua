local damage_functions = {
	"damage_tase",
	"damage_melee",
	"damage_bullet"
}

for _, function_name in ipairs(damage_functions) do
	PlayerDamage["original_pre_deflect_" .. function_name] = PlayerDamage["original_pre_deflect_" .. function_name] or PlayerDamage[function_name]

	PlayerDamage[function_name] = function(self, attack_data)
		local current_state = self._unit:movement()._current_state

		if (current_state and current_state.in_melee and current_state:in_melee()) then
			local melee_entry = managers.blackmarket:equipped_melee_weapon()
			local melee_tweak =  tweak_data.blackmarket.melee_weapons[melee_entry]

			if (melee_tweak and melee_tweak.deflect) then
				local attacker_unit = attack_data.attacker_unit

				if (attacker_unit and not attacker_unit:base().sentry_gun and attacker_unit.character_damage) then
					local action_data = {
						variant = "stun",
						damage = 0,
						attacker_unit = self._unit,
						weapon_unit = self._unit,
						col_ray = {
							position = mvector3.copy(attacker_unit:movement():m_head_pos()),
							ray = -attacker_unit:movement():m_fwd()
						}
					}

					attacker_unit:character_damage():stun_hit(action_data)
				end

				if (current_state._play_melee_sound) then
					local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
					local anim_attack_var = anim_attack_vars and math.random(#anim_attack_vars)

					current_state:_play_melee_sound(melee_entry, "hit_gen", anim_attack_var or 0)

					if (function_name == "damage_tase") then
						self._unit:sound():play("tase_counter_attack")
					end
				end

				if (current_state.discharge_melee) then
					current_state:discharge_melee()
				end

				return
			end
		end

		return PlayerDamage["original_pre_deflect_" .. function_name](self, attack_data)
	end
end
