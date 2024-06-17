Hooks:RegisterHook("BlackMarketManagerModifyGetInventoryCategory")
function BlackMarketManager.get_inventory_category(self, category)

	local t = {}

	for global_value, categories in pairs(self._global.inventory) do
		if categories[category] then

			for id, amount in pairs(categories[category]) do
				table.insert(t, {
					id = id,
					global_value = global_value,
					amount = amount
				})
			end

		end
	end

	Hooks:Call("BlackMarketManagerModifyGetInventoryCategory", self, category, t)

	return t

end