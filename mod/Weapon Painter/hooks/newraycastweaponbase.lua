NewRaycastWeaponBase.weapon_painter_set_texture_switches = NewRaycastWeaponBase.weapon_painter_set_texture_switches or NewRaycastWeaponBase.set_texture_switches

function NewRaycastWeaponBase:set_texture_switches( texture_switches )
	self:weapon_painter_set_texture_switches( texture_switches )

	if texture_switches and texture_switches.paints and self.set_paint_data then
		self:set_paint_data(texture_switches.paints)
	end
end