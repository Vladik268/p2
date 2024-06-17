local function make_fine_text(text_gui)
	local x, y, w, h = text_gui:text_rect()

	text_gui:set_size(w, h)
	text_gui:set_position(math.round(text_gui:x()), math.round(text_gui:y()))
end

local function fit_text_height(text_gui)
	local _, y, _, h = text_gui:text_rect()

	text_gui:set_h(h)
	text_gui:set_y(math.round(text_gui:y()))
end

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local IS_WIN_32 = SystemInfo:platform() == Idstring("WIN32")
local NOT_WIN_32 = not IS_WIN_32
local TOP_ADJUSTMENT = NOT_WIN_32 and 45 or 45
local BOT_ADJUSTMENT = NOT_WIN_32 and 45 or 45
local BIG_PADDING = 13.5
local PADDING = 10
local PAGE_TREE_OVERLAP = 2
local SKILLS_WIDTH_PERCENT = 0.7
local PAGE_TAB_H = medium_font_size + 10

NewSkillTreeSkillItem = NewSkillTreeSkillItem or class(NewSkillTreeItem)
function NewSkillTreeSkillItem:init(skill_id, skill_data, skill_panel, tree_panel, tree, tier, tier_item, fullscreen_panel, gui)
	NewSkillTreeSkillItem.super.init(self)

	self._gui = gui
	self._skilltree = managers.skilltree
	self._fullscreen_panel = fullscreen_panel
	self._tree = tree
	self._tier = tier
	self._tier_item = tier_item
	self._skill_panel = skill_panel
	self._tree_panel = tree_panel
	self._skill_id = skill_id
	self._selected = false
	self._can_refund = false
	self._event_listener = gui:event_listener()

	self._event_listener:add(skill_id, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))

	local skill_text = skill_panel:text({
		name = "SkillName",
		blend_mode = "add",
		rotation = 360,
		layer = 2,
		text = managers.localization:to_upper_text(skill_data.name_id),
		font = small_font,
		font_size = small_font_size,
		color = tweak_data.screen_colors.text
	})

	make_fine_text(skill_text)

	local icon_panel_size = skill_panel:h() - skill_text:h() - PADDING * 2
	local skill_icon_panel = skill_panel:panel({
		name = "SkillIconPanel",
		w = icon_panel_size,
		h = icon_panel_size
	})

	skill_icon_panel:set_center_x(skill_panel:w() / 2)
	skill_icon_panel:set_top(PADDING)
	skill_text:set_center_x(skill_icon_panel:center_x())
	skill_text:set_top(skill_icon_panel:bottom())

	local texture_rect_x = skill_data.icon_xy and skill_data.icon_xy[1] or 0
	local texture_rect_y = skill_data.icon_xy and skill_data.icon_xy[2] or 0
	self._icon = skill_icon_panel:bitmap({
		texture = skill_data.texture or "guis/textures/pd2/skilltree_2/icons_atlas_2",
		name = "Icon",
		blend_mode = "normal",
		layer = 1,
		texture_rect = {
			texture_rect_x * 80,
			texture_rect_y * 80,
			80,
			80
		},
		color = tweak_data.screen_colors.button_stage_3
	})
	local locked = skill_icon_panel:bitmap({
		texture = "guis/textures/pd2/skilltree/padlock",
		name = "Locked",
		blend_mode = "normal",
		layer = 2,
		color = tweak_data.screen_colors.text
	})

	locked:set_center(skill_icon_panel:w() / 2, skill_icon_panel:h() / 2)

	local maxed_indicator = skill_icon_panel:bitmap({
		texture = "guis/textures/pd2/skilltree_2/ace_symbol",
		name = "MaxedIndicator",
		blend_mode = "add",
		color = tweak_data.screen_colors.button_stage_2
	})

	maxed_indicator:set_size(skill_icon_panel:w() * 1.2, skill_icon_panel:h() * 1.2)
	maxed_indicator:set_center(skill_icon_panel:w() / 2, skill_icon_panel:h() / 2)

	self._selected_size = math.floor(self._icon:w())
	self._unselected_size = math.floor(self._icon:w() * 0.8)
	self._current_size = self._unselected_size

	self._icon:set_size(self._current_size, self._current_size)
	self._icon:set_center(skill_icon_panel:w() / 2, skill_icon_panel:h() / 2)

	self._connection = self._connection or {}

	self:refresh()
end

function NewSkillTreeGui:set_skill_point_text(skill_points)
	local x, y, old_w, old_h = self._skill_points_text:text_rect()

	self._skill_points_text:set_text(tostring(self._skilltree:points()))

	local x, y, w, h = self._skill_points_text:text_rect()
	local new_w = old_w - w
	local new_h = old_h - h

	self._skill_points_text:set_size(w, h)
	self._skill_points_text:set_position(self._skill_points_text:x() + new_w, self._skill_points_text:y() + new_h)

	local color = skill_points > 0 and tweak_data.screen_colors.text or tweak_data.screen_colors.important_1

	self._skill_points_title_text:set_color(color)
	self._skill_points_text:set_color(color)
end

function NewSkillTreePage:init(page, page_data, tree_title_panel, tree_panel, fullscreen_panel, gui)
	NewSkillTreePage.super.init(self)

	local skilltrees_tweak = tweak_data.skilltree.trees
	self._gui = gui
	self._active = false
	self._selected = 0
	self._tree_titles = {}
	self._trees = {}
	self._trees_idx = {}
	self._page_name = page
	self._tree_title_panel = tree_title_panel
	self._tree_panel = tree_panel
	self._event_listener = gui:event_listener()

	self._event_listener:add(page, {
		"refresh"
	}, callback(self, self, "_on_refresh_event"))

	local tree_space = tree_title_panel:w() / 2 * 0.015
	local tree_width = tree_title_panel:w() / 3 - tree_space
	tree_space = (tree_title_panel:w() - tree_width * 3) / 2
	local panel, tree_data = nil

	for index, tree in ipairs(page_data) do
		tree_data = skilltrees_tweak[tree]

		table.insert(self._trees_idx, tree)

		panel = tree_title_panel:panel({
			name = "TreeTitle" .. tostring(tree),
			w = tree_width,
			x = (index - 1) * (tree_width + tree_space)
		})

		panel:text({
			name = "TitleText",
			blend_mode = "add",
			align = "center",
			vertical = "center",
			text = managers.localization:to_upper_text(tree_data.name_id),
			font = large_font,
			font_size = large_font_size * 0.75,
			color = tweak_data.screen_colors.button_stage_3
		})
		table.insert(self._tree_titles, panel)

		panel = NewSkillTreeTreeItem:new(tree, tree_data, tree_panel:panel({
			name = "Tree" .. tostring(tree),
			w = tree_width,
			x = (index - 1) * (tree_width + tree_space)
		}), fullscreen_panel, gui, self)

		table.insert(self._trees, panel)
	end

	for tree, tree_item in ipairs(self._trees) do
		tree_item:link(self._trees[tree - 1], self._trees[tree + 1])
	end

	self:refresh()
end