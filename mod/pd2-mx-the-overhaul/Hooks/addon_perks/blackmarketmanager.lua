local old_BlackMarketManager_recoil_addend = BlackMarketManager.recoil_addend
function BlackMarketManager:recoil_addend(name, categories, recoil_index, silencer, blueprint, current_state, is_single_shot)
	local result = old_BlackMarketManager_recoil_addend(self, name, categories, recoil_index, silencer, blueprint, current_state, is_single_shot)
	result = result + managers.player:upgrade_value("player", "stability_increase_bonus_striker", 0)
	return result
end

local old_BlackMarketManager_accuracy_addend = BlackMarketManager.accuracy_addend
function BlackMarketManager:accuracy_addend(name, categories, spread_index, silencer, current_state, fire_mode, blueprint, is_moving, is_single_shot)
	local result = old_BlackMarketManager_accuracy_addend(self, name, categories, spread_index, silencer, current_state, fire_mode, blueprint, is_moving, is_single_shot)
	result = result + managers.player:upgrade_value("player", "accuracy_increase_bonus_striker", 0)
	return result
end


local old_BlackMarketManager_fire_rate_multiplier = BlackMarketManager.fire_rate_multiplier
function BlackMarketManager:fire_rate_multiplier(name, categories, silencer, detection_risk, current_state, blueprint)
	local result = old_BlackMarketManager_fire_rate_multiplier(self, name, categories, silencer, detection_risk, current_state, blueprint)
	
	if categories[1] ~= "grenade_launcher" and managers.player:has_category_upgrade("player", "lonestar_extra_ammo_multiplier") then
		result = result * 1.25 -- 25% Increase
	end
	return result
end
