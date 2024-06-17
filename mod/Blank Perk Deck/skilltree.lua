local data = SkillTreeTweakData.init
function SkillTreeTweakData:init(tweak_data)
	data(self, tweak_data)
table.insert(self.specializations,
		{
			name_id = "menu_st_spec_0",
			desc_id = "menu_st_spec_0_desc",
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_1",
				desc_id = "menu_deck0_1_desc"
			},			
			{
				upgrades = {
					},
				cost = 0,
				icon_xy = {900, 5},
				name_id = "menu_deck0_2",
				desc_id = "menu_deck0_2_desc"
			},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_3",
				desc_id = "menu_deck0_3_desc"
			},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_4",
				desc_id = "menu_deck0_4_desc"
			},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 0},
				name_id = "menu_deck0_5",
				desc_id = "menu_deck0_5_desc"
			},

			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_7",
				desc_id = "menu_deck0_7_desc"
			},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_8",
				desc_id = "menu_deck0_8_desc"
			},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_9",
				desc_id = "menu_deck0_9_desc"
			},
					{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 8},
				name_id = "menu_deck0_6",
				desc_id = "menu_deck0_6_desc"
			}
			})
			
table.insert(self.specializations,
			{
			name_id = "menu_st_spec_00",
			desc_id = "menu_st_spec_00_desc",
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 7},
				name_id = "menu_deck00_1",
				desc_id = "menu_deck00_1_desc"
			},
	{	
	upgrades = {
			"weapon_passive_headshot_damage_multiplier"
		},
		cost = 300,
		icon_xy = {1, 0},
		name_id = "menu_deckall_2",
		desc_id = "menu_deckall_2_desc"
	},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 7},
				name_id = "menu_deck0_3",
				desc_id = "menu_deck0_3_desc"
			},
			{
		upgrades = {
			"passive_player_xp_multiplier",
			"player_passive_suspicion_bonus",
			"player_passive_armor_movement_penalty_multiplier"
		},
		cost = 600,
		icon_xy = {3, 0},
		name_id = "menu_deckall_4",
		desc_id = "menu_deckall_4_desc"
	},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 7},
				name_id = "menu_deck0_5",
				desc_id = "menu_deck0_5_desc"
			},
			{
		upgrades = {
			"armor_kit",
			"player_pick_up_ammo_multiplier"
		},
		cost = 1600,
		icon_xy = {5, 0},
		name_id = "menu_deckall_6",
		desc_id = "menu_deckall_6_desc"
	},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 7},
				name_id = "menu_deck0_7",
				desc_id = "menu_deck0_7_desc"
			},
			{
		upgrades = {
			"weapon_passive_damage_multiplier",
			"passive_doctor_bag_interaction_speed_multiplier"
		},
		cost = 3200,
		icon_xy = {7, 0},
		name_id = "menu_deckall_8",
		desc_id = "menu_deckall_8_desc"
	},
			{
				upgrades = {
				},
				cost = 0,
				icon_xy = {900, 7},
				name_id = "menu_deck0_9",
				desc_id = "menu_deck0_9_desc"
			}		
		}
		)
end