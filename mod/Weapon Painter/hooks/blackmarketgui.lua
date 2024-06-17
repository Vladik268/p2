Hooks:PostHook( BlackMarketGui, "_setup", "WeaponPainter_Setup", function(self, is_start_page, component_data)
	local is_weapon_mods = self._data.topic_id == "bm_menu_blackmarket_title"

	if is_weapon_mods then
		local current_mode = self._edit_mode_gui and self._edit_mode_gui._current_mode or 1

		self._edit_mode_gui = WeaponEditModeGui:new(self._ws, self._panel, self, current_mode)
		self._data_backup = self._data_backup or deep_clone(self._data)
	end
end)

Hooks:PostHook( BlackMarketGui, "mouse_moved", "WeaponPainter_MouseMoved", function(self, o, x, y)
	if self._edit_mode_gui then
		self._edit_mode_gui:mouse_moved(x, y)
	end
end)

Hooks:PostHook( BlackMarketGui, "mouse_pressed", "WeaponPainter_MouseMoved", function(self, button, x, y)
	if self._edit_mode_gui then
		self._edit_mode_gui:mouse_pressed(button, x, y)
	end
end)

function BlackMarketGui:populate_paints(data)
	local cosmetics_data = tweak_data.blackmarket.weapon_skins
	local crafted = managers.blackmarket:get_crafted_category(data.category)[data.prev_node_data and data.prev_node_data.slot]
	local index_i = 1

	local part_id = data.on_create_data.main_part_id

	local part_type = data.on_create_data.part_type
	local part_type_is_string = type(part_type) == "string"

	local current_equipped_string = nil
	if ( crafted and crafted.paints and crafted.paints[part_type] ) then
		local paint_inv_data = crafted.paints[part_type]
		if paint_inv_data.paint_id then
			if paint_inv_data.weapon_skin_data and paint_inv_data.weapon_skin_data.quality then
				current_equipped_string = paint_inv_data.paint_id .. "_" .. paint_inv_data.weapon_skin_data.quality
			else
				current_equipped_string = paint_inv_data.paint_id
			end
		end
	end

	local function make_skin_cosmetic_data(cosmetic_id, quality, equipped)
		local my_cd = cosmetics_data[cosmetic_id]

		local new_data = {
			name = cosmetic_id .. "_" .. quality,
			name_localized = my_cd and my_cd.name_id and managers.localization:text(my_cd.name_id) or managers.localization:text("bm_menu_no_mod"),
			desc_id = my_cd and my_cd.desc_id,
			category = data.category or data.prev_node_data and data.prev_node_data.category
		}
		local bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(my_cd.weapon_id, {
			id = cosmetic_id
		})
		new_data.bitmap_texture = bitmap_texture
		new_data.bg_texture = bg_texture

		if string.match(string.lower(managers.localization:text(new_data.desc_id)), "modification") then
			new_data.desc_id = nil
		end

		new_data.slot = data.slot or data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = my_cd and my_cd.global_value or "normal"
		new_data.cosmetic_id = cosmetic_id
		new_data.cosmetic_quality = quality
		new_data.cosmetic_rarity = my_cd and my_cd.rarity or "common"
		new_data.unlocked = true
		new_data.equipped = equipped
		new_data.stream = true

		if not crafted.previewing then
			if new_data.equipped then
				table.insert(new_data, "custom_unselect")
			else
				table.insert(new_data, "custom_select")
			end
		end

		if part_type_is_string then
			new_data.custom_callback = {
				custom_select = function(data, bm_gui)
					managers.blackmarket:set_weapon_paint( new_data.category, new_data.slot, part_type, cosmetic_id, true, { quality = quality } )
					managers.blackmarket:view_weapon( new_data.category, new_data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data() )
					bm_gui:reload()
				end,
				custom_unselect = function(data, bm_gui)
					managers.blackmarket:clear_weapon_paint( new_data.category, new_data.slot, part_type )
					managers.blackmarket:view_weapon( new_data.category, new_data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data() )
					bm_gui:reload()
				end
			}
		else
			new_data.custom_callback = {
				custom_select = function(data, bm_gui)
					for _, part_tipe in ipairs(part_type) do
						managers.blackmarket:set_weapon_paint( new_data.category, new_data.slot, part_tipe, cosmetic_id, true, { quality = quality } )
					end
					managers.blackmarket:view_weapon( new_data.category, new_data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data() )
					bm_gui:reload()
				end
			}
		end

		return new_data
	end

	local function make_texture_cosmetic_data(paint_id, paint_data, equipped)
		local guis_catalog = "guis/"
		if paint_data.texture_bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(paint_data.texture_bundle_folder) .. "/"
		end

		local new_data = {
			name = paint_id,
			name_localized = managers.localization:text(paint_data.name_id or "bm_w_paint_" .. paint_id),
			desc_id = paint_data.desc_id or "bm_w_paint_" .. paint_id .. "_desc",
			category = data.category or data.prev_node_data and data.prev_node_data.category
		}
		new_data.bitmap_texture = paint_data.icon or ( guis_catalog .. "textures/pd2/blackmarket/icons/texture_variants/" .. part_id .. "/" .. new_data.name )

		new_data.slot = data.slot or data.prev_node_data and data.prev_node_data.slot
		new_data.unlocked = true
		new_data.equipped = equipped

		if not crafted.previewing then
			if new_data.equipped then
				table.insert(new_data, "custom_unselect")
			else
				table.insert(new_data, "custom_select")
			end
		end

		new_data.custom_callback = {
			custom_select = function(data, bm_gui)
				managers.blackmarket:set_weapon_paint( new_data.category, new_data.slot, part_type, paint_id, false )
				managers.blackmarket:view_weapon( new_data.category, new_data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data() )
				bm_gui:reload()
			end,
			custom_unselect = function(data, bm_gui)
				managers.blackmarket:clear_weapon_paint( new_data.category, new_data.slot, part_type )
				managers.blackmarket:view_weapon( new_data.category, new_data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data() )
				bm_gui:reload()
			end
		}

		return new_data
	end

	if not part_type_is_string then
		bitmap_texture, bg_texture = managers.blackmarket:get_weapon_icon_path(data.prev_node_data.name, nil)

		local new_data = {
			name = "clear_all",
			name_localized = managers.localization:text("bm_menu_clear_all"),
			desc_id = "bm_menu_clear_all_desc",
			category = data.category or data.prev_node_data and data.prev_node_data.category
		}
		new_data.bitmap_texture = bitmap_texture
		new_data.slot = data.slot or data.prev_node_data and data.prev_node_data.slot
		new_data.unlocked = true

		table.insert(new_data, "custom_select")
		new_data.custom_callback = {
			custom_select = function(data, bm_gui)
				for _, part_tipe in ipairs(part_type) do
					managers.blackmarket:clear_weapon_paint( new_data.category, new_data.slot, part_tipe )
				end
				managers.blackmarket:view_weapon( new_data.category, new_data.slot, callback(self, self, "_update_crafting_node"), nil, BlackMarketGui.get_crafting_custom_data() )
				bm_gui:reload()
			end
		}

		data[index_i] = new_data
		index_i = index_i + 1
	end

	local texture_variants = data.on_create_data.texture_variants or {}
	local mod_texture_bundle_folder = data.on_create_data.texture_bundle_folder
	for paint_id, paint_data in pairs(texture_variants) do
		if type(paint_data) == "table" then
			paint_data.texture_bundle_folder = paint_data.texture_bundle_folder or texture_variants.texture_bundle_folder or mod_texture_bundle_folder
			local new_data = make_texture_cosmetic_data( paint_id, paint_data, paint_id == current_equipped_string )
			data[index_i] = new_data
			index_i = index_i + 1
		end
	end

	local skins = data.on_create_data.skins or {}
	local skin_indexes = {}
	local skin_list = {}
	for _, skin_data in pairs(skins) do
		local cosmetic_id = skin_data[1]
		local quality = skin_data[2]
		local index = cosmetic_id .. "_" .. quality

		if not table.contains(skin_indexes, index) then
			table.insert(skin_indexes, index)
		end

		skin_list[index] = {
			equipped = part_type_is_string and ( current_equipped_string == index ),
			id = cosmetic_id,
			quality = quality
		}
	end

	for _, table_index in ipairs(skin_indexes) do
		local skin_data = skin_list[table_index]
		local new_data = make_skin_cosmetic_data(skin_data.id, skin_data.quality, skin_data.equipped)
		data[index_i] = new_data
		index_i = index_i + 1
	end

	local count = table.size(skins) + table.size(texture_variants)

	local modulo = (index_i-1) % 6
	if modulo ~= 0 then
		local blank_needed = 6 - modulo

		for i = 1, blank_needed, 1 do
			local new_data = {
				name = "empty",
				name_localized = "",
				category = data.category,
				slot = data.slot,
				unlocked = true,
				equipped = false
			}
			
			data[index_i] = new_data
			index_i = index_i + 1
		end
	end
end