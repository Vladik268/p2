Hooks:PostHook(UpgradesTweakData, "init", "Oppressor_UpgradesTweakData_init", function(self)
    self.values.lmg.reload_speed_multiplier = {1.2, 1.5}
    self.values.lmg.fire_rate_multiplier = {1.20,1.4}
    self.values.lmg.damage_addend = {0.5}
    self.values.lmg.damage_multiplier = {1.10}
    self.values.lmg.extra_ammo_multiplier = {1.25,1.50}
    self.values.lmg.spread_index_addend = {2,3}
    self.values.minigun.reload_speed_multiplier = {1.2, 1.5}
    self.values.minigun.fire_rate_multiplier = {1.20,1.4}
    self.values.minigun.damage_addend = {0.5}
    self.values.minigun.damage_multiplier = {1.10}
    self.values.minigun.extra_ammo_multiplier = {1.25,1.50}
    self.values.minigun.spread_index_addend = {2,3}


    self.values.player.detection_risk_damage_multiplier = {
        {
            0.05,-- gain 5% dmg for 
            6, -- every x points       
            "above", -- MAX: 7=25% 6=30% 5=40% 4=50% 3=65%
            35 -- above x 
        },
        {
            0.05,
            5,
            "above",
            35
        }
    }

    self:add_definition(nil, "reload_speed_multiplier", "minigun", 1)
    self:add_definition(nil, "reload_speed_multiplier", "minigun", 2)
    self:add_definition(nil, "fire_rate_multiplier", "minigun", 1)
    self:add_definition(nil, "fire_rate_multiplier", "minigun", 2)
    self:add_definition(nil, "damage_addend", "minigun", 1)
    self:add_definition(nil, "damage_multiplier", "minigun", 1)
    self:add_definition(nil, "extra_ammo_multiplier", "minigun", 1)
    self:add_definition(nil, "extra_ammo_multiplier", "minigun", 2)
    self:add_definition(nil, "spread_index_addend", "minigun", 1)
    self:add_definition(nil, "spread_index_addend", "minigun", 2)
    
    self:add_definition(nil, "detection_risk_damage_multiplier", "player", 1)
    self:add_definition(nil, "detection_risk_damage_multiplier", "player", 2)

    self:add_definition(nil, "reload_speed_multiplier", "lmg", 1)
    self:add_definition(nil, "reload_speed_multiplier", "lmg", 2)
    self:add_definition(nil, "fire_rate_multiplier", "lmg", 1)
    self:add_definition(nil, "fire_rate_multiplier", "lmg", 2)
    self:add_definition(nil, "damage_addend", "lmg", 1)
    self:add_definition(nil, "damage_multiplier", "lmg", 1)
    self:add_definition(nil, "extra_ammo_multiplier", "lmg", 1)
    self:add_definition(nil, "extra_ammo_multiplier", "lmg", 2)
    self:add_definition(nil, "spread_index_addend", "lmg", 1)
    self:add_definition(nil, "spread_index_addend", "lmg", 2)
end)