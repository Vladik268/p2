local EHI = EHI
if EHI:CheckLoadHook("HUDManagerPD2") then
    return
end

local original =
{
    _setup_player_info_hud_pd2 = HUDManager._setup_player_info_hud_pd2,
    sync_set_assault_mode = HUDManager.sync_set_assault_mode,
    destroy = HUDManager.destroy,
    set_disabled = HUDManager.set_disabled,
    set_enabled = HUDManager.set_enabled
}

function HUDManager:_setup_player_info_hud_pd2(...)
    original._setup_player_info_hud_pd2(self, ...)
    local server = EHI:IsHost()
    local hud = self:script(PlayerBase.PLAYER_INFO_HUD_PD2)
    self.ehi = managers.ehi_tracker
    managers.ehi_waypoint:SetPlayerHUD(self)
    managers.ehi_assault:init_hud(self)
    self.ehi_manager = managers.ehi_manager
    local EHIWaypoints = EHI:GetOption("show_waypoints")
    local level_id = Global.game_settings.level_id
    if server or EHI:IsHeistTimerInverted() then
        if EHIWaypoints then
            self:AddEHIUpdator(self.ehi_manager, "EHIManager_Update")
        else
            self:AddEHIUpdator(self.ehi, "EHI_Update")
        end
    else
        original.feed_heist_time = self.feed_heist_time
        if EHIWaypoints then
            function HUDManager:feed_heist_time(time, ...)
                original.feed_heist_time(self, time, ...)
                self.ehi_manager:update_client(time)
            end
        else
            function HUDManager:feed_heist_time(time, ...)
                original.feed_heist_time(self, time, ...)
                self.ehi:update_client(time)
            end
        end
    end
    if EHI:IsVR() then
        self.ehi:SetPanel(hud.panel)
    end
    if EHI:GetOption("show_buffs") then
        managers.ehi_buff:init_finalize(self, hud.panel)
    end
    if EHI:GetOption("show_floating_health_bar") then
        dofile(EHI.LuaPath .. "EHIHealthFloatManager.lua")
        EHIHealthFloatManager:new(self)
    end
    if tweak_data.levels:IsLevelSafehouse(level_id) then
        return
    end
    if EHI:GetOptionAndLoadTracker("show_captain_damage_reduction") then
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
            if mode == "phalanx" then
                self.ehi:AddTracker({
                    id = "PhalanxDamageReduction",
                    class = "EHIPhalanxDamageReductionTracker",
                })
            else
                self.ehi:ForceRemoveTracker("PhalanxDamageReduction")
            end
        end)
    end
    if tweak_data.levels:IsStealthAvailable(level_id) then
        if EHI:GetOption("show_pager_tracker") then
            local base = tweak_data.player.alarm_pager.bluff_success_chance_w_skill
            if server then
                for _, value in ipairs(base) do
                    if value > 0 and value < 1 then
                        -- Random Chance
                        self.ehi:AddTracker({
                            id = "PagersChance",
                            chance = self.ehi:RoundChanceNumber(base[1] or 0),
                            icons = { EHI.Icons.Pager },
                            hint = "pager_chance",
                            remove_on_alarm = true,
                            class = EHI.Trackers.Chance
                        })
                        return
                    end
                end
            end
            local max = 0
            for _, value in ipairs(base) do
                if value > 0 then
                    max = max + 1
                end
            end
            self.ehi:AddTracker({
                id = "Pagers",
                max = max,
                icons = { EHI.Icons.Pager },
                set_color_bad_when_reached = true,
                hint = "pager_counter",
                remove_on_alarm = true,
                class = EHI.Trackers.Progress
            })
            if max == 0 then
                self.ehi:CallFunction("Pagers", "SetBad")
            end
        end
        if EHI:GetOption("show_bodybags_counter") then
            self.ehi:AddTracker({
                id = "BodybagsCounter",
                icons = { "equipment_body_bag" },
                hint = "bodybags_counter",
                remove_on_alarm = true,
                class = EHI.Trackers.Counter
            })
        end
    end
end

---@param class table
---@param id string
function HUDManager:AddEHIUpdator(class, id)
    if not class.update then
        EHI:Log("Class with ID '" .. id .. "' is missing 'update' function!")
        return
    elseif not self._ehi_updators then
        EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function()
            self:RemoveEHIUpdators()
        end)
    end
    self._ehi_updators = self._ehi_updators or {}
    self._ehi_updators[id] = class
    self:add_updator(id, callback(class, class, "update"))
end

function HUDManager:RemoveEHIUpdators()
    for id, class in pairs(self._ehi_updators or {}) do
        self:remove_updator(id)
        if class and class.update_last then
            class:update_last()
        end
    end
    self._ehi_updators = nil
end

function HUDManager:sync_set_assault_mode(mode, ...)
    original.sync_set_assault_mode(self, mode, ...)
    EHI:CallCallback(EHI.CallbackMessage.AssaultModeChanged, mode)
end

if EHI:GetBuffAndOption("stamina") then
    original.set_stamina_value = HUDManager.set_stamina_value
    function HUDManager:set_stamina_value(value, ...)
        original.set_stamina_value(self, value, ...)
        managers.ehi_buff:AddGauge("Stamina", value)
    end
    original.set_max_stamina = HUDManager.set_max_stamina
    function HUDManager:set_max_stamina(value, ...)
        original.set_max_stamina(self, value, ...)
        managers.ehi_buff:CallFunction("Stamina", "SetMaxStamina", value)
    end
end

function HUDManager:set_disabled(...)
    original.set_disabled(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.HUDVisibilityChanged, false)
end

function HUDManager:set_enabled(...)
    original.set_enabled(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.HUDVisibilityChanged, true)
end

function HUDManager:destroy(...)
    self.ehi_manager:destroy()
    original.destroy(self, ...)
end

if EHI:IsAssaultDelayTrackerEnabled() then
    original.sync_start_anticipation_music = HUDManager.sync_start_anticipation_music
    function HUDManager:sync_start_anticipation_music(...)
        original.sync_start_anticipation_music(self, ...)
        managers.ehi_assault:AnticipationStart()
    end
end

if EHI:IsAssaultTrackerEnabled() then
    original.sync_start_assault = HUDManager.sync_start_assault
    function HUDManager:sync_start_assault(...)
        original.sync_start_assault(self, ...)
        managers.ehi_assault:AssaultStart()
    end
    original.sync_end_assault = HUDManager.sync_end_assault
    function HUDManager:sync_end_assault(...)
        original.sync_end_assault(self, ...)
        managers.ehi_assault:AssaultEnd()
    end
end

---@param id string
---@param beardlib boolean?
function HUDManager:ShowAchievementStartedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", EHI._cache.Beardlib[id].name, "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT STARTED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

---@param id string
---@param beardlib boolean?
function HUDManager:ShowAchievementFailedPopup(id, beardlib)
    if beardlib then
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", EHI._cache.Beardlib[id].name, "ehi_" .. id)
    else
        self:custom_ingame_popup_text("ACHIEVEMENT FAILED!", managers.localization:to_upper_text("achievement_" .. id), EHI:GetAchievementIconString(id))
    end
end

---@param id string
---@param beardlib boolean?
function HUDManager:ShowAchievementDescription(id, beardlib)
    if beardlib then
        local Achievement = EHI._cache.Beardlib[id]
        managers.chat:_receive_message(1, Achievement.name, Achievement.objective, Color.white)
    else
        managers.chat:_receive_message(1, managers.localization:text("achievement_" .. id), managers.localization:text("achievement_" .. id .. "_desc"), Color.white)
    end
end

---@param id string
function HUDManager:ShowTrophyStartedPopup(id)
    self:custom_ingame_popup_text("TROPHY STARTED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

---@param id string
function HUDManager:ShowTrophyFailedPopup(id)
    self:custom_ingame_popup_text("TROPHY FAILED!", managers.localization:to_upper_text(id), "milestone_trophy")
end

---@param id string
function HUDManager:ShowTrophyDescription(id)
    managers.chat:_receive_message(1, managers.localization:text(id), managers.localization:text(id .. "_objective"), Color.white)
end

---@param id string
---@param daily_job boolean
---@param icon string?
function HUDManager:ShowSideJobStartedPopup(id, daily_job, icon)
    local text = daily_job and ("menu_challenge_" .. id) or id
    icon = icon or tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB STARTED!", managers.localization:to_upper_text(text), icon)
end

---@param id string
---@param daily_job boolean
---@param icon string?
function HUDManager:ShowSideJobFailedPopup(id, daily_job, icon)
    local text = daily_job and ("menu_challenge_" .. id) or id
    icon = tweak_data.ehi.icons[id] and id or "milestone_trophy"
    self:custom_ingame_popup_text("DAILY SIDE JOB FAILED!", managers.localization:to_upper_text(text), icon)
end

---@param id string
---@param daily_job boolean?
function HUDManager:ShowSideJobDescription(id, daily_job)
    local text = daily_job and ("menu_challenge_" .. id) or id
    local objective = daily_job and ("menu_challenge_" .. id .. "_desc") or (id .. "_objective")
    managers.chat:_receive_message(1, managers.localization:text(text), managers.localization:text(objective), Color.white)
end

---@param single_sniper boolean?
function HUDManager:ShowSnipersSpawned(single_sniper)
    local id = single_sniper and "SNIPER!" or "SNIPERS!"
    local desc = single_sniper and "ehi_popup_sniper_spawned" or "ehi_popup_snipers_spawned"
    self:custom_ingame_popup_text(id, managers.localization:text(desc), "EHI_Sniper")
end

function HUDManager:Debug(id)
    local dt = 0
    if self._ehi_debug_time then
        local new_time = TimerManager:game():time()
        dt = new_time - self._ehi_debug_time
        self._ehi_debug_time = new_time
    else
        self._ehi_debug_time = TimerManager:game():time()
    end
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; dt: " .. dt, Color.white)
end

---@param id number
---@param editor_name string
---@param enabled boolean
function HUDManager:DebugElement(id, editor_name, enabled)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(id) .. "; Editor Name: " .. tostring(editor_name) .. "; Enabled: " .. tostring(enabled), Color.white)
end

function HUDManager:DebugExperience(id, name, amount)
    local s = string.format("`%s` ElementExperince %d: Gained %d XP", name, id, amount)
    managers.chat:_receive_message(1, "[EHI]", s, Color.white)
    if EHI.debug.gained_experience.log then
        EHI:Log(s)
    end
end

function HUDManager:DebugBaseElement(id, instance_index, continent_index, element)
    managers.chat:_receive_message(1, "[EHI]", "ID: " .. tostring(EHI:GetBaseUnitID(id, instance_index, continent_index or 100000)) .. "; Element: " .. tostring(element), Color.white)
end

function HUDManager:DebugBaseElement2(base_id, instance_index, continent_index, element, instance_name)
    managers.chat:_receive_message(1, "[EHI]", "Base ID: " .. tostring(EHI:GetBaseUnitID(base_id, instance_index, continent_index or 100000)) .. "; ID: " .. tostring(base_id) .. "; Element: " .. tostring(element) .. "; Instance: " .. tostring(instance_name), Color.white)
end

--[[local animation = { start_t = {}, end_t = {} }
function HUDManager:DebugAnimation(id, type)
    if type == "start" then
        animation.start_t[id] = TimerManager:game():time()
    else -- "end"
        animation.end_t[id] = TimerManager:game():time()
    end
    if animation.start_t[id] and animation.end_t[id] then
        local diff = animation.end_t[id] - animation.start_t[id]
        managers.chat:_receive_message(1, "[EHI]", "Animation: " .. tostring(id) .. "; Time: " .. tostring(diff), Color.white)
        animation.end_t[id] = nil
        animation.start_t[id] = nil
    end
end

local last_id = ""
function HUDManager:DebugAnimation2(id, type)
    if id then
        last_id = id
    end
    self:DebugAnimation(last_id, type)
    if type == "end" then
        last_id = ""
    end
end]]