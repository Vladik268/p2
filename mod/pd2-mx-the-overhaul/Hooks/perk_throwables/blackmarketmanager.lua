local VPPP_OutfitString_Block = BlackMarketManager.outfit_string

function BlackMarketManager:outfit_string()
	local outfit_string = VPPP_OutfitString_Block(self)
	local _grenade = self:equipped_grenade()
	if tweak_data.blackmarket.projectiles[_grenade].custom then
		outfit_string = outfit_string:gsub(_grenade, 'concussion') -- I dont care of using based_on like beardlib, I just dont want people to crash
	end
	return outfit_string
end

-- This crap does not work properly
-- local old_BlackMarketManager_damage_addend = BlackMarketManager.damage_addend
-- function BlackMarketManager:damage_addend(name, categories, silencer, detection_risk, current_state, blueprint)
-- 	local value = old_BlackMarketManager_damage_addend(self, name, categories, silencer, detection_risk, current_state, blueprint)
-- 	for _, category in ipairs(categories) do
-- 		value = value + managers.player:upgrade_value(category, "damage_addend_v2", 0)
-- 	end
-- 	return value
-- end
