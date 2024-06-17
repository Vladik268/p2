function FPCameraPlayerBase:anim_clbk_spawn_cigarette()
	if not self._cigarette_unit then
		local align_obj_name = Idstring("a_weapon_left")
		local align_obj = self._unit:get_object(align_obj_name)
		local cigarette_unit_name = Idstring("units/pd2_mod_smoking/props/cigarette/cigarette")
		local cigarette_unit = World:spawn_unit(cigarette_unit_name, align_obj:position(), align_obj:rotation())

		self._unit:link(align_obj_name, cigarette_unit, cigarette_unit:orientation_object():name())

		self._cigarette_unit = cigarette_unit
	end
end

function FPCameraPlayerBase:anim_clbk_unspawn_cigarette()
	if self._cigarette_unit and alive(self._cigarette_unit) then
		self._cigarette_unit:set_visible(false)
		self._cigarette_unit:set_slot(0)

		self._cigarette_unit = nil
	end
end