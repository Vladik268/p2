local is_win32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not is_win32
local WIDTH_MULTIPLIER = NOT_WIN_32 and 0.68 or 0.71
local BOX_GAP = 13.5
local GRID_H_MUL = (NOT_WIN_32 and 6.9 or 6.95) / 8
local ITEMS_PER_ROW = 3
local ITEMS_PER_COLUMN = 3
local BUY_MASK_SLOTS = {
	7,
	4
}
local WEAPON_MODS_SLOTS = {
	6,
	1
}
local WEAPON_MODS_GRID_H_MUL = 0.126
local DEFAULT_LOCKED_BLEND_MODE = "normal"
local DEFAULT_LOCKED_BLEND_ALPHA = 0.50
local DEFAULT_LOCKED_COLOR = Color(1, 1, 1)
local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size


Hooks:RegisterHook("BlackMarketGUIPreSetup")
Hooks:RegisterHook("BlackMarketGUIPostSetup")
Hooks:PostHook(BlackMarketGui, "_setup", "goonmodshop__setup", function(self, is_start_page, component_data)
	Hooks:Call("BlackMarketGUIPreSetup", self, is_start_page, component_data)
	Hooks:Call("BlackMarketGUIPostSetup", self, is_start_page, component_data)
end)

Hooks:RegisterHook("BlackMarketGUIOnPopulateMasks")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMasksActionList")
function BlackMarketGui.populate_masks(self, data)

	Hooks:Call("BlackMarketGUIOnPopulateMasks", self, data)

	local NOT_WIN_32 = SystemInfo:platform() ~= Idstring("WIN32")
	local GRID_H_MUL = (NOT_WIN_32 and 7 or 6.6) / 8

	local new_data = {}
	local crafted_category = managers.blackmarket:get_crafted_category("masks") or {}
	local mini_icon_helper = math.round((self._panel:h() - (tweak_data.menu.pd2_medium_font_size + 10) - 60) * GRID_H_MUL / 3) - 16
	local max_items = data.override_slots and data.override_slots[1] * data.override_slots[2] or 9
	local start_crafted_item = data.start_crafted_item or 1
	local hold_crafted_item = managers.blackmarket:get_hold_crafted_item()
	local currently_holding = hold_crafted_item and hold_crafted_item.category == "masks"
	local max_rows = tweak_data.gui.MAX_MASK_ROWS or 5
	max_items = max_rows * (data.override_slots and data.override_slots[2] or 3)
	for i = 1, max_items do
		data[i] = nil
	end

	local guis_catalog = "guis/"
	local index = 0
	for i, crafted in pairs(crafted_category) do

		index = i - start_crafted_item + 1
		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.masks[crafted.mask_id] and tweak_data.blackmarket.masks[crafted.mask_id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = crafted.mask_id
		new_data.name_localized = managers.blackmarket:get_mask_name_by_category_slot("masks", i)
		new_data.raw_name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.custom_name_text = managers.blackmarket:get_crafted_custom_name("masks", i, true)
		new_data.custom_name_text_right = crafted.modded and -55 or -20
		new_data.custom_name_text_width = crafted.modded and 0.6
		new_data.category = "masks"
		new_data.global_value = crafted.global_value
		new_data.slot = i
		new_data.unlocked = true
		new_data.equipped = crafted.equipped
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. new_data.name
		new_data.stream = false
		new_data.holding = currently_holding and hold_crafted_item.slot == i
		local is_locked = tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:has_dlc(new_data.global_value)
		local locked_parts = {}
		if not is_locked then
			for part, type in pairs(crafted.blueprint) do
				if tweak_data.lootdrop.global_values[part.global_value] and tweak_data.lootdrop.global_values[part.global_value].dlc and not tweak_data.dlc[part.global_value].free and not managers.dlc:has_dlc(part.global_value) then
					locked_parts[type] = part.global_value
					is_locked = true
				end
			end
		end

		if is_locked then
			new_data.unlocked = false
			new_data.lock_texture = self:get_lock_icon(new_data, "guis/textures/pd2/lock_incompatible")
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
		end

		if currently_holding then
			if i ~= 1 then
				new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_swap_mask")
			end

			if i ~= 1 and new_data.slot ~= hold_crafted_item.slot then
				table.insert(new_data, "m_swap")
			end

			table.insert(new_data, "i_stop_move")
		else
			if new_data.unlocked then
				if not new_data.equipped then
					table.insert(new_data, "m_equip")
				end

				if i ~= 1 and new_data.equipped then
					table.insert(new_data, "m_move")
				end

				if not crafted.modded and managers.blackmarket:can_modify_mask(i) and i ~= 1 then
					table.insert(new_data, "m_mod")
				end

				if i ~= 1 then
					table.insert(new_data, "m_preview")
				end

			end

			if i ~= 1 then
				Hooks:Call("BlackMarketGUIOnPopulateMasksActionList", self, new_data)
			end

			if i ~= 1 then
				if managers.money:get_mask_sell_value(new_data.name, new_data.global_value) > 0 then
					table.insert(new_data, "m_sell")
				else
					table.insert(new_data, "m_remove")
				end

			end

		end

		if crafted.modded then
			new_data.mini_icons = {}
			local color_1 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[1]
			local color_2 = tweak_data.blackmarket.colors[crafted.blueprint.color.id].colors[2]
			table.insert(new_data.mini_icons, {
				texture = false,
				w = 16,
				h = 16,
				right = 0,
				bottom = 0,
				layer = 1,
				color = color_2
			})
			table.insert(new_data.mini_icons, {
				texture = false,
				w = 16,
				h = 16,
				right = 18,
				bottom = 0,
				layer = 1,
				color = color_1
			})
			if locked_parts.color then
				local texture = self:get_lock_icon({
					global_value = locked_parts.color
				})
				table.insert(new_data.mini_icons, {
					texture = texture,
					w = 32,
					h = 32,
					right = 2,
					bottom = -5,
					layer = 2,
					color = tweak_data.screen_colors.important_1
				})
			end

			local pattern = crafted.blueprint.pattern.id
			if pattern == "solidfirst" or pattern == "solidsecond" then
			else
				local material_id = crafted.blueprint.material.id
				guis_catalog = "guis/"
				local bundle_folder = tweak_data.blackmarket.materials[material_id] and tweak_data.blackmarket.materials[material_id].texture_bundle_folder
				if bundle_folder then
					guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
				end

				local right = -3
				local bottom = 38 - (NOT_WIN_32 and 20 or 10)
				local w = 42
				local h = 42
				table.insert(new_data.mini_icons, {
					texture = guis_catalog .. "textures/pd2/blackmarket/icons/materials/" .. material_id,
					right = right,
					bottom = bottom,
					w = w,
					h = h,
					layer = 1,
					stream = true
				})
				if locked_parts.material then
					local texture = self:get_lock_icon({
						global_value = locked_parts.material
					})
					table.insert(new_data.mini_icons, {
						texture = texture,
						w = 32,
						h = 32,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						layer = 2,
						color = tweak_data.screen_colors.important_1
					})
				end

			end

			do
				local right = -3
				local bottom = math.round(mini_icon_helper - 6 - 6 - 42)
				local w = 42
				local h = 42
				table.insert(new_data.mini_icons, {
					texture = tweak_data.blackmarket.textures[pattern].texture,
					right = right,
					bottom = bottom,
					w = h,
					h = w,
					layer = 1,
					stream = true,
					render_template = Idstring("VertexColorTexturedPatterns")
				})
				if locked_parts.pattern then
					local texture = self:get_lock_icon({
						global_value = locked_parts.pattern
					})
					table.insert(new_data.mini_icons, {
						texture = texture,
						w = 32,
						h = 32,
						right = right + (w - 32) / 2,
						bottom = bottom + (h - 32) / 2,
						layer = 2,
						color = tweak_data.screen_colors.important_1
					})
				end

			end

			new_data.mini_icons.borders = true
		elseif i ~= 1 and managers.blackmarket:can_modify_mask(i) and managers.blackmarket:got_new_drop("normal", "mask_mods", crafted.mask_id) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false,
				visible = true
			})
			new_data.new_drop_data = {}
		end

		data[index] = new_data

	end

	local can_buy_masks = true
	for i = 1, max_items do
		if not data[i] then
			index = i + start_crafted_item - 1
			can_buy_masks = managers.blackmarket:is_mask_slot_unlocked(i)
			new_data = {}
			if can_buy_masks then
				new_data.name = "bm_menu_btn_buy_new_mask"
				new_data.name_localized = managers.localization:text("bm_menu_empty_mask_slot")
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				if not currently_holding or not new_data.mid_text.noselected_text then
				end

				new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_new_mask")
				new_data.mid_text.selected_color = currently_holding and new_data.mid_text.noselected_color or tweak_data.screen_colors.button_stage_2
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.cannot_buy = not can_buy_masks
				if currently_holding then
					if i ~= 1 then
						new_data.selected_text = managers.localization:to_upper_text("bm_menu_btn_place_mask")
					end

					if i ~= 1 then
						table.insert(new_data, "m_place")
					end

					table.insert(new_data, "i_stop_move")
				else
					table.insert(new_data, "em_buy")
				end

				if index ~= 1 and managers.blackmarket:got_new_drop(nil, "mask_buy", nil) then
					new_data.mini_icons = new_data.mini_icons or {}
					table.insert(new_data.mini_icons, {
						name = "new_drop",
						texture = "guis/textures/pd2/blackmarket/inv_newdrop",
						right = 0,
						top = 0,
						layer = 1,
						w = 16,
						h = 16,
						stream = false,
						visible = false
					})
					new_data.new_drop_data = {}
				end

			else
				new_data.name = "bm_menu_btn_buy_mask_slot"
				new_data.name_localized = managers.localization:text("bm_menu_locked_mask_slot")
				new_data.empty_slot = true
				new_data.category = "masks"
				new_data.slot = index
				new_data.unlocked = true
				new_data.equipped = false
				new_data.num_backs = 0
				new_data.lock_texture = "guis/textures/pd2/blackmarket/money_lock"
				new_data.lock_color = tweak_data.screen_colors.button_stage_3
				new_data.lock_shape = {
					w = 32,
					h = 32,
					x = 0,
					y = -32
				}
				new_data.locked_slot = true
				new_data.dlc_locked = managers.experience:cash_string(managers.money:get_buy_mask_slot_price())
				new_data.mid_text = {}
				new_data.mid_text.noselected_text = new_data.name_localized
				new_data.mid_text.noselected_color = tweak_data.screen_colors.button_stage_3
				new_data.mid_text.is_lock_same_color = true
				if currently_holding then
					new_data.mid_text.selected_text = new_data.mid_text.noselected_text
					new_data.mid_text.selected_color = new_data.mid_text.noselected_color
					table.insert(new_data, "i_stop_move")
				elseif managers.money:can_afford_buy_mask_slot() then
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_btn_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.button_stage_2
					table.insert(new_data, "em_unlock")
				else
					new_data.mid_text.selected_text = managers.localization:text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.selected_color = tweak_data.screen_colors.important_1
					new_data.dlc_locked = new_data.dlc_locked .. "  " .. managers.localization:to_upper_text("bm_menu_cannot_buy_mask_slot")
					new_data.mid_text.lock_noselected_color = tweak_data.screen_colors.important_1
					new_data.cannot_buy = true
				end

			end

			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateMods")
Hooks:RegisterHook("BlackMarketGUIOnPopulateModsActionList")

local populate_choose_mask_mod1 = BlackMarketGui.populate_choose_mask_mod
Hooks:RegisterHook("BlackMarketGUIOnPopulateMaskMods")
Hooks:RegisterHook("BlackMarketGUIOnPopulateMaskModsActionList")
function BlackMarketGui.populate_choose_mask_mod(self, data)
populate_choose_mask_mod1(self, data)
	Hooks:Call("BlackMarketGUIOnPopulateMaskMods", self, data)

	local new_data = {}
	local index = 1
	local equipped_mod = managers.blackmarket:customize_mask_category_id(data.category)
	local equipped_first, equipped_second = nil

	if data.category == "mask_colors" then
		equipped_first = data.is_first_color and managers.blackmarket:customize_mask_category_id("color_a")
		equipped_second = not data.is_first_color and managers.blackmarket:customize_mask_category_id("color_b")
	end
	local guis_catalog = "guis/"
	local type_func = type

	for k, mods in pairs(data.on_create_data) do

		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket[data.category][mods.id] and tweak_data.blackmarket[data.category][mods.id].texture_bundle_folder
		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {}
		new_data.name = mods.id
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket[data.category][new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = index
		new_data.prev_slot = data.prev_node_data and data.prev_node_data.slot
		new_data.unlocked = mods.default or mods.amount
		new_data.amount = mods.amount or 0
		new_data.equipped = equipped_mod == mods.id
		new_data.equipped_text = managers.localization:text("bm_menu_chosen")
		new_data.mods = mods
		new_data.stream = data.category ~= "colors"
		new_data.global_value = mods.global_value
		local is_locked = false
		if new_data.amount < 1 and mods.id ~= "plastic" and mods.id ~= "no_color_full_material" and not mods.free_of_charge then
			if type(new_data.unlocked) == "number" then
				new_data.unlocked = -math.abs(new_data.unlocked)
			end
			new_data.lock_texture = true
			new_data.dlc_locked = "bm_menu_amount_locked"
			is_locked = true
		end
		
		if new_data.unlocked and type_func(new_data.unlocked) == "number" and tweak_data.lootdrop.global_values[new_data.global_value] and tweak_data.lootdrop.global_values[new_data.global_value].dlc and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = self:get_lock_icon(new_data)
			new_data.dlc_locked = tweak_data.lootdrop.global_values[new_data.global_value].unlock_id or "bm_menu_dlc_locked"
			is_locked = true
		elseif managers.dlc:is_content_achievement_locked(data.category, new_data.name) or managers.dlc:is_content_achievement_milestone_locked(data.category, new_data.name) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = "guis/textures/pd2/lock_achievement"
		elseif managers.dlc:is_content_skirmish_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		elseif managers.dlc:is_content_crimespree_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		elseif managers.dlc:is_content_infamy_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/lock_infamy"
			-- new_data.infamy_lock = true
		end

		if data.category == "mask_colors" then
			new_data.equipped = equipped_first == new_data.name or equipped_second == new_data.name
			new_data.bitmap_texture = "guis/dlcs/mcu/textures/pd2/blackmarket/icons/mask_color/mask_color_icon"
			new_data.bitmap_color = tweak_data.blackmarket.mask_colors[new_data.name].color
			new_data.is_first_color = data.is_first_color
		elseif data.category == "textures" then
			new_data.bitmap_texture = tweak_data.blackmarket[data.category][mods.id].texture
			new_data.render_template = Idstring("VertexColorTexturedPatterns")
		else
			new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. new_data.name
			if mods.bitmap_texture_override then
				new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/" .. tostring(data.category) .. "/" .. mods.bitmap_texture_override
			end
		end

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", new_data.category, new_data.name) then
			new_data.mini_icons = new_data.mini_icons or {}
			table.insert(new_data.mini_icons, {
				name = "new_drop",
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				right = 0,
				top = 0,
				layer = 1,
				w = 16,
				h = 16,
				stream = false
			})
			new_data.new_drop_data = {
				new_data.global_value or "normal",
				new_data.category,
				new_data.name
			}
		end

		new_data.btn_text_params = {
			type = managers.localization:text("bm_menu_" .. data.category)
		}
		if not is_locked then

			if data.category == "mask_colors" then
				if data.is_first_color then
					table.insert(new_data, "mp_choose_first")
				else
					table.insert(new_data, "mp_choose_second")
				end
			else
				table.insert(new_data, "mp_choose")
			end
			table.insert(new_data, "mp_preview")

		end

		if managers.blackmarket:can_finish_customize_mask() and managers.blackmarket:can_afford_customize_mask() then
			table.insert(new_data, "mm_buy")
		end

		Hooks:Call("BlackMarketGUIOnPopulateMaskModsActionList", self, new_data)

		data[index] = new_data
		index = index + 1

	end

	if #data == 0 then
		new_data = {}
		new_data.name = "bm_menu_nothing"
		new_data.empty_slot = true
		new_data.category = data.category
		new_data.slot = 1
		new_data.unlocked = true
		new_data.can_afford = true
		new_data.equipped = false
		data[1] = new_data
	end

	local max_mask_mods = #data.on_create_data
	for i = 1, math.ceil(max_mask_mods / data.override_slots[1]) * data.override_slots[1] do
		if not data[i] then
			new_data = {}
			new_data.name = "empty"
			new_data.name_localized = ""
			new_data.category = data.category
			new_data.slot = i
			new_data.unlocked = true
			new_data.equipped = false
			data[i] = new_data
		end

	end

end

Hooks:RegisterHook("BlackMarketGUIOnPopulateBuyMasks")
Hooks:RegisterHook("BlackMarketGUIOnPopulateBuyMasksActionList")
function BlackMarketGui.populate_buy_mask(self, data)

	Hooks:Call("BlackMarketGUIOnPopulateBuyMasks", self, data)

	local new_data = {}
	local guis_catalog = "guis/"
	local mask_list = data.on_create_data
	mask_list = self:get_filtered_search_list(mask_list, tweak_data.blackmarket.masks, "mask_id")
	local num_prev_data = #data

	for i = 1, num_prev_data do
		data[i] = nil
	end

	local max_masks = #mask_list

	for i = 1, max_masks do
		local guis_mask_id = mask_list[i].mask_id

		if tweak_data.blackmarket.masks[guis_mask_id].guis_id then
			guis_mask_id = tweak_data.blackmarket.masks[guis_mask_id].guis_id
		end

		guis_catalog = "guis/"
		local bundle_folder = tweak_data.blackmarket.masks[guis_mask_id] and tweak_data.blackmarket.masks[guis_mask_id].texture_bundle_folder

		if bundle_folder then
			guis_catalog = guis_catalog .. "dlcs/" .. tostring(bundle_folder) .. "/"
		end

		new_data = {
			name = mask_list[i].mask_id
		}
		new_data.name_localized = managers.localization:text(tweak_data.blackmarket.masks[new_data.name].name_id)
		new_data.category = data.category
		new_data.slot = data.prev_node_data and data.prev_node_data.slot
		new_data.global_value = mask_list[i].global_value
		new_data.global_value_category = data.name
		new_data.unlocked = managers.blackmarket:get_item_amount(new_data.global_value, "masks", new_data.name, true) or 0
		new_data.equipped = false
		new_data.num_backs = data.prev_node_data.num_backs + 1
		new_data.bitmap_texture = guis_catalog .. "textures/pd2/blackmarket/icons/masks/" .. guis_mask_id
		new_data.stream = true

		if not new_data.global_value then
			Application:debug("BlackMarketGui:populate_buy_mask( data ) Missing global value on mask", new_data.name)
		end

		local dlc = tweak_data.blackmarket.masks[new_data.name].dlc or managers.dlc:global_value_to_dlc(new_data.global_value)

		if dlc and not managers.dlc:is_dlc_unlocked(dlc) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = self:get_lock_icon(new_data)
			local dlc_global_value = managers.dlc:dlc_to_global_value(dlc)
			new_data.dlc_locked = dlc_global_value and tweak_data.lootdrop.global_values[dlc_global_value] and tweak_data.lootdrop.global_values[dlc_global_value].unlock_id or "bm_menu_dlc_locked"
		elseif managers.dlc:is_content_achievement_locked(data.category, new_data.name) or managers.dlc:is_content_achievement_milestone_locked(data.category, new_data.name) then
			new_data.unlocked = -math.abs(new_data.unlocked)
			new_data.lock_texture = "guis/textures/pd2/lock_achievement"
		elseif managers.dlc:is_content_skirmish_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		elseif managers.dlc:is_content_crimespree_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/skilltree/padlock"
		elseif managers.dlc:is_content_infamy_locked(data.category, new_data.name) and (not new_data.unlocked or new_data.unlocked == 0) then
			new_data.lock_texture = "guis/textures/pd2/lock_infamy"
			new_data.infamy_lock = true
		else
			local event_job_challenge = managers.event_jobs:get_challenge_from_reward(data.category, new_data.name)

			if event_job_challenge and not event_job_challenge.completed then
				new_data.unlocked = -math.abs(new_data.unlocked)
				new_data.lock_texture = "guis/textures/pd2/lock_achievement"
				new_data.dlc_locked = event_job_challenge.locked_id or "menu_event_job_lock_info"
			end
		end

		if tweak_data.blackmarket.masks[new_data.name].infamy_lock then

			local infamy_lock = tweak_data.blackmarket.masks[new_data.name].infamy_lock
			local is_unlocked = managers.infamy:owned(infamy_lock)
			if not is_unlocked then
				if type(new_data.unlocked) == "number" then
					new_data.unlocked = -math.abs(new_data.unlocked)
				end
				new_data.lock_texture = "guis/textures/pd2/lock_infamy"
				new_data.infamy_lock = infamy_lock
			end

		end

		new_data.active = true

		if new_data.unlocked and new_data.unlocked > 0 then
			if new_data.active then
				table.insert(new_data, "bm_buy")
				table.insert(new_data, "bm_preview")
			end

			if managers.money:get_mask_sell_value(new_data.name, new_data.global_value) > 0 then
				table.insert(new_data, "bm_sell")
			end
		else
			local dlc_data = Global.dlc_manager.all_dlc_data[new_data.global_value]

			if dlc_data and dlc_data.app_id and not dlc_data.external and not managers.dlc:is_dlc_unlocked(new_data.global_value) then
				table.insert(new_data, "bw_buy_dlc")
			end

			if new_data.active then
				table.insert(new_data, "bm_preview")
			end

			new_data.mid_text = ""
			new_data.lock_texture = new_data.lock_texture or true
		end

		if new_data.unlocked and new_data.unlocked > 0 then

			table.insert(new_data, "bm_buy")
			table.insert(new_data, "bm_preview")
			if 0 < managers.money:get_mask_sell_value(new_data.name, new_data.global_value) then
				table.insert(new_data, "bm_sell")
			end

		else
			table.insert(new_data, "bm_preview")
			new_data.mid_text = ""
			new_data.lock_texture = new_data.lock_texture or true

		end

		Hooks:Call("BlackMarketGUIOnPopulateBuyMasksActionList", self, new_data)

		if managers.blackmarket:got_new_drop(new_data.global_value or "normal", "masks", new_data.name) then
			new_data.mini_icons = new_data.mini_icons or {}

			table.insert(new_data.mini_icons, {
				texture = "guis/textures/pd2/blackmarket/inv_newdrop",
				name = "new_drop",
				h = 16,
				w = 16,
				top = 0,
				layer = 1,
				stream = false,
				right = 0
			})

			new_data.new_drop_data = {
				new_data.global_value or "normal",
				"masks",
				new_data.name
			}
		end

		data[i] = new_data

	end

	local max_items = self:calc_max_items(max_masks, data.override_slots)

	for i = max_masks + 1, max_items do
		new_data = {
			name = "empty",
			name_localized = "",
			category = data.category,
			slot = i,
			unlocked = true,
			equipped = false
		}
		data[i] = new_data
	end

end

Hooks:RegisterHook("BlackMarketGUIChooseMaskPartCallback")
Hooks:PostHook(BlackMarketGui, "choose_mask_part_callback", "goonmodshop_choose_mask_part_callback", function(self, data)
	local r = Hooks:ReturnCall("BlackMarketGUIChooseMaskPartCallback", self, data)
	if r then
		return
	end
end)