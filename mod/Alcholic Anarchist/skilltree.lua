
local data = SkillTreeTweakData.init
function SkillTreeTweakData:init(tweak_data)
data(self, tweak_data)
local ps2 = {
upgrades = {"weapon_passive_headshot_damage_multiplier"},
cost = 300,
icon_xy = {1, 0},
name_id = "all_2",
desc_id = "all_2_desc"}
local ps4 = {
upgrades = {"passive_player_xp_multiplier",
"player_passive_suspicion_bonus",
"player_passive_armor_movement_penalty_multiplier"},
cost = 600,
icon_xy = {3, 0},
name_id = "all_4",
desc_id = "all_4_desc"}
local ps6 = {
upgrades = {"armor_kit",
"player_pick_up_ammo_multiplier"},
cost = 1600,
icon_xy = {5, 0},
name_id = "all_6",
desc_id = "all_6_desc"}
local ps8 = {
upgrades = {"weapon_passive_damage_multiplier",
"passive_doctor_bag_interaction_speed_multiplier"},
cost = 3200,
icon_xy = {7, 0},
name_id = "all_8",
desc_id = "all_8_desc"}
local pc1 = 200
local pc3 = 300
local pc5 = 400
local pc7 = 600
local pc9 = 1000
local pdcb = "player_passive_loot_drop_multiplier"
table.insert(self.specializations,{
name_id = "anarchistoic'name",
desc_id = "anarchistoic'desc",{
upgrades = {
"player_damage_control_passive", "temporary_damage_control", "damage_control", "player_damage_control_cooldown_drain_1", "player_armor_grinding_1", "player_perk_armor_regen_timer_multiplier_1", "temporary_armor_break_invulnerable_1", "player_tier_armor_multiplier_2"
},
cost = pc1,
icon_xy = {1, 1},
name_id = "anarchistoic'perk1n",
desc_id = "anarchistoic'perk1d"},
ps2,{
upgrades = {
"player_tier_armor_multiplier_4", "player_perk_armor_regen_timer_multiplier_2", "player_armor_increase_1", "player_health_decrease_1"
},
cost = pc3,
icon_xy = {1, 1},
name_id = "anarchistoic'perk3n",
desc_id = "anarchistoic'perk3d"},
ps4,{
upgrades = {
"player_tier_armor_multiplier_4", "player_armor_regen_damage_health_ratio_multiplier_2", "player_armor_increase_2", "player_damage_control_auto_shrug"
},
cost = pc5,
icon_xy = {1, 1},
name_id = "anarchistoic'perk5n",
desc_id = "anarchistoic'perk5d"},
ps6,{
upgrades = {
"player_armor_regen_timer_multiplier_passive", "player_perk_armor_regen_timer_multiplier_4", "player_armor_regen_damage_health_ratio_multiplier_3", "player_armor_increase_3", "player_damage_control_cooldown_drain_2"
},
cost = pc7,
icon_xy = {1, 1},
name_id = "anarchistoic'perk7n",
desc_id = "anarchistoic'perk7d"},
ps8,{
upgrades = {
"player_tier_armor_multiplier_6", "player_perk_armor_regen_timer_multiplier_5", "player_damage_to_armor_1", "player_damage_control_healing", "player_tier_armor_multiplier_1", "weapon_passive_swap_speed_multiplier_1", "player_armor_increase_3"
},
cost = pc9,
icon_xy = {1, 1},
name_id = "anarchistoic'perk9n",
desc_id = "anarchistoic'perk9d"}})
end