Hooks:PostHook(UpgradesTweakData, "init", "VPPP_UpgradesTweakData_init", function(self)
	self:common_add_throwables("yakuza_injector", 1, 8)
	self:common_add_throwables("burglar_luck", 1, 8)
	self:common_add_throwables("med_x", 1, 8)
	self:common_add_throwables("adrenaline_shot", 2, 10)
	self:common_add_throwables("spare_armor_plate", 1, 0.5)
	self:common_add_throwables("liquid_armor", 2, 10)
	self:common_add_throwables("blood_transfusion", 1, 0.5)
	self:common_add_throwables("wick_mode", 1, 6)
	self:common_add_throwables("emergency_requisition", 1, 2)
	self:common_add_throwables("auto_inject_super_stimpak", 1, 0.1)
	self:common_add_throwables("the_mixtape", 1, 4)
	self:common_add_throwables("throwable_trip_mine", 1, 0.1)
	self:common_add_throwables("jet", 1, 8)
	self:common_add_throwables("whiff", 2, 8)
	self:common_add_throwables("lonestar_rage", 0, 5)
	self:common_add_throwables("crooks_con", 1, 4)
	self:common_add_throwables("crew_synchrony", 1, 12)
	self:common_add_throwables("buff_banner", 1, 12)
	-- self.values.player.body_armor.dodge[1] = 1 -- Debug always dodgde
	-- mx_print_table(self.specialization_descs)
end)

-- Todo make new override for [pd2-lua\lib\managers\menu\skilltreegui.lua]SpecializationTierItem:init the self._desc_string and use new macros

--[[
	cooldown_reduction on kill, does not includes the custom cooldown reductions, like on melee or explosive kill
]]
function UpgradesTweakData:common_add_throwables(name_id, cooldown_reduction, duration)
	self.values.temporary[name_id] = {
		{
			cooldown_reduction,
			duration,
		}
	}

	self.definitions[name_id] = {
		category = "grenade",
	}

	self.definitions["temporary_"..name_id.."_1"] = {
		name_id = "menu_temporary_"..name_id.."_1",
		category = "temporary",
		upgrade = {
			value = 1,
			upgrade = name_id,
			category = "temporary"
		}
	}
end
