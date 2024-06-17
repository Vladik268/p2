local EHI = EHI
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

---@class EHIBuffManager : EHIBaseManager
---@field new fun(self: self): self
EHIBuffManager = class(EHIBaseManager)
EHIBuffManager._sync_add_buff = "EHISyncAddBuff"

---@param hud HUDManager
---@param panel Panel
function EHIBuffManager:init_finalize(hud, panel)
    self._buffs = {} ---@type table<string, EHIBuffTracker?>
    self._update_buffs = setmetatable({}, {__mode = "k"}) ---@type table<string, EHIBuffTracker?>
    self._visible_buffs = setmetatable({}, {__mode = "k"}) ---@type table<string, EHIBuffTracker?>
    self._n_visible = 0
    self._cache = {}
    self._gap = 6
    self._x = EHI:IsVR() and EHI:GetOption("buffs_vr_x_offset") or EHI:GetOption("buffs_x_offset") --[[@as number]]
    local path = EHI.LuaPath .. "buffs/"
    dofile(path .. "EHIBuffTracker.lua")
    dofile(path .. "EHIGaugeBuffTracker.lua")
    dofile(path .. "SimpleBuffEdits.lua")
    hud:AddEHIUpdator(self, "EHI_Buff_Update")
    self._panel = panel
    local scale = EHI:GetOption("buffs_scale") --[[@as number]]
    local buff_y = EHI:IsVR() and EHI:GetOption("buffs_vr_y_offset") or EHI:GetOption("buffs_y_offset") --[[@as number]]
    local buff_w = 32 * scale
    local buff_h = 64 * scale
    self:InitializeBuffs(buff_y, buff_w, buff_h, scale)
    self:InitializeTagTeamBuffs(buff_y, buff_w, buff_h, scale)
    self:UnusedBuffClassesCleanup()
    local function destroy()
        self._update_buffs = {}
    end
    EHI:AddCallback(EHI.CallbackMessage.GameEnd, destroy)
    EHI:AddCallback(EHI.CallbackMessage.GameRestart, destroy)
    if EHI:IsClient() then
        self:AddReceiveHook(self._sync_add_buff, callback(self, self, "SyncAddBuff"))
    end
end

---@param buff_y number
---@param buff_w number
---@param buff_h number
---@param scale number
function EHIBuffManager:InitializeBuffs(buff_y, buff_w, buff_h, scale)
    for id, buff in pairs(tweak_data.ehi.buff) do
        if buff.option and not EHI:GetBuffOption(buff.option) then
        elseif buff.deck_option and not EHI:GetBuffDeckOption(buff.deck_option.deck, buff.deck_option.option) then
        else
            local params = {}
            params.id = id
            params.x = self._x
            params.y = buff_y
            params.w = buff_w
            params.h = buff_h
            params.text = buff.text
            params.texture, params.texture_rect = GetIcon(buff)
            params.format = buff.format
            params.good = not buff.bad
            params.no_progress = buff.no_progress
            params.max = buff.max
            params.class = buff.class
            params.class_to_load = buff.class_to_load
            params.scale = scale
            params.enable_in_loud = buff.enable_in_loud
            self:CreateBuff(params, buff.persistent, buff.deck_option)
        end
    end
end

---@param buff_y number
---@param buff_w number
---@param buff_h number
---@param scale number
function EHIBuffManager:InitializeTagTeamBuffs(buff_y, buff_w, buff_h, scale)
    if not EHI:GetBuffDeckOption("tag_team", "tagged") then
        return
    end
    local local_peer_id = managers.network:session():local_peer():id()
    local texture, texture_rect = GetIcon(tweak_data.ehi.buff.TagTeamEffect)
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        if i ~= local_peer_id then -- You cannot tag yourself...
            local params = {}
            params.id = "TagTeamTagged_" .. i .. local_peer_id
            params.x = self._x
            params.y = buff_y
            params.w = buff_w
            params.h = buff_h
            params.texture = texture
            params.texture_rect = texture_rect
            params.good = true
            params.icon_color = tweak_data.chat_colors[i] or Color.white
            params.scale = scale
            self:CreateBuff(params)
        end
    end
end

---@param params table
---@param persistent string?
---@param deck_option table?
function EHIBuffManager:CreateBuff(params, persistent, deck_option)
    local buff
    if params.class_to_load then
        if params.class_to_load.prerequisite and not _G[params.class_to_load.prerequisite] then
            dofile(string.format("%s%s%s.lua", EHI.LuaPath, "buffs/", params.class_to_load.prerequisite))
        end
        if params.class_to_load.load_class then
            dofile(string.format("%s%s%s.lua", EHI.LuaPath, "buffs/", params.class_to_load.load_class))
        end
        buff = _G[params.class_to_load.class]:new(self._panel, params, self) --[[@as EHIBuffTracker]]
    else
        buff = _G[params.class or "EHIBuffTracker"]:new(self._panel, params, self) --[[@as EHIBuffTracker]]
    end
    self._buffs[params.id] = buff
    if persistent and EHI:GetBuffOption(persistent) then
        buff:SetPersistent()
    elseif deck_option and EHI:GetBuffDeckOption(deck_option.deck, deck_option.persistent) then
        buff:SetPersistent()
    end
end

function EHIBuffManager:UnusedBuffClassesCleanup()
    for id, buff in pairs(tweak_data.ehi.buff) do
        if buff.class_to_load and buff.class_to_load.prerequisite then
            local class = buff.class_to_load.class
            if _G[class] and not self._buffs[id] then -- Tracker class exists, but the tracker is not created because it is disabled; remove the class
                _G[class] = nil
            end
        end
    end
end

---@param id string
function EHIBuffManager:UpdateBuffIcon(id)
    local tweak = tweak_data.ehi.buff[id]
    local buff = self._buffs[id]
    if buff and tweak then
        local texture, texture_rect = GetIcon(tweak)
        buff:UpdateIcon(texture, texture_rect)
    end
end

---@param id string
---@param f string
---@param ... unknown
function EHIBuffManager:CallFunction(id, f, ...)
    local buff = self._buffs[id]
    if buff and buff[f] then
        buff[f](buff, ...)
    end
end

---@param id string
---@param t number
function EHIBuffManager:SyncBuff(id, t)
    self:SyncTable(self._sync_add_buff, { id = id, t = t })
end

function EHIBuffManager:ActivateUpdatingBuffs()
    if not self._buffs then
        return
    end
    for id, buff in pairs(tweak_data.ehi.buff) do
        if buff.activate_after_spawn then
            local b = self._buffs[id]
            if b and b:PreUpdateCheck() then
                b:PreUpdate()
                if not b._enable_in_loud then
                    self:AddBuffToUpdate(b)
                end
            end
        elseif buff.check_after_spawn then
            local b = self._buffs[id]
            if b and b:PreUpdateCheck() then
                b:PreUpdate()
            end
        end
    end
end

---@param state boolean
function EHIBuffManager:SetCustodyState(state)
    for _, buff in pairs(self._buffs or {}) do
        buff:SetCustodyState(state)
    end
    self:RemoveAbilityCooldown(state)
end

function EHIBuffManager:SwitchToLoudMode()
    for _, buff in pairs(self._buffs or {}) do
        buff:SwitchToLoudMode()
    end
end

function EHIBuffManager:SyncAddBuff(data, sender)
    local tbl = json.decode(data)
    self:AddBuff(tbl.id, tbl.t or 0)
end

---@param id string
---@param t number
function EHIBuffManager:AddBuff(id, t)
    local buff = self._buffs[id]
    if buff then
        if buff:IsActive() then
            buff:Extend(t)
        else
            buff:Activate(t, self._n_visible)
            self._visible_buffs[id] = buff
            self._n_visible = self._n_visible + 1
            self:ReorganizeFast(self._n_visible, buff)
        end
    end
end

---@param id string
---@param start_t number
---@param end_t number
function EHIBuffManager:AddBuff2(id, start_t, end_t)
    local t = end_t - start_t
    self:AddBuff(id, t)
end

---To stop moving buffs left and right on the screen
---@param id string
---@param start_t number
---@param end_t number
function EHIBuffManager:AddBuff3(id, start_t, end_t)
    local t = end_t - start_t + 0.2
    self:AddBuff(id, t)
end

---@param id string
function EHIBuffManager:AddBuffNoUpdate(id)
    local buff = self._buffs[id]
    if buff and not buff:IsActive() then
        buff:ActivateNoUpdate(self._n_visible)
        self._visible_buffs[id] = buff
        self._n_visible = self._n_visible + 1
        self:ReorganizeFast(self._n_visible, buff)
    end
end

---@param id string
---@param ratio number
---@param custom_value number?
function EHIBuffManager:AddGauge(id, ratio, custom_value)
    local buff = self._buffs[id] --[[@as EHIGaugeBuffTracker?]]
    if buff then
        if buff:IsActive() then
            buff:SetRatio(ratio, custom_value)
        else
            buff:Activate(ratio, custom_value, self._n_visible)
            self._visible_buffs[id] = buff
            self._n_visible = self._n_visible + 1
            self:ReorganizeFast(self._n_visible, buff)
        end
    end
end

---@param id string
function EHIBuffManager:RemoveBuff(id)
    local buff = self._buffs[id]
    if buff and buff:IsActive() then
        buff:Deactivate()
    end
end

---@param id string
---@param t number
function EHIBuffManager:AddTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:AddTime(t)
    end
end

---@param id string
---@param t number
---@param max number
function EHIBuffManager:AddTimeCeil(id, t, max)
    local buff = self._buffs[id]
    if buff then
        buff:AddTimeCeil(t, max)
    end
end

---@param id string
---@param t number
function EHIBuffManager:ShortBuffTime(id, t)
    local buff = self._buffs[id]
    if buff then
        buff:Shorten(t)
    end
end

---@param buff EHIBuffTracker
function EHIBuffManager:AddVisibleBuff(buff)
    self._visible_buffs[buff._id] = buff
    buff:SetPos(self._n_visible)
    self._n_visible = self._n_visible + 1
    self:ReorganizeFast(self._n_visible, buff)
end

---@param id string
---@param pos number?
function EHIBuffManager:RemoveVisibleBuff(id, pos)
    local buff = self._visible_buffs[id] or self._buffs[id] --[[@as EHIBuffTracker]]
    self._visible_buffs[id] = nil
    self._n_visible = self._n_visible - 1
    self:Reorganize(pos, buff, true)
end

---@param buff EHIBuffTracker
function EHIBuffManager:AddBuffToUpdate(buff)
    self._update_buffs[buff._id] = buff
end

---@param id string
function EHIBuffManager:RemoveBuffFromUpdate(id)
    self._update_buffs[id] = nil
end

---@param in_custody boolean
function EHIBuffManager:RemoveAbilityCooldown(in_custody)
    if in_custody then
        local ability = self._cache and self._cache.Ability
        if ability then
            self:RemoveBuff(ability)
        end
    end
end

---@param dt number
function EHIBuffManager:update(t, dt)
    for _, buff in pairs(self._update_buffs) do
        buff:update(dt)
    end
end

local alignment = EHI:GetOption("buffs_alignment")
if alignment == 1 then -- Left
    ---@param pos number?
    ---@param buff EHIBuffTracker
    ---@param removal boolean?
    function EHIBuffManager:Reorganize(pos, buff, removal)
        if self._n_visible == 0 then
            return
        end
        pos = pos or self._n_visible
        for _, v_buff in pairs(self._visible_buffs) do
            v_buff:SetLeftXByPos(self._x, pos)
        end
    end

    ---@param pos number
    ---@param buff EHIBuffTracker
    function EHIBuffManager:ReorganizeFast(pos, buff)
        buff:SetLeftXByPos(self._x, pos)
    end
elseif alignment == 2 then -- Center
    local ceil = math.ceil
    local floor = math.floor
    ---@param pos number?
    ---@param buff EHIBuffTracker
    ---@param removal boolean?
    function EHIBuffManager:Reorganize(pos, buff, removal)
        if self._n_visible == 0 then
            return
        elseif self._n_visible == 1 then
            local center_x = self._panel:center_x()
            if removal then
                local _, v_buff = next(self._visible_buffs) ---@cast v_buff -?
                v_buff:SetCenterDefaultX(center_x)
            else
                buff:SetCenterDefaultX(center_x)
            end
        else
            local even = self._n_visible % 2 == 0
            local center_pos = even and ceil(self._n_visible / 2) or floor(self._n_visible / 2)
            local center_x = self._panel:center_x()
            pos = pos or self._n_visible
            for _, v_buff in pairs(self._visible_buffs) do
                v_buff:SetCenterXByPos(center_x, pos, center_pos, even)
            end
        end
    end
    EHIBuffManager.ReorganizeFast = EHIBuffManager.Reorganize
else -- Right
    ---@param pos number?
    ---@param buff EHIBuffTracker
    ---@param removal boolean?
    function EHIBuffManager:Reorganize(pos, buff, removal)
        if self._n_visible == 0 then
            return
        end
        pos = pos or self._n_visible
        for _, v_buff in pairs(self._visible_buffs) do
            v_buff:SetRightXByPos(self._x, pos)
        end
    end

    ---@param pos number
    ---@param buff EHIBuffTracker
    function EHIBuffManager:ReorganizeFast(pos, buff)
        buff:SetRightXByPos(self._x, pos)
    end
end