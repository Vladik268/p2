local function GetIcon(params)
    local texture, texture_rect
    local x = params.x or 0
    local y = params.y or 0
    if params.skills then
        texture = "guis/textures/pd2/skilltree/icons_atlas"
		texture_rect = { x * 64, y * 64, 64, 64 }
    elseif params.u100skill then
        texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		texture_rect = { x * 80, y * 80, 80, 80 }
    elseif params.deck then
        texture = "guis/" .. (params.folder and ("dlcs/" .. params.folder .. "/") or "") .. "textures/pd2/specialization/icons_atlas"
		texture_rect = { x * 64, y * 64, 64, 64 }
    elseif params.texture then
        texture = params.texture
        texture_rect = params.texture_rect
    end
    return texture, texture_rect
end

local EHI = EHI
local buff_w_original = 32
local buff_h_original = 64
local buff_w = buff_w_original
local buff_h = buff_h_original
---@class FakeEHIBuffsManager
FakeEHIBuffsManager = {}
---@param panel Panel
function FakeEHIBuffsManager:new(panel)
    self._class_redirect =
    {
        EHIGaugeBuffTracker = "FakeEHIGaugeBuffTracker"
    }
	self._buffs = {}
    self._panel = panel:panel({
        name = "fake_ehi_buffs_panel",
        layer = 0,
        alpha = 1
    })
    self:SetScale(EHI:GetOption("buffs_scale"))
    self._x = EHI:GetOption("buffs_x_offset")
    self._y = EHI:GetOption("buffs_y_offset")
    self._n_visible = 0
	self._buffs_alignment = EHI:GetOption("buffs_alignment")
    self._gap = 6
    self:AddFakeBuffs()
    self:OrganizeBuffs()
    return self
end

function FakeEHIBuffsManager:SetScale(scale)
    self._scale = scale
	buff_w = buff_w_original * scale
    buff_h = buff_h_original * scale
end

function FakeEHIBuffsManager:AddFakeBuffs()
    local visible = EHI:GetOption("show_buffs")
    local shape = EHI:GetOption("buffs_shape")
    local progress = EHI:GetOption("buffs_show_progress")
    local buffs = tweak_data.ehi.buff
    local max = math.random(3, 5)
    local max_buffs = table.size(buffs)
    local visible_buffs = {}
    local saferect_x, saferect_y
    saferect_x, saferect_y = managers.gui_data:full_to_safe(self._panel:w(), self._panel:h())
    saferect_x = self._panel:w() - saferect_x + 0.5
    saferect_y = self._panel:h() - saferect_y + 0.5
    saferect_x = saferect_x * 2
    saferect_y = saferect_y * 2
    local invert_progress = EHI:GetOption("buffs_invert_progress")
    for _ = 1, max, 1 do
        local n = 0
        local m = math.random(1, max_buffs)
        for key, buff in pairs(buffs) do
            n = n + 1
            if m == n then
                if not visible_buffs[key] then
                    local params = {}
                    params.id = key
                    params.texture, params.texture_rect = GetIcon(buff)
                    params.text = buff.text
                    params.x = self._x - saferect_x
                    params.y = self._y + saferect_y
                    params.visible = visible
                    params.shape = shape
                    params.scale = self._scale
                    params.show_progress = progress
                    params.good = not buff.bad
                    params.saferect_x = saferect_x
                    params.saferect_y = saferect_y
                    params.parent_class = self
                    params.invert = invert_progress
                    if buff.class then
                        params.class = self._class_redirect[buff.class]
                    end
                    self:AddFakeBuff(params)
                    visible_buffs[key] = true
                    break
                else
                    n = n - 1
                end
            end
        end
    end
end

function FakeEHIBuffsManager:AddFakeBuff(params)
    self._n_visible = self._n_visible + 1
    self._buffs[self._n_visible] = _G[params.class or "FakeEHIBuffTracker"]:new(self._panel, params)
end

function FakeEHIBuffsManager:OrganizeBuffs()
    if self._buffs_alignment == 1 then -- Left
        if self._n_visible == 0 then
            return
        end
        local previous_buff
        for i, buff in ipairs(self._buffs) do
            if i == 1 then
                buff:SetX(self._x)
            else
                buff:SetXOnly(previous_buff._panel:right() + self._gap)
            end
            previous_buff = buff
        end
    elseif self._buffs_alignment == 2 then -- Center
        if self._n_visible == 0 then
            return
        elseif self._n_visible == 1 then
            self._buffs[1]:SetCenterX(self._panel:center_x())
        else
            local even = self._n_visible % 2 == 0
            local center_x = self._panel:center_x()
            local buff_w_half = buff_w / 2
            if even then
                local switch = true
                local move = buff_w_half + self._gap
                local move_gap_2 = move - (self._gap / 2)
                local panel_move = buff_w_half + move
                local buff_left
                local buff_right
                for _, buff in ipairs(self._buffs) do
                    buff:SetCenterX(center_x)
                    if switch then
                        if buff_left then
                            buff:SetXOnly(buff_left._panel:x() - panel_move)
                        else
                            buff:MovePanelLeft(move_gap_2)
                        end
                        buff_left = buff
                    else
                        if buff_right then
                            buff:SetXOnly(buff_right._panel:right() + self._gap)
                        else
                            buff:MovePanelRight(move_gap_2)
                        end
                        buff_right = buff
                    end
                    switch = not switch
                end
            else
                local middle_switch = true
                local switch = false
                local move = buff_w_half + self._gap
                local panel_move = buff_w_half + move
                local buff_left
                local buff_right
                for _, buff in ipairs(self._buffs) do
                    buff:SetCenterX(center_x)
                    if middle_switch then
                        buff_left = buff
                        buff_right = buff
                        middle_switch = false
                    elseif switch then
                        buff:SetXOnly(buff_left._panel:x() - panel_move)
                        buff_left = buff
                    else
                        buff:SetXOnly(buff_right._panel:right() + self._gap)
                        buff_right = buff
                    end
                    switch = not switch
                end
            end
        end
    else -- Right
        if self._n_visible == 0 then
            return
        end
        local move = buff_w + self._gap
        for i, buff in ipairs(self._buffs) do
            buff:SetRight(self._x)
            buff:MovePanelLeft(move * (i - 1))
        end
    end
end

function FakeEHIBuffsManager:UpdateXOffset(x)
	self._x = x
	if self._buffs_alignment == 2 then -- Center
		return
	end
	self:OrganizeBuffs()
end

function FakeEHIBuffsManager:UpdateYOffset(y)
	self._y = y
    self:UpdateBuffs("SetY", y)
end

function FakeEHIBuffsManager:UpdateScale(scale)
    self:SetScale(scale)
    self:UpdateBuffs("destroy")
    self._buffs = {}
    self._n_visible = 0
    self:AddFakeBuffs()
    self:OrganizeBuffs()
end

function FakeEHIBuffsManager:UpdateAlignment(alignment)
	self._buffs_alignment = alignment
	self:OrganizeBuffs()
end

---@param f string
---@param ... unknown
function FakeEHIBuffsManager:UpdateBuffs(f, ...)
    for _, buff in ipairs(self._buffs) do
        buff[f](buff, ...)
    end
end

---@class FakeEHIBuffTracker
FakeEHIBuffTracker = class()
FakeEHIBuffTracker._rect_circle = {128, 0, -128, 128}
FakeEHIBuffTracker._rect_square = {32, 0, -32, 32}
---@param panel Panel
---@param params table
function FakeEHIBuffTracker:init(panel, params)
    local buff_w_half = buff_w / 2
    self._show_progress = params.show_progress
    self._shape = params.shape
    self._scale = params.scale
    self._id = params.id
    self._parent_panel = panel
    self._panel = panel:panel({
        name = self._id,
        w = buff_w,
        h = buff_h,
        y = panel:bottom() - buff_h - params.y + (params.saferect_y / 2),
        visible = params.visible
    })
    local icon = self._panel:bitmap({
        name = "icon",
        texture = params.texture,
        texture_rect = params.texture_rect,
        color = params.good and Color.white or Color.red,
        x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w
    })
	self._bg_box = self._panel:panel({
		x = 0,
        y = buff_w_half,
        w = buff_w,
        h = buff_w
	})
	self._bg_box:rect({
		blend_mode = "normal",
		name = "bg_square",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = Color(1, 0, 0, 0),
        visible = self._shape == 1
	})
    self._bg_box:bitmap({
        name = "bg_circle",
        layer = -1,
        w = self._bg_box:w(),
        h = self._bg_box:h(),
        texture = "guis/textures/pd2_mod_ehi/buff_cframe_bg",
        color = Color.black:with_alpha(0.2),
        visible = self._shape == 2
    })
    self._panel:bitmap({
        name = "progress_circle",
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = icon:y(),
        w = icon:w(),
        h = icon:h(),
        texture = params.good and "guis/textures/pd2_mod_ehi/buff_cframe" or "guis/textures/pd2_mod_ehi/buff_cframe_debuff",
        texture_rect = self._rect_circle,
        visible = self._shape == 2 and self._show_progress
    })
    self._panel:bitmap({
        name = "progress_square",
        render_template = "VertexColorTexturedRadial",
        layer = 5,
        y = icon:y(),
        w = icon:w(),
        h = icon:h(),
        texture = params.good and "guis/textures/pd2_mod_ehi/buff_sframe" or "guis/textures/pd2_mod_ehi/buff_sframe_debuff",
        texture_rect = self._rect_square,
        visible = self._shape == 1 and self._show_progress
    })
    self._hint = self._panel:text({
        name = "hint",
        text = params.text or "",
        w = self._panel:w(),
        h = buff_w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = buff_w_half,
        color = Color.white,
        align = "center",
        x = 0,
        y = 0
    })
    self:FitTheText(self._hint)
    self._time = math.random(0, 100)
    self._text = self._panel:text({
        name = "text",
        text = self:Format(),
        w = self._panel:w(),
        h = self._panel:h() - self._bg_box:h() - buff_w_half,
        font = tweak_data.menu.pd2_large_font,
		font_size = buff_w_half,
        color = Color.white,
        align = "center",
        vertical = "center",
        y = self._panel:w() + buff_w_half,
    })
    self:FitTheText(self._text)
    self._panel:set_center_x(panel:center_x())
    self._saferect_x = params.saferect_x
    self._saferect_y = params.saferect_y
    self:SetProgress()
    self:UpdateProgressVisibility(self._show_progress, true)
    self._inverted = false
    if params.invert then
        self:InvertProgress()
    end
    if self._show_progress then
        local size = 24 * self._scale
        local move = 4 * self._scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    end
end

---@param text PanelText
function FakeEHIBuffTracker:FitTheText(text)
    text:set_font_size(self._panel:w() / 2)
    local w = select(3, text:text_rect())
    if w > text:w() then
        text:set_font_size(text:font_size() * (text:w() / w))
    end
end

function FakeEHIBuffTracker:SetProgress()
    local c = Color(1, self:GetProgress(), 1, 1)
    self._panel:child("progress_circle"):set_color(c)
    self._panel:child("progress_square"):set_color(c)
end

---@return number
function FakeEHIBuffTracker:GetProgress()
    return self._time / 100
end

---@param center_x number
function FakeEHIBuffTracker:SetCenterX(center_x)
    self._panel:set_center_x(center_x)
end

---@param visibility boolean
function FakeEHIBuffTracker:SetVisibility(visibility)
	self._panel:set_visible(visibility)
end

---@param x number
function FakeEHIBuffTracker:SetX(x)
    self:SetXOnly(x + (self._saferect_x / 2))
end

---@param x number
function FakeEHIBuffTracker:SetXOnly(x)
    self._panel:set_x(x)
end

---@param y number
function FakeEHIBuffTracker:SetY(y)
    local _y = y - (self._saferect_y / 2)
	self._panel:set_y(self._panel:parent():bottom() - self._panel:h() - _y - self._saferect_y)
end

---@param x number
function FakeEHIBuffTracker:MovePanelLeft(x)
    self._panel:set_x(self._panel:x() - x)
end

---@param x number
function FakeEHIBuffTracker:MovePanelRight(x)
    self._panel:set_x(self._panel:x() + x)
end

---@param x number
function FakeEHIBuffTracker:SetRight(x)
    self._panel:set_right(self._panel:parent():w() - x - (self._saferect_x / 2))
end

---@param shape number
function FakeEHIBuffTracker:UpdateBuffShape(shape)
    if shape == 1 then -- Square
        self._bg_box:child("bg_square"):set_visible(true)
        self._panel:child("progress_square"):set_visible(self._show_progress)
        self._bg_box:child("bg_circle"):set_visible(false)
        self._panel:child("progress_circle"):set_visible(false)
    else -- Circle
        self._bg_box:child("bg_square"):set_visible(false)
        self._panel:child("progress_square"):set_visible(false)
        self._bg_box:child("bg_circle"):set_visible(true)
        self._panel:child("progress_circle"):set_visible(self._show_progress)
    end
    self._shape = shape
end

---@param visibility boolean
---@param dont_force boolean
function FakeEHIBuffTracker:UpdateProgressVisibility(visibility, dont_force)
    self._show_progress = visibility
    self:UpdateBuffShape(self._shape)
    if dont_force then
        return
    end
    local icon = self._panel:child("icon") --[[@as PanelBitmap]]
    if self._show_progress then
        local size = 24 * self._scale
        local move = 4 * self._scale
        icon:set_size(size, size)
        icon:set_x(icon:x() + move)
        icon:set_y(icon:y() + move)
    else
        local size = 32 * self._scale
        icon:set_size(size, size)
        icon:set_x(self._bg_box:x())
        icon:set_y(self._bg_box:y())
    end
end

---@param self FakeEHIBuffTracker
---@param rect number[]
---@param shape string
local function Invert(self, rect, shape)
    local size = self._inverted and 0 or rect[4]
    local size_3 = self._inverted and rect[4] or rect[3]
    self._panel:child(shape):set_texture_rect(size, rect[2], size_3, rect[4]) ---@diagnostic disable-line
end
function FakeEHIBuffTracker:InvertProgress()
    self._inverted = not self._inverted
    Invert(self, self._rect_square, "progress_square")
    Invert(self, self._rect_circle, "progress_circle")
end

function FakeEHIBuffTracker:Format()
    return self._time .. "s"
end

function FakeEHIBuffTracker:destroy()
    if alive(self._panel) and alive(self._parent_panel) then
        self._parent_panel:remove(self._panel)
    end
end

---@class FakeEHIGaugeBuffTracker : FakeEHIBuffTracker
---@field super FakeEHIBuffTracker
FakeEHIGaugeBuffTracker = class(FakeEHIBuffTracker)
---@param panel Panel
---@param params table
function FakeEHIGaugeBuffTracker:init(panel, params)
    self._ratio = math.random()
    FakeEHIGaugeBuffTracker.super.init(self, panel, params)
    self:InvertProgress()
end

---@return number
function FakeEHIGaugeBuffTracker:GetProgress()
    return self._ratio
end

function FakeEHIGaugeBuffTracker:Format()
    return math.floor(self._ratio * 100) .. "%"
end