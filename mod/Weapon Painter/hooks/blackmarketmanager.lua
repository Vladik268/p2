local weapon_data_functions = {
	"equipped_primary",
	"equipped_secondary"
}

for _, function_name in ipairs(weapon_data_functions) do
	BlackMarketManager["weapon_painter_" .. function_name] = BlackMarketManager["weapon_painter_" .. function_name] or BlackMarketManager[function_name]

	BlackMarketManager[function_name] = function(self, ...)
		local return_data = BlackMarketManager["weapon_painter_" .. function_name](self, ...)

		if return_data and return_data.paints then
			local new_return_data = deep_clone(return_data)

			new_return_data.cosmetics = new_return_data.cosmetics or {}
			new_return_data.cosmetics.paints = return_data.paints

			return new_return_data
		end

		return return_data
	end
end

BlackMarketManager.weapon_painter_get_weapon_texture_switches = BlackMarketManager.weapon_painter_get_weapon_texture_switches or BlackMarketManager.get_weapon_texture_switches
function BlackMarketManager:get_weapon_texture_switches( category, slot, weapon )
	weapon = weapon or self._global.crafted_items[category][slot]
	local return_data = self:weapon_painter_get_weapon_texture_switches( category, slot, weapon )

	if weapon and weapon.paints then

		local new_return_data = return_data and deep_clone(return_data) or {}

		new_return_data.paints = weapon.paints

		return new_return_data
	end

	return return_data
end

BlackMarketManager.weapon_painter_get_weapon_cosmetics = BlackMarketManager.weapon_painter_get_weapon_cosmetics or BlackMarketManager.get_weapon_cosmetics
function BlackMarketManager:get_weapon_cosmetics( ... )
	local return_data = self:weapon_painter_get_weapon_cosmetics( ... )

	if return_data and return_data.id then
		return return_data
	end

	return
end

function BlackMarketManager:get_weapon_paint( category, slot )
	local crafted = self:get_crafted_category_slot(category,slot)
	if ( crafted.paints ) then
		return crafted.paints
	end
end

function BlackMarketManager:set_weapon_paint( category, slot, type, paint_id, is_weapon_skin, weapon_skin_data )
	local crafted = self:get_crafted_category_slot(category,slot)
	crafted.paints = crafted.paints or {}

	crafted.paints[type] = {
		paint_id = paint_id,
		using_weapon_skin = is_weapon_skin,
		weapon_skin_data = weapon_skin_data
	}
end

function BlackMarketManager:clear_weapon_paint( category, slot, type )
	local crafted = self:get_crafted_category_slot(category,slot)
	if not ( crafted.paints ) then return end

	crafted.paints[type] = nil
end