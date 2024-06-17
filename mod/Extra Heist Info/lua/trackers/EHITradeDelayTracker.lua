---@class EHITradeDelayTracker : EHITracker
---@field FormatUnique fun(self: self, label: PanelText, time: number, civilians_killed: number)
---@field FormatTime fun(self: self, time: number): string
---@field super EHITracker
EHITradeDelayTracker = class(EHITracker)
EHITradeDelayTracker._forced_hint_text = "trade_delay"
EHITradeDelayTracker._update = false
EHITradeDelayTracker._forced_icons = { "mugshot_in_custody" }
EHITradeDelayTracker._init_create_text = false
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHITradeDelayTracker:init(panel, params, parent_class)
    self._pause_t = 0
    self._n_of_peers = 0
    self._peers = {} ---@type table<number, { t: number, in_custody: boolean, civilians_killed: number, label: PanelText }?>
    self._tick = 0
    EHITradeDelayTracker.super.init(self, panel, params, parent_class)
    self._default_panel_w = self._panel:w()
    self._default_bg_box_w = self._bg_box:w()
    self._panel_half = self._default_bg_box_w / 2
    self._panel_w = self._default_panel_w
end

function EHITradeDelayTracker:SetTextPeerColor()
    if self._n_of_peers == 1 then
        return
    end
    for peer_id, peer_data in pairs(self._peers) do
        peer_data.label:set_color(tweak_data.chat_colors[peer_id] or Color.white)
    end
end

---@param peer_id number
---@param color Color
function EHITradeDelayTracker:UpdateTextPeerColor(peer_id, color)
    if self._n_of_peers == 1 or not color then
        return
    end
    local peer_data = self._peers[peer_id]
    if peer_data then
        peer_data.label:set_color(color)
    end
end

function EHITradeDelayTracker:SetIconColor()
    if self._n_of_peers >= 2 then
        self._icon1:set_color(Color.white)
    else
        local peer_id, _ = next(self._peers)
        self._icon1:set_color(tweak_data.chat_colors[peer_id] or Color.white)
    end
end

---@param peer_id number
---@param time number
---@param civilians_killed number? Defaults to `1` if not provided
function EHITradeDelayTracker:AddPeerCustodyTime(peer_id, time, civilians_killed)
    local text = self:CreateText({ w = self._default_bg_box_w })
    local kills = civilians_killed or 1
    self._peers[peer_id] =
    {
        t = time,
        in_custody = false,
        civilians_killed = kills,
        label = text
    }
    self._n_of_peers = self._n_of_peers + 1
    if self._n_of_peers >= 2 then
        self:AnimateBG()
    end
    self:FormatUnique(text, time, kills)
    self:Reorganize(true)
    self:SetIconColor()
    self:SetTextPeerColor()
end

function EHITradeDelayTracker:RedrawPanel()
    for _, text in ipairs(self._bg_box:children()) do ---@cast text PanelText
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

function EHITradeDelayTracker:AnimateMovement()
    self:AnimatePanelWAndRefresh(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconX(self._panel_w - self._icon_size_scaled)
end

function EHITradeDelayTracker:AlignTextOnHalfPos()
    local pos = 0
    for i = 1, HUDManager.PLAYER_PANEL, 1 do
        local peer_data = self._peers[i]
        if peer_data then
            local text = peer_data.label
            text:set_w(self._panel_half)
            text:set_x(self._panel_half * pos)
            self:FitTheText(text)
            pos = pos + 1
        end
    end
end

---@param addition boolean?
function EHITradeDelayTracker:Reorganize(addition)
    if self._n_of_peers == 1 then
        return
    elseif self._n_of_peers == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self._bg_box:set_w(self._default_bg_box_w)
            self:AnimateMovement()
        end
    elseif addition then
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w + self._panel_half
        self._bg_box:set_w(self._bg_box:w() + self._panel_half)
        self:AnimateMovement()
    else
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w - self._panel_half
        self._bg_box:set_w(self._bg_box:w() - self._panel_half)
        self:AnimateMovement()
    end
end

---@param peer_id number
---@param time number
---@param civilians_killed number? If provided, sets the number of killed civilians. Otherwise it adds 1 more civilian killed to the counter
---@param anim boolean?
function EHITradeDelayTracker:SetPeerCustodyTime(peer_id, time, civilians_killed, anim)
    local peer_data = self._peers[peer_id] ---@cast peer_data -?
    peer_data.t = time
    peer_data.civilians_killed = civilians_killed or (peer_data.civilians_killed + 1)
    self:FormatUnique(peer_data.label, time, peer_data.civilians_killed)
    self:FitTheText(peer_data.label)
    if anim then
        self:AnimateBG()
    end
end

---@param peer_id number
---@param time number
function EHITradeDelayTracker:IncreasePeerCustodyTime(peer_id, time)
    local t = self:GetPeerData(peer_id, "t", 0) ---@cast t -boolean
    self:SetPeerCustodyTime(peer_id, t + time, nil, true)
end

---@param peer_id number
---@param time number
---@param civilians_killed number?
function EHITradeDelayTracker:UpdatePeerCustodyTime(peer_id, time, civilians_killed)
    local t = self:GetPeerData(peer_id, "t", 0) ---@cast t -boolean
    if t == time then -- Don't blink on the player, son
        return
    end
    self:SetPeerCustodyTime(peer_id, time, civilians_killed)
end

---@param peer_id number
---@param time number
---@param civilians_killed number?
function EHITradeDelayTracker:AddOrUpdatePeerCustodyTime(peer_id, time, civilians_killed, in_custody)
    if self:PeerExists(peer_id) then
        self:UpdatePeerCustodyTime(peer_id, time, civilians_killed)
    else
        self:AddPeerCustodyTime(peer_id, time, civilians_killed)
    end
    if in_custody then
        self:SetPeerInCustody(peer_id)
    end
end

---@param t number
function EHITradeDelayTracker:SetTick(t)
    --[[
        This function makes Trade Delay accurate because of the braindead use of the "update" loop in TradeManager
        Why is OVK using another variable to "count down" the remaining time ? As shown below:
        "self._trade_counter_tick = self._trade_counter_tick - dt" (which later subtracts 1s from the delay when self._trade_counter_tick <= 0)
        when they could just simply do:
        "crim.respawn_penalty - dt"
        Much faster and cleaner imo

        But why bother ?
        1. This time correction actually makes the tracker accurate
        2. To not confuse players why the tracker is blinking after a teammate is taken to custody or during count down
        Eg.:
        2:35 -> 2:36
    ]]
    self._tick = t
end

---@param t number
function EHITradeDelayTracker:SetTradePause(t)
    self._pause_t = t
end

---@param peer_id number
function EHITradeDelayTracker:RemovePeerFromCustody(peer_id)
    if not self:PeerExists(peer_id) then
        return
    end
    self._n_of_peers = self._n_of_peers - 1
    if self._n_of_peers == 0 then
        self:delete()
        return
    end
    self._bg_box:remove(self._peers[peer_id].label)
    self._peers[peer_id] = nil
    if self._n_of_peers == 1 then
        local _, peer_data = next(self._peers) ---@cast peer_data -?
        local text = peer_data.label
        text:set_color(Color.white)
        text:set_x(0)
        text:set_w(self._default_bg_box_w)
        self:FitTheText(text)
    end
    self:AnimateBG()
    self:SetIconColor()
    self:SetTextPeerColor()
    self:Reorganize()
end

---@param peer_id number
function EHITradeDelayTracker:SetPeerInCustody(peer_id)
    if not self:PeerExists(peer_id) then
        return
    end
    self._peers[peer_id].in_custody = true
end

---@param peer_id number
function EHITradeDelayTracker:PeerExists(peer_id)
    return self._peers[peer_id] ~= nil
end

---@generic T
---@param peer_id number
---@param field_name string
---@param default_value T
---@return number|boolean|T
function EHITradeDelayTracker:GetPeerData(peer_id, field_name, default_value)
    if self:PeerExists(peer_id) then
        return self._peers[peer_id][field_name] or default_value
    end
    return default_value
end

if EHI:GetOption("show_trade_delay_amount_of_killed_civilians") then
    function EHITradeDelayTracker:FormatUnique(label, time, civilians_killed)
        label:set_text(string.format("%s (%d)", self:ShortFormatTime(time), civilians_killed))
    end
else
    function EHITradeDelayTracker:FormatUnique(label, time, civilians_killed)
        label:set_text(self:ShortFormatTime(time))
    end
end

---@param dt number
function EHITradeDelayTracker:update(dt)
    if self._tick > 0 then
        self._tick = self._tick - dt
        return
    end
    if self._pause_t > 0 then
        self._pause_t = self._pause_t - dt
        return
    end
    for peer_id, data in pairs(self._peers) do
        if data.in_custody then
            local time = data.t - dt
            if time <= 0 then
                self:RemovePeerFromCustody(peer_id)
            else
                data.t = time
                self:FormatUnique(data.label, time, data.civilians_killed)
                self:FitTheText(data.label)
            end
        end
    end
end

---@param trade boolean
---@param t number
---@param force_t boolean
function EHITradeDelayTracker:SetAITrade(trade, t, force_t)
    if trade then
        if not self._trade then
            self:SetTick(t)
            if not self._respawn then
                self:AddTrackerToUpdate()
            end
        end
        if force_t then
            self:SetTick(t)
        end
        self._ai_trade = true
        self._respawn = nil
    else
        if not self._trade then
            if self:CanRespawn() then
                self._respawn = true
            else
                self:RemoveTrackerFromUpdate()
            end
        end
        self._ai_trade = false
    end
end

---@param trade boolean
---@param t number
---@param force_t boolean
function EHITradeDelayTracker:SetTrade(trade, t, force_t)
    if trade then
        if not self._ai_trade then
            self:SetTick(t)
            if not self._respawn then
                self:AddTrackerToUpdate()
            end
        end
        if force_t then
            self:SetTick(t)
        end
        self._trade = true
        self._respawn = nil
    else
        if not self._ai_trade then
            if self:CanRespawn() then
                self._respawn = true
            else
                self:RemoveTrackerFromUpdate()
            end
        end
        self._trade = false
    end
end

function EHITradeDelayTracker:CanRespawn()
    return tweak_data.player.damage.automatic_respawn_time and not Global.game_settings.single_player
end