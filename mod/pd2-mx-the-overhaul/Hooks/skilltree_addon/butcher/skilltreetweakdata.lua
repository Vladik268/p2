local skilltree_name = "mx_pack_2"

Hooks:Add("SF_InfamyTweakDataPostInit", "SF_InfamyTweakDataPostInit_Butcher", function(infamy)
    infamy:add_skill_tree(skilltree_name)
end)

local Old_SkillTreeTweakData_init = SkillTreeTweakData.init
function SkillTreeTweakData:init()
    Old_SkillTreeTweakData_init(self)

    self:add_skill_tree(skilltree_name)

    local treeTiers = {
		{"martial_arts_plus"},
		{"predator_thirst", "pumping_iron_plus"},
		{"counter_strike_plus", "adrenaline"},
        {"predator_deflect"}
	}

    self:add_sub_skill_tree(skilltree_name, "mx_butcher", treeTiers)

    local martial_arts_plus_basic = {"player_melee_damage_dampener", "player_during_melee_dodge_1" }
    local martial_arts_plus_aced = {"player_melee_knockdown_mul", "player_during_melee_dodge_2" }
    self:add_new_skill("martial_arts_plus", martial_arts_plus_basic, martial_arts_plus_aced, 1, {11,7})

    local pumping_iron_plus_basic = {"player_non_special_melee_multiplier", "player_melee_range_boost_1"}
    local pumping_iron_plus_aced = {"player_melee_damage_multiplier", "player_melee_range_boost_2"}
    self:add_new_skill("pumping_iron_plus", pumping_iron_plus_basic, pumping_iron_plus_aced, 2, {1, 3})

	local predator_thirst_basic = {"player_melee_speed_boost_1", "player_temp_melee_kill_increase_reload_speed_1"}
    local predator_thirst_aced = {"player_melee_speed_boost_2"}
    self:add_new_skill("predator_thirst", predator_thirst_basic, predator_thirst_aced, 3, {11,6})

    local counter_strike_plus_basic = {"player_counter_strike_melee", "player_counter_strike_spooc", "player_melee_charge_run_speed_boost_1"}
    local counter_strike_plus_aced = {"player_melee_charge_run_speed_boost_2"}
    self:add_new_skill("counter_strike_plus", counter_strike_plus_basic, counter_strike_plus_aced, 3, {4,12})

    local adrenaline_basic = {"player_butcher_melee_stacking_1"}
    local adrenaline_aced = {"player_butcher_melee_stacking_2"}
    self:add_new_skill("adrenaline", adrenaline_basic, adrenaline_aced, 3, {2, 2})
    
    local predator_deflect_basic = {"player_melee_deflect_1"}
    local predator_deflect_aced = {"player_melee_deflect_2"}
    self:add_new_skill("predator_deflect", predator_deflect_basic, predator_deflect_aced, 4, {0, 11})
end

--[[
	-- Melee attack speed
	-- Extra range
	-- Berserker Plus
	-- Counter attack plus
	-- Pumping iron plus
	-- Hit multiple enemies at once?
]] -- 
