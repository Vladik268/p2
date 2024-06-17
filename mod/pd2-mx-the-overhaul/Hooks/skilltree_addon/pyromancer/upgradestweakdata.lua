Hooks:PostHook(UpgradesTweakData, "init", "Pyromancer_UpgradesTweakData_init", function(self)
    self.values.flamethrower = self.values.flamethrower or {}
    self.values.flamethrower.reload_speed_multiplier = {
        1.45,
        1.75
	}

    self.values.flamethrower.flame_max_range = {
        1600,
        2100
    }

    self.values.flamethrower.magazine_capacity_inc = {
        1.5,
        2
    }

    self.values.flamethrower.damage_addend = {
		5,
		7
	}

    self.values.flamethrower.fire_rate_multiplier = {
		0.3,
		0.40
	}

    -- self.values.flamethrower.hot_trade = {
    --     0.75, -- tick dmg
    --     0.50, -- tick dmg
	-- }

    self.values.flamethrower.dot_damage_addend = {
        -15,
	}

    self.values.flamethrower.dot_length_addend = {
        0.8,
        2
	}
    
    self.values.flamethrower.dot_trigger_chance = {
        10,
        20
	}
  
    self.values.flamethrower.hip_run_and_shoot = {
        true
	}
    
    self.values.flamethrower.extra_ammo_multiplier = {
        1.25,
        1.50
	}

    self.values.flamethrower.thermal_bomb = {
        500,
        400
	}

    self:add_definition(nil, "flame_max_range", "flamethrower", 1)
    self:add_definition(nil, "flame_max_range", "flamethrower", 2)
    self:add_definition(nil, "reload_speed_multiplier", "flamethrower", 1)
    self:add_definition(nil, "reload_speed_multiplier", "flamethrower", 2)
    self:add_definition(nil, "damage_addend", "flamethrower", 1)
    self:add_definition(nil, "damage_addend", "flamethrower", 2)
    self:add_definition(nil, "fire_rate_multiplier", "flamethrower", 1)
    self:add_definition(nil, "fire_rate_multiplier", "flamethrower", 2)
    self:add_definition(nil, "magazine_capacity_inc", "flamethrower", 1)
    self:add_definition(nil, "magazine_capacity_inc", "flamethrower", 2)
    -- self:add_definition(nil, "hot_trade", "flamethrower", 1)
    -- self:add_definition(nil, "hot_trade", "flamethrower", 2)
    self:add_definition(nil, "dot_damage_addend", "flamethrower", 1)
    self:add_definition(nil, "dot_length_addend", "flamethrower", 1)
    self:add_definition(nil, "dot_length_addend", "flamethrower", 2)
    self:add_definition(nil, "dot_trigger_chance", "flamethrower", 1)
    self:add_definition(nil, "dot_trigger_chance", "flamethrower", 2)
    self:add_definition(nil, "extra_ammo_multiplier", "flamethrower", 1)
    self:add_definition(nil, "extra_ammo_multiplier", "flamethrower", 2)
    self:add_definition(nil, "hip_run_and_shoot", "flamethrower", 1)
    self:add_definition(nil, "thermal_bomb", "flamethrower", 1)
    self:add_definition(nil, "thermal_bomb", "flamethrower", 2)
end)