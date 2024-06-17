Hooks:PostHook(NewFlamethrowerBase, "setup_default", "Pyromancer_NewFlamethrowerBase_setup_default", function(self)
	self._flame_max_range = managers.player:upgrade_value("flamethrower", "flame_max_range", 1000)
end)

function NewFlamethrowerBase:calculate_ammo_max_per_clip()
    local added = NewFlamethrowerBase.super.calculate_ammo_max_per_clip(self)
	local weapon_tweak_data = self:weapon_tweak_data()

    local ammo = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX + added
    for _, category in ipairs(tweak_data.weapon[self._name_id].categories) do
		ammo = ammo * managers.player:upgrade_value(category, "magazine_capacity_inc", 1)
	end

    return ammo
end

function NewFlamethrowerBase:run_and_shoot_allowed()
	local allowed = NewFlamethrowerBase.super.run_and_shoot_allowed(self)

	return allowed or managers.player:has_category_upgrade("flamethrower", "hip_run_and_shoot")
end