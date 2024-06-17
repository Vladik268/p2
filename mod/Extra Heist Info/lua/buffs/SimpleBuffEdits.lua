---@class EHIHealthRegenBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHealthRegenBuffTracker = class(EHIBuffTracker)
function EHIHealthRegenBuffTracker:init(...)
    EHIHealthRegenBuffTracker.super.init(self, ...)
    local icon = self._panel:child("icon") --[[@as PanelBitmap]] -- Hostage Taker regen
    self._panel:bitmap({ -- Muscle regen
        name = "icon2",
        texture = "guis/textures/pd2/specialization/icons_atlas",
        texture_rect = {4 * 64, 64, 64, 64},
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self._panel:bitmap({
        name = "icon3",
        texture = tweak_data.hud_icons.skill_5.texture,
        texture_rect = tweak_data.hud_icons.skill_5.texture_rect,
        color = Color.white,
        x = icon:x(),
        y = icon:y(),
        w = icon:w(),
        h = icon:h()
    })
    self:SetIcon("hostage_taker")
end

---@param buff string
function EHIHealthRegenBuffTracker:SetIcon(buff)
    if self._buff == buff then
        return
    end
    if buff == "hostage_taker" then
        self._panel:child("icon"):set_visible(true)
        self._panel:child("icon2"):set_visible(false)
        self._panel:child("icon3"):set_visible(false)
    elseif buff == "muscle" then
        self._panel:child("icon2"):set_visible(true)
        self._panel:child("icon"):set_visible(false)
        self._panel:child("icon3"):set_visible(false)
    else -- AIRegen
        self._panel:child("icon3"):set_visible(true)
        self._panel:child("icon2"):set_visible(false)
        self._panel:child("icon"):set_visible(false)
    end
    self._buff = buff
end

---@class EHIStaminaBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIStaminaBuffTracker = class(EHIGaugeBuffTracker)
---@param max_stamina number
function EHIStaminaBuffTracker:Spawned(max_stamina)
    self:SetMaxStamina(max_stamina)
    self:PreUpdate()
end

function EHIStaminaBuffTracker:PreUpdate()
    self:SetRatio(self._max_stamina)
    self:Activate()
end

---@param value number
function EHIStaminaBuffTracker:SetMaxStamina(value)
    self._max_stamina = value
end

---@param ratio number
function EHIStaminaBuffTracker:SetRatio(ratio)
    local value = ratio / self._max_stamina
    local rounded = self._parent_class.RoundNumber(value, 2)
    EHIStaminaBuffTracker.super.SetRatio(self, value, rounded)
end

function EHIStaminaBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
end

function EHIStaminaBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:RemoveVisibleBuff()
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end

---@class EHIStoicBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIStoicBuffTracker = class(EHIBuffTracker)
---@param t number
---@param pos number
function EHIStoicBuffTracker:Activate(t, pos)
    EHIStoicBuffTracker.super.Activate(self, self._auto_shrug or t, pos)
end

---@param t number
function EHIStoicBuffTracker:Extend(t)
    EHIStoicBuffTracker.super.Extend(self, self._auto_shrug or t)
end

---@param t number
function EHIStoicBuffTracker:SetAutoShrug(t)
    self._auto_shrug = t
end

---@class EHIHackerTemporaryDodgeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIHackerTemporaryDodgeBuffTracker = class(EHIBuffTracker)
function EHIHackerTemporaryDodgeBuffTracker:Activate(...)
    EHIHackerTemporaryDodgeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

function EHIHackerTemporaryDodgeBuffTracker:Deactivate()
    EHIHackerTemporaryDodgeBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction("DodgeChance", "ForceUpdate")
end

---@class EHIUnseenStrikeBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIUnseenStrikeBuffTracker = class(EHIBuffTracker)
function EHIUnseenStrikeBuffTracker:Activate(...)
    EHIUnseenStrikeBuffTracker.super.Activate(self, ...)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

function EHIUnseenStrikeBuffTracker:Deactivate()
    EHIUnseenStrikeBuffTracker.super.Deactivate(self)
    self._parent_class:CallFunction("CritChance", "ForceUpdate")
end

---@class EHIExPresidentBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIExPresidentBuffTracker = class(EHIGaugeBuffTracker)
function EHIExPresidentBuffTracker:PreUpdateCheck()
    if managers.player:has_category_upgrade("player", "armor_health_store_amount") then
        local buff, original = self, {}
        original.update_armor_stored_health = PlayerDamage.update_armor_stored_health
        function PlayerDamage:update_armor_stored_health(...)
            original.update_armor_stored_health(self, ...)
            buff:SetStoredHealthMaxAndUpdateRatio(self:max_armor_stored_health(), self._armor_stored_health)
        end
        original.add_armor_stored_health = PlayerDamage.add_armor_stored_health
        function PlayerDamage:add_armor_stored_health(...)
            local previous = self._armor_stored_health
            original.add_armor_stored_health(self, ...)
            if previous ~= self._armor_stored_health and not self._check_berserker_done then
                buff:SetRatio(nil, self._armor_stored_health)
            end
        end
        original.clear_armor_stored_health = PlayerDamage.clear_armor_stored_health
        function PlayerDamage:clear_armor_stored_health(...)
            original.clear_armor_stored_health(self, ...)
            buff:SetRatio(nil, self._armor_stored_health)
        end
        local player_unit = managers.player:player_unit()
        local character_damage = player_unit and player_unit:character_damage() ---@cast character_damage -HuskPlayerDamage
        self:SetStoredHealthMaxAndUpdateRatio(character_damage and character_damage:max_armor_stored_health() or 0, 0)
        return true
    end
end

function EHIExPresidentBuffTracker:PreUpdate()
    self._parent_class:AddBuffNoUpdate(self._id)
end

---@param max number
---@param ratio number
function EHIExPresidentBuffTracker:SetStoredHealthMaxAndUpdateRatio(max, ratio)
    self._stored_health_max = max
    self:SetRatio(nil, ratio)
end

---@param ratio nil
---@param custom_value number
function EHIExPresidentBuffTracker:SetRatio(ratio, custom_value)
    ratio = custom_value / self._stored_health_max
    EHIExPresidentBuffTracker.super.SetRatio(self, ratio, custom_value)
end

---@class EHIManiacBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
EHIManiacBuffTracker = class(EHIGaugeBuffTracker)
function EHIManiacBuffTracker:PreUpdateCheck()
    if self._persistent and managers.player:has_category_upgrade("player", "cocaine_stacking") then
        self:ActivateSoft()
    end
end

function EHIManiacBuffTracker:SetPersistent()
    self._persistent = true
end

function EHIManiacBuffTracker:Deactivate()
    if self._persistent then
        self._ratio = 0
        self._progress:stop()
        self._progress:animate(self._anim, 0, self._progress_bar)
        return
    end
    EHIManiacBuffTracker.super.Deactivate(self)
end

---@class EHIReplenishThrowableBuffTracker : EHIBuffTracker
---@field super EHIBuffTracker
EHIReplenishThrowableBuffTracker = class(EHIBuffTracker)
function EHIReplenishThrowableBuffTracker:init(...)
    self._replenish_count_running = 0
    EHIReplenishThrowableBuffTracker.super.init(self, ...)
    self._hint:set_visible(false)
end

function EHIReplenishThrowableBuffTracker:AddToReplenish()
    self._replenish_count_running = self._replenish_count_running + 1
    if self._replenish_count_running >= 2 then
        self:SetHintText(self._replenish_count_running)
        self._hint:set_visible(true)
    end
end

function EHIReplenishThrowableBuffTracker:Replenished()
    self._replenish_count_running = math.max(0, self._replenish_count_running - 1)
    if self._replenish_count_running <= 1 then
        self:SetHintText(self._replenish_count_running)
        self._hint:set_visible(false)
    end
end