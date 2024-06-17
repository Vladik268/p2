function AddAddonPerks(self)
    -- Updated to use the default perks from then current perkdecks, ence making it compatible with any existing overhaul mod (hopefully)
    local deck2 = deep_clone(self.specializations[1][2])
    deck2.cost = 0
	local deck4 = deep_clone(self.specializations[1][4])
    deck4.cost = 0
	local deck6 = deep_clone(self.specializations[1][6])
    deck6.cost = 0
	local deck8 = deep_clone(self.specializations[1][8])
    deck8.cost = 0

    local dodgeOpath = {
        {
            cost = 0,
            desc_id = "dodgeopath_1_desc",
            name_id = "dodgeopath_1",
            upgrades = {
                "player_damage_dampener_outnumbered_strong",
                "melee_stacking_hit_damage_multiplier_1",
                "player_passive_dodge_chance_2",
                "temporary_dodgeopath_speed_1",
                "temporary_dodgeopath_invulnerability_on_kill_1",
                "the_mixtape",
                "temporary_the_mixtape_1"
            },
            icon_xy = {
                6,
                4
            }
        },
        deck2,
        {
            cost = 0,
            desc_id = "dodgeopath_3_desc",
            name_id = "dodgeopath_3",
            upgrades = {

            },
            icon_xy = {
                0,
                5
            }
        },
        deck4,
        {
            cost = 0,
            desc_id = "dodgeopath_5_desc",
            name_id = "dodgeopath_5",
            upgrades = {
                "player_damage_dampener_close_contact_1"
            },
            icon_xy = {
                1,
                5
            }
        },
        deck6,
        {
            cost = 0,
            desc_id = "dodgeopath_7_desc",
            name_id = "dodgeopath_7",
            upgrades = {

            },
            icon_xy = {
                2,
                5
            }
        },
        deck8,
        {
            cost = 0,
            desc_id = "dodgeopath_9_desc",
            name_id = "dodgeopath_9",
            upgrades = {
                "player_passive_loot_drop_multiplier",
                "player_killshot_close_panic_chance"
            },
            icon_xy = {
                3,
                5
            }
        },
        name_id = "dodgeopath",
        desc_id = "dodgeopath_desc"
    }

    local striker = {
        {
            cost = 0,
            name_id = "striker_1",
            desc_id = "striker_1_desc",
            texture_bundle_folder = "addon_perks_striker",
            upgrades = {
                "player_striker_accuracy_to_damage_1",
                "player_stability_increase_bonus_striker_1",
                "player_accuracy_increase_bonus_striker_1"
            },
            icon_xy = {
                2,
                0
            }
        },
        deck2,
        {
            cost = 0,
            name_id = "striker_3",
            desc_id = "striker_3_desc",
            texture_bundle_folder = "addon_perks_striker",
            upgrades = {

            },
            icon_xy = {
                0,
                0
            }
        },
        deck4,
        {
            cost = 0,
            name_id = "striker_5",
            desc_id = "striker_5_desc",
            texture_bundle_folder = "addon_perks_striker",
            upgrades = {

            },
            icon_xy = {
                1,
                0
            }
        },
        deck6,
        {
            cost = 0,
            name_id = "striker_7",
            desc_id = "striker_7_desc",
            texture_bundle_folder = "addon_perks_striker",
            upgrades = {

            },
            icon_xy = {
                1,
                0
            }
        },
        deck8,
        {
            custom = true,
            cost = 0,
            name_id = "striker_9",
            desc_id = "striker_9_desc",
            upgrades = {
                "player_passive_loot_drop_multiplier",
            },
            texture_bundle_folder = "addon_perks_striker",
            icon_xy = {
                1,
                1
            }
        },
        custom = true,
        custom_id = "Striker",
        name_id = "striker",
        desc_id = "striker_desc",
    }

    local lonestar = {
        {
            cost = 0,
            name_id = "lonestar_1",
            desc_id = "lonestar_1_desc",
            texture_bundle_folder = "addon_perks_lonestar",
            upgrades = {
                "lonestar_rage",
                "temporary_lonestar_rage_1",
                "player_lonestar_extra_ammo_multiplier_1",
            },
            icon_xy = {
                0,
                0
            }
        },
        deck2,
        {
            cost = 0,
            name_id = "lonestar_3",
            desc_id = "lonestar_3_desc",
            texture_bundle_folder = "addon_perks_lonestar",
            upgrades = {
    
            },
            icon_xy = {
                1,
                0
            }
        },
        deck4,
        {
            cost = 0,
            name_id = "lonestar_5",
            desc_id = "lonestar_5_desc",
            texture_bundle_folder = "addon_perks_lonestar",
            upgrades = {
    
            },
            icon_xy = {
                2,
                0
            }
        },
        deck6,
        {
            cost = 0,
            name_id = "lonestar_7",
            desc_id = "lonestar_7_desc",
            texture_bundle_folder = "addon_perks_lonestar",
            upgrades = {
    
            },
            icon_xy = {
                3,
                0
            }
        },
        deck8,
        {
            custom = true,
            cost = 0,
            name_id = "lonestar_9",
            desc_id = "lonestar_9_desc",
            upgrades = {
                "player_passive_loot_drop_multiplier",
            },
            texture_bundle_folder = "addon_perks_lonestar",
            icon_xy = {
                0,
                0
            }
        },
        custom = true,
        custom_id = "lonestar",
        name_id = "lonestar",
        desc_id = "lonestar_desc",
    }

    local redacted = {
        {
            cost = 0,
            name_id = "redacted_1",
            desc_id = "redacted_1_desc",
            texture_bundle_folder = "addon_perks_redacted",
            upgrades = {
                "player_redacted_pain_1",
                "player_passive_health_multiplier_4",
                "player_redacted_damage_reduction_1"
            },
            icon_xy = {
                0,
                0
            }
        },
        deck2,
        {
            cost = 0,
            name_id = "redacted_3",
            desc_id = "redacted_3_desc",
            texture_bundle_folder = "addon_perks_redacted",
            upgrades = {
    
            },
            icon_xy = {
                1,
                0
            }
        },
        deck4,
        {
            cost = 0,
            name_id = "redacted_5",
            desc_id = "redacted_5_desc",
            texture_bundle_folder = "addon_perks_redacted",
            upgrades = {
    
            },
            icon_xy = {
                2,
                0
            }
        },
        deck6,
        {
            cost = 0,
            name_id = "redacted_7",
            desc_id = "redacted_7_desc",
            texture_bundle_folder = "addon_perks_redacted",
            upgrades = {
    
            },
            icon_xy = {
                3,
                0
            }
        },
        deck8,
        {
            custom = true,
            cost = 0,
            name_id = "redacted_9",
            desc_id = "redacted_9_desc",
            upgrades = {
                "player_passive_loot_drop_multiplier",
                "player_killshot_close_panic_chance"
            },
            texture_bundle_folder = "addon_perks_redacted",
            icon_xy = {
                0,
                1
            }
        },
        custom = true,
        custom_id = "redacted",
        name_id = "redacted",
        desc_id = "redacted_desc",
    }

    table.insert(self.specializations, dodgeOpath)
    table.insert(self.specializations, striker)
    table.insert(self.specializations, lonestar)
    table.insert(self.specializations, redacted)
end

Hooks:PostHook(SkillTreeTweakData, "init", "addon_perks_SkillTreeTweakData_init", AddAddonPerks)
