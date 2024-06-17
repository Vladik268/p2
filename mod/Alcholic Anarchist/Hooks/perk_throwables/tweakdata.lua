tweak_data.hud_icons.yakuza_injector = {
    texture = "guis/textures/pd2/equipment_02",
    texture_rect = {
        96,
        0,
        32,
        32
    }
}

tweak_data.hud_icons.burglar_luck = {
    texture = "guis/textures/pd2/equipment_02",
    texture_rect = {
        96,
        0,
        32,
        32
    }
}

tweak_data.hud_icons.med_x = {
    texture = "guis/textures/pd2/equipment_02",
    texture_rect = {
        96,
        0,
        32,
        32
    }
}

tweak_data.hud_icons.adrenaline_shot = {
    texture = "guis/textures/pd2/equipment_02",
    texture_rect = {
        96,
        0,
        32,
        32
    }
}

tweak_data.hud_icons.auto_inject_super_stimpak = {
    texture = "guis/textures/pd2/equipment_02",
    texture_rect = {
        96,
        0,
        32,
        32
    }
}

-- From pd2-lua\lib\tweak_data\hudiconstweakdata.lua
local csb_size = 128
tweak_data.hud_icons.spare_armor_plate = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 4,
        csb_size * 0,
        csb_size,
        csb_size
    }
}

tweak_data.hud_icons.liquid_armor = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 4,
        csb_size * 0,
        csb_size,
        csb_size
    }
}

tweak_data.hud_icons.blood_transfusion = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 6,
        csb_size * 0,
        csb_size,
        csb_size
    }
}

tweak_data.hud_icons.wick_mode = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 2,
        csb_size * 0,
        csb_size,
        csb_size
    }
}

tweak_data.hud_icons.emergency_requisition = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 2,
        csb_size * 0,
        csb_size,
        csb_size
    }
}

tweak_data.hud_icons.lonestar_rage = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 2,
        csb_size * 0,
        csb_size,
        csb_size
    }
}

tweak_data.hud_icons.crooks_con = {
    texture = "guis/dlcs/cee/textures/pd2/crime_spree/boosts_atlas",
    texture_rect = {
        csb_size * 0,
        csb_size * 2,
        csb_size,
        csb_size
    }
}

tweak_data.projectiles.throwable_trip_mine = {
    damage = 110,
    launch_speed = 600,
    adjust_z = 120,
    mass_look_up_modifier = 1,
    -- name_id = "bm_prj_hur",
    -- push_at_body_index = "dynamic_body_spinn",
    sounds = {
        flyby = "hur_flyby",
        flyby_stop = "hur_flyby_stop",
        impact = "hur_impact_gen"
    }
}