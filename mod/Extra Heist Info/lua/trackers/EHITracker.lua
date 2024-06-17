local Color = Color
local math_abs = math.abs
local math_min = math.min
local math_sin = math.sin
local math_lerp = math.lerp
---@param o PanelBaseObject
---@param hint PanelText
---@param end_a number End alpha
local function visibility_hint(o, hint, end_a)
    local t, TOTAL_T = 0, 0.18
    local o_start_a = o:alpha()
    local hint_start_a = hint:alpha()
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_alpha(math_lerp(o_start_a, end_a, lerp))
        hint:set_alpha(math_lerp(hint_start_a, end_a, lerp))
    end
end
---@param o PanelBaseObject
---@param end_a number End alpha
local function visibility(o, end_a) -- This is actually faster than manually re-typing optimized "over" function
    local t, TOTAL_T = 0, 0.18
    local start_a = o:alpha()
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_alpha(math_lerp(start_a, end_a, lerp))
    end
end
---@param o PanelBaseObject
---@param t number
local function hint_wait(o, t)
    wait(t)
    visibility(o, 0)
end
---@param o PanelBaseObject
---@param target_y number
local function top(o, target_y)
    local t, total = 0, 0.18
    local from_y = o:y()
    while t < total do
        t = t + coroutine.yield()
        o:set_y(math_lerp(from_y, target_y, t / total))
    end
    o:set_y(target_y)
end
---@param o PanelBaseObject
---@param target_x number
local function left(o, target_x)
    local t, total = 0, 0.18
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(math_lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
local panel_w
if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", 4) or EHI:IsVerticalAlignmentAndOption("tracker_vertical_w_anim") == 2 then -- Horizontal; Right to Left or Panel W anim is Right to Left and Vertical alignment
    ---@param o PanelBaseObject
    ---@param target_w number
    ---@param self EHITracker?
    panel_w = function(o, target_w, self)
        local TOTAL_T = 0.18
        local from_w = o:w()
        local from_x = o:x()
        local abs = -(from_w - target_w)
        local target_x = from_x + -(target_w - from_w)
        local t = (1 - abs / abs) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math_min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_x(math_lerp(from_x, target_x, lerp))
            o:set_w(math_lerp(from_w, target_w, lerp))
        end
        if self and self.RedrawPanel then
            self:RedrawPanel()
        end
    end
else
    ---@param o PanelBaseObject
    ---@param target_w number
    ---@param self EHITracker?
    panel_w = function(o, target_w, self)
        local TOTAL_T = 0.18
        local from_w = o:w()
        local abs = -(from_w - target_w)
        local t = (1 - abs / abs) * TOTAL_T
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = math_min(t + dt, TOTAL_T)
            local lerp = t / TOTAL_T
            o:set_w(math_lerp(from_w, target_w, lerp))
        end
        if self and self.RedrawPanel then
            self:RedrawPanel()
        end
    end
end

---@param o PanelBaseObject
---@param target_x number
local function icon_x(o, target_x)
    local TOTAL_T = 0.18
    local from_x = o:x()
    local t = (1 - math_abs(from_x - target_x) / math_abs(from_x - target_x)) * TOTAL_T
    while TOTAL_T > t do
        local dt = coroutine.yield()
        t = math_min(t + dt, TOTAL_T)
        local lerp = t / TOTAL_T
        o:set_x(math_lerp(from_x, target_x, lerp))
    end
    o:set_x(target_x)
end
---@param bg PanelRectangle
---@param total_t number
local function bg_attention(bg, total_t)
    local color = Color.white
	local t = total_t or 3
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local cv = math_abs(math_sin(t * 180 * 1))
		bg:set_color(Color(1, color.red * cv, color.green * cv, color.blue * cv))
	end
	bg:set_color(Color(1, 0, 0, 0))
end
---@param o PanelBaseObject
---@param skip boolean
---@param self EHITracker
local function destroy(o, skip, self)
    if not skip then
        if self._hint then
            visibility_hint(o, self._hint, 0)
        else
            visibility(o, 0)
        end
    end
    self._bg_box:child("bg"):stop()
    self._panel:parent():remove(self._panel)
    if self._hint then
        self._hint:parent():remove(self._hint)
    end
end
local icons = tweak_data.ehi.icons
---@param icon string
---@return string, number[]
local function GetIcon(icon)
    if icons[icon] then
        return icons[icon].texture, icons[icon].texture_rect
    end
    return tweak_data.hud_icons:get_icon_or(icon, icons.default.texture, icons.default.texture_rect)
end

---@param text PanelText
local function make_fine_text(text)
    local _, _, w, h = text:text_rect()
    text:set_size(w, h)
    text:set_position(math.round(text:x()), math.round(text:y()))
end

local bg_visibility = EHI:GetOption("show_tracker_bg")
local corner_visibility = EHI:GetOption("show_tracker_corners")

---@param panel Panel
---@param params table
local function CreateHUDBGBox(panel, params)
    local box_panel = panel:panel(params)
	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = Color(1, 0, 0, 0),
        visible = bg_visibility
	})
    if bg_visibility and corner_visibility then
        box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            y = 0,
            halign = "left",
            x = 0,
            valign = "top",
            blend_mode = "add"
        })
        local left_bottom = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "left",
            rotation = -90,
            valign = "bottom",
            blend_mode = "add"
        })
        left_bottom:set_bottom(box_panel:h())
        local right_top = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "right",
            rotation = 90,
            valign = "top",
            blend_mode = "add"
        })
        right_top:set_right(box_panel:w())
        local right_bottom = box_panel:bitmap({
            texture = "guis/textures/pd2/hud_corner",
            visible = true,
            layer = 0,
            x = 0,
            y = 0,
            halign = "right",
            rotation = 180,
            valign = "bottom",
            blend_mode = "add"
        })
        right_bottom:set_right(box_panel:w())
        right_bottom:set_bottom(box_panel:h())
    end
	return box_panel
end

---@class EHITracker
---@field new fun(self: self, panel: Panel, params: AddTrackerTable|ElementTrigger, parent_class: EHITrackerManager): self
---@field _forced_icons table? Forces specific icons in the tracker
---@field _forced_time number? Forces specific time in the tracker
---@field _forced_hint_text string? Forces specific hint text in the tracker
---@field _forced_icon_color Color[]? Forces specific icon color in the tracker
---@field _icon1 PanelBitmap
---@field _panel_override_w number?
---@field _hint_no_localization boolean?
---@field _hint_vanilla_localization boolean?
EHITracker = class()
EHITracker._update = true
EHITracker._fade_time = 5
EHITracker._tracker_type = "accurate"
EHITracker._gap = 5
EHITracker._icon_size = 32
EHITracker._scale = EHI:IsVR() and EHI:GetOption("vr_scale") or EHI:GetOption("scale") --[[@as number]]
EHITracker._text_scale = EHI:GetOption("text_scale") --[[@as number]]
-- (32 + 5) * self._scale
EHITracker._icon_gap_size_scaled = (EHITracker._icon_size + EHITracker._gap) * EHITracker._scale
-- 32 * self._scale
EHITracker._icon_size_scaled = EHITracker._icon_size * EHITracker._scale
-- 5 * self._scale
EHITracker._gap_scaled = EHITracker._gap * EHITracker._scale
EHITracker._default_bg_size = 64 * EHITracker._scale
EHITracker._text_color = Color.white
if EHI:GetOption("show_tracker_hint") then
    EHITracker._hint_t = EHI:GetOption("show_tracker_hint_t") --[[@as number]]
else
    EHITracker._hint_disabled = true
end
EHITracker._init_create_text = true
if EHI:GetOption("show_icon_position") == 1 then
    EHITracker._ICON_LEFT_SIDE_START = true
    EHITracker._ICON_ANIM_BLOCKED = true
end
---@param panel Panel Main panel provided by EHITrackerManager
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHITracker:init(panel, params, parent_class)
    self:pre_init(params)
    self._id = params.id
    self._icons = self._forced_icons or params.icons
    self._parent_class = parent_class
    self._n_of_icons = 0
    local gap = 0
    if type(self._icons) == "table" then
        self._n_of_icons = #self._icons
        gap = self._gap * self._n_of_icons
    end
    self._time = self._forced_time or params.time or 0
    self._panel = panel:panel({
        x = 0,
        y = 0,
        w = (64 + gap + (self._icon_size * self._n_of_icons)) * self._scale,
        h = self._icon_size_scaled,
        alpha = 0,
        visible = true
    })
    self._bg_box = CreateHUDBGBox(self._panel, {
        x = self._ICON_LEFT_SIDE_START and (self._icon_gap_size_scaled * self._n_of_icons) or 0,
        y = 0,
        w = self._default_bg_size,
        h = self._icon_size_scaled
    })
    if self._init_create_text then
        self._text = self._bg_box:text({
            text = self:Format(),
            align = "center",
            vertical = "center",
            w = self._bg_box:w(),
            h = self._icon_size_scaled,
            font = tweak_data.menu.pd2_large_font,
            font_size = self._panel:h() * self._text_scale,
            color = self._text_color
        })
        self:FitTheText()
    end
    if self._n_of_icons > 0 then
        self:CreateIcons()
    end
    self:OverridePanel()
    self._hide_on_delete = params.hide_on_delete
    self._flash_times = params.flash_times or 3
    self._anim_flash = params.flash_bg ~= false
    self._remove_on_alarm = params.remove_on_alarm --Removes tracker when alarm sounds
    self._update_on_alarm = params.update_on_alarm --Calls `OnAlarm` function when alarm sounds
    self:post_init(params)
    self:CreateHint(params.hint, params.delay_popup)
end

---@param params EHITracker.params
function EHITracker:pre_init(params)
end

---@param params EHITracker.params
function EHITracker:post_init(params)
end

function EHITracker:OverridePanel()
end

function EHITracker:PrecomputeDoubleSize()
    self._bg_box_w = self._bg_box:w()
    self._bg_box_double = self._default_bg_size * 2
    self._panel_w = self._panel:w()
    self._panel_double = self._bg_box_double + (self._icon_gap_size_scaled * self._n_of_icons)
end

---@param new_id string
function EHITracker:UpdateID(new_id)
    self._id = new_id
end

---@param x number
---@param y number
function EHITracker:PosAndSetVisible(x, y)
    if self.__vertical_anim_w_left_diff then
        x = x + self.__vertical_anim_w_left_diff
        self.__vertical_anim_w_left_diff = nil
    end
    self._panel:set_x(x)
    self._panel:set_y(y)
    self:SetPanelAlpha(1)
    self:PositionHint(x, y)
end

---@param alpha number
function EHITracker:SetPanelAlpha(alpha)
    if self._anim_visibility then
        self._panel:stop(self._anim_visibility)
    end
    if self._hint then
        self._hint:stop()
        self._anim_visibility = self._panel:animate(visibility_hint, self._hint, alpha)
    else
        self._anim_visibility = self._panel:animate(visibility, alpha)
    end
end

---@param target_y number
function EHITracker:AnimateTop(target_y)
    if self._anim_move then
        self._panel:stop(self._anim_move)
    end
    self._anim_move = self._panel:animate(top, target_y)
    if self._hint then
        if self._anim_hint_move then
            self._hint:stop(self._anim_hint_move)
        end
        self._anim_hint_move = self._hint:animate(top, target_y - self._hint_pos.y_diff)
    end
end

---@param target_x number
function EHITracker:AnimateLeft(target_x)
    if self._anim_move then
        self._panel:stop(self._anim_move)
    end
    self._anim_move = self._panel:animate(left, target_x)
    if self._hint then
        if self._anim_hint_move then
            self._hint:stop(self._anim_hint_move)
        end
        self._anim_hint_move = self._hint:animate(left, target_x)
        self._hint_pos.x = target_x
    end
end

---@param target_w number
function EHITracker:AnimatePanelW(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
    end
    self:AnimateHintX(target_w)
    self._anim_set_w = self._panel:animate(panel_w, target_w)
end

---@param target_w number
function EHITracker:AnimatePanelWAndRefresh(target_w)
    if self._anim_set_w then
        self._panel:stop(self._anim_set_w)
    end
    self:AnimateHintX(target_w)
    self._anim_set_w = self._panel:animate(panel_w, target_w, self)
end

---@param previous_icon PanelBitmap?
---@param icon PanelBitmap? Defaults to `self._icon1` if not provided
function EHITracker:SetIconX(previous_icon, icon)
    icon = icon or self._icon1
    if icon then
        local x = previous_icon and previous_icon:right() or (self._ICON_LEFT_SIDE_START and 0 or self._bg_box:w())
        local gap = previous_icon and self._gap_scaled or (self._ICON_LEFT_SIDE_START and 0 or self._gap_scaled)
        icon:set_x(x + gap)
    end
end

function EHITracker:SetIconsX()
    local previous_icon ---@type PanelBitmap?
    for i = 1, self._n_of_icons, 1 do
        local icon = self["_icon" .. tostring(i)] --[[@as PanelBitmap?]]
        if icon then
            self:SetIconX(previous_icon, icon)
            previous_icon = icon
        end
    end
end

---@param target_x number
function EHITracker:AnimIconX(target_x)
    if self._ICON_ANIM_BLOCKED or not self._icon1 then
        return
    end
    self._icon_anims = self._icon_anims or {}
    if self._icon_anims[1] then
        self._icon1:stop(self._icon_anims[1])
    end
    self._icon_anims[1] = self._icon1:animate(icon_x, target_x)
end

---@param target_x number
function EHITracker:AnimIconsX(target_x)
    if self._ICON_ANIM_BLOCKED then
        return
    end
    self._icon_anims = self._icon_anims or {}
    local offset = self._icon_gap_size_scaled
    for i = 1, self._n_of_icons, 1 do
        local icon = self["_icon" .. tostring(i)] ---@type PanelBitmap?
        if icon then
            if self._icon_anims[i] then
                icon:stop(self._icon_anims[i])
            end
            self._icon_anims[i] = icon:animate(icon_x, target_x + (offset * (i - 1)))
        end
    end
end

if EHI:GetOption("time_format") == 1 then
    EHITracker.Format = tweak_data.ehi.functions.FormatSecondsOnly
    EHITracker.FormatTime = tweak_data.ehi.functions.ReturnSecondsOnly
    EHITracker.ShortFormat = tweak_data.ehi.functions.ShortFormatSecondsOnly
    EHITracker.ShortFormatTime = tweak_data.ehi.functions.ReturnShortFormatSecondsOnly
    EHITracker._TIME_FORMAT = 1 -- Seconds only
else
    EHITracker.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
    EHITracker.FormatTime = tweak_data.ehi.functions.ReturnMinutesAndSeconds
    EHITracker.ShortFormat = tweak_data.ehi.functions.ShortFormatMinutesAndSeconds
    EHITracker.ShortFormatTime = tweak_data.ehi.functions.ReturnShortFormatMinutesAndSeconds
    EHITracker._TIME_FORMAT = 2 -- Minutes and seconds
end

if EHI:GetOption("show_one_icon") then
    EHITracker._ONE_ICON = true
    function EHITracker:CreateIcons()
        self._n_of_icons = 1
        local icon_pos = self._ICON_LEFT_SIDE_START and 0 or (self._bg_box:w() + self._gap_scaled)
        local first_icon = self._icons[1]
        if type(first_icon) == "string" then
            local texture, rect = GetIcon(first_icon)
            self:CreateIcon(1, "1", texture, rect, icon_pos)
        elseif type(first_icon) == "table" then
            local texture, rect = GetIcon(first_icon.icon or "default")
            self:CreateIcon(1, "1", texture, rect, icon_pos, first_icon.visible, first_icon.color, first_icon.alpha)
        end
    end
else
    function EHITracker:CreateIcons()
        local icon_pos = self._ICON_LEFT_SIDE_START and 0 or (self._bg_box:w() + self._gap_scaled)
        for i, v in ipairs(self._icons) do
            local s_i = tostring(i)
            if type(v) == "string" then
                local texture, rect = GetIcon(v)
                self:CreateIcon(i, s_i, texture, rect, icon_pos)
            elseif type(v) == "table" then -- table
                local texture, rect = GetIcon(v.icon or "default")
                self:CreateIcon(i, s_i, texture, rect, icon_pos, v.visible, v.color, v.alpha)
            end
            icon_pos = icon_pos + self._icon_gap_size_scaled
        end
    end
end

---@param i number
---@param s_i string
---@param texture string
---@param texture_rect number[]
---@param x number
---@param visible boolean?
---@param color Color?
---@param alpha number?
function EHITracker:CreateIcon(i, s_i, texture, texture_rect, x, visible, color, alpha)
    self["_icon" .. s_i] = self._panel:bitmap({
        texture = texture,
        texture_rect = texture_rect,
        color = self._forced_icon_color and self._forced_icon_color[i] or color or Color.white,
        alpha = alpha or 1,
        visible = visible ~= false,
        x = x,
        w = self._icon_size_scaled,
        h = self._icon_size_scaled
    })
end

---@param params EHITracker.CreateText?
function EHITracker:CreateText(params)
    params = params or {}
    local text = self._bg_box:text({
        name = params.name,
        text = params.text or "",
        align = "center",
        vertical = "center",
        x = params.x or params.left --[[@as number]],
        w = params.w or self._bg_box:w(),
        h = params.h or self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = params.color or self._text_color,
        visible = params.visible
    })
    if params.status_text then
        self:SetStatusText(params.status_text, text)
    end
    if params.FitTheText then
        self:FitTheText(text, params.FitTheText_FontSize)
    end
    return text
end

---@param text string
---@param delay_popup boolean?
function EHITracker:CreateHint(text, delay_popup)
    text = self._forced_hint_text or text
    if self._hint_disabled or not text then
        return
    end
    local loc
    if self._hint_no_localization then
        loc = text
    else
        loc = managers.localization:text(self._hint_vanilla_localization and text or "ehi_hint_" .. text)
    end
    self._hint = self._panel:parent():text({
        text = loc,
        align = "center",
        vertical = "center",
        w = 18,
        h = 18,
        font = tweak_data.menu.pd2_large_font,
        font_size = 18,
        color = Color.white,
        visible = true,
        alpha = 0
    })
    make_fine_text(self._hint)
    self._hint_pos = { x = self._hint:x(), y_diff = 0 }
    self._delay_hint = delay_popup
end

---@param text string
function EHITracker:UpdateHint(text)
    if self._hint_disabled or not text or not self._hint then
        return
    end
    local loc
    if self._hint_no_localization then
        loc = text
    else
        loc = self._hint_vanilla_localization and text or "ehi_hint_" .. text
    end
    self._hint:set_text(managers.localization:text(loc))
    make_fine_text(self._hint)
    self._hint:set_x(self._hint_pos.x)
end

function EHITracker:ForceShowHint()
    self._delay_hint = nil
    if self._hint and self._hint_t > 0 then
        self._hint:animate(hint_wait, self._hint_t)
    end
end

---@param n_of_icons number?
function EHITracker:AnimateRepositionHintX(n_of_icons)
    if not self._hint then
        return
    end
    local hint_x = self._panel_override_w or (self._bg_box:w() + (self._icon_gap_size_scaled * (n_of_icons or self._n_of_icons)))
    self:AnimateHintX(hint_x)
end

if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", { [1] = true, [2] = true }) then
    if EHI:GetOption("tracker_vertical_w_anim") == 2 then
        EHITracker._VERTICAL_ANIM_W_LEFT = true
        EHITracker._ICON_ANIM_BLOCKED = nil
        ---@param target_w number
        function EHITracker:AnimateHintX(target_w)
        end

        ---@param target_w number
        function EHITracker:SetHintX(target_w)
        end
    else
        ---@param target_w number
        function EHITracker:AnimateHintX(target_w)
            if not self._hint then
                return
            end
            if self._anim_hint_x then
                self._hint:stop(self._anim_hint_x)
            end
            local x = self._hint_pos.x + (target_w - self._panel:w())
            self._anim_hint_x = self._hint:animate(left, x)
            self._hint_pos.x = x
        end

        ---@param target_w number
        function EHITracker:SetHintX(target_w)
            if not self._hint then
                return
            end
            local x = self._hint_pos.x + (target_w - self._panel:w())
            self._hint:set_x(x)
            self._hint_pos.x = x
        end
    end

    ---@param x number World X
    ---@param y number World Y
    function EHITracker:PositionHint(x, y)
        if not self._hint then
            return
        end
        self._hint:set_center_y(self._panel:center_y())
        local hint_x = self._panel_override_w or (self._bg_box:w() + (self._icon_gap_size_scaled * self._n_of_icons))
        self._hint:set_x(x + hint_x + 3)
        self._hint_pos.x = self._hint:x()
        self._hint_pos.y_diff = y - self._hint:y()
        if self._hint_t > 0 and not self._delay_hint then
            self._hint:animate(hint_wait, self._hint_t)
        end
    end
else
    ---@param x number World X
    ---@param y number World Y
    function EHITracker:PositionHint(x, y)
        if not self._hint then
            return
        end
        local y_new = y + self._icon_size_scaled + 3
        self._hint:set_x(x)
        self._hint_pos.x = x
        self._hint:set_y(y_new)
        self._hint:set_w(self._panel_override_w or (self._bg_box:w() + (self._icon_gap_size_scaled * self._n_of_icons)))
        self:FitTheText(self._hint, 18)
        if self._hint_t > 0 and not self._delay_hint then
            self._hint:animate(hint_wait, self._hint_t)
        end
    end

    if EHI:CheckVRAndNonVROption("vr_tracker_alignment", "tracker_alignment", { [3] = true }) then
        ---@param target_w number
        function EHITracker:AnimateHintX(target_w)
            if not self._hint then
                return
            end
            self._hint:set_w(target_w)
            self:FitTheText(self._hint, 18)
            self._hint:set_x(self._hint_pos.x)
        end
        EHITracker.SetHintX = EHITracker.AnimateHintX
    else
        ---@param target_w number
        function EHITracker:AnimateHintX(target_w)
            if not self._hint then
                return
            end
            if self._anim_hint_x then
                self._hint:stop(self._anim_hint_x)
            end
            self._hint:set_w(target_w)
            self:FitTheText(self._hint, 18)
            local x = self._panel:x() + -(target_w - self._panel:w())
            self._anim_hint_x = self._hint:animate(left, x)
            self._hint_pos.x = x
        end

        ---@param target_w number
        function EHITracker:SetHintX(target_w)
            if not self._hint then
                return
            end
            self._hint:set_w(target_w)
            self:FitTheText(self._hint, 18)
            local x = self._panel:x() + -(target_w - self._panel:w())
            self._hint:set_x(x)
            self._hint_pos.x = x
        end
    end
end

---@param w number? If not provided, `w` is taken from the BG
---@param type string?
---|"add" # Adds `w` to the BG; default `type` if not provided
---|"short" # Shorts `w` on the BG
---|"set" # Sets `w` on the BG
---@param dont_recalculate_panel_w boolean? Setting this to `true` will not recalculate the total width on the main panel
function EHITracker:SetBGSize(w, type, dont_recalculate_panel_w)
    local original_w = self._bg_box:w()
    w = w or original_w
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
    if self._VERTICAL_ANIM_W_LEFT and self._panel:alpha() == 0 then
        -- Panel is not visible, adjustment will be performed when manager calls the `EHITracker:PosAndSetVisible()` function  
        -- Otherwise you need to adjust panel position via animation
        self.__vertical_anim_w_left_diff = original_w - self._bg_box:w()
    end
end

---@param dt number
function EHITracker:update(dt)
    self._time = self._time - dt
    self._text:set_text(self:Format())
    if self._time <= 0 then
        self:delete()
    end
end

---@param dt number
function EHITracker:update_fade(dt)
    self._fade_time = self._fade_time - dt
    if self._fade_time <= 0 then
        self:delete()
    end
end

---@param text PanelText?
---@param font_size number?
function EHITracker:FitTheText(text, font_size)
    text = text or self._text
    text:set_font_size(font_size or self._panel:h() * self._text_scale)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w) * self._text_scale)
    end
end

---@param ... number
function EHITracker:FitTheTextBasedOnTime(...)
    local time_check = self._TIME_FORMAT == 1 and 100 or 60
    if math.max(self._time, ...) >= time_check then
        local max_refresh_t = math.max(0, ...)
        if max_refresh_t >= time_check then
            local t = self._time
            self._time = max_refresh_t
            self:SetAndFitTheText()
            self._time = t
        else
            self:SetAndFitTheText()
        end
    end
end

---@param t number
---@param default_text string?
function EHITracker:FitTheTime(t, default_text)
    self._text:set_text(self:FormatTime(t))
    self:FitTheText()
    if default_text then
        self._text:set_text(default_text)
    end
end

---@param text string? If not provided, `Format` function will be called
function EHITracker:SetAndFitTheText(text)
    self._text:set_text(text or self:Format())
    self:FitTheText()
end

---@param time number
function EHITracker:SetTime(time)
    self:SetTimeNoAnim(time)
    self:AnimateBG()
end

---@param time number
function EHITracker:SetTimeNoAnim(time)
    self._time = time
    self:SetAndFitTheText()
end

---@param time number
function EHITracker:SetTimeIfLower(time)
    if self._time >= time then
        self:SetTime(time)
    end
end

---@param params AddTrackerTable|ElementTrigger
function EHITracker:Run(params)
    self:SetTimeNoAnim(params.time or 0)
    self:SetTextColor()
end

---@param delay number
function EHITracker:AddDelay(delay)
    self:SetTime(self._time + delay)
end

---@param t number?
function EHITracker:AnimateBG(t)
    t = t or self._flash_times
    if self._anim_flash and t > 0 then
        local bg = self._bg_box:child("bg") --[[@as PanelBitmap]]
        bg:stop()
        bg:set_color(Color(1, 0, 0, 0))
        bg:animate(bg_attention, t)
    end
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text PanelText? Defaults to `self._text` if not provided
function EHITracker:SetTextColor(color, text)
    text = text or self._text
    text:set_color(color or self._text_color)
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text PanelText? Defaults to `self._text` if not provided
function EHITracker:StopAndSetTextColor(color, text)
    text = text or self._text
    text:stop()
    self:SetTextColor(color, text)
end

---@param new_icon string
---@return string, { x: number, y: number, w: number, h: number }
function EHITracker:GetIcon(new_icon)
    return GetIcon(new_icon)
end

---@param new_icon string
---@param icon PanelBitmap?
function EHITracker:SetIcon(new_icon, icon)
    icon = icon or self._icon1
    local texture, texture_rect = GetIcon(new_icon)
    if texture_rect then
        icon:set_image(texture, unpack(texture_rect))
    else
        icon:set_image(texture)
    end
end

---@param color Color
---@param icon PanelBitmap?
function EHITracker:SetIconColor(color, icon)
    icon = icon or self._icon1
    if icon then
        icon:set_color(color)
    end
end

---@param status string
---@param text PanelText?
function EHITracker:SetStatusText(status, text)
    text = text or self._text
    local txt = "ehi_status_" .. status
    if LocalizationManager._custom_localizations[txt] then
        text:set_text(managers.localization:text(txt))
    else
        text:set_text(string.upper(status))
    end
    self:FitTheText(text)
end

---@param time number
function EHITracker:SetTrackerAccurate(time)
    self._tracker_type = "accurate"
    self:SetTextColor()
    self:SetTimeNoAnim(time)
end

function EHITracker:AddTrackerToUpdate()
    self._parent_class:_add_tracker_to_update(self)
end

function EHITracker:RemoveTrackerFromUpdate()
    self._parent_class:_remove_tracker_from_update(self._id)
end

function EHITracker:DelayForcedDelete()
    self._hide_on_delete = nil
    self._refresh_on_delete = nil
    self:AddTrackerToUpdate()
end

---@param w number? If not provided the width is then called from `EHITracker:GetPanelW()`
---@param move_the_tracker boolean? If the tracker should move too, useful if number icons change and tracker needs to be rearranged to fit properly
function EHITracker:ChangeTrackerWidth(w, move_the_tracker)
    self._parent_class:_change_tracker_width(self._id, w or self:GetPanelW(), move_the_tracker)
end

function EHITracker:GetPanelW()
    return self._panel_override_w or self._panel:w()
end

function EHITracker:StopPanelAnims()
    self._panel:stop()
    if self._hint then
        self._hint:stop()
    end
end

---@param skip boolean?
function EHITracker:destroy(skip)
    if alive(self._panel) then
        if self._icon1 then
            self._icon1:stop()
        end
        self:StopPanelAnims()
        self._panel:animate(destroy, skip, self)
    end
end

function EHITracker:delete()
    if self._hide_on_delete then
        self:StopPanelAnims()
        self:SetPanelAlpha(0)
        self._parent_class:HideTracker(self._id)
        return
    elseif self._refresh_on_delete then
        self:Refresh()
        return
    end
    self:destroy()
    self._parent_class:_destroy_tracker(self._id)
end

function EHITracker:Refresh()
end

function EHITracker:ForceDelete()
    self._hide_on_delete = nil
    self._refresh_on_delete = nil
    self:delete()
end

function EHITracker:PlayerSpawned()
    self:ForceShowHint()
end

function EHITracker:SwitchToLoudMode()
    if self._remove_on_alarm then
        self:ForceDelete()
    elseif self._update_on_alarm then
        self:OnAlarm()
    end
end

function EHITracker:OnAlarm()
end

---@param state boolean
function EHITracker:OnPlayerCustody(state)
end

function EHITracker:RedrawPanel()
end

---Returns current real tracker size and not of what is reported via `self._panel:w()`
---@param n_of_icons number?
function EHITracker:GetTrackerSize(n_of_icons)
    local w = self._bg_box:w()
    local n = n_of_icons or self._n_of_icons
    return w + self._gap_scaled + (n * self._icon_gap_size_scaled)
end

---@param create_f fun(panel: Panel, params: table): Panel
---@param animate_f fun(bg: PanelRectangle, total_t: number)
function EHITracker.SetCustomBGFunctions(create_f, animate_f)
    CreateHUDBGBox = create_f
    bg_attention = animate_f
end

if EHITracker._ICON_LEFT_SIDE_START then
    EHITracker.AnimatePanelW = EHITracker.AnimatePanelWAndRefresh
end