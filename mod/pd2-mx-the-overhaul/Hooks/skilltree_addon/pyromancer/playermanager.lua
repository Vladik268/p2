Hooks:PostHook(PlayerManager, "check_skills", "Pyromancer_check_skills", function(self)
	if self:has_category_upgrade("flamethrower", "thermal_bomb") then
		local function thermal_bomb(weapon_unit, variant, killed_unit)
            local increase = (ORIGINAL_HEALTH_MAP[killed_unit:base()._tweak_table] or 4) -- Fallback because overkill BS
			self._pyromancer_thermal_bomb = self._pyromancer_thermal_bomb + increase 
            -- mx_print(self._pyromancer_thermal_bomb.."/"..self:upgrade_value("flamethrower", "thermal_bomb").." +"..increase)
            if self._pyromancer_thermal_bomb > self:upgrade_value("flamethrower", "thermal_bomb") then
                self._pyromancer_thermal_bomb = 0
                -- Im aware this code is kinda bad, but it's the overkill way plus my fix for the fire 
                -- since the OVK code for the explosion and burn effect breaks the ragdoll of the killedunit for some reason
                local pos = killed_unit:position()
                local normal = math.UP
                local range = 500
                local slot_mask = managers.slot:get_mask("explosion_targets")
                local custom_params = {
                    camera_shake_max_mul = 4,
                    sound_muffle_effect = true,
                    effect = "effects/payday2/particles/explosions/grenade_incendiary_explosion",
                    sound_event = "white_explosion",
                    feedback_range = range * 2
                }

                managers.explosion:play_sound_and_effects(pos, normal, range, custom_params)
                local bodies = World:find_units_quick("sphere", pos, 500, slot_mask)
                for _, hit_unit in ipairs(bodies) do
                    if hit_unit:character_damage() then
                        local col_ray = {
                            ray = Vector3(1, 0, 0),
                            position = pos
                        }
                        local fire_dot_data = {
                            dot_trigger_chance = 100,
                            dot_damage = 25,
                            dot_length = 2.1,
                            dot_trigger_max_distance = 3000,
                            dot_tick_period = 0.5
                        }
                        local action_data = {
                            variant = "fire",
                            damage = 0.1,
                            attacker_unit = managers.player:player_unit(),
                            col_ray = col_ray,
                            fire_dot_data = fire_dot_data,
                        }
                        hit_unit:character_damage():damage_fire(action_data)
                    end
                end
            end
		end
	
		self:register_message(Message.OnEnemyKilled, "thermal_bomb_pyromancer", thermal_bomb)
        self._pyromancer_thermal_bomb = 0
	else
		self:unregister_message(Message.OnEnemyKilled, "thermal_bomb_pyromancer")
        self._pyromancer_thermal_bomb = 0
	end
end)
