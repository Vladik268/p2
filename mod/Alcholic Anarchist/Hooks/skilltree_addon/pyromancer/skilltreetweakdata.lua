local skilltree_name = "mx_pack"

Hooks:Add("SF_InfamyTweakDataPostInit", "Pyromancer_InfamyTweakDataPostInit_Hawkeye", function(infamy)
    infamy:add_skill_tree(skilltree_name)
end)

Hooks:PostHook(SkillTreeTweakData, "init", "Pyromancer_SkillTreeTweakData_init", function(self)
    self:add_skill_tree(skilltree_name)

	local PyromancerTreeTiers = {
		{
			"fuel_backpack",
		},
		{
			"extender",
			"flaming_hands"
		},
		{
			"everlasting_flames",
			"cleansing_fire"
		},
		{
			"thermal_bomb"
		}
	}

	self:add_sub_skill_tree(skilltree_name, "mx_pyromancer", PyromancerTreeTiers)

	local fuel_backpack_1 = {"flamethrower_magazine_capacity_inc_1", "flamethrower_extra_ammo_multiplier_1"}
	local fuel_backpack_2 = {"flamethrower_magazine_capacity_inc_2", "flamethrower_extra_ammo_multiplier_2"}
	self:add_new_skill("fuel_backpack", fuel_backpack_1, fuel_backpack_2, 2, { 6,0 }) -- 50% mag size | 100% mag size

	self:add_new_skill("extender", "flamethrower_flame_max_range_1", "flamethrower_flame_max_range_2", 2, { 6,6 }) -- range 16m - 21m
	
	local flaming_hands_1 = {"flamethrower_reload_speed_multiplier_1", "flamethrower_hip_run_and_shoot_1"}
	self:add_new_skill("flaming_hands", flaming_hands_1, "flamethrower_reload_speed_multiplier_2", 2, { 1,9 }) -- reload 45% | 75%

	local cleansing_fire_1 = {"flamethrower_damage_addend_1", "flamethrower_dot_damage_addend_1", "flamethrower_fire_rate_multiplier_1"}
	local cleansing_fire_2 = {"flamethrower_damage_addend_2", "flamethrower_fire_rate_multiplier_2"}
	self:add_new_skill("cleansing_fire", cleansing_fire_1 , cleansing_fire_2, 3, { 9,10 }) -- +50 |	+70 

	local hot_1 = {"flamethrower_dot_length_addend_1", "flamethrower_dot_trigger_chance_1"}
	local hot_2 = {"flamethrower_dot_length_addend_2", "flamethrower_dot_trigger_chance_2"}
	self:add_new_skill("everlasting_flames", hot_1, hot_2, 3, { 1,7 })

	local thermal_bomb_1 = {"flamethrower_thermal_bomb_1"}
	local thermal_bomb_2 = {"flamethrower_thermal_bomb_2"}
	self:add_new_skill("thermal_bomb", thermal_bomb_1, thermal_bomb_2, 4, { 9,9 })
	
	self:add_new_skill("primer_round", "XXX", "XXX", 4, { 0,0 })
end)