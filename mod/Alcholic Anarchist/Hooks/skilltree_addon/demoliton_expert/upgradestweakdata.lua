local old_UpgradesTweakData_init_pd2_values = UpgradesTweakData._init_pd2_values
function UpgradesTweakData:_init_pd2_values()
	old_UpgradesTweakData_init_pd2_values(self, tweak_data)	

    -- Must add table cause by defaut it does not exist
	self.values.grenade_launcher = {}

	self.values.grenade_launcher.bulletproof_nades = { true }

	self.values.grenade_launcher.afterburn = { true }

	-- Rapid Reload
	self.values.grenade_launcher.reload_speed_multiplier = {1.35, 1.75, 3, 4}

	-- Strong Back
	self.values.grenade_launcher.extra_ammo_multiplier = {
		1.35, 
		1.50,  
	} 

	-- Swap speed, I'm not sure if I need it or not
	self.values.grenade_launcher.swap_speed_multiplier = {1.50, 2, 3} 

	-- Hip Fire!
	self.values.grenade_launcher.hip_run_and_shoot = {
		true
	}

	self.values.player.explosion_resistance = {
		0.5, -- 50% resistance
		0.20 -- 80% resistance
	}

	self.values.player.primer_round = {
		0.40,
		0.55
	}

	self.values.grenade_launcher.fire_rate_multiplier = {
		1.25,
		1.50
	}
end

local old_UpgradesTweakData_weapon_definitions = UpgradesTweakData._weapon_definitions
function UpgradesTweakData:_weapon_definitions()
	old_UpgradesTweakData_weapon_definitions(self)

	self:add_definition("grenade_launcher_fire_rate_multiplier_1", "fire_rate_multiplier", "grenade_launcher", 1)
	self:add_definition("grenade_launcher_fire_rate_multiplier_2", "fire_rate_multiplier", "grenade_launcher", 2)
	
	self:add_definition("grenade_launcher_bulletproof_nades_1", "bulletproof_nades", "grenade_launcher", 1)

	self:add_definition("grenade_launcher_afterburn", "afterburn", "grenade_launcher", 1)

	self.definitions.grenade_launcher_extra_ammo_multiplier_1 = {
		name_id = "menu_grenade_launcher_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "extra_ammo_multiplier",
			category = "grenade_launcher"
		}
	}
	self.definitions.grenade_launcher_extra_ammo_multiplier_2 = {
		name_id = "menu_grenade_launcher_extra_ammo_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "extra_ammo_multiplier",
			category = "grenade_launcher"
		}
	}

	self.definitions.grenade_launcher_reload_speed_multiplier_1 = {
		name_id = "menu_grenade_launcher_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "reload_speed_multiplier",
			category = "grenade_launcher"
		}
	}
	self.definitions.grenade_launcher_reload_speed_multiplier_2 = {
		name_id = "menu_grenade_launcher_reload_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "reload_speed_multiplier",
			category = "grenade_launcher"
		}
	}

	self.definitions.grenade_launcher_hip_run_and_shoot_1 = {
		name_id = "menu_grenade_launcher_hip_run_and_shoot",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "hip_run_and_shoot",
			category = "grenade_launcher"
		}
	}


	self.definitions.grenade_launcher_swap_speed_multiplier_1 = {
		name_id = "menu_grenade_launcher_swap_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "swap_speed_multiplier",
			category = "grenade_launcher"
		}
	}

	self.definitions.player_explosion_resistance_1 = {
		name_id = "menu_player_explosion_resistance",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "explosion_resistance",
			category = "player"
		}
	}

	self.definitions.player_explosion_resistance_2 = {
		name_id = "menu_player_explosion_resistance",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "explosion_resistance",
			category = "player"
		}
	}

	self.definitions.player_primer_round_1 = {
		name_id = "menu_player_primer_round",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "primer_round",
			category = "player"
		}
	}

	self.definitions.player_primer_round_2 = {
		name_id = "menu_player_primer_round",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "primer_round",
			category = "player"
		}
	}
end