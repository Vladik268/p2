---@class EHILootTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHILootTracker = class(EHIProgressTracker)
EHILootTracker._forced_hint_text = "loot_counter"
EHILootTracker._forced_icons = { EHI.Icons.Loot }
EHILootTracker._show_popup = EHI:GetOption("show_all_loot_secured_popup")
---@param params EHITracker.params
function EHILootTracker:pre_init(params)
    EHILootTracker.super.pre_init(self, params)
    self._mission_loot = 0
    self._offset = params.offset or 0
    self._max_random = params.max_random or 0
    self._stay_on_screen = self._max_random > 0
    self._max_xp_bags = params.max_xp_bags or 0
    self._unknown_random = params.unknown_random
end

---@param params EHITracker.params
function EHILootTracker:post_init(params)
    EHILootTracker.super.post_init(self, params)
    self._show_finish_after_reaching_target = self._stay_on_screen
    self._loot_id = {}
    self._loot_check_delay = {} ---@type table<number, number>
    self._loot_check_n = 0
    if self._max_xp_bags > 0 then
        self:SetTextColor(Color.yellow)
    end
end

function EHILootTracker:OverridePanel()
    if self._max_random > 0 and self._unknown_random then
        self:IncreaseTrackerSize()
    end
end

---@param animate boolean?
function EHILootTracker:IncreaseTrackerSize(animate)
    if self.__tracker_size_increased then
        return
    end
    self.__tracker_size_increased = true
    if animate then
        self:SetBGSize(self._bg_box:w() / 2, "add", true)
        local new_w = self._bg_box:w()
        local new_panel_w = self:GetTrackerSize()
        self._text:set_w(new_w)
        self:AnimIconX(new_w + self._gap_scaled)
        self:AnimatePanelWAndRefresh(new_panel_w)
        self:ChangeTrackerWidth(new_panel_w)
        self:AnimateRepositionHintX()
    else
        self:SetBGSize(self._bg_box:w() / 2, "add")
        self._text:set_w(self._bg_box:w())
        self:SetIconX()
        self:SetAndFitTheText()
    end
end

---@param animate boolean?
function EHILootTracker:DecreaseTrackerSize(animate)
    if not self.__tracker_size_increased then
        return
    end
    self.__tracker_size_increased = nil
    if animate then
        self:SetBGSize(self._default_bg_size, "set", true)
        local new_w = self._bg_box:w()
        local new_panel_w = self:GetTrackerSize()
        self._text:set_w(new_w)
        self:AnimIconX(new_w + self._gap_scaled)
        self:AnimatePanelWAndRefresh(new_panel_w)
        self:ChangeTrackerWidth(new_panel_w)
        self:AnimateRepositionHintX()
    else
        self:SetBGSize(self._default_bg_size, "set", animate)
        self._text:set_w(self._bg_box:w())
        self:SetIconX()
        self:SetAndFitTheText()
        self:SetHintX(self:GetTrackerSize())
    end
end

if EHI:GetOption("variable_random_loot_format") == 1 then
    function EHILootTracker:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            local max = self._max + self._max_random
            if self._unknown_random then
                return self._progress .. "/" .. self._max .. "-" .. max .. "?+?"
            else
                return self._progress .. "/" .. self._max .. "-" .. max .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return EHILootTracker.super.Format(self)
    end
elseif EHI:GetOption("variable_random_loot_format") == 2 then
    function EHILootTracker:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            local max = self._max + self._max_random
            if self._unknown_random then
                return self._progress .. "/" .. max .. "?+?"
            else
                return self._progress .. "/" .. max .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return EHILootTracker.super.Format(self)
    end
else
    function EHILootTracker:Format()
        if self._max_xp_bags > 0 then
            local max = math.min(self._max, self._max_xp_bags)
            return self._progress .. "/" .. max
        elseif self._max_random > 0 then
            if self._unknown_random then
                return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?+?"
            else
                return self._progress .. "/" .. self._max .. "+" .. self._max_random .. "?"
            end
        elseif self._unknown_random then
            return self._progress .. "/" .. self._max .. "+?"
        end
        return EHILootTracker.super.Format(self)
    end
end

---@param dt number
function EHILootTracker:update(dt)
    for id, t in pairs(self._loot_check_delay) do
        t = t - dt
        if t <= 0 then
            self._loot_check_delay[id] = nil
            self._loot_check_n = self._loot_check_n - 1
            if self:CanDisableUpdate() then
                self:RemoveTrackerFromUpdate()
            end
            self:RandomLootDeclinedCheck(id)
        else
            self._loot_check_delay[id] = t
        end
    end
end

function EHILootTracker:CanDisableUpdate()
    return self._loot_check_n <= 0
end

---@param id number
---@param t number? Defaults to `2` if not provided
function EHILootTracker:AddDelayedLootDeclinedCheck(id, t)
    self._loot_check_delay[id] = t or 2
    if self._loot_check_n == 0 then
        self:AddTrackerToUpdate()
    end
    self._loot_check_n = self._loot_check_n + 1
end

---@param progress number
function EHILootTracker:SetProgress(progress)
    local fixed_progress = progress + self._mission_loot - self._offset
    local original_max = self._max
    if self._max_xp_bags > 0 then
        self._max = math.min(self._max, self._max_xp_bags)
    end
    EHILootTracker.super.SetProgress(self, fixed_progress)
    self._max = original_max
end

function EHILootTracker:Finalize()
    local progress = self._progress
    self._progress = self._progress - self._offset
    EHILootTracker.super.Finalize(self)
    self._progress = progress
end

---@param force boolean?
function EHILootTracker:SetCompleted(force)
    EHILootTracker.super.SetCompleted(self, force)
    if self._stay_on_screen and self._status then
        self:SetAndFitTheText()
        self._status = nil
    elseif self:CanShowLootSecuredPopup() then
        self:ShowLootSecuredPopup()
    end
end

---@param no_update boolean?
function EHILootTracker:ShowLootSecuredPopup(no_update)
    self._popup_showed = true
    if not no_update then
        self.update = self.update_fade
    end
    local xp_text = self._max_xp_bags > 0 and "ehi_popup_all_xp_loot_secured" or "ehi_popup_all_loot_secured"
    managers.hud:custom_ingame_popup_text("LOOT COUNTER", managers.localization:text(xp_text), "EHI_Loot")
end

function EHILootTracker:CanShowLootSecuredPopup()
    return self._show_popup and not self._popup_showed and not self._show_finish_after_reaching_target
end

---@param max number
function EHILootTracker:SetProgressMax(max)
    if self._max_xp_bags > 0 and self._max_xp_bags >= max then
        self._max_xp_bags = 0
        self:SetTextColor(Color.white)
    end
    EHILootTracker.super.SetProgressMax(self, max)
    self._disable_counting = nil
    self:VerifyStatus()
end

function EHILootTracker:VerifyStatus()
    self._stay_on_screen = self._max_random > 0
    self._show_finish_after_reaching_target = self._stay_on_screen
    if self._progress == self._max then
        self:SetCompleted()
    end
end

---@param random number?
function EHILootTracker:RandomLootSpawned(random)
    if self._max_random <= 0 then
        return
    end
    local n = random or 1
    self._max_random = self._max_random - n
    self:CheckUnknownRandomAndMaxRandom()
    self:IncreaseProgressMax(n)
end

---@param random number?
function EHILootTracker:RandomLootDeclined(random)
    if self._max_random <= 0 then
        return
    end
    self._max_random = self._max_random - (random or 1)
    self:CheckUnknownRandomAndMaxRandom()
    self:SetProgressMax(self._max)
end

---@param max number?
function EHILootTracker:SetMaxRandom(max)
    self._max_random = max or 0
    self:CheckUnknownRandomAndMaxRandom()
    self:SetProgressMax(self._max)
end

---@param progress number?
function EHILootTracker:IncreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random + (progress or 1))
end

---@param progress number?
function EHILootTracker:DecreaseMaxRandom(progress)
    self:SetMaxRandom(self._max_random - (progress or 1))
end

function EHILootTracker:CheckUnknownRandomAndMaxRandom()
    local random_check = self._max_random > 0 and self._unknown_random
    if self.__tracker_size_increased then
        if random_check then
            return
        end
        self:DecreaseTrackerSize(true)
    elseif random_check then
        self:IncreaseTrackerSize(true)
    end
end

---@param id number
---@param force boolean?
function EHILootTracker:RandomLootSpawnedCheck(id, force)
    if self._loot_id[id] then
        if force then -- This is here to combat desync, use it if element does not have "fail" state
            self:IncreaseProgressMax()
        end
        return
    end
    self._loot_id[id] = true
    self:RandomLootSpawned()
end

---@param id number
function EHILootTracker:RandomLootDeclinedCheck(id)
    if self._loot_id[id] then
        return
    end
    self:RandomLootDeclined()
end

---@param id number
function EHILootTracker:BlockRandomLoot(id)
    self._loot_id[id] = true
end

---@param state boolean
function EHILootTracker:SetUnknownRandomLoot(state)
    if state and not self._unknown_random then
        self:IncreaseTrackerSize(true)
    elseif self._unknown_random and not state then
        self:DecreaseTrackerSize(true)
    end
    self._unknown_random = state
    self:SetAndFitTheText()
end

function EHILootTracker:SecuredMissionLoot()
    local progress = self._progress - self._mission_loot + self._offset
    self._mission_loot = self._mission_loot + 1
    self:SetProgress(progress)
end

EHILootTracker.FormatProgress = EHILootTracker.Format

---@class EHILootCountTracker : EHICountTracker
EHILootCountTracker = class(EHICountTracker)
EHILootCountTracker._forced_hint_text = "loot_counter"
EHILootCountTracker._forced_icons = { EHI.Icons.Loot }
EHILootCountTracker.SetProgress = EHILootCountTracker.SetCount

---@class EHILootMaxTracker : EHILootTracker
---@field super EHILootTracker
EHILootMaxTracker = class(EHILootTracker)
---@param params EHITracker.params
function EHILootMaxTracker:post_init(params)
    EHILootMaxTracker.super.post_init(self, params)
    self._params = params.xp_params or {} ---@type LootCounterTable.MaxBagsForMaxLevel
    self._refresh_max = 5
    self._show_finish_after_reaching_target = true
    local function refresh()
        self:Refresh()
    end
    EHI:AddCallback("ExperienceManager_RefreshPlayerCount", refresh)
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, refresh)
    if EHI:IsClient() then
        ---@param loot LootManager
        EHI:AddCallback(EHI.CallbackMessage.LootLoadSync, function(loot)
            self._offset = loot:GetSecuredBagsAmount()
            self:SetProgress(self._progress)
        end)
    end
end

function EHILootMaxTracker:PlayerSpawned()
    EHILootMaxTracker.super.PlayerSpawned(self)
    self:AddTrackerToUpdate()
end

---@param state boolean
function EHILootMaxTracker:OnPlayerCustody(state)
    self:Refresh()
end

---@param dt number
function EHILootMaxTracker:update(dt)
    if self._refresh_max then
        self._refresh_max = self._refresh_max - dt
        if self._refresh_max <= 0 then
            self._refresh_max = nil
            self:CacheVariables()
            self:Refresh()
            if self:CanDisableUpdate() then
                self:RemoveTrackerFromUpdate()
                return
            end
        end
    end
    EHILootMaxTracker.super.update(self, dt)
end

function EHILootMaxTracker:VerifyStatus()
    if self._progress == self._max then
        self:SetCompleted()
    end
end

function EHILootMaxTracker:CacheVariables()
    self._xp_player_limit = managers.ehi_experience:GetPlayerXPLimit()
end

function EHILootMaxTracker:Refresh()
    if self._refresh_max then
        return
    end
    local xp_per_bags, current_secured_bags = 1, nil
    if self._params.xp_per_loot then
        local xp = 0
        current_secured_bags = 0
        for loot, value in pairs(self._params.xp_per_loot) do
            local amount = managers.loot:GetSecuredBagsTypeAmount(loot)
            xp = xp + (amount * value)
            current_secured_bags = current_secured_bags + amount
        end
        xp_per_bags = managers.ehi_experience:MultiplyXPWithAllBonuses(xp, 1)
    elseif self._params.xp_per_bag_all then
        xp_per_bags = managers.ehi_experience:MultiplyXPWithAllBonuses(self._params.xp_per_bag_all, 1)
    end
    local xp_mission = managers.ehi_experience:MultiplyXPWithAllBonuses(self._params.mission_xp, 0)
    local xp_remaining_to_max = self._xp_player_limit - xp_mission
    local new_max = math.ceil(xp_remaining_to_max / xp_per_bags)
    if new_max ~= self._max then
        current_secured_bags = math.clamp((current_secured_bags or managers.loot:GetSecuredBagsAmount()) - self._offset, 0, math.huge)
        local max_secured_bags = new_max
        if new_max < self._max and self._progress > max_secured_bags then
            current_secured_bags = new_max
        end
        self._progress = math.clamp(self._progress, current_secured_bags, max_secured_bags)
        self:SetProgressMax(new_max)
    end
end

---@param amount number
function EHILootMaxTracker:ObjectiveXPAwarded(amount)
    if amount <= 0 then
        return
    end
    self._params.mission_xp = (self._params.mission_xp or 0) + amount
    self:Refresh()
end

---@class EHIAchievementLootCounterTracker : EHILootTracker, EHIAchievementTracker
---@field _icon2 PanelBitmap
---@field super EHILootTracker
EHIAchievementLootCounterTracker = ehi_achievement_class(EHILootTracker)
EHIAchievementLootCounterTracker._PrepareHint = EHIAchievementTracker.PrepareHint
EHIAchievementLootCounterTracker._PlayerSpawned = EHIAchievementTracker.PlayerSpawned
---@param panel Panel
---@param params EHITracker.params
function EHIAchievementLootCounterTracker:init(panel, params, ...)
    self._no_failure = params.no_failure
    self._beardlib = params.beardlib
    self._loot_counter_on_fail = params.loot_counter_on_fail
    self._forced_icons[1] = params.icons[1]
    self._forced_icons[2] = "pd2_loot"
    if not params.start_silent then
        self:PrepareHint(params)
    end
    EHIAchievementLootCounterTracker.super.init(self, panel, params, ...)
    if params.start_silent then
        self._silent_start = true
        if self._icon2 then
            self._icon2:set_visible(true)
            self._icon1:set_visible(false)
            self._panel_override_w = self._bg_box:w() + self._icon_gap_size_scaled
            self:SetHintX(self._panel_override_w)
            self._icon2:set_x(self._icon1:x())
        else
            self:SetIcon("pd2_loot")
        end
    else
        self:ShowStartedPopup(params.delay_popup)
        self:ShowAchievementDescription(params.delay_popup)
    end
end

---@param params EHITracker.params
function EHIAchievementLootCounterTracker:PrepareHint(params)
    self:_PrepareHint(params)
    self._forced_hint_text = params.hint
end

function EHIAchievementLootCounterTracker:PlayerSpawned()
    if self._silent_start then
        EHIAchievementLootCounterTracker.super.PlayerSpawned(self)
        return
    end
    self:_PlayerSpawned()
end

function EHIAchievementLootCounterTracker:DelayForcedDelete()
    EHIAchievementLootCounterTracker.super.DelayForcedDelete(self)
    self._show_finish_after_reaching_target = nil
    if self:CanShowLootSecuredPopup() then
        self:ShowLootSecuredPopup()
    end
end

---@param force boolean?
function EHIAchievementLootCounterTracker:SetCompleted(force)
    self._achieved_popup_showed = true
    EHIAchievementLootCounterTracker.super.SetCompleted(self, force)
end

function EHIAchievementLootCounterTracker:SetFailed()
    if self._loot_counter_on_fail then
        self:AnimateBG()
        if self._icon2 then
            self._icon2:set_visible(true)
            self._icon1:set_visible(false)
            self._icon2:set_x(self._icon1:x())
            self:ChangeTrackerWidth(self._bg_box:w() + self._icon_gap_size_scaled, true)
            self._hint_vanilla_localization = nil
            self:UpdateHint("loot_counter")
            self:AnimateRepositionHintX(1)
        else
            self:SetIcon("pd2_loot")
        end
        self._show_finish_after_reaching_target = nil
        self._status = nil
        self._disable_counting = false
        self:SetProgress(self._progress)
    else
        EHIAchievementLootCounterTracker.super.SetFailed(self)
    end
    if self._status_is_overridable then
        self._achieved_popup_showed = nil
    end
    self:ShowFailedPopup()
end

function EHIAchievementLootCounterTracker:SetFailed2()
    if self._failed_allowed then
        self:SetFailed()
    end
end

function EHIAchievementLootCounterTracker:SetFailedSilent()
    self._failed_on_sync = true
    self._show_failed = nil
    self._show_finish_after_reaching_target = nil
    self._hint_vanilla_localization = nil
    self:UpdateHint("loot_counter")
    self:SetFailed()
end

function EHIAchievementLootCounterTracker:SetStarted()
    if self._show_started then
        self._failed_allowed = self._silent_start
        if self._silent_start then
            self._hint_vanilla_localization = true
            self:UpdateHint("achievement_" .. self._id)
        end
        self:ShowStartedPopup()
        self._icon1:set_visible(true)
        if self._icon2 then
            self._icon2:set_visible(true)
            self:SetIconsX()
            self._panel_override_w = nil
            self:AnimateRepositionHintX(3) -- Why 3 ? I have no clue
            self:ChangeTrackerWidth(nil, true)
        else
            self:SetIcon(self._forced_icons[1])
        end
    end
    self:ShowAchievementDescription()
end