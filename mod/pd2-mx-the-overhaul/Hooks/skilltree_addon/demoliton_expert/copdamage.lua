local function is_a_bow(attack_data)
    return attack_data and attack_data.weapon_unit and attack_data.weapon_unit.base and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("bow")
end

Hooks:PostHook(CopDamage, "damage_bullet", "Demo_CopDamage_damage_bullet",    function(self, attack_data) 
    local is_real_bullet = attack_data.variant == "bullet" and not is_a_bow(attack_data)
    local is_player_damage = attack_data.attacker_unit == managers.player:player_unit()
    local is_friendly_fire = self:is_friendly_fire(attack_data.attacker_unit)

    if managers.player:has_category_upgrade("player", "primer_round") and is_real_bullet and is_player_damage and not is_friendly_fire then
        local primer_damage_mult = managers.player:upgrade_value("player", "primer_round")
        local SLOT_MASK = managers.slot:get_mask("enemies")
        local col_ray = attack_data.col_ray
        local user_unit = managers.player:player_unit()

        local has_Movement = managers.player:player_unit():movement()
        local has_state = has_Movement and has_Movement:current_state()
        local has_unit = has_state and has_state._equipped_unit
        local has_base = has_unit and has_unit:base()
        local has_name_id = has_base._name_id 
        local exp_damage = 10

        if has_Movement and has_state and has_unit and has_base and has_name_id and tweak_data.weapon[has_name_id] then
            local weapon = tweak_data.weapon[has_name_id]
            local weapon_stats = weapon.stats
            local damage = weapon_stats and weapon_stats.damage or 1
            local damage_modifier = weapon.stats_modifiers and weapon.stats_modifiers.damage or 1
            local base_damage = tweak_data.weapon[has_name_id].stats.damage * primer_damage_mult * damage_modifier
            -- Divided by 10 because the value read from he stats.damage is the value that appears in the Inventory not the real ingame damage
            -- Confirmed by hoppip too
            -- Also takes in consideration the idiotic way overkill handles damage multipiers
            exp_damage = base_damage / 10
        end

        -- Seriously, this became really complicated, so I just decided to use the InstantExplosiveBulletBase
        -- local exp_range = 300 -- 500 was too much Test value
        -- -- Look for the enemies in the explosion range
        -- local bodies = World:find_units_quick("sphere", col_ray.position, exp_range, SLOT_MASK)
        -- for _, hit_unit in ipairs(bodies) do
        --     if hit_unit:character_damage() then
        --         hit_unit:character_damage():damage_simple({
        -- 			variant = "mx_damage",
        -- 			damage = exp_damage,
        -- 			attacker_unit = managers.player:player_unit(),
        -- 			pos = attack_data.pos,
        -- 			attack_dir = Vector3(0, 0, 0)
        -- 		})
        --     end
        -- end
        
        -- Range is 200 pd2-lua\lib\tweak_data\upgradestweakdata.lua - self.explosive_bullet
        InstantExplosiveBulletBase:on_collision(col_ray, attack_data.weapon_unit, user_unit, exp_damage, false) 
    end
end)

Hooks:PostHook(CopDamage, "damage_explosion", "Demo_damage_explosion" ,function(self, attack_data)
    if self._dead or self._invulnerable or not managers.player:has_category_upgrade("grenade_launcher", "afterburn") then
		return
	end

    local dot_damage = (attack_data.damage * 0.10)
    local fire_dot_data = {
        dot_damage = dot_damage,
        dot_trigger_max_distance = 9000,
        dot_trigger_chance = 100,
        dot_length = 3,
        dot_tick_period = 0.5
    }
    local action_data = {}
    action_data.variant = "fire"
    action_data.damage = 0.1
    action_data.attacker_unit = managers.player:player_unit()
    action_data.col_ray = attack_data.col_ray
    action_data.fire_dot_data = fire_dot_data
    self:damage_fire(action_data)
end)