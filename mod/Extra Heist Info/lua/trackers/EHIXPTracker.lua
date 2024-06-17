---@class EHIXPTracker : EHITracker
---@field super EHITracker
EHIXPTracker = class(EHITracker)
EHIXPTracker._forced_icons = { "xp" }
EHIXPTracker._forced_hint_text = "gained_xp"
EHIXPTracker.update = EHIXPTracker.update_fade
---@param params EHITracker.params
function EHIXPTracker:pre_init(params)
    self._xp = params.amount or 0
end

function EHIXPTracker:Format()
    return managers.experience:cash_string(self._xp, self._xp >= 0 and "+" or "")
end

---@param amount number
function EHIXPTracker:AddXP(amount)
    self._fade_time = 5
    self._xp = self._xp + amount
    self:SetAndFitTheText()
    self:AnimateBG()
end

---@class EHIHiddenXPTracker : EHIXPTracker
---@field super EHIXPTracker
EHIHiddenXPTracker = class(EHIXPTracker)
EHIHiddenXPTracker._update = false
EHIHiddenXPTracker._init_create_text = false
---@param params EHITracker.params
function EHIHiddenXPTracker:pre_init(params)
    self._total_xp = 0
    self._refresh_t = params.refresh_t or 1
    self._xp_panel = params.panel or 3
    params.time = self._refresh_t
    self._experience = managers.localization:text("ehi_popup_experience")
    self._experience_total_text = managers.localization:text("ehi_popup_experience_total")
    local gained = params.format == 1 and "ehi_popup_experience_base_gained" or "ehi_popup_experience_gained"
    if self._xp_panel == 3 then
        local xp = managers.localization:text("ehi_experience_xp")
        self._experience_format = "%s%s " .. xp .. "\n%s%s " .. xp
    else
        local xp = managers.localization:text("ehi_experience_xp")
        self._experience_format = "%s%s " .. xp .. ";%s%s " .. xp
        gained = "ehi_popup_experience_gained"
    end
    self._experience_gained_text = managers.localization:text(gained)
    self._xp_class = managers.experience
    if (params.amount or 0) > 0 then
        if self._refresh_t == 0 then
            self:ShowPopup(params.amount)
        else
            self._xp = params.amount
            self:AddTrackerToUpdate()
        end
    end
end

---@param xp number?
function EHIHiddenXPTracker:ShowPopup(xp)
    xp = xp or self._xp or 0
    local xp_string = string.format(self._experience_format, self._experience_gained_text, self._xp_class:cash_string(xp, xp >= 0 and "+" or ""), self._experience_total_text, self._xp_class:cash_string(self._total_xp, "+"))
    if self._xp_panel == 3 then
        managers.hud:custom_ingame_popup_text(self._experience, xp_string, "EHI_XP")
    else
        managers.hud:show_hint({ text = xp_string })
    end
end

---@param dt number
function EHIHiddenXPTracker:update(dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:RemoveTrackerFromUpdate()
        self:ShowPopup()
        self._xp = nil
    end
end

---@param amount number
function EHIHiddenXPTracker:AddXP(amount)
    self._total_xp = self._total_xp + amount
    if self._refresh_t == 0 then
        self:ShowPopup(amount)
        return
    elseif not self._xp then
        self:AddTrackerToUpdate()
    end
    self._time = self._refresh_t
    self._xp = (self._xp or 0) + amount
end

---@class EHITotalXPTracker : EHIXPTracker
---@field super EHIXPTracker
EHITotalXPTracker = class(EHIXPTracker)
EHITotalXPTracker._forced_hint_text = "total_xp"
EHITotalXPTracker._update = false
---@param o PanelText
---@param self EHITotalXPTracker
EHITotalXPTracker._anim_xp = function(o, self)
    local xp = self._player_xp_limit > 0 and math.min(self._xp, self._player_xp_limit) or self._xp
    local previous_xp = self._total_xp_anim
    local t = 0
    while t < 1 do
        t = t + coroutine.yield()
        local n = math.lerp(previous_xp, xp, t)
        o:set_text(self:Format(n))
        self._total_xp_anim = n
    end
    self._total_xp = xp
    self._total_xp_anim = xp
    o:set_text(self:Format())
    self:FitTheText(o)
end
---@param panel Panel
---@param params EHITracker.params
function EHITotalXPTracker:init(panel, params, ...)
    self._total_xp = params.amount or 0
    self._total_xp_anim = self._total_xp
    self._player_xp_limit = params.xp_limit or 0
    self._xp_overflow_enabled = params.xp_overflow_enabled
    EHITotalXPTracker.super.init(self, panel, params, ...)
    if self._xp_overflow_enabled then
        self._player_xp_limit = 0
    elseif self._player_xp_limit <= 0 then
        self._update = true -- Request deletion next frame
    end
end

---@param dt number
function EHITotalXPTracker:update(dt)
    self:delete()
end

function EHITotalXPTracker:OverridePanel()
    self:SetBGSize(self._bg_box:w() / 2)
    self._text:set_w(self._bg_box:w())
    self:SetIconX()
end

---@param amount number?
function EHITotalXPTracker:Format(amount)
    return managers.experience:cash_string(amount or self._total_xp, "+") -- Will never show a negative value
end

---@param amount number
function EHITotalXPTracker:SetXP(amount)
    self._xp = amount
    if self._total_xp ~= self._xp and not self._player_limit_reached then
        if self._xp >= self._player_xp_limit and not self._xp_overflow_enabled then
            self._player_limit_reached = true
            self:SetTextColor(Color.green)
        end
        self._text:stop()
        self._text:animate(self._anim_xp, self)
        self:AnimateBG()
    end
end

function EHITotalXPTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHITotalXPTracker.super.delete(self)
end