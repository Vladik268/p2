WeaponEditModeGui = WeaponEditModeGui or class()
WeaponEditModeGui.quick_panel_h = 24

WeaponEditModeGui.modes = {
	"edit",
	"paint"
}

function WeaponEditModeGui:init(ws, panel, parent_node_gui, force_mode)
	self._ws = ws
	self._panel = self._panel or panel:panel({
		w = 280,
		h = 36 + self.quick_panel_h
	})
	self._parent_node_gui = parent_node_gui

	self._panel:set_bottom(panel:bottom() - 4)
	self._panel:set_center_x(panel:w() / 2)

	self._profile_panel = self._profile_panel or self._panel:panel({
		w = 280,
		h = 36,
		y = self.quick_panel_h
	})

	self._profile_panel:rect({
		alpha = 0.4,
		layer = -100,
		color = Color.black
	})

	self._box_panel = self._profile_panel:panel()
	self._box = BoxGuiObject:new(self._box_panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})

	self._max_length = 15

	self._current_mode = force_mode or 1

	self:update()
end

function WeaponEditModeGui:panel()
	return self._panel
end

function WeaponEditModeGui:profile_panel()
	return self._profile_panel
end

function WeaponEditModeGui:update()
	local name = managers.localization:text("bm_menu_weapon_mode_" .. self.modes[self._current_mode])
	self._name_text = self._profile_panel:child("name")

	if alive(self._name_text) then
		self._profile_panel:remove(self._name_text)
	end

	self._name_text = self._profile_panel:text({
		name = "name",
		vertical = "center",
		align = "center",
		text = name,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.text
	})
	local text_width = self._name_text:w()

	self._name_text:set_w(text_width * 0.8)
	self._name_text:set_left(text_width * 0.1)

	local arrow_left = self._profile_panel:child("arrow_left")

	if not arrow_left then
		arrow_left = self._profile_panel:bitmap({
			texture = "guis/textures/menu_arrows",
			name = "arrow_left",
			size = 32,
			texture_rect = {
				0,
				0,
				24,
				24
			},
			color = self:has_previous() and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color
		})
	end

	local arrow_right = self._profile_panel:child("arrow_right")

	if not arrow_right then
		arrow_right = self._profile_panel:bitmap({
			texture = "guis/textures/menu_arrows",
			name = "arrow_right",
			size = 32,
			rotation = 180,
			texture_rect = {
				0,
				0,
				24,
				24
			},
			color = self:has_next() and tweak_data.screen_colors.button_stage_3 or tweak_data.menu.default_disabled_text_color
		})
	end

	arrow_left:set_left(0)
	arrow_right:set_right(self._profile_panel:w())
	arrow_left:set_center_y(self._profile_panel:h() / 2)
	arrow_right:set_center_y(self._profile_panel:h() / 2)
end

function WeaponEditModeGui:mouse_moved(x, y)
	local function anim_func(o, large)
		local current_width = o:w()
		local current_height = o:h()
		local end_width = large and 32 or 24
		local end_height = end_width
		local cx, cy = o:center()

		over(0.2, function (p)
			o:set_size(math.lerp(current_width, end_width, p), math.lerp(current_height, end_height, p))
			o:set_center(cx, cy)
		end)
	end

	local pointer, used = nil
	local arrow_left = self._profile_panel:child("arrow_left")

	if arrow_left and self:has_previous() then
		if arrow_left:inside(x, y) then
			if self._arrow_selection ~= "left" then
				arrow_left:set_color(tweak_data.screen_colors.button_stage_2)
				arrow_left:animate(anim_func, true)
				managers.menu_component:post_event("highlight")
			end

			self._arrow_selection = "left"
			pointer = "link"
			used = true
		elseif self._arrow_selection == "left" then
			arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
			arrow_left:animate(anim_func, false)

			self._arrow_selection = nil
		else
			arrow_left:set_color(tweak_data.screen_colors.button_stage_3)
		end
	else
		arrow_left:set_color(tweak_data.menu.default_disabled_text_color)
		arrow_left:animate(anim_func, false)

		if self._arrow_selection == "left" then
			self._arrow_selection = nil
		end
	end

	local arrow_right = self._profile_panel:child("arrow_right")

	if arrow_right and self:has_next() then
		if arrow_right:inside(x, y) then
			if self._arrow_selection ~= "right" then
				arrow_right:set_color(tweak_data.screen_colors.button_stage_2)
				arrow_right:animate(anim_func, true)
				managers.menu_component:post_event("highlight")
			end

			self._arrow_selection = "right"
			pointer = "link"
			used = true
		elseif self._arrow_selection == "right" then
			arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
			arrow_right:animate(anim_func, false)

			self._arrow_selection = nil
		else
			arrow_right:set_color(tweak_data.screen_colors.button_stage_3)
		end
	else
		arrow_right:set_color(tweak_data.menu.default_disabled_text_color)
		arrow_right:animate(anim_func, false)

		if self._arrow_selection == "right" then
			self._arrow_selection = nil
		end
	end

	return used, pointer
end

function WeaponEditModeGui:mouse_pressed(button, x, y)
	if button == Idstring("0") then
		if self:arrow_selection() == "left" then
			self:left_arrow()
			managers.menu_component:post_event("menu_enter")

			return
		elseif self:arrow_selection() == "right" then
			self:right_arrow()
			managers.menu_component:post_event("menu_enter")

			return
		end
	end
end

function WeaponEditModeGui:arrow_selection()
	return self._arrow_selection
end

function WeaponEditModeGui:has_previous()
	return ( self._current_mode ~= 1 )
end

function WeaponEditModeGui:has_next()
	return ( self._current_mode ~= #self.modes )
end

function WeaponEditModeGui:left_arrow()
	if not self:has_previous() then return end
	self._current_mode = self._current_mode - 1

	self:trigger_mode(self._current_mode)
end

function WeaponEditModeGui:right_arrow()
	if not self:has_next() then return end
	self._current_mode = self._current_mode + 1

	self:trigger_mode(self._current_mode)
end

function WeaponEditModeGui:trigger_mode( mode_number )
	local mode = self.modes[mode_number]

	self["trigger_" .. mode](self)
end

function WeaponEditModeGui:trigger_edit()
	self._parent_node_gui._data = deep_clone(self._parent_node_gui._data_backup)

	self._parent_node_gui:set_selected_tab(1, true)
	self._parent_node_gui:reload()
end

function WeaponEditModeGui:trigger_paint()
	local base_tab = deep_clone(self._parent_node_gui._data_backup[1])

	for index, data in ipairs(self._parent_node_gui._data) do
		self._parent_node_gui._data[index] = nil
	end

	local prev_node_data = base_tab.prev_node_data
	local category = prev_node_data.category
	local slot = prev_node_data.slot
	local weapon_id = prev_node_data.name

	local inventory_tradable = managers.blackmarket:get_inventory_tradable()
	local cosmetics_data = tweak_data.blackmarket.weapon_skins

	local rtd = tweak_data.economy.rarities
	local x_td, y_td, x_rar, y_rar, x_quality, y_quality = nil

	local function sort_func(x, y)
		x_td = cosmetics_data[inventory_tradable[x].entry]
		y_td = cosmetics_data[inventory_tradable[y].entry]
		x_rar = rtd[x_td.rarity]
		y_rar = rtd[y_td.rarity]

		if x_rar.index ~= y_rar.index then
			return x_rar.index < y_rar.index
		end

		if inventory_tradable[x].entry ~= inventory_tradable[y].entry then
			return inventory_tradable[y].entry < inventory_tradable[x].entry
		end

		x_quality = tweak_data.economy.qualities[inventory_tradable[x].quality]
		y_quality = tweak_data.economy.qualities[inventory_tradable[y].quality]

		if x_quality.index ~= y_quality.index then
			return y_quality.index < x_quality.index
		end

		return y < x
	end

	-- Gather unlocked cosmetics.
	local cosmetics_instances = base_tab.on_create_data.instances or {}
	if WeaponPainter.Options:GetValue("UnrestrictedWeaponIDs") then
		cosmetics_instances = {}

		for instance_id, data in pairs(inventory_tradable) do
			if data.category == "weapon_skins" and cosmetics_data[data.entry] then
				table.insert(cosmetics_instances, instance_id)
			end
		end
	end
	table.sort(cosmetics_instances, sort_func)

	-- Gather the rest.
	local all_cosmetics_sorted = base_tab.on_create_data.all or {}
	if WeaponPainter.Options:GetValue("UnrestrictedWeaponIDs") then
		all_cosmetics_sorted = {}

		for cosmetic_id, data in pairs(cosmetics_data) do
			table.insert(all_cosmetics_sorted, {
				id = cosmetic_id,
				data = data
			})
		end
	end
	table.sort(all_cosmetics_sorted, function (x, y)
		x_td = cosmetics_data[x.id]
		x_rar = rtd[x_td.rarity]
		y_td = cosmetics_data[y.id]
		y_rar = rtd[y_td.rarity]

		return y_rar.index < x_rar.index
	end)

	local unlocked_skins = {}
	
	for _, instance_id in ipairs(cosmetics_instances) do
		if inventory_tradable[instance_id] then
			local inv_inst = inventory_tradable[instance_id]
			local cosmetic_id = inv_inst.entry
			local quality = inv_inst.quality

			table.insert(unlocked_skins, {cosmetic_id, quality})
		end
	end

	for _, cosm_data in ipairs(all_cosmetics_sorted) do
		local cosmetic_id = cosm_data.id
		local my_cd = cosmetics_data[cosmetic_id]

		if not my_cd.is_template then
			local global_value = my_cd and my_cd.global_value or "normal"
			local unlocked = managers.blackmarket:get_item_amount(global_value, "weapon_skins", cosmetic_id, true) > 0
			local not_color_skin = not cosm_data.data.is_a_color_skin

			if unlocked and not_color_skin then
				table.insert(unlocked_skins, {cosmetic_id, "mint"})
			end
		end
	end

	local parts = tweak_data.weapon.factory.parts

	local base_blueprint = managers.blackmarket:get_weapon_blueprint(category, slot) or {}
	local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)

	local weapon_blueprint = managers.weapon_factory:get_assembled_blueprint( factory_id, base_blueprint ) or {}

	local ignore_types = {
		"ammo",
		"bonus",
		"custom"
	}

	local types = {}
	local part_ids_by_type = {}

	for _, part_id in ipairs(weapon_blueprint) do
		local part_data = parts[part_id]
		local part_type = part_data.type

		if not table.contains(ignore_types, part_type) then
			if not part_ids_by_type[part_type] then
				table.insert(types, part_type )
				part_ids_by_type[part_type] = {}
			end
			table.insert(part_ids_by_type[part_type], part_id)
		end
	end

	table.sort(types)

	table.insert(self._parent_node_gui._data, {
		name = "weapon_paint_presets",
		on_create_func_name = "populate_paints",
		name_localized = managers.localization:text("bm_menu_paint_presets"),
		category = category,
		prev_node_data = prev_node_data,
		on_create_data = {
			skins = unlocked_skins,
			part_type = types
		},
		override_slots = {
			6,
			1
		},
		identifier = BlackMarketGui.identifiers.weapon_cosmetic
	})

	for _, part_type in pairs(types) do
		local part_id = managers.weapon_factory:get_part_id_from_weapon_by_type(part_type, weapon_blueprint)
		local part_data = managers.weapon_factory:get_part_data_by_part_id_from_weapon(part_id, factory_id, weapon_blueprint)
		local texture_vars = part_data and part_data.texture_variants or {}

		-- Fuck off normal index values and XML shite.
		for index, _ in ipairs(texture_vars) do
			texture_vars[index] = nil
		end
		for key, _ in pairs(texture_vars) do
			if ( string.sub(key, 1, 1) == "_" ) then
				texture_vars[key] = nil
			end
		end

		if ( ( table.size(unlocked_skins) + table.size(texture_vars) ) > 0 ) then
			table.insert(self._parent_node_gui._data, {
				name = part_type,
				on_create_func_name = "populate_paints",
				name_localized = managers.localization:text("bm_menu_" .. part_type),
				category = category,
				prev_node_data = prev_node_data,
				on_create_data = {
					skins = unlocked_skins,
					texture_variants = texture_vars,
					part_type = part_type,
					main_part_id = part_ids_by_type[part_type][1],
					texture_bundle_folder = part_data.texture_bundle_folder
				},
				override_slots = {
					6,
					1
				},
				identifier = BlackMarketGui.identifiers.weapon_cosmetic
			})
		end
	end

	self._parent_node_gui:set_selected_tab(1, true)
	self._parent_node_gui:reload()
end