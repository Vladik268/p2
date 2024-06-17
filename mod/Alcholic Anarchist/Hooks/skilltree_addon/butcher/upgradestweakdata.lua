Hooks:PostHook(UpgradesTweakData, "init", "Butcher_UpgradesTweakData_init", function(self)
	self.values.player.during_melee_dodge = {
		0.08,
		0.12
	}
	self:add_definition(nil, "during_melee_dodge", "player", 1)
	self:add_definition(nil, "during_melee_dodge", "player", 2)

	self.values.player.butcher_melee_stacking = {
		2,
		3
	}
	self:add_definition(nil, "butcher_melee_stacking", "player", 1)
	self:add_definition(nil, "butcher_melee_stacking", "player", 2)
	
	self.values.player.melee_range_boost = {
		1.50,
		1.70
	}

	self:add_definition(nil, "melee_range_boost", "player", 1)
	self:add_definition(nil, "melee_range_boost", "player", 2)

	self.values.player.melee_speed_boost = {
		0.80,
		0.70
	}

	self:add_definition(nil, "melee_speed_boost", "player", 1)
	self:add_definition(nil, "melee_speed_boost", "player", 2)
	
	self.values.player.melee_charge_run_speed_boost = {
		1.10,
		1.25
	}

	self.values.player.melee_deflect = {
		{
			cooldown = 60,
			duration = 6
		},
		{
			cooldown = 45,
			duration = 6
		}
	}
	
	self:add_definition(nil, "melee_deflect", "player", 1)
	self:add_definition(nil, "melee_deflect", "player", 2)
end)