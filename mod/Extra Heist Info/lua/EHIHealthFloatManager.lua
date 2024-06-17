local EHI = EHI
if EHI:CheckLoadHook("EHIHealthFloatManager") then
    return
end
local mvector3 = mvector3
local function round(num, dec)
    local res = string.format('%.' .. (dec or 0) .. 'g', num)
    return res:find('e') and tostring(math.floor(num)) or res
end

---@class EHIHealthFloatManager
EHIHealthFloatManager = {}
---@param hud HUDManager
function EHIHealthFloatManager:new(hud)
    self._ws = managers.gui_data:create_fullscreen_workspace()
    self._pnl = self._ws:panel():panel({ name = 'dmg_sheet', layer = 4 })
    self._ww = self._pnl:w()
    self._hh = self._pnl:h()
    managers.viewport:add_resolution_changed_func(callback(self, self, "onResolutionChanged"))
    self._floats = {} ---@type table<string, EHIHealthFloatBar?>
    self._smokes = {} ---@type table<string, Vector3>
    self._unit_slot_mask = World:make_slot_mask(1, 8, 11, 12, 14, 16, 18, 21, 22, 24, 25, 26, 33, 34, 35)
    EHI:HookWithID(QuickSmokeGrenade, "detonate", "EHI_QuickSmokeGrenade_detonate", function(base, ...)
        local unit = base._unit
        self._smokes[unit:key()] = unit:position()
    end)
    EHI:HookWithID(QuickSmokeGrenade, "destroy", "EHI_QuickSmokeGrenade_destroy", function(base, ...)
        self._smokes[base._unit:key()] = nil
    end)
    hud:AddEHIUpdator(self, "EHI_HealthFloat_Update")
end

function EHIHealthFloatManager:onResolutionChanged()
    if alive(self._ws) then
        managers.gui_data:layout_fullscreen_workspace(self._ws)
        self._ww = self._pnl:w()
        self._hh = self._pnl:h()
    end
end

function EHIHealthFloatManager:Float(unit, t)
    local key = unit.key and unit:key()
    if not key then return end
    local float = self._floats[key]
    if float then
        float:renew(t)
    else
        self._floats[key] = EHIHealthFloatBar:new(self, key, unit, t)
    end
end

function EHIHealthFloatManager:update(t, dt)
    self._cam = managers.viewport:get_current_camera()
    if not self._cam then return end
    self._camPos = self._cam:position()
    local rot = self._cam:rotation()
    self._nl_cam_forward = rot:y()
    self:_updateItems(t)
end

function EHIHealthFloatManager:update_last()
    for _, float in pairs(self._floats) do
        float:force_delete()
    end
end

function EHIHealthFloatManager:_tryGetState()
    local unit = managers.player:player_unit()
    if unit then
        local movement = unit:movement()
        if movement then
            return movement:current_state()
        end
    end
    return nil
end

function EHIHealthFloatManager:_updateItems(t)
    self.state = self.state or self:_tryGetState()
    self.ADS = self.state and self.state._state_data.in_steelsight

    local r = nil
    local from = alive(managers.player:player_unit()) and managers.player:player_unit():movement():m_head_pos()
    if from then
        local to = from + managers.player:player_unit():movement():m_head_rot():y() * 30000
        r = World:raycast("ray", from, to, "slot_mask", self._unit_slot_mask)
    end
    if r and r.unit then
        local unit = r.unit
        if unit and unit:in_slot(8) and alive(unit:parent()) then
            unit = unit:parent()
        end
        unit = unit and unit:movement() and unit
        if unit then
            local cHealth = unit:character_damage() and unit:character_damage()._health or false
            if cHealth and cHealth > 0 and not Global.hud_disabled then
                self:Float(unit, t)
            end
        end
    end

    for _, float in pairs(self._floats) do
        float:draw(t)
    end
end

local UnitVector = Vector3()
---@param something number|UnitEnemy
function EHIHealthFloatManager:_pos(something)
    local t, unit = type(something)
    if t == 'number' then
        unit = managers.network:session():peer(something):unit()
    else
        unit = something
    end
    if not (unit and alive(unit)) then
        return Vector3()
    end
    local pos = UnitVector
    mvector3.set(pos, unit:position())
    local head_pos = unit.movement and unit:movement():m_head_pos()
    if head_pos then
        mvector3.set_z(pos, head_pos.z)
    end
    return pos
end

---@param uPos Vector3?
function EHIHealthFloatManager:_visibility(uPos)
    local result = 1 - math.min(0.9, managers.environment_controller._current_flashbang or 1)
    if not uPos then
        return result
    end
    local minDis = 9999
    local sRad = 300
    for i, sPos in pairs(self._smokes) do
        local cPos = self._camPos
        local disR, dotR = 1, 1
        local sDir = sPos - cPos
        local uDir = uPos - cPos
        local xDir = sPos - uPos
        minDis = math.min(sDir:length(), xDir:length())
        if minDis <= sRad then
            disR = math.pow(minDis / sRad, 3)
        elseif sDir:length() < uDir:length() then
            mvector3.normalize(sDir)
            mvector3.normalize(uDir)
            local dot = mvector3.dot(sDir, uDir)
            dotR = 1 - math.pow(dot, 3)
        end
        result = math.min(result, math.min(disR, dotR))
    end

    return result
end

function EHIHealthFloatManager:_v2p(pos)
    return alive(self._ws) and pos and self._ws:world_to_screen(self._cam, pos)
end

---@class EHIHealthFloatBar
---@field new fun(self: self, owner: EHIHealthFloatManager, key: string, unit: UnitEnemy, t: number): self
EHIHealthFloatBar = class()
EHIHealthFloatBar._size = 16
EHIHealthFloatBar._margin = 2
EHIHealthFloatBar._opacity = 0.9
EHIHealthFloatBar._color_start = Color("FFA500"):with_alpha(1)
EHIHealthFloatBar._color_end = Color("FF0000"):with_alpha(1)
EHIHealthFloatBar._color_friendly = Color("00FF00"):with_alpha(1)
---@param owner EHIHealthFloatManager
---@param key string
---@param unit UnitEnemy
---@param t number
function EHIHealthFloatBar:init(owner, key, unit, t)
    self._parent = owner
    self._unit = unit
    self._key = key
    self._ppnl = owner._pnl
    self._lastT = t
    self:_make()
end

---@param x number?
function EHIHealthFloatBar:__shadow(x)
    if x then
        self.lblShadow1:set_x(x + 1)
        self.lblShadow2:set_x(x - 1)
    else
        self.lblShadow1:set_text(self._txts)
        self.lblShadow2:set_text(self._txts)
    end
end

function EHIHealthFloatBar:_lbl(lbl, txts)
    local result = ''
    if alive(lbl) then
        if type(txts) == 'table' then
            local pos = 0
            local posEnd = 0
            local ranges = {}
            for i, txtObj in ipairs(txts) do
                txtObj[1] = tostring(txtObj[1])
                result = result .. txtObj[1]
                local _, count = txtObj[1]:gsub('[^\128-\193]', '')
                posEnd = pos + count
                ranges[i] = { pos, posEnd, txtObj[2] or Color.white }
                pos = posEnd
            end
            lbl:set_text(result)
            for _, range in ipairs(ranges) do
                lbl:set_range_color(range[1], range[2], range[3] or Color.green)
            end
        elseif type(txts) == 'string' then
            result = txts
            lbl:set_text(txts)
        end
    elseif type(txts) == 'table' then
        for _, t in ipairs(txts) do
            result = result .. tostring(t[1])
        end
    else
        result = txts
    end
    return result
end

function EHIHealthFloatBar:_make()
    local size = self._size
    local m = self._margin
    local pnl = self._ppnl:panel({
        x = 0,
        y = -size,
        w = 300,
        h = 100
    })
    self._pnl = pnl
    self.bg = pnl:bitmap({
        name = 'blur',
        texture = 'guis/textures/test_blur_df',
        render_template = 'VertexColorTexturedBlur3D',
        layer = -1,
        x = 0,
        y = 0
    })
    self.pie = CircleBitmapGuiObject:new(pnl, {
        use_bg = false,
        x = m,
        y = m,
        image = "guis/textures/pd2/hud_health",
        radius = size / 2,
        sides = 64,
        current = 20,
        total = 64,
        blend_mode = "normal",
        layer = 4
    })
    self.pie._circle:set_texture_rect(128, 0, -128, 128)
    self.pieBg = pnl:bitmap({
        name = "pieBg",
        texture = "guis/textures/pd2/hud_progress_active",
        w = size,
        h = size,
        layer = 3,
        x = m,
        y = m,
        color = Color.black:with_alpha(0.5)
    })
    self.lbl = pnl:text{
        text = "text",
        font = "fonts/font_medium_mf",
        font_size = size,
        color = Color.white,
        x = size + m * 2,
        y = m,
        layer = 3,
        blend_mode = 'normal'
    }
    self.lblShadow1 = pnl:text{
        text = "shadow",
        font = "fonts/font_medium_mf",
        font_size = size,
        color = Color.black:with_alpha(0.3),
        x = 1 + size + m * 2,
        y = 1 + m,
        layer = 2,
        blend_mode = 'normal'
    }
    self.lblShadow2 = pnl:text{
        text = "shadow",
        font = "fonts/font_medium_mf",
        font_size = size,
        color = Color.black:with_alpha(0.3),
        x = size + m * 2 - 1,
        y = 1 + m,
        layer = 2,
        blend_mode = "normal"
    }
end

---@param t number
function EHIHealthFloatBar:draw(t)
    if not alive(self._unit) or (t - self._lastT > 0.5) and not self._dead then
        self._dead = true
    end
    if self._dead and not self._dying then
        self:delete()
        return
    end
    if not alive(self._pnl) then
        return
    end
    local unit = self._unit
    if not alive(unit) then
        return
    end
    local dx, dy, d, pDist, ww, hh = 0, 0, 1, 0, self._parent._ww, self._parent._hh
    local pos = self._parent:_pos(unit)
    local nl_dir = pos - self._parent._camPos
    mvector3.normalize(nl_dir)
    local dot_visible = mvector3.dot(self._parent._nl_cam_forward, nl_dir) > 0
    local pPos = self._parent:_v2p(pos)
    dx = pPos.x - ww / 2
    dy = pPos.y - hh / 2
    pDist = dx * dx + dy * dy
    self._pnl:set_visible(dot_visible)
    if dot_visible then
        local size = self._size
        local m = self._margin
        local isADS = self._parent.ADS
        local txts = {}
        local cHealth = unit:character_damage() and unit:character_damage()._health and unit:character_damage()._health * 10 or 0
        local fHealth = cHealth > 0 and unit:character_damage() and (unit:character_damage()._HEALTH_INIT and unit:character_damage()._HEALTH_INIT * 10 or unit:character_damage()._health_max and unit:character_damage()._health_max * 10) or 1
        local prog = cHealth / fHealth
        local isEnemy = managers.enemy:is_enemy(unit)
        local isConverted = unit:brain() and unit:brain().converted and unit:brain():converted()
        local isTurret = unit:base() and unit:base().get_type and unit:base():get_type() == "swat_turret" ---@diagnostic disable-line
        local color = ((isEnemy and not isConverted) or isTurret) and math.lerp(self._color_end, self._color_start, prog) or self._color_friendly
        if pDist <= 100000 and cHealth > 0 then
            txts[1] = { round(cHealth, 2) .. '/' .. round(fHealth, 2), color }
        end
        pPos = pPos:with_y(pPos.y - size * 2)
        if prog > 0 then
            self.pie:set_current(prog)
            self.pieBg:set_visible(true)
            local x = 2 * m + size
            self.lbl:set_x(x)
            self:__shadow(x)
        else
            self.pie:set_visible(false)
            self.pieBg:set_visible(false)
            self.lbl:set_x(m)
            self:__shadow(m)
        end
        if self._txts ~= self:_lbl(nil, txts) then
            self._txts = self:_lbl(self.lbl, txts)
            self:__shadow()
        end
        local _, _, w, h = self.lbl:text_rect()
        h = math.max(h, size)
        self._pnl:set_size(m * 2 + (w > 0 and w + m + 1 or 0) + (prog > 0 and size or 0), h + 2 * m)
        self.bg:set_size(self._pnl:size())
        self._pnl:set_center(pPos.x, pPos.y)
        d = isADS and math.clamp((pDist - 1000) / 2000, 0.4, 1) or 1
        d = math.min(d, self._opacity)
        if not (unit and unit:contour() and next(unit:contour()._contour_list or {})) then
            d = math.min(d, self._parent:_visibility(pos))
        end
        if not self._dying then
            self._pnl:set_alpha(d)
            self.lastD = d -- d is for starting alpha
        end
    end
end

---@param t number
function EHIHealthFloatBar:renew(t)
    self._lastT = math.max(self._lastT, t)
    self._dead = false
    self._dying = false
    self._pnl:stop()
end

function EHIHealthFloatBar:delete()
    local pnl = self._pnl
    if alive(pnl) and not self._dying then
        self._dying = true
        pnl:stop()
        pnl:animate(self._fade, self.lastD or 1, self._destroy_callback, 0.2)
    end
end

function EHIHealthFloatBar:force_delete()
    self._dead = true
    self:delete()
end

function EHIHealthFloatBar:destroy()
    local pnl = self._pnl
    if alive(self._ppnl) and alive(pnl) then
        self._ppnl:remove(self._pnl)
    end
    self._parent._floats[self._key] = nil
end

function EHIHealthFloatBar._fade(o, lastD, done_cb, seconds)
    o:set_visible(true)
    o:set_alpha(1)
    local t = seconds
    while alive(o) and t > 0 do
        local dt = coroutine.yield()
        t = t - dt
        o:set_alpha(lastD * t / seconds)
    end
    o:set_visible(false)
    done_cb()
end
EHIHealthFloatBar._destroy_callback = callback(EHIHealthFloatBar, EHIHealthFloatBar, "destroy")