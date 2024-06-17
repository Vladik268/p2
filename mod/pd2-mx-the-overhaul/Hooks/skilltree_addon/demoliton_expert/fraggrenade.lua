function FragGrenade:bullet_hit()
	if not Network:is_server() or managers.player:has_category_upgrade("grenade_launcher", "bulletproof_nades") then
		return
	end

	print("FragGrenade:bullet_hit()")

	self._timer = nil

	self:_detonate()
end
