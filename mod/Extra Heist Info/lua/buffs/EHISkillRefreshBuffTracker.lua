---@class EHISkillRefreshBuffTracker : EHIGaugeBuffTracker
---@field super EHIGaugeBuffTracker
---@field _refresh_option string?
EHISkillRefreshBuffTracker = class(EHIGaugeBuffTracker)
function EHISkillRefreshBuffTracker:init(...)
    EHISkillRefreshBuffTracker.super.init(self, ...)
    self._skill_value = 0
    self._refresh_time = self._refresh_option and (1 / EHI:GetBuffOption(self._refresh_option)) or 1
    self._time = self._refresh_time
end

function EHISkillRefreshBuffTracker:PreUpdate()
    self._player_manager = managers.player
    self:SetRatio(0)
    if not self._enable_in_loud then
        self:PreUpdate2()
    end
end

---@param state boolean
function EHISkillRefreshBuffTracker:SetCustodyState(state)
    if state then
        self:RemoveBuffFromUpdate()
        self._skill_value = -1
        self:Deactivate()
    else
        self._time = self._refresh_time
        self:AddBuffToUpdate()
    end
end

function EHISkillRefreshBuffTracker:SwitchToLoudMode()
    if self:SwitchToLoudModeEnabled() then
        self:PreUpdate2()
        self:AddBuffToUpdate()
    else
        self._enable_in_loud = nil -- In case "SwitchToLoudMode" is called first before "PreUpdate" has a chance to init variables => mission started in loud mode in the briefing screen
    end
end

function EHISkillRefreshBuffTracker:SwitchToLoudModeEnabled()
    return self._player_manager and self._enable_in_loud
end

-- Hooks functions after alarm has been raised
function EHISkillRefreshBuffTracker:PreUpdate2()
end

---@param dt number
function EHISkillRefreshBuffTracker:update(dt)
    self._time = self._time - dt
    if self._time <= 0 then
        self:UpdateValue()
        self._time = self._refresh_time
    end
end

function EHISkillRefreshBuffTracker:UpdateValue()
end

function EHISkillRefreshBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self._panel:stop()
    self._panel:animate(self._show)
    self:AddVisibleBuff()
end

function EHISkillRefreshBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:RemoveVisibleBuff()
    self._panel:stop()
    self._panel:animate(self._hide)
    self._active = false
end

---@class EHIDodgeChanceBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIDodgeChanceBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDodgeChanceBuffTracker._DODGE_INIT = tweak_data.player.damage.DODGE_INIT or 0
EHIDodgeChanceBuffTracker._refresh_option = "dodge_refresh"
function EHIDodgeChanceBuffTracker:init(...)
    EHIDodgeChanceBuffTracker.super.init(self, ...)
    self._update_disabled = true
end

function EHIDodgeChanceBuffTracker:UpdateValue()
    local player = self._player_manager:player_unit()
    if player == nil then
        return
    end
    local player_movement = player:movement() ---@cast player_movement -HuskPlayerMovement
    if player_movement == nil then
        return
    end
    local armorchance = self._player_manager:body_armor_value("dodge") --[[@as number]]
    local skillchance = self._player_manager:skill_dodge_chance(player_movement:running(), player_movement:crouching(), player_movement:zipline_unit() --[[@as boolean]])
    local total = self._DODGE_INIT + armorchance + skillchance
    if self._skill_value == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = total
end

function EHIDodgeChanceBuffTracker:ForceUpdate()
    if self._update_disabled then
        return
    end
    self:UpdateValue()
    self._time = self._refresh_time
end

function EHIDodgeChanceBuffTracker:PreUpdate2()
    local function update()
        self:UpdateValue()
        self._time = self._refresh_time
    end
    EHI:HookWithID(PlayerStandard, "_start_action_zipline", "EHI_DodgeBuff_start_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_end_action_zipline", "EHI_DodgeBuff_end_action_zipline", update)
    EHI:HookWithID(PlayerStandard, "_start_action_ducking", "EHI_DodgeBuff_start_action_ducking", update)
    EHI:HookWithID(PlayerStandard, "_end_action_ducking", "EHI_DodgeBuff_end_action_ducking", update)
    self._update_disabled = false
end

---@param state boolean
function EHIDodgeChanceBuffTracker:SetCustodyState(state)
    EHIDodgeChanceBuffTracker.super.SetCustodyState(self, state)
    self._update_disabled = state
end

function EHIDodgeChanceBuffTracker:SwitchToLoudMode()
    if self:SwitchToLoudModeEnabled() then
        self._update_disabled = false
    end
    EHIDodgeChanceBuffTracker.super.SwitchToLoudMode(self)
end

---@class EHICritChanceBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHICritChanceBuffTracker = class(EHISkillRefreshBuffTracker)
EHICritChanceBuffTracker._refresh_option = "crit_refresh"
function EHICritChanceBuffTracker:init(...)
    EHICritChanceBuffTracker.super.init(self, ...)
    self._update_disabled = true
end

function EHICritChanceBuffTracker:UpdateValue()
    local total = self._player_manager:critical_hit_chance(self._detection_risk)
    if self._skill_value == total then
        return
    elseif self._persistent or total > 0 then
        self:SetRatio(total)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = total
end

function EHICritChanceBuffTracker:ForceUpdate()
    if self._update_disabled then
        return
    end
    self:UpdateValue()
    self._time = self._refresh_time
end

function EHICritChanceBuffTracker:PreUpdate()
    EHICritChanceBuffTracker.super.PreUpdate(self)
    self._detection_risk = managers.blackmarket:get_suspicion_offset_of_local(tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
    self._detection_risk = math.round(self._detection_risk * 100)
end

function EHICritChanceBuffTracker:PreUpdate2()
    self._update_disabled = false
end

---@param new_detection_risk number?
function EHICritChanceBuffTracker:UpdateDetectionRisk(new_detection_risk)
    self._detection_risk = new_detection_risk or self._detection_risk
end

---@param state boolean
function EHICritChanceBuffTracker:SetCustodyState(state)
    EHICritChanceBuffTracker.super.SetCustodyState(self, state)
    self._update_disabled = state
end

function EHICritChanceBuffTracker:SwitchToLoudMode()
    if self:SwitchToLoudModeEnabled() then
        self._update_disabled = false
    end
    EHICritChanceBuffTracker.super.SwitchToLoudMode(self)
end

---@class EHIDamageAbsorptionBuffTracker : EHISkillRefreshBuffTracker
EHIDamageAbsorptionBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDamageAbsorptionBuffTracker._refresh_option = "damage_absorption_refresh"
function EHIDamageAbsorptionBuffTracker:UpdateValue()
    local absorption = self._player_manager:damage_absorption()
    if self._skill_value == absorption then
        return
    elseif self._persistent or absorption > 0 then
        local total = 0
        local player_unit = self._player_manager:player_unit()
        if alive(player_unit) then
            local damage = player_unit:character_damage() ---@cast damage -HuskPlayerDamage
            if damage then
                local max_health = damage:_max_health()
                total = absorption / max_health
            end
        end
        self:SetRatio(total, absorption * 10)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = absorption
end

---@class EHIDamageReductionBuffTracker : EHISkillRefreshBuffTracker
EHIDamageReductionBuffTracker = class(EHISkillRefreshBuffTracker)
EHIDamageReductionBuffTracker._refresh_option = "damage_reduction_refresh"
function EHIDamageReductionBuffTracker:UpdateValue()
    local reduction = 1 - self._player_manager:damage_reduction_skill_multiplier("bullet")
    if self._skill_value == reduction then
        return
    elseif self._persistent or reduction > 0 then
        self:SetRatio(reduction)
        self:Activate()
    else
        self:Deactivate()
    end
    self._skill_value = reduction
end

---@class EHIBerserkerBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIBerserkerBuffTracker = class(EHISkillRefreshBuffTracker)
EHIBerserkerBuffTracker._refresh_option = "berserker_refresh"
function EHIBerserkerBuffTracker:init(...)
    EHIBerserkerBuffTracker.super.init(self, ...)
    self._time = 0.2
    self._damage_multiplier = 0
    self._melee_damage_multiplier = 0
end

function EHIBerserkerBuffTracker:PreUpdate()
    EHIBerserkerBuffTracker.super.PreUpdate(self)
    if self._player_manager:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) == 0 then
        self:delete()
        return
    end
    self._THRESHOLD = tweak_data.upgrades.player_damage_health_ratio_threshold or 0.5
    if self._player_manager:has_category_upgrade("player", "armor_regen_damage_health_ratio_multiplier") then -- Yakuza 9/9 deck
        self._THRESHOLD = 1 - self._player_manager:_get_damage_health_ratio_threshold("armor_regen")
    elseif self._player_manager:has_category_upgrade("player", "movement_speed_damage_health_ratio_multiplier") then -- Yakuza 9/9 deck
        self._THRESHOLD = 1 - self._player_manager:_get_damage_health_ratio_threshold("movement_speed")
    end
    self._damage_multiplier = self._player_manager:upgrade_value('player', 'damage_health_ratio_multiplier', 0) --[[@as number]]
    self._melee_damage_multiplier = self._player_manager:upgrade_value('player', 'melee_damage_health_ratio_multiplier', 0) --[[@as number]]
    self:AddBuffToUpdate()
    if self._persistent then
        self:ActivateSoft()
    end
end

---@param state boolean
function EHIBerserkerBuffTracker:SetCustodyState(state)
    if state then
        self:RemoveBuffFromUpdate()
        if self._persistent then
            self:Deactivate2()
        else
            self:Deactivate()
        end
    else
        self:Activate()
        self._time = self._refresh_time
        self:AddBuffToUpdate()
        if self._persistent then
            self:ActivateSoft()
        end
    end
end

function EHIBerserkerBuffTracker:UpdateValue()
    local player_unit = self._player_manager:player_unit()
    if not player_unit then
        return
    end
    local character_damage = player_unit:character_damage() ---@cast character_damage -HuskPlayerDamage
    if not character_damage then
        return
    end
    local health_ratio = character_damage:health_ratio()
    if health_ratio <= self._THRESHOLD then
        local damage_ratio = 1 - (health_ratio / math.max(0.01, self._THRESHOLD))
        self._current_melee_damage_multiplier = 1 + self._melee_damage_multiplier * damage_ratio
        self._current_damage_multiplier = 1 + self._damage_multiplier * damage_ratio
        local mul = self._current_damage_multiplier * self._current_melee_damage_multiplier
        if mul > 1 then
            self:ActivateSoft()
            self:SetRatio(damage_ratio)
        else
            self:DeactivateSoft()
        end
    else
        self:DeactivateSoft()
    end
end

function EHIBerserkerBuffTracker:Activate()
    self._active = true
end

function EHIBerserkerBuffTracker:DeactivateSoft()
    if self._persistent then
        self._current_damage_multiplier = nil
        self._current_melee_damage_multiplier = nil
        self:SetRatio(0)
        return
    end
    EHIBerserkerBuffTracker.super.DeactivateSoft(self)
end

function EHIBerserkerBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self._active = false
    self._progress_bar.red = 0 -- No need to animate this because the panel is no longer visible
    self._progress:set_color(self._progress_bar)
end

function EHIBerserkerBuffTracker:Deactivate2()
    self._persistent = false
    self:Deactivate()
    self._persistent = true
end

function EHIBerserkerBuffTracker:SetPersistent()
    self._persistent = true
end

if EHI:GetBuffOption("berserker_format") == 1 then
    function EHIBerserkerBuffTracker:Format()
        local dmg = self._parent_class.RoundNumber(self._current_damage_multiplier or 0, 1)
        local mdmg = self._parent_class.RoundNumber(self._current_melee_damage_multiplier or 0, 1)
        local s
        if dmg == 0 and mdmg == 0 then
            s = "1x 1x"
        else
            s = (dmg > 1 and dmg .. "x" or "") .. (dmg > 1 and (mdmg > 1 and " " .. mdmg .. "x" or "") or (mdmg > 1 and mdmg .. "x" or ""))
        end
        return s
    end
else
    function EHIBerserkerBuffTracker:Format()
        local dmg = self._parent_class:RoundChanceNumber((self._current_damage_multiplier or 1) - 1)
        local mdmg = self._parent_class:RoundChanceNumber((self._current_melee_damage_multiplier or 1) - 1)
        local s
        if dmg == 0 and mdmg == 0 then
            s = "0% 0%"
        else
            s = (dmg > 0 and dmg .. "%" or "") .. (dmg > 0 and (mdmg > 0 and " " .. mdmg .. "%" or "") or (mdmg > 0 and mdmg .. "%" or ""))
        end
        return s
    end
end

---@class EHIUppersRangeBuffTracker : EHISkillRefreshBuffTracker
---@field super EHISkillRefreshBuffTracker
EHIUppersRangeBuffTracker = class(EHISkillRefreshBuffTracker)
EHIUppersRangeBuffTracker._refresh_option = "uppers_range_refresh"
function EHIUppersRangeBuffTracker:init(...)
    self._mv3_distance = mvector3.distance
    EHIUppersRangeBuffTracker.super.init(self, ...)
end

function EHIUppersRangeBuffTracker:PreUpdate()
    EHIUppersRangeBuffTracker.super.PreUpdate(self)
    local function Check(...)
        if self._in_custody then
            return
        end
        if next(FirstAidKitBase.List) then
            self:Activate()
        else
            self:Deactivate()
        end
    end
    EHI:HookWithID(FirstAidKitBase, "Add", "EHI_UppersRangeBuff_Add", Check)
    EHI:HookWithID(FirstAidKitBase, "Remove", "EHI_UppersRangeBuff_Remove", Check)
    self:SetCustodyState(false)
end

function EHIUppersRangeBuffTracker:Activate()
    if self._active then
        return
    end
    self._active = true
    self:AddBuffToUpdate()
end

---@param state boolean?
function EHIUppersRangeBuffTracker:SetCustodyState(state)
    if state then
        self:Deactivate()
    elseif next(FirstAidKitBase.List) then
        self:Activate()
    end
    self._in_custody = state
end

function EHIUppersRangeBuffTracker:Deactivate()
    if not self._active then
        return
    end
    self:DeactivateSoft()
    self:RemoveBuffFromUpdate()
    self._active = false
end

function EHIUppersRangeBuffTracker:UpdateValue()
    local player_unit = self._player_manager:player_unit()
    if alive(player_unit) then
        local found, distance, min_distance = self:GetFirstAidKit(player_unit:position())
        if found then
            local ratio = 1 - (distance / min_distance)
            self._distance = distance / 100
            self:ActivateSoft()
            self:SetRatio(ratio)
        else
            self:DeactivateSoft()
        end
    end
end

---@param pos Vector3
---@return boolean, number?, number?
function EHIUppersRangeBuffTracker:GetFirstAidKit(pos)
    for _, o in ipairs(FirstAidKitBase.List) do
        local dst = self._mv3_distance(pos, o.pos)
        if dst <= o.min_distance then
            return true, dst, o.min_distance
        end
    end
    return false
end

function EHIUppersRangeBuffTracker:Format()
    return string.format("%dm", math.floor(self._distance or 0))
end