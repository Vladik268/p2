local Butcher_PlayerStandard__calc_melee_hit_ray = PlayerStandard._calc_melee_hit_ray
function PlayerStandard:_calc_melee_hit_ray(t, sphere_cast_radius)
	local result = Butcher_PlayerStandard__calc_melee_hit_ray(self, t, sphere_cast_radius)

    if managers.player:has_category_upgrade("player", "melee_range_boost") then
        -- It's the same code as the original, but with the dded melee range skill upgrade 
        local melee_entry = managers.blackmarket:equipped_melee_weapon()
        local range = tweak_data.blackmarket.melee_weapons[melee_entry].stats.range or 175
        range = range  * managers.player:upgrade_value("player", "melee_range_boost")
        local from = self._unit:movement():m_head_pos()
        local to = from + self._unit:movement():m_head_rot():y() * range
        return self._unit:raycast("ray", from, to, "slot_mask", self._slotmask_bullet_impact_targets, "sphere_cast_radius", sphere_cast_radius, "ray_type", "body melee")
    end

	return result
end

Hooks:PostHook(PlayerStandard, "_do_action_melee", "Butcher_PlayerStandard__do_action_melee", function(self, t, input, skip_damage)
    if managers.player:has_category_upgrade("player", "melee_speed_boost") then
        local melee_entry = managers.blackmarket:equipped_melee_weapon()
        local boost = managers.player:upgrade_value("player", "melee_speed_boost")
        self._state_data.melee_expire_t = t + tweak_data.blackmarket.melee_weapons[melee_entry].expire_t
        self._state_data.melee_repeat_expire_t = t + math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t) * boost
        local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	    melee_damage_delay = math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t) * boost
        self._state_data.melee_damage_delay_t = t + melee_damage_delay
    end
end)

local Butcher_PlayerStandard__get_melee_charge_lerp_value = PlayerStandard._get_melee_charge_lerp_value
function PlayerStandard:_get_melee_charge_lerp_value(t, offset)
	local result = Butcher_PlayerStandard__get_melee_charge_lerp_value(self, t, offset)
    self._state_data.melee_charge_lerp_value = result
	return result
end

function PlayerStandard:get_current_melee_charge_lerp_value()
    return self._state_data.melee_charge_lerp_value
end

function PlayerStandard:is_melee_charge_full()
    return (self._state_data.melee_charge_lerp_value or 0) >= 1
end

function PlayerStandard:discharge_melee_fast()
    self:_do_action_melee_mx(managers.player:player_timer():time(), nil, true)
end

function PlayerStandard:_do_action_melee_mx(t, input, skip_damage)
	local deflect_boost = 5
	local animation_deflect_boost = 5
	-- From below here the code is the same as vanilla lol except the boosts
	self._state_data.meleeing = nil
	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local instant_hit = tweak_data.blackmarket.melee_weapons[melee_entry].instant
	local pre_calc_hit_ray = tweak_data.blackmarket.melee_weapons[melee_entry].hit_pre_calculation
	local melee_damage_delay = tweak_data.blackmarket.melee_weapons[melee_entry].melee_damage_delay or 0
	melee_damage_delay = math.min(melee_damage_delay, tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t)
	local primary = managers.blackmarket:equipped_primary()
	local primary_id = primary.weapon_id
	local bayonet_id = managers.blackmarket:equipped_bayonet(primary_id)
	local bayonet_melee = false

	if bayonet_id and self._equipped_unit:base():selection_index() == 2 then
		bayonet_melee = true
	end

	self._state_data.melee_expire_t = t + (tweak_data.blackmarket.melee_weapons[melee_entry].expire_t / deflect_boost)
	self._state_data.melee_repeat_expire_t = t + (math.min(tweak_data.blackmarket.melee_weapons[melee_entry].repeat_expire_t, tweak_data.blackmarket.melee_weapons[melee_entry].expire_t) / deflect_boost)

	if not instant_hit and not skip_damage then
		self._state_data.melee_damage_delay_t = t + melee_damage_delay

		if pre_calc_hit_ray then
			self._state_data.melee_hit_ray = self:_calc_melee_hit_ray(t, 20) or true
		else
			self._state_data.melee_hit_ray = nil
		end
	end

	local send_redirect = instant_hit and (bayonet_melee and "melee_bayonet" or "melee") or "melee_item"

	if instant_hit then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, send_redirect)
	else
		self._ext_network:send("sync_melee_discharge")
	end

	if self._state_data.melee_charge_shake then
		self._ext_camera:shaker():stop(self._state_data.melee_charge_shake)

		self._state_data.melee_charge_shake = nil
	end

	self._melee_attack_var = 0

	if instant_hit then
		local hit = skip_damage or self:_do_melee_damage(t, bayonet_melee)

		if hit then
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_bayonet") or self:get_animation("melee"))
		else
			self._ext_camera:play_redirect(bayonet_melee and self:get_animation("melee_miss_bayonet") or self:get_animation("melee_miss"))
		end
	else
		local state = self._ext_camera:play_redirect(self:get_animation("melee_attack"), animation_deflect_boost)
		local anim_attack_vars = tweak_data.blackmarket.melee_weapons[melee_entry].anim_attack_vars
		self._melee_attack_var = anim_attack_vars and math.random(#anim_attack_vars)

		self:_play_melee_sound(melee_entry, "hit_air", self._melee_attack_var)

		local melee_item_tweak_anim = "attack"
		local melee_item_prefix = ""
		local melee_item_suffix = ""
		local anim_attack_param = anim_attack_vars and anim_attack_vars[self._melee_attack_var]

		if anim_attack_param then
			self._camera_unit:anim_state_machine():set_parameter(state, anim_attack_param, 1)

			melee_item_prefix = anim_attack_param .. "_"
		end

		if self._state_data.melee_hit_ray and self._state_data.melee_hit_ray ~= true then
			self._camera_unit:anim_state_machine():set_parameter(state, "hit", 1)

			melee_item_suffix = "_hit"
		end

		melee_item_tweak_anim = melee_item_prefix .. melee_item_tweak_anim .. melee_item_suffix

		self._camera_unit:base():play_anim_melee_item(melee_item_tweak_anim)
	end
end


Hooks:PostHook(PlayerStandard, "_check_action_melee", "Butcher_PlayerStandard__check_action_melee", function(self, t, input)
	self._state_data.btn_melee_press = input.btn_melee_press or input.btn_melee_release or self._state_data.melee_charge_wanted or input.btn_meleet_state
end)

function PlayerStandard:is_btn_melee_press()
    return self._state_data.btn_melee_press or self._state_data.melee_hold_t or self._state_data.melee_hold
end