local EHI = EHI
local Icon = EHI.Icons
local panel_size_original = 32
local panel_offset_original = 6
local panel_size = panel_size_original
local panel_offset = panel_offset_original
---@class FakeEHITrackerManager
FakeEHITrackerManager = {}
FakeEHITrackerManager.make_fine_text = BlackMarketGui.make_fine_text
---@param panel Panel
---@param aspect_ratio number
function FakeEHITrackerManager:new(panel, aspect_ratio)
    self._hud_panel = panel:panel({
        name = "fake_ehi_panel",
        --layer = -10,
        alpha = 1
    })
    if EHI:IsVR() then
        self._scale = EHI:GetOption("vr_scale")
        local x, y = managers.gui_data:safe_to_full(EHI:GetOption("vr_x_offset"), EHI:GetOption("vr_y_offset"))
        self._x = x
        self._y = y
    else
        self._scale = EHI:GetOption("scale")
        local x_offset, y_offset = EHI:GetOption("x_offset"), EHI:GetOption("y_offset")
        if aspect_ratio ~= EHIMenu.AspectRatio._4_3 then
            self._x, self._y = managers.gui_data:safe_to_full(x_offset, y_offset)
        else
            self._x, self._y = managers.gui_data:safe_to_full_16_9(x_offset, y_offset)
        end
    end
    self._text_scale = EHI:GetOption("text_scale")
    self._bg_visibility = EHI:GetOption("show_tracker_bg")
    self._corner_visibility = EHI:GetOption("show_tracker_corners")
    self._icons_visibility = EHI:GetOption("show_one_icon")
    self._tracker_alignment = EHI:GetOption("tracker_alignment")
    self._icons_pos = EHI:GetOption("show_icon_position")
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self._horizontal = {
        x = self._x,
        y = self._y,
        x_offset = 0
    }
    self._vertical = {
        x = self._x,
        y = self._y,
        y_offset = 0,
        max_icons = 4
    }
    self:AddFakeTrackers()
    return self
end

function FakeEHITrackerManager:AddFakeTrackers()
    self._n_of_trackers = 0
    self._fake_trackers = {} ---@type FakeEHITracker[]?
    self:AddFakeTracker({ id = "show_mission_trackers", time = math.rand(0.5, 9.99), icons = { Icon.Wait } })
    self:AddFakeTracker({ id = "show_mission_trackers", time = math.random(60, 180), icons = { Icon.Car, Icon.Escape } })
    self:AddFakeTracker({ id = "show_unlockables", time = math.random(60, 180), icons = { Icon.Trophy } })
    do
        local xp_panel = EHI:GetOption("xp_panel")
        if xp_panel <= 2 then
            self:AddFakeTracker({ id = "show_gained_xp", icons = { "xp" }, extend_half = xp_panel == 2, class = "FakeEHIXPTracker" })
        end
    end
    self:AddFakeTracker({ id = "show_trade_delay", icons = { { icon = "mugshot_in_custody", color = self:GetPeerColor() } }, class = "FakeEHITradeDelayTracker" })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 240), icons = { Icon.Drill, Icon.Wait, "silent", Icon.Loop } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { Icon.PCHack } })
    self:AddFakeTracker({ id = "show_timers", time = math.random(60, 120), icons = { Icon.PCHack }, extend = true, class = "FakeEHITimerTracker" })
    self:AddFakeTracker({ id = "show_camera_loop", time = math.random(10, 25), icons = { "camera_loop" } })
    self:AddFakeTracker({ id = "show_enemy_turret_trackers", time = math.random(10, 30), icons = { Icon.Turret, "reload" } })
    self:AddFakeTracker({ id = "show_enemy_turret_trackers", time = math.random(10, 30), icons = { Icon.Turret, Icon.Fix } })
    do
        local time = math.rand(1, 8)
        self:AddFakeTracker({ id = "show_zipline_timer", time = time, icons = { "zipline_bag" } })
        self:AddFakeTracker({ id = "show_zipline_timer", time = time * 2, icons = { "zipline", Icon.Loop } })
    end
    if EHI:GetOption("gage_tracker_panel") == 1 then
        self:AddFakeTracker({ id = "show_gage_tracker", icons = { "gage" }, class = "FakeEHIProgressTracker" })
    end
    self:AddFakeTracker({ id = "show_captain_damage_reduction", icons = { "buff_shield" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_captain_spawn_chance", time = math.random(0, 120), icons = { "buff_shield" }, extend = true, class = "FakeEHIPhalanxChanceTracker" })
    self:AddFakeTracker({ id = "show_equipment_tracker", show_placed = true, icons = { "doctor_bag" }, class = "FakeEHIEquipmentTracker" })
    self:AddFakeTracker({ id = "show_minion_tracker", min = 1, charges = 4, icons = { "minion" }, class = "FakeEHIMinionCounterTracker" })
    self:AddFakeTracker({ id = "show_difficulty_tracker", icons = { "enemy" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_drama_tracker", chance = math.random(100), icons = { "C_Escape_H_Street_Bullet" }, class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_pager_tracker", progress = 3, max = 4, icons = { Icon.Pager }, class = "FakeEHIProgressTracker" })
    self:AddFakeTracker({ id = "show_pager_callback", time = math.rand(0.5, 12), icons = { "pager_icon" } })
    self:AddFakeTracker({ id = "show_enemy_count_tracker", count = math.random(20, 80), icons = { "pager_icon", { icon = "enemy", visible = false } }, class = "FakeEHIEnemyCountTracker" })
    self:AddFakeTracker({ id = "show_civilian_count_tracker", count = math.random(1, 15), icons = { "civilians", "hostage" }, class = "FakeEHICivilianCountTracker" })
    self:AddFakeTracker({ id = "show_hostage_count_tracker", count = math.random(4, 10), icons = { "hostage", { icon = "hostage", color = Color(0, 1, 1) } }, class = "FakeEHIHostageCountTracker" })
    self:AddFakeTracker({ id = "show_laser_tracker", time = math.rand(0.5, 4), icons = { EHI.Icons.Lasers } })
    self:AddFakeTracker({ id = "show_assault_delay_tracker", time = math.random(30, 120), diff = math.random(0, 100), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker", control = true })
    self:AddFakeTracker({ id = "show_assault_time_tracker", time = math.random(0, 240), diff = math.random(0, 100), icons = { "assaultbox" }, class = "FakeEHIAssaultTimeTracker" })
    self:AddFakeTracker({ id = "show_loot_counter", icons = { Icon.Loot }, class = "FakeEHIProgressTracker" })
    self:AddFakeTracker({ id = "show_bodybags_counter", count = math.random(1, 3), icons = { "equipment_body_bag" }, class = "FakeEHICountTracker" })
    self:AddFakeTracker({ id = "show_escape_chance", icons = { { icon = Icon.Car, color = Color.red } }, chance = math.random(100), class = "FakeEHIChanceTracker" })
    self:AddFakeTracker({ id = "show_sniper_tracker", icons = { "sniper" }, class = "FakeEHISniperTracker" })
    self:AddPreviewText()
end

function FakeEHITrackerManager:AddFakeTracker(params)
    if not EHI:GetOption(params.id) then
        return
    end
    if self._n_of_trackers == 0 then
        self:CreateFirstFakeTracker(params)
    else
        self:CreateFakeTracker(params)
    end
end

function FakeEHITrackerManager:CreateFakeTracker(params)
    params.x, params.y = self:GetPos(self._n_of_trackers)
    params.scale = self._scale
    params.text_scale = self._text_scale
    params.bg = self._bg_visibility
    params.corners = self._corner_visibility
    params.one_icon = self._icons_visibility
    params.icon_pos = self._icons_pos
    local tracker = _G[params.class or "FakeEHITracker"]:new(self._hud_panel, params, self) --[[@as FakeEHITracker]]
    self._n_of_trackers = self._n_of_trackers + 1
    self._fake_trackers[self._n_of_trackers] = tracker
    if self._tracker_alignment == 4 then -- Horizontal; Right to Left
        tracker:SetPos(self:GetPos2(tracker, self._n_of_trackers - 1))
    end
end

function FakeEHITrackerManager:CreateFirstFakeTracker(params)
    params.first = true
    self:CreateFakeTracker(params)
    local bg_box = self._fake_trackers[1]._bg_box
    if self._tracker_alignment == 2 then
        bg_box:child("left_bottom"):set_color(Color.red)
    else
        bg_box:child("left_top"):set_color(Color.red)
    end
end

function FakeEHITrackerManager:GetPeerColor()
    if CustomNameColor and CustomNameColor.GetOwnColor then
        return CustomNameColor:GetOwnColor()
    end
    local i = 1
    local session = managers.network and managers.network:session()
    if session and session:local_peer() then
        i = session:local_peer():id()
    end
    return tweak_data.chat_colors[i] or tweak_data.chat_colors[#tweak_data.chat_colors] or Color.white
end

function FakeEHITrackerManager:GetOtherPeerColor()
    local colors = deep_clone(tweak_data.chat_colors)
    local i = 1
    local session = managers.network and managers.network:session()
    if session and session:local_peer() then
        i = session:local_peer():id()
    end
    table.remove(colors, i)
    return colors[math.random(#colors - 1)]
end

function FakeEHITrackerManager:AddPreviewText()
    if self._n_of_trackers == 0 then
        self:UpdatePreviewTextVisibility(false)
        return
    elseif not self._preview_text then
        self._preview_text = self._hud_panel:text({
            name = "preview_text",
            text = managers.localization:text("ehi_preview"),
            font_size = 23,
            font = tweak_data.menu.pd2_large_font,
            align = "center",
            vertical = "center",
            layer = 401,
            visible = EHI:GetOption("show_preview_text")
        })
        self:make_fine_text(self._preview_text)
    end
    self:SetPreviewTextPosition()
end

function FakeEHITrackerManager:SetPreviewTextPosition()
    if self._preview_text then
        self._preview_text:set_x(self._x)
        if self._tracker_alignment == 2 then -- Vertical; Bottom to Top
            self._preview_text:set_top(self:GetY(1) + panel_offset)
        else
            self._preview_text:set_bottom(self:GetY(0) - panel_offset)
        end
    end
end

---@param visibility boolean
function FakeEHITrackerManager:UpdatePreviewTextVisibility(visibility)
    if self._preview_text then
        self._preview_text:set_visible(visibility)
    end
end

---@param pos number
---@return number, number
function FakeEHITrackerManager:GetPos(pos)
    local x, y = self._x, self._y
    if self._tracker_alignment <= 2 then -- Vertical
        local from_bottom = self._tracker_alignment == 2
        local new_y = self:GetY(pos, true, from_bottom)
        local h = from_bottom and (new_y - panel_offset - panel_size) or (new_y + panel_offset + panel_size)
        if (from_bottom and h < 0) or h > self._hud_panel:h() then
            self._vertical.y_offset = pos
            local new_x = self._vertical.x + self:GetTrackerSize(self._vertical.max_icons)
            self._vertical.x = new_x
            x = new_x
        else
            x = self._vertical.x
            y = new_y
        end
    elseif pos and pos > 0 and self._tracker_alignment == 3 then -- Horizontal; Left to Right
        local tracker = self._fake_trackers[pos]
        x = tracker._panel:right() + (tracker:GetSize() - tracker._panel:w()) + panel_offset
    end
    return x, y
end

---@param tracker FakeEHITracker
---@param pos number
---@return number, number
function FakeEHITrackerManager:GetPos2(tracker, pos)
    local x = self._x
    if pos > 0 then
        local previous_tracker = self._fake_trackers[pos]
        x = previous_tracker._panel:left() - tracker:GetSize() - panel_offset
    end
    return x, self._y
end

---@param pos number
---@param vectical boolean?
---@param vertical_from_bottom boolean?
---@return number
function FakeEHITrackerManager:GetY(pos, vectical, vertical_from_bottom)
    local corrected_pos = vectical and (pos - self._vertical.y_offset) or pos
    if vertical_from_bottom then
        return self._y - (corrected_pos * (panel_size + panel_offset))
    end
    return self._y + (corrected_pos * (panel_size + panel_offset))
end

---@param n_of_icons number
---@return number
function FakeEHITrackerManager:GetTrackerSize(n_of_icons)
    local panel_with_offset = panel_size + panel_offset
    local gap = 5 * n_of_icons
    local icons = panel_size_original * n_of_icons
    local final_size = (64 + panel_with_offset + gap + icons) * self._scale
    return final_size
end

function FakeEHITrackerManager:UpdateTracker(id, value)
    local correct_id = ""
    if id == "xp_panel" then
        correct_id = "show_gained_xp"
    elseif id == "gage_tracker_panel" then
        correct_id = "show_gage_tracker"
    end
    if correct_id == "" then
        return
    end
    local tracker = self:GetTracker(correct_id)
    if not not tracker ~= value then
        self:Redraw()
    end
end

---@param id string
---@param value any
function FakeEHITrackerManager:UpdateTrackerFormat(id, value)
    local tracker = self:GetTracker(id)
    if tracker then
        tracker:UpdateFormat(value)
    end
end

function FakeEHITrackerManager:UpdateFormat(format)
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateFormat(format)
    end
end

function FakeEHITrackerManager:UpdateEquipmentFormat(format)
    for _, tracker in ipairs(self._fake_trackers) do ---@cast tracker FakeEHIEquipmentTracker
        if tracker.UpdateEquipmentFormat then
            tracker:UpdateEquipmentFormat(format)
        end
    end
end

function FakeEHITrackerManager:UpdateXOffset(x)
    local x_full, _ = managers.gui_data:safe_to_full(x, 0)
    self._x = x_full
    self._vertical.x = x_full
    self._vertical.y_offset = 0
    if self._tracker_alignment == 4 then -- Horizontal; Right to Left
        for i, tracker in ipairs(self._fake_trackers) do
            tracker:SetPos(self:GetPos2(tracker, i - 1))
        end
    else
        for i, tracker in ipairs(self._fake_trackers) do
            local x_new, _ = self:GetPos(i - 1)
            tracker:SetX(x_new)
        end
    end
    if self._preview_text then
        self:SetPreviewTextPosition()
    end
end

function FakeEHITrackerManager:UpdateYOffset(y)
    local _, y_full = managers.gui_data:safe_to_full(0, y)
    self._y = y_full
    self._vertical.x = self._x
    self._vertical.y = y_full
    self._vertical.y_offset = 0
    if self._tracker_alignment == 4 then -- Horizontal; Right to Left
        for _, tracker in ipairs(self._fake_trackers) do
            tracker:SetY(y_full)
        end
    else
        for i, tracker in ipairs(self._fake_trackers) do
            local x_new, y_new = self:GetPos(i - 1)
            tracker:SetPos(x_new, y_new)
        end
    end
    self:SetPreviewTextPosition()
end

function FakeEHITrackerManager:SetSelected(id)
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:SetSelected(id)
    end
end

---@param scale number
function FakeEHITrackerManager:UpdateTextScale(scale)
    self._text_scale = scale
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateTextScale(scale)
    end
end

function FakeEHITrackerManager:UpdateScale(scale)
    self._scale = scale
    panel_size = panel_size_original * self._scale
    panel_offset = panel_offset_original * self._scale
    self:Redraw()
end

function FakeEHITrackerManager:UpdateBGVisibility(visibility)
    self._bg_visibility = visibility
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateBGVisibility(visibility, self._corner_visibility)
    end
end

function FakeEHITrackerManager:UpdateCornerVisibility(visibility)
    self._corner_visibility = visibility
    if self._bg_visibility then
        for _, tracker in ipairs(self._fake_trackers) do
            tracker:UpdateCornerVisibility(visibility)
        end
    end
end

function FakeEHITrackerManager:UpdateIconsVisibility(visibility)
    self._icons_visibility = visibility
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateIconsVisibility(visibility)
    end
    if self._tracker_alignment >= 3 then -- Horizontal Alignment
        self:UpdateXOffset(EHI:GetOption("x_offset"))
    end
end

function FakeEHITrackerManager:UpdateIconsPosition(position)
    self._icons_pos = position
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:UpdateIconsPos(position)
    end
end

function FakeEHITrackerManager:UpdateTrackerAlignment(alignment)
    if self._tracker_alignment == alignment then
        return
    end
    self._tracker_alignment = alignment
    self:Redraw()
end

function FakeEHITrackerManager:Redraw()
    for _, tracker in ipairs(self._fake_trackers) do
        tracker:destroy()
    end
    self._horizontal.x = self._x
    self._horizontal.y = self._y
    self._horizontal.x_offset = 0
    self._vertical.x = self._x
    self._vertical.y = self._y
    self._vertical.y_offset = 0
    self:AddFakeTrackers()
end

---@param id string
---@return FakeEHITracker?
function FakeEHITrackerManager:GetTracker(id)
    for _, tracker in ipairs(self._fake_trackers) do
        if tracker._id == id then
            return tracker
        end
    end
end

function FakeEHITrackerManager:ForceReposition()
    if self._tracker_alignment >= 3 then -- Horizontal Alignment
        self:UpdateXOffset(EHI:GetOption("x_offset"))
    end
end

---@param id string
---@param f string
function FakeEHITrackerManager:CallFunction(id, f, ...)
    local tracker = self:GetTracker(id)
    if tracker and tracker[f] then
        tracker[f](tracker, ...)
    end
end

local icons = tweak_data.ehi and tweak_data.ehi.icons or {}

local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

---@param self FakeEHITracker
---@param i string
---@param texture string
---@param texture_rect table?
---@param color Color
---@param alpha number
---@param visible boolean
---@param x number
local function CreateIcon(self, i, texture, texture_rect, color, alpha, visible, x)
    self["_icon" .. i] = self._panel:bitmap({
        name = "icon" .. i,
        texture = texture,
        texture_rect = texture_rect,
        color = color,
        alpha = alpha,
        visible = visible,
        x = x,
        w = self._icon_size_scaled,
        h = self._icon_size_scaled
    })
end

---@param panel Panel
---@param params table
---@param config table
---@return Panel
local function HUDBGBox_create(panel, params, config) -- Not available when called from menu
	local box_panel = panel:panel(params)
	local color = config and config.color or Color.white
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
    local corner_visible = config.bg_visible and config.corner_visible

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = bg_color,
        visible = config.bg_visible
	})

	box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "left_top",
		visible = params.first or corner_visible,
		layer = 0,
		y = 0,
		halign = "left",
		x = 0,
		valign = "top",
		color = color,
		blend_mode = "add"
	})
	local left_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "left_bottom",
		visible = corner_visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "left",
		rotation = -90,
		valign = "bottom",
		color = color,
		blend_mode = "add"
	})

	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "right_top",
		visible = corner_visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 90,
		valign = "top",
		color = color,
		blend_mode = "add"
	})

	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2_mod_ehi/hud_corner",
		name = "right_bottom",
		visible = corner_visible,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 180,
		valign = "bottom",
		color = color,
		blend_mode = "add"
	})

	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

	return box_panel
end

---@class FakeEHITracker
---@field _icon1 PanelBitmap
---@field _text_color Color?
FakeEHITracker = class()
FakeEHITracker._gap = 5
FakeEHITracker._icon_size = 32
FakeEHITracker._icon_gap_size = FakeEHITracker._icon_size + FakeEHITracker._gap
FakeEHITracker._selected_color = Color(255, 255, 165, 0) / 255
---@param panel Panel
---@param params EHITracker.params
---@param parent_class FakeEHITrackerManager
function FakeEHITracker:init(panel, params, parent_class)
    self:pre_init(params)
    self._scale = params.scale --[[@as number]]
    self._text_scale = params.text_scale --[[@as number]]
    self._first = params.first
    self._n_of_icons = 0
    local gap = 0
    if params.icons then
        self._n_of_icons = #params.icons
        gap = self._gap * self._n_of_icons
    end
    self._n = self._n_of_icons
    self._gap_scaled = self._gap * self._scale -- 5 * self._scale
    self._icon_size_scaled = 32 * self._scale -- 32 * self._scale
    self._icon_gap_size_scaled = (self._icon_size + self._gap) * self._scale -- (32 + 5) * self._scale
    self._panel = panel:panel({
        name = params.id,
        x = params.x,
        y = params.y,
        w = (64 + gap + (self._icon_size * self._n_of_icons)) * self._scale,
        h = self._icon_size_scaled
    })
    self._time = params.time or 0
    self._bg_box = HUDBGBox_create(self._panel, {
        x = params.icon_pos == 1 and (self._icon_gap_size_scaled * self._n_of_icons) or 0,
        y = 0,
        w = 64 * self._scale,
        h = self._icon_size_scaled
    }, {
        bg_visible = params.bg,
        corner_visible = params.corners,
        first = self._first
    })
    if params.extend then
        self:SetBGSize()
    elseif params.extend_half then
        self:SetBGSize(self._bg_box:w() / 2)
    end
    self._text = self._bg_box:text({
        name = "text1",
        text = self:Format(),
        align = "center",
        vertical = "center",
        w = params.extend_half and self._bg_box:w() or (64 * self._scale),
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
		font_size = self._panel:h() * self._text_scale,
        color = params.text_color or self._text_color or Color.white
    })
    self:FitTheText()
    if self._n_of_icons > 0 then
        local start = params.icon_pos == 1 and 0 or self._bg_box:w()
        local icon_gap = params.icon_pos == 1 and 0 or self._gap_scaled
        for i, v in ipairs(params.icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                CreateIcon(self, s_i, texture, rect, Color.white, 1, true, start + icon_gap)
            else -- table
                local texture, rect = GetIcon(v.icon)
                CreateIcon(self, s_i, texture, rect, v.color,
                    v.alpha or 1,
                    v.visible ~= false,
                    start + icon_gap)
            end
            start = start + self._icon_size_scaled
            icon_gap = icon_gap + self._gap_scaled
        end
        self:UpdateIcons()
        if params.one_icon then
            self:UpdateIconsVisibility(true)
        end
        self.__icon_pos_left = params.icon_pos == 1
    end
    self._id = params.id
    self._parent_class = parent_class
    self._selected = false
    self:post_init(params)
end

---@param params EHITracker.params
function FakeEHITracker:pre_init(params)
end

---@param params EHITracker.params
function FakeEHITracker:post_init(params)
end

---@param w number? If not provided, `w` is taken from the BG
---@param type string?
---|"add" # Adds `w` to the BG; default `type` if not provided
---|"short" # Shorts `w` on the BG
---|"set" # Sets `w` on the BG
---@param dont_recalculate_panel_w boolean? Setting this to `true` will not recalculate the total width on the main panel
function FakeEHITracker:SetBGSize(w, type, dont_recalculate_panel_w)
    w = w or self._bg_box:w()
    if not type or type == "add" then
        self._bg_box:set_w(self._bg_box:w() + w)
    elseif type == "short" then
        self._bg_box:set_w(self._bg_box:w() - w)
    else
        self._bg_box:set_w(w)
    end
    if not dont_recalculate_panel_w then
        local start = self._bg_box:w()
        local icons_with_gap = self._icon_gap_size_scaled * self._n_of_icons
        self._panel:set_w(start + icons_with_gap)
    end
end

---@param previous_icon PanelBitmap?
---@param icon PanelBitmap? Defaults to `self._icon1` if not provided
function FakeEHITracker:SetIconX(previous_icon, icon)
    icon = icon or self._icon1
    if icon then
        local x = previous_icon and previous_icon:right() or (self.__icon_pos_left and 0 or self._bg_box:w())
        local gap = previous_icon and self._gap_scaled or (self.__icon_pos_left and 0 or self._gap_scaled)
        icon:set_x(x + gap)
    end
end

function FakeEHITracker:SetIconsX()
    local previous_icon ---@type PanelBitmap?
    for i = 1, self._n_of_icons, 1 do
        local icon = self["_icon" .. tostring(i)] --[[@as PanelBitmap?]]
        if icon then
            self:SetIconX(previous_icon, icon)
            previous_icon = icon
        end
    end
end

---@param params EHITracker.CreateText?
---@return PanelText
function FakeEHITracker:CreateText(params)
    params = params or {}
    local text = self._bg_box:text({
        text = params.text or "",
        align = "center",
        vertical = "center",
        x = params.x or params.left --[[@as number]],
        w = params.w or self._bg_box:w(),
        h = params.h or self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.color or Color.white
    })
    if params.FitTheText then
        self:FitTheText(text)
    end
    return text
end

---@param text PanelText?
function FakeEHITracker:FitTheText(text)
    text = text or self._text
    text:set_font_size(self._panel:h() * self._text_scale)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

---@param format number?
function FakeEHITracker:UpdateFormat(format)
    self._text:set_text(self:Format(format))
    self:FitTheText()
end

---@param format number?
function FakeEHITracker:Format(format)
    format = format or EHI:GetOption("time_format") --[[@as number]]
    if format == 1 then
        return tweak_data.ehi.functions.FormatSecondsOnly(self)
    else
        return tweak_data.ehi.functions.FormatMinutesAndSeconds(self)
    end
end

---@param x number
function FakeEHITracker:SetX(x)
    self._panel:set_x(x)
end

---@param y number
function FakeEHITracker:SetY(y)
    self._panel:set_y(y)
end

---@param x number
---@param y number
function FakeEHITracker:SetPos(x, y)
    self:SetX(x)
    self:SetY(y)
end

---@param id string
function FakeEHITracker:SetSelected(id)
    local previous = self._selected
    self._selected = id == self._id
    if previous == self._selected then
        return
    end
    self:SetTextColor(self._selected)
end

---@param selected boolean
function FakeEHITracker:SetTextColor(selected)
    self._text:set_color(selected and self._selected_color or Color.white)
end

function FakeEHITracker:UpdateBGVisibility(visibility, corners)
    self._bg_box:child("bg"):set_visible(visibility)
    self:UpdateCornerVisibility(visibility and corners)
end

---@param visibility boolean
function FakeEHITracker:UpdateCornerVisibility(visibility)
    self._bg_box:child("left_top"):set_visible(self._first or visibility)
    self._bg_box:child("left_bottom"):set_visible(visibility)
    self._bg_box:child("right_top"):set_visible(visibility)
    self._bg_box:child("right_bottom"):set_visible(visibility)
end

---@param visibility boolean
function FakeEHITracker:UpdateIconsVisibility(visibility)
    local i_start = visibility and 2 or 1
    self._n = visibility and 1 or self._n_of_icons
    for i = i_start, self._n_of_icons, 1 do
        self["_icon" .. i]:set_visible(not visibility)
    end
    if self.__icon_pos_left then
        self._bg_box:set_x(self._icon_gap_size_scaled * self._n)
    end
end

function FakeEHITracker:UpdateIcons()
end

---@param pos number
function FakeEHITracker:UpdateIconsPos(pos)
    self.__icon_pos_left = pos == 1
    self._bg_box:set_x(pos == 1 and (self._icon_gap_size_scaled * self._n) or 0)
    self:SetIconsX()
end

---@param scale number
function FakeEHITracker:UpdateTextScale(scale)
    self._text_scale = scale
    self:FitTheText()
end

function FakeEHITracker:GetSize()
    if self._n == 1 then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return self._panel:w()
end

function FakeEHITracker:Reposition()
    self._parent_class:ForceReposition()
end

function FakeEHITracker:destroy()
    if alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

---@class FakeEHITradeDelayTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHITradeDelayTracker = class(FakeEHITracker)
---@param params EHITracker.params
function FakeEHITradeDelayTracker:pre_init(params)
    self._civilians_format = EHI:GetOption("show_trade_delay_amount_of_killed_civilians")
    self._civilians_killed = math.random(1, 4)
    params.time = 5 + (self._civilians_killed * 30)
end

---@param format boolean
function FakeEHITradeDelayTracker:UpdateFormat(format)
    self._civilians_format = format
    FakeEHITradeDelayTracker.super.UpdateFormat(self)
end

---@param format number?
function FakeEHITradeDelayTracker:Format(format)
    local s = FakeEHITradeDelayTracker.super.Format(self, format)
    if self._civilians_format then
        return string.format("%s (%d)", s, self._civilians_killed)
    end
    return s
end

---@class FakeEHIXPTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIXPTracker = class(FakeEHITracker)
function FakeEHIXPTracker:init(...)
    self._xp = math.random(1000, 1000000)
    FakeEHIXPTracker.super.init(self, ...)
end

function FakeEHIXPTracker:Format(format)
    return "+" .. self._xp
end

---@class FakeEHIProgressTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIProgressTracker = class(FakeEHITracker)
function FakeEHIProgressTracker:init(panel, params, parent_class)
    self._progress = math.random(0, params.progress or 9)
    self._max = params.max or 10
    FakeEHIProgressTracker.super.init(self, panel, params, parent_class)
end

function FakeEHIProgressTracker:Format(format)
    return self._progress .. "/" .. self._max
end

---@class FakeEHIChanceTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIChanceTracker = class(FakeEHITracker)
function FakeEHIChanceTracker:init(panel, params, parent_class)
    self._chance = params.chance or (math.random(1, 10) * 5)
    FakeEHIChanceTracker.super.init(self, panel, params, parent_class)
end

function FakeEHIChanceTracker:Format(format)
    return self._chance .. "%"
end

---@class FakeEHIEquipmentTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHIEquipmentTracker = class(FakeEHITracker)
function FakeEHIEquipmentTracker:init(panel, params, parent_class)
    self._show_placed = params.show_placed
    local max = params.charges or 16
    self._charges = math.random(params.min or 2, max)
    self._placed = self._charges > 4 and math.ceil(self._charges / 4) or 1
    FakeEHIEquipmentTracker.super.init(self, panel, params, parent_class)
end

function FakeEHIEquipmentTracker:Format(format)
    return self:EquipmentFormat()
end

function FakeEHIEquipmentTracker:EquipmentFormat(format)
    format = format or EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        if self._show_placed then
            return self._charges .. " (" .. self._placed .. ")"
        else
            return tostring(self._charges)
        end
    elseif format == 2 then -- (Bags placed) Uses
        if self._show_placed then
            return "(" .. self._placed .. ") " .. self._charges
        else
            return tostring(self._charges)
        end
    elseif format == 3 then -- (Uses) Bags placed
        if self._show_placed then
            return "(" .. self._charges .. ") " .. self._placed
        else
            return tostring(self._charges)
        end
    elseif format == 4 then -- Bags placed (Uses)
        if self._show_placed then
            return self._placed .. " (" .. self._charges .. ")"
        else
            return tostring(self._charges)
        end
    elseif format == 5 then -- Uses
        return tostring(self._charges)
    else -- Bags placed
        if self._show_placed then
            return tostring(self._placed)
        else
            return tostring(self._charges)
        end
    end
end

function FakeEHIEquipmentTracker:UpdateEquipmentFormat(format)
    self._text:set_font_size(self._panel:h() * self._text_scale)
    self._text:set_text(self:EquipmentFormat(format))
    self:FitTheText()
end

---@class FakeEHIMinionCounterTracker : FakeEHIEquipmentTracker
---@field super FakeEHIEquipmentTracker
FakeEHIMinionCounterTracker = class(FakeEHIEquipmentTracker)
function FakeEHIMinionCounterTracker:init(panel, params, parent_class)
    FakeEHIMinionCounterTracker.super.init(self, panel, params, parent_class)
    self._charges_second_player = math.random(params.min, params.charges)
    self._color_second_player = self._parent_class:GetOtherPeerColor()
    self._text_second_player = self:CreateText({
        text = tostring(self._charges_second_player),
        w = self._bg_box:w() / 2,
        color = self._color_second_player
    })
    self._text_second_player:set_right(self._bg_box:right())
    self:FitTheText(self._text_second_player)
    self._text_total = self:CreateText({
        text = tostring(self._charges + self._charges_second_player)
    })
    self:UpdateFormat(EHI:GetOption("show_minion_option"))
end

function FakeEHIMinionCounterTracker:UpdateFormat(value)
    self._icon1:set_color(value == 1 and self._parent_class:GetPeerColor() or Color.white)
    self._text_second_player:set_visible(value == 3)
    self._text_total:set_visible(value == 2)
    self._text:set_visible(value ~= 2)
    self._text:set_color(value == 3 and self._parent_class:GetPeerColor() or Color.white)
    self._format = value
    if value == 3 then
        self._text:set_w(self._bg_box:w() / 2)
    else
        self._text:set_w(self._bg_box:w())
    end
    self:FitTheText()
end

---@param selected boolean
function FakeEHIMinionCounterTracker:SetTextColor(selected)
    self._text:set_color(selected and self._selected_color or (self._format == 3 and self._parent_class:GetPeerColor() or Color.white))
    self._text_second_player:set_color(selected and self._selected_color or self._color_second_player)
end

---@class FakeEHICountTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHICountTracker = class(FakeEHITracker)
---@param params EHITracker.params
function FakeEHICountTracker:pre_init(params)
    self._count = params.count
end

function FakeEHICountTracker:Format(format)
    return tostring(self._count)
end

---@class FakeEHIEnemyCountTracker : FakeEHICountTracker
---@field super FakeEHICountTracker
---@field _icon2 PanelBitmap
FakeEHIEnemyCountTracker = class(FakeEHICountTracker)
function FakeEHIEnemyCountTracker:init(panel, params, parent_class)
    self._alarm_count = math.random(0, 10)
    self._format_alarm = EHI:GetOption("show_enemy_count_show_pagers")
    FakeEHIEnemyCountTracker.super.init(self, panel, params, parent_class)
end

function FakeEHIEnemyCountTracker:GetSize()
    if self._n >= 2 and not self._format_alarm then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return FakeEHIEnemyCountTracker.super.GetSize(self)
end

function FakeEHIEnemyCountTracker:Format(format)
    if self._format_alarm then
        return self._alarm_count .. "|" .. self._count
    end
    return FakeEHIEnemyCountTracker.super.Format(self, format)
end

function FakeEHIEnemyCountTracker:UpdateFormat(format)
    self._format_alarm = format
    FakeEHIEnemyCountTracker.super.UpdateFormat(self, format)
    self:UpdateIconPos(true)
end

---@param reposition boolean?
function FakeEHIEnemyCountTracker:UpdateIconPos(reposition)
    if self._n == 1 then -- 1 icon
        self._icon1:set_visible(self._format_alarm)
        self._icon2:set_visible(not self._format_alarm)
        self._icon2:set_x(self._icon1:x())
    else
        self._icon1:set_visible(self._format_alarm)
        self._icon2:set_visible(true)
        if self._format_alarm then
            self._icon2:set_x(self._icon1:x() + self._icon_gap_size_scaled)
        else
            self._icon2:set_x(self._icon1:x())
        end
    end
    if reposition then
        self:Reposition()
    end
end

---@param visibility boolean
function FakeEHIEnemyCountTracker:UpdateIconsVisibility(visibility)
    FakeEHIEnemyCountTracker.super.UpdateIconsVisibility(self, visibility)
    self:UpdateIconPos()
end
FakeEHIEnemyCountTracker.UpdateIcons = FakeEHIEnemyCountTracker.UpdateIconPos

---@class FakeEHITimerTracker : FakeEHITracker, FakeEHIProgressTracker
---@field super FakeEHITracker
FakeEHITimerTracker = class(FakeEHITracker)
FakeEHITimerTracker.FormatProgress = FakeEHIProgressTracker.Format
function FakeEHITimerTracker:init(panel, params, parent_class)
    self._max = 3
    self._progress = math.random(0, 2)
    FakeEHITimerTracker.super.init(self, panel, params, parent_class)
    self._text:set_left(0)
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        w = self._bg_box:w() / 2,
        left = self._text:right(),
        FitTheText = true
    })
end

---@param selected boolean
function FakeEHITimerTracker:SetTextColor(selected)
    FakeEHITimerTracker.super.SetTextColor(self, selected)
    self._progress_text:set_color(selected and self._selected_color or Color.white)
end

function FakeEHITimerTracker:UpdateTextScale(...)
    FakeEHITimerTracker.super.UpdateTextScale(self, ...)
    self:FitTheText(self._progress_text)
end

---@class FakeEHICivilianCountTracker : FakeEHICountTracker
---@field super FakeEHICountTracker
---@field _icon2 PanelBitmap
FakeEHICivilianCountTracker = class(FakeEHICountTracker)
FakeEHICivilianCountTracker._ehi_option = "civilian_count_tracker_format"
---@param params EHITracker.params
function FakeEHICivilianCountTracker:pre_init(params)
    FakeEHICivilianCountTracker.super.pre_init(self, params)
    self._tied_count = math.random(0, self._count)
    self._format_civilian = EHI:GetOption(self._ehi_option)
end

function FakeEHICivilianCountTracker:GetSize()
    if self._n >= 2 and self._format_civilian == 1 then
        return self._bg_box:w() + self._icon_gap_size_scaled
    end
    return FakeEHICivilianCountTracker.super.GetSize(self)
end

function FakeEHICivilianCountTracker:UpdateFormat(format)
    self._format_civilian = format
    FakeEHICivilianCountTracker.super.UpdateFormat(self, format)
    self:UpdateIconPos(true)
end

function FakeEHICivilianCountTracker:Format(format)
    format = format or self._format_civilian
    if format == 1 then
        return tostring(self._count)
    else
        local untied = self._count - self._tied_count
        if format == 2 then
            return self._tied_count .. "|" .. untied
        else
            return untied .. "|" .. self._tied_count
        end
    end
end

---@param reposition boolean?
function FakeEHICivilianCountTracker:UpdateIconPos(reposition)
    if self._n == 1 then -- 1 icon
        self:SetIconX()
        self._icon2:set_visible(false)
    else
        self._icon2:set_visible(self._format_civilian >= 2)
        if self._format_civilian == 2 then
            self:SetIconX(nil, self._icon2)
            self:SetIconX(self._icon2)
        else
            self:SetIconsX()
        end
    end
    if reposition then
        self:Reposition()
    end
end

function FakeEHICivilianCountTracker:UpdateIcons()
    self._icon2:set_visible(self._format_civilian >= 2)
end

---@param visibility boolean
function FakeEHICivilianCountTracker:UpdateIconsVisibility(visibility)
    FakeEHICivilianCountTracker.super.UpdateIconsVisibility(self, visibility)
    self:UpdateIconPos()
end

---@class FakeEHIHostageCountTracker : FakeEHICivilianCountTracker
---@field super FakeEHICivilianCountTracker
FakeEHIHostageCountTracker = class(FakeEHICivilianCountTracker)
FakeEHIHostageCountTracker._ehi_option = "hostage_count_tracker_format"
---@param params EHITracker.params
function FakeEHIHostageCountTracker:pre_init(params)
    FakeEHIHostageCountTracker.super.pre_init(self, params)
    self._tied_count = math.random(0, math.floor(self._count / 2))
end

function FakeEHIHostageCountTracker:Format(format)
    format = format or self._format_civilian
    if format == 1 then
        return tostring(self._count)
    else
        local civilian_hostages = self._count - self._tied_count
        if format == 2 then
            return self._count .. "|" .. self._tied_count
        elseif format == 3 then
            return self._tied_count .. "|" .. self._count
        elseif format == 4 then
            return civilian_hostages .. "|" .. self._tied_count
        else
            return self._tied_count .. "|" .. civilian_hostages
        end
    end
end

function FakeEHIHostageCountTracker:UpdateIconPos(...)
    local original_format = self._format_civilian
    if self._format_civilian == 2 then
        self._format_civilian = 3
    elseif self._format_civilian == 3 or self._format_civilian == 5 then
        self._format_civilian = 2
    end
    FakeEHIHostageCountTracker.super.UpdateIconPos(self, ...)
    self._format_civilian = original_format
end

---@class FakeEHIAssaultTimeTracker : FakeEHITracker, FakeEHIChanceTracker
---@field super FakeEHITracker
FakeEHIAssaultTimeTracker = class(FakeEHITracker)
FakeEHIAssaultTimeTracker.FormatChance = FakeEHIChanceTracker.Format
---@param params EHITracker.params
function FakeEHIAssaultTimeTracker:post_init(params)
    if params.control then
        self._icon1:set_color(Color.white)
    elseif self._time <= 5 then -- Fade
        self._icon1:set_color(Color(255, 0, 255, 255) / 255)
    elseif self._time >= 205 then -- Build
        self._icon1:set_color(Color.yellow)
    else
        self._icon1:set_color(Color(255, 237, 127, 127) / 255)
    end
    self._bg_size = self._bg_box:w()
    self._chance = params.diff
    self._diff_chance_text = self:CreateText({
        text = self:FormatChance(),
        left = self._text:right()
    })
    self:UpdateFormat(EHI:GetOption("show_assault_diff_in_assault_trackers"))
end

---@param format boolean
---@param reposition boolean?
function FakeEHIAssaultTimeTracker:UpdateFormat(format, reposition)
    if self._show_diff == format then
        return
    end
    self._show_diff = format
    self._diff_chance_text:set_visible(format)
    if format then
        self:SetBGSize()
    else
        self:SetBGSize(self._bg_size, "set")
    end
    self:SetIconX()
    if reposition then
        self:Reposition()
    end
end

---@class FakeEHISniperTracker : FakeEHITracker
---@field super FakeEHITracker
FakeEHISniperTracker = class(FakeEHITracker)
FakeEHISniperTracker._selected_color = Color.yellow
FakeEHISniperTracker._text_color = FakeEHITracker._selected_color
---@param params EHITracker.params
function FakeEHISniperTracker:post_init(params)
    self._text:set_text(tostring(math.random(1, 4)))
end

---@param selected boolean
function FakeEHISniperTracker:SetTextColor(selected)
    self._text:set_color(selected and self._selected_color or self._text_color)
end

---@class FakeEHIPhalanxChanceTracker : FakeEHITimerTracker
---@field super FakeEHITimerTracker
FakeEHIPhalanxChanceTracker = class(FakeEHITimerTracker)
FakeEHIPhalanxChanceTracker.FormatProgress = FakeEHIChanceTracker.Format
function FakeEHIPhalanxChanceTracker:init(...)
    self._chance = 5 + (9 * math.random(0, 5))
    FakeEHIPhalanxChanceTracker.super.init(self, ...)
    self._progress_text:set_left(0)
    self._text:set_left(self._progress_text:right())
end