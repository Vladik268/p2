function UpgradesTweakData:add_definition(key, upgrade, category, value)
	key = key or category.."_"..upgrade.."_"..tostring(value)
    self.definitions[key] = {
		name_id = "menu_"..key,
		category = "feature",
		upgrade = {
			value = value,
			upgrade = upgrade,
			category = category
		}
	}
end

function UpgradesTweakData:add_definition_v2(category, upgrade, values)
	for _, value in ipairs(values) do
		local key = category.."_"..upgrade.."_"..tostring(value)
    self.definitions[key] = {
		name_id = "menu_"..key,
		category = "feature",
		upgrade = {
			value = value,
			upgrade = upgrade,
			category = category
		}
	}
	end
end

function UpgradesTweakData:add_temporary_upgrades_v2(name_id, values)
	for _, value in ipairs(values) do
		self.definitions["temporary_"..name_id.."_1"] = {
			name_id = "menu_temporary_"..name_id.."_1",
			category = "temporary",
			upgrade = {
				value = value,
				upgrade = name_id,
				category = "temporary"
			}
		}
	end
end