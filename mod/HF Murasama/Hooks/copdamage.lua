CopDamage.pre_rick_boy_dismember_condition = CopDamage.pre_rick_boy_dismember_condition or CopDamage._dismember_condition

function CopDamage:_dismember_condition(attack_data)
	local dismember_victim = self:pre_rick_boy_dismember_condition(attack_data)

	local target_is_spook = false
	if alive(attack_data.col_ray.unit) and attack_data.col_ray.unit:base() then
		target_is_spook = attack_data.col_ray.unit:base()._tweak_table == "spooc"
	end

	local melee_entry = managers.blackmarket:equipped_melee_weapon()
	local melee_tweak =  tweak_data.blackmarket.melee_weapons[melee_entry]

	if target_is_spook and melee_tweak and melee_tweak.dismember then
		dismember_victim = true
	end

	return dismember_victim
end