local pm
---@class EHIBikerBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIBikerBuffTracker = class(EHIBuffTracker)
EHIBikerBuffTracker._max_kills = tweak_data.upgrades.wild_max_triggers_per_time or 4
function EHIBikerBuffTracker:PreUpdateCheck()
    pm = managers.player
    if pm:has_category_upgrade("player", "wild_health_amount") or pm:has_category_upgrade("player", "wild_armor_amount") then
        return true
    else
        self:delete()
    end
end

function EHIBikerBuffTracker:PreUpdate()
    self._f = function(...)
        if pm._wild_kill_triggers then
            -- Old kills were purged here before our post hook is called, no need to purge them again
            local kills = #pm._wild_kill_triggers
            self:Trigger(kills)
        end
    end
    self:SetCustodyState(false)
    if self._persistent then
        self:ActivateSoft()
    end
end

---@param state boolean
function EHIBikerBuffTracker:SetCustodyState(state)
    if state then
        EHI:Unhook("BikerBuff_Post")
        if self._persistent then
            EHIBikerBuffTracker.super.Deactivate(self)
        end
    else
        EHI:HookWithID(PlayerManager, "chk_wild_kill_counter", "EHI_BikerBuff_Post", self._f)
        if self._persistent then
            self:ActivateSoft()
        end
    end
end

---@param kills number
function EHIBikerBuffTracker:Trigger(kills)
    if kills < 1 then
        if self._active then
            self:Deactivate()
        end
        return
    end
    local t = Application:time()
    local cd
    if kills < self._max_kills then
        cd = pm._wild_kill_triggers[kills] - t
        self:SetIconColor(Color.white)
        self._hint:set_text(tostring(kills))
    else
        cd = pm._wild_kill_triggers[1] - t
        self:SetIconColor(Color.red)
        self._hint:set_text(tostring(self._max_kills))
        self._retrigger = true
    end
    if self._active then
        self:Extend(cd)
    else
        self:Activate(cd)
    end
end

---@param color Color
function EHIBikerBuffTracker:SetIconColor(color)
    self._panel:child("icon"):set_color(color)
end

---@param t number
function EHIBikerBuffTracker:Activate(t)
    if self._persistent then
        self._active = true
        self._time = t
        self._time_set = t
        self:AddBuffToUpdate()
    else
        EHIBikerBuffTracker.super.Activate(self, t)
        self:AddVisibleBuff()
    end
end

function EHIBikerBuffTracker:Deactivate()
    if self._retrigger then
        self._retrigger = nil
        self:Retrigger()
        return
    elseif self._persistent then
        self._active = false
        self._hint:set_text("0")
        self:RemoveBuffFromUpdate()
        return
    end
    EHIBikerBuffTracker.super.Deactivate(self)
end

function EHIBikerBuffTracker:Retrigger()
    -- Check again if there are still kills, but first, purge old kills so they don't mess up with the calculation
    local t = Application:time()
    while pm._wild_kill_triggers[1] and t >= pm._wild_kill_triggers[1] do
        table.remove(pm._wild_kill_triggers, 1)
    end
    local n = #pm._wild_kill_triggers
    self:Trigger(n)
end

function EHIBikerBuffTracker:SetPersistent()
    self._persistent = true
    self._hint:set_text("0")
    self._text:set_text("0")
end