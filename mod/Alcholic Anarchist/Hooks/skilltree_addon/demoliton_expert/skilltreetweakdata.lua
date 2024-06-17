local skilltree_name = "mx_pack"

Hooks:Add("SF_InfamyTweakDataPostInit", "SF_InfamyTweakDataPostInit_Demo_Exp", function(infamy)
    infamy:add_skill_tree(skilltree_name)
end)

local Old_SkillTreeTweakData_init = SkillTreeTweakData.init
function SkillTreeTweakData:init()
	Old_SkillTreeTweakData_init(self)   

	self:add_skill_tree(skilltree_name)

	local demolitionistTreeTiers = {
		{
			"the_demolitionist_sacrifice"
		},
		{
			"strong_back",
			"rapid_reload"
		},
		{
			"hard_skin",
			"good_demoman"
		},
		{
			"primer_round"
		}
	}

	self:add_sub_skill_tree(skilltree_name, "mx_demolitionist", demolitionistTreeTiers)
	self:add_new_skill("the_demolitionist_sacrifice", "grenade_launcher_bulletproof_nades_1", "grenade_launcher_afterburn", 1, { 6,6 })

	self:add_new_skill("strong_back", "grenade_launcher_extra_ammo_multiplier_1", "grenade_launcher_extra_ammo_multiplier_2", 2, { 6,0 })
	self:add_new_skill("rapid_reload", {"grenade_launcher_reload_speed_multiplier_1"}, {"grenade_launcher_reload_speed_multiplier_2"}, 2, { 1,9 })

	local good_demoman_1 = {"grenade_launcher_hip_run_and_shoot_1", "grenade_launcher_fire_rate_multiplier_1"}
	local good_demoman_2 = {"grenade_launcher_swap_speed_multiplier_1", "grenade_launcher_fire_rate_multiplier_2"}
	self:add_new_skill("good_demoman", good_demoman_1, good_demoman_2, 3, { 9,10 })
	self:add_new_skill("hard_skin", {"player_explosion_resistance_1"}, {"player_explosion_resistance_2"}, 3, { 1,7 })
	
	-- self:add_new_skill("primer_round", {"player_primer_round_1"}, {"player_primer_round_2"}, 4, { 0,0 }, "icons_atlas_mx")
	self:add_new_skill("primer_round", {"player_primer_round_1"}, {"player_primer_round_2"}, 4, { 9,9 })
end