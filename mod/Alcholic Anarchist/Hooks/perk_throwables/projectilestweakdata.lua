Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "VPPP_init_projectiles", function (self)
    local injectors = {
        {
            name_id = "yakuza_injector",
            base_cooldown = 30,
            max_amount = 1,
        },
        {
            name_id = "burglar_luck",
            base_cooldown = 30,
            max_amount = 1,
        },
        {
            name_id = "med_x",
            base_cooldown = 50,
            max_amount = 1,
        },
        {
            name_id = "auto_inject_super_stimpak",
            base_cooldown = 210,
            max_amount = 1,
        },
        {
            name_id = "adrenaline_shot",
            base_cooldown = 60,
            max_amount = 2,
        },
        {
            name_id = "spare_armor_plate",
            base_cooldown = 90,
            max_amount = 2,
            activate = "" -- I know, it's a bad fix, but I had no better idea to disable the sound and keep the default value defined
        },
        {
            name_id = "liquid_armor",
            base_cooldown = 90,
            max_amount = 1,
            activate = "" -- I know, it's a bad fix, but I had no better idea to disable the sound and keep the default value defined
        },
        {
            name_id = "blood_transfusion",
            base_cooldown = 40,
            max_amount = 1,
        },
        {
            name_id = "wick_mode",
            base_cooldown = 50,
            max_amount = 1,
        },
        {
            name_id = "emergency_requisition",
            base_cooldown = 25,
            max_amount = 1,
            activate = "" -- I know, it's a bad fix, but I had no better idea to disable the sound and keep the default value defined
        },
        {
            name_id = "the_mixtape",
            base_cooldown = 40,
            max_amount = 1,
            icon = "chico_injector"
        },
        {
            name_id = "jet",
            base_cooldown = 40,
            max_amount = 1,
            icon = "chico_injector"
        },
        {
            name_id = "whiff",
            base_cooldown = 40,
            max_amount = 1,
            icon = "chico_injector"
        },
        {
            name_id = "lonestar_rage",
            base_cooldown = 40,
            max_amount = 1,
            icon = "lonestar_rage"
        },
        {
            name_id = "crooks_con",
            base_cooldown = 35,
            max_amount = 2,
            icon = "crooks_con"
        },
        {
            name_id = "crew_synchrony",
            base_cooldown = 50,
            max_amount = 1,
            icon = "blood_transfusion"
        },
        {
            name_id = "buff_banner",
            base_cooldown = 90,
            max_amount = 1,
            icon = "blood_transfusion"
        },
    }

    for i, injector in ipairs(injectors) do
        self.projectiles[injector.name_id] = {
            name_id = "bm_ability_"..injector.name_id.."",
            desc_id = "bm_ability_"..injector.name_id.."_desc",
            ignore_statistics = true,
            icon = injector.icon or injector.name_id,
            ability = injector.name_id,
            texture_bundle_folder = "mods",
            base_cooldown = injector.base_cooldown,
            max_amount = injector.max_amount,
            custom = true,
            sounds = {
                activate = injector.activate or "perkdeck_activate",
                cooldown = "perkdeck_cooldown_over"
            }
        }
    end

    self.projectiles.throwable_trip_mine = {
        name_id = "bm_ability_throwable_trip_mine",
        desc_id = "bm_ability_throwable_trip_mine_desc",
        custom = true,
        base_cooldown = 80,
        max_amount = 2,
        icon = "equipment_trip_mine",
		unit = "units/mx_throwables/throwable_trip_mine",
		unit_dummy = "units/payday2/equipment/gen_equipment_tripmine/gen_equipment_tripmine_dummy",
		local_unit = "units/mx_throwables/throwable_trip_mine",
		throw_shout = true,
		no_cheat_count = true,
		impact_detonation = true,
		client_authoritative = true,
		add_trail_effect = true,
		throwable = true,
		texture_bundle_folder = "mods",
		anim_global_param = "projectile_four",
		throw_allowed_expire_t = 0.15,
		expire_t = 1.1,
		repeat_expire_t = 0.5
	}
end)