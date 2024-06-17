local skilltree_name = "mx_pack"

Hooks:Add("SF_InfamyTweakDataPostInit", "Oppressor_InfamyTweakDataPostInit_Hawkeye", function(infamy)
    infamy:add_skill_tree(skilltree_name)
end)

Hooks:PostHook(SkillTreeTweakData, "init", "Oppressor_SkillTreeTweakData_init", function(self)
    self:add_skill_tree(skilltree_name)

	local OppressorTreeTiers = {
		{
			"opp_accuracy",
		},
		{
			"opp_reload",
			"opp_rof"
		},
		{
			"opp_damage",
			"opp_ammo"
		},
		{
			"opp_conc_dmg"
		}
	}

	self:add_sub_skill_tree(skilltree_name, "mx_oppressor", OppressorTreeTiers)

    local opp_accuracy_1 = {"minigun_spread_index_addend_1", "lmg_spread_index_addend_1"}
	local opp_accuracy_2 = {"minigun_spread_index_addend_2", "lmg_spread_index_addend_2"}
	self:add_new_skill("opp_accuracy", opp_accuracy_1, opp_accuracy_2, 2, { 8,5 })
	
    local opp_reload_1 = {"minigun_reload_speed_multiplier_1", "lmg_reload_speed_multiplier_1"}
	local opp_reload_2 = {"minigun_reload_speed_multiplier_2", "lmg_reload_speed_multiplier_2"}
	self:add_new_skill("opp_reload", opp_reload_1, opp_reload_2, 2, { 5,1 })

    local opp_rof_1 = {"minigun_fire_rate_multiplier_1", "lmg_fire_rate_multiplier_1"}
	local opp_rof_2 = {"minigun_fire_rate_multiplier_2", "lmg_fire_rate_multiplier_2"}
	self:add_new_skill("opp_rof", opp_rof_1, opp_rof_2, 2, { 1,9 })

    local opp_damage_1 = {"minigun_damage_addend_1", "lmg_damage_addend_1"}
	local opp_damage_2 = {"minigun_damage_multiplier_1", "lmg_damage_multiplier_1"}
	self:add_new_skill("opp_damage", opp_damage_1, opp_damage_2, 3, { 2,2 })

    local opp_ammo_1 = {"minigun_extra_ammo_multiplier_1", "lmg_extra_ammo_multiplier_1"}
	local opp_ammo_2 = {"minigun_extra_ammo_multiplier_2", "lmg_extra_ammo_multiplier_2"}
	self:add_new_skill("opp_ammo", opp_ammo_1, opp_ammo_2, 3, { 3,0 })


    self:add_new_skill("opp_conc_dmg", "player_detection_risk_damage_multiplier_1", "player_detection_risk_damage_multiplier_2", 4, { 4, 11 })
end)