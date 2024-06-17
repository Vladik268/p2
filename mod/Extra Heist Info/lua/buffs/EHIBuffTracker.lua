local progress = EHI:GetOption("buffs_show_progress")
local circle_shape = EHI:GetOption("buffs_shape") == 2
local invert = EHI:GetOption("buffs_invert_progress")
local rect = {32, 0, -32, 32}
local prefix = "s"
if circle_shape then
    rect = {128, 0, -128, 128}
    prefix = "c"
end
if invert then
    rect[1] = 0
    rect[3] = -rect[3]
end
local texture_good = "guis/textures/pd2_mod_ehi/buff_" .. prefix .. "frame"
local texture_bad = "guis/textures/pd2_mod_ehi/buff_" .. prefix .. "frame_debuff"
local Color = Color
local lerp = math.lerp
---@param o Panel
---@param target_x number
local function set_x(o, target_x)
    local t = 0
    local total = 0.15
    local from_x = o:x()
    while t < total do
        t = t + coroutine.yield()
        o:set_x(lerp(from_x, target_x, t / total))
    end
    o:set_x(target_x)
end
---@param o Panel
---@param x number
local function set_right(o, x)
    local t = 0
    local total = 0.15
    local from_right = o:right()
    local target_right = o:parent():w() - x
    while t < total do
        t = t + coroutine.yield()
        o:set_right(lerp(from_right, target_right, t / total))
    end
    o:set_right(target_right)
end
---@class EHIBuffTracker
---@field _init_text string?
---@field _inverted_progress boolean
EHIBuffTracker = class()
---@param o Panel
EHIBuffTracker._show = function(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(t / total)
    end
    o:set_alpha(1)
end
---@param o Panel
EHIBuffTracker._hide = function(o)
    local t = 0
    local total = 0.15
    while t < total do
        t = t + coroutine.yield()
        o:set_alpha(1 - (t / total))
    end
    o:set_alpha(0)
end
---@param panel Panel
---@param params table
---@param parent_class EHIBuffManager
function EHIBuffTracker:init(panel, params, parent_class)
    local w_half = params.w / 2
    local progress_visible = progress and not params.no_progress
    self._id = params.id --[[@as string]]
    self._parent_class = parent_class
    self._enable_in_loud = params.enable_in_loud
    self._panel = panel:panel({
        name = self._id,
        w = params.w,
        h = params.h,
        x = params.x,
        y = panel:bottom() - params.h - params.y,
        alpha = 0,
        visible = true
    })
    local icon = self._panel:bitmap({
        name = "icon",
        texture = params.texture,
        texture_rect = params.texture_rect,
        color = params.icon_color or params.good and Color.white or Color.red,
        x = 0,
        y = w_half,
        w = params.w,
        h = params.w
    })
    local bg_box = self._panel:panel({
		x = 0,
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
	})
    if circle_shape then
        bg_box:bitmap({
            name = "bg",
            layer = -1,
            w = bg_box:w(),
            h = bg_box:h(),
            texture = "guis/textures/pd2_mod_ehi/buff_cframe_bg",
            color = Color.black:with_alpha(0.2)
        })
    else
        bg_box:rect({
            blend_mode = "normal",
            name = "bg",
            halign = "grow",
            alpha = 0.25,
            layer = -1,
            valign = "grow",
            color = Color(1, 0, 0, 0),
            visible = true
        })
    end
    self._hint = self._panel:text({
        text = params.text or "",
        w = self._panel:w(),
        h = w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = w_half,
        color = Color.white,
        align = "center",
        x = 0,
        y = 0
    })
    self:FitTheText(self._hint)
    self._text = self._panel:text({
        text = "100s",
        w = self._panel:w(),
        h = self._panel:h() - bg_box:h() - w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = w_half,
        color = Color.white,
        align = "center",
        vertical = "center",
        y = self._panel:w() + w_half,
        visible = not params.no_progress
    })
    self._progress_bar = Color(1, 0, 1, 1)
    self._progress = self._panel:bitmap({
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = icon:y(),
        w = icon:w(),
        h = icon:h(),
        texture = params.good and texture_good or texture_bad,
        texture_rect = rect,
        color = self._progress_bar,
        visible = progress_visible
    })
    if progress_visible then
        local size = 24 * params.scale
        local move = 4 * params.scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    end
    self._panel:set_center_x(panel:center_x())
    self._active = false
    self._time = 0
    if self._inverted_progress then
        local size = invert and rect[4] or 0
        self._progress:set_texture_rect(size, rect[2], -rect[3], rect[4])
    end
    local panel_w = self._panel:w()
    self._panel_w_gap = panel_w + 6
    self._panel_move_gap = (panel_w / 2) + 3 -- add only half of the gap
    self:post_init(params)
end

---@param params table
function EHIBuffTracker:post_init(params)
end

---@param text PanelText
function EHIBuffTracker:FitTheText(text)
    text:set_font_size(self._panel:w() / 2)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

function EHIBuffTracker:SetPersistent()
    self._persistent = true
    self:Activate()
end

---@param texture string
---@param texture_rect table?
function EHIBuffTracker:UpdateIcon(texture, texture_rect)
    if texture_rect then
        self._panel:child("icon"):set_image(texture, unpack(texture_rect)) ---@diagnostic disable-line
    else
        self._panel:child("icon"):set_image(texture) ---@diagnostic disable-line
    end
end

---@param center_x number
function EHIBuffTracker:SetCenterDefaultX(center_x)
    self._panel:set_center_x(center_x)
    self:SetPos(0)
end

---@param x number
function EHIBuffTracker:MovePanelLeft(x)
    self._panel:set_x(self._panel:x() - x)
end

---@param x number
function EHIBuffTracker:MovePanelRight(x)
    self._panel:set_x(self._panel:x() + x)
end

---@param x number
function EHIBuffTracker:SetX(x)
    if self._move_panel_x then
        self._panel:stop(self._move_panel_x)
    end
    self._move_panel_x = self._panel:animate(set_x, x)
end

---@param x number
function EHIBuffTracker:SetRight(x)
    if self._move_panel_x then
        self._panel:stop(self._move_panel_x)
    end
    self._move_panel_x = self._panel:animate(set_right, x)
end

function EHIBuffTracker:IsActive()
    return self._active
end

---@param t number? Required
---@param pos number? Required
function EHIBuffTracker:Activate(t, pos)
    self._active = true
    self._time = t
    self._time_set = t
    self:AddBuffToUpdate()
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

---@param pos number
function EHIBuffTracker:ActivateNoUpdate(pos)
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self._pos = pos
end

function EHIBuffTracker:ActivateSoft()
    if self._visible then
        return
    end
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
    self._visible = true
end

---@param t number
function EHIBuffTracker:Extend(t)
    self._time = t
    self._time_set = t
end

---@param t number
function EHIBuffTracker:AddTime(t)
    self._time = self._time + t
    self._time_set = self._time
end

---@param t number
---@param max number
function EHIBuffTracker:AddTimeCeil(t, max)
    self._time = math.min(self._time + t, max)
    self._time_set = self._time
end

function EHIBuffTracker:Deactivate()
    self._parent_class:RemoveBuffFromUpdate(self._id)
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end

function EHIBuffTracker:DeactivateSoft()
    if not self._visible then
        return
    end
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
    self._panel:stop()
    self._panel:animate(self._hide)
    self._visible = false
end

---@param t number
function EHIBuffTracker:Shorten(t)
    self._time = self._time - t
end

---@param pos number
function EHIBuffTracker:SetPos(pos)
    self._pos = pos
end

function EHIBuffTracker:SetHintText(text)
    self._hint:set_text(tostring(text))
    self:FitTheText(self._hint)
end

---@param x number
---@param pos number
function EHIBuffTracker:SetLeftXByPos(x, pos)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    self:SetX(x + (self._panel_w_gap * self._pos))
end

local abs = math.abs
---@param center_x number
---@param pos number
---@param center_pos number
---@param even boolean
function EHIBuffTracker:SetCenterXByPos(center_x, pos, center_pos, even)
    self._panel:set_center_x(center_x)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    if even then
        local n = abs(center_pos - self._pos)
        local final_x = self._panel_move_gap + (self._panel_w_gap * n)
        if self._pos < center_pos then -- Left side
            final_x = final_x - self._panel_w_gap
            self:MovePanelLeft(final_x)
        else -- Right side
            self:MovePanelRight(final_x)
        end
    elseif self._pos ~= center_pos then -- Not center
        local n = abs(center_pos - self._pos)
        local final_x = self._panel_w_gap * n
        if self._pos < center_pos then -- Left side
            self:MovePanelLeft(final_x)
        else -- Right side
            self:MovePanelRight(final_x)
        end
    end
end

---@param x number
---@param pos number
function EHIBuffTracker:SetRightXByPos(x, pos)
    if pos < self._pos then
        self._pos = self._pos - 1
    end
    self:SetRight(x + (self._panel_w_gap * self._pos))
end

function EHIBuffTracker:AddBuffToUpdate()
    self._parent_class:AddBuffToUpdate(self)
end

function EHIBuffTracker:RemoveBuffFromUpdate()
    self._parent_class:RemoveBuffFromUpdate(self._id)
end

function EHIBuffTracker:AddVisibleBuff()
    self._parent_class:AddVisibleBuff(self)
end

function EHIBuffTracker:RemoveVisibleBuff()
    self._parent_class:RemoveVisibleBuff(self._id, self._pos)
end

function EHIBuffTracker:PreUpdate()
end

function EHIBuffTracker:PreUpdateCheck()
    return true
end

---@param state boolean
function EHIBuffTracker:SetCustodyState(state)
end

function EHIBuffTracker:SwitchToLoudMode()
end

if progress then
    function EHIBuffTracker:update(dt)
        self._time = self._time - dt
        self._text:set_text(self:Format())
        self._progress_bar.red = self._time / self._time_set
        self._progress:set_color(self._progress_bar)
        if self._time <= 0 then
            self:Deactivate()
        end
    end
else
    function EHIBuffTracker:update(dt)
        self._time = self._time - dt
        self._text:set_text(self:Format())
        if self._time <= 0 then
            self:Deactivate()
        end
    end
end

if EHI:GetOption("time_format") == 1 then
    EHIBuffTracker.Format = tweak_data.ehi.functions.FormatSecondsOnly
else
    EHIBuffTracker.Format = tweak_data.ehi.functions.FormatMinutesAndSeconds
end

function EHIBuffTracker:delete()
    if self._panel and alive(self._panel) then
        self._panel:stop()
        self._panel:parent():remove(self._panel)
    end
    self:RemoveBuffFromUpdate()
    if self._pos then
        self:RemoveVisibleBuff()
    end
    self._parent_class._buffs[self._id] = nil
end