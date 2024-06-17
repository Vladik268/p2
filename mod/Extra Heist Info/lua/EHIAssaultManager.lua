local EHI = EHI
---@class EHIAssaultManager
EHIAssaultManager = {}
---@param ehi_tracker EHITrackerManager
function EHIAssaultManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._diff = 0
    return self
end

---@param manager EHIManager
function EHIAssaultManager:init_finalize(manager)
    self._internal = manager:CreateAndCopyInternal("assault")
    self._is_skirmish = tweak_data.levels:IsLevelSkirmish()
    local combine = EHI:CombineAssaultDelayAndAssaultTime()
    self._anticipation =
    {
        sync_f = EHI:IsHost() and "SyncAnticipationColor" or "SyncAnticipation",
        t = 30 -- Get it from tweak_data; although `HUDManager:sync_start_anticipation_music()` checks if the time is less than 30s
    }
    self._assault_delay =
    {
        blocked = not (combine or EHI:GetOption("show_assault_delay_tracker")),
        name = combine and "Assault" or "AssaultDelay",
        delete_on_assault = not combine,
        hint = combine and "assault" or "assault_delay"
    }
    self._assault_time =
    {
        blocked = not (combine or EHI:GetOption("show_assault_time_tracker")),
        name = combine and "Assault" or "AssaultTime",
        delete_on_delay = not combine,
        combine_skirmish_remove = combine and self._is_skirmish,
        show_endless_assault = EHI:GetOption("show_endless_assault"),
        hint = combine and "assault" or "assault_time"
    }
    if not self._assault_time.blocked then
        if self._assault_time.show_endless_assault then
            EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode, element_id)
                if self._blocked_wave_mode_elements and self._blocked_wave_mode_elements[element_id] then
                    return
                end
                self._endless_assault = mode == "endless"
                self._trackers:CallFunction(self._assault_time.name, "SetEndlessAssault", self._endless_assault)
            end)
        else
            EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode, element_id)
                if self._blocked_wave_mode_elements and self._blocked_wave_mode_elements[element_id] then
                    return
                elseif mode == "endless" then
                    self._endless_assault = true
                    self._trackers:ForceRemoveTracker(self._assault_time.name)
                else
                    self._endless_assault = nil
                end
            end)
        end
        EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
            if mode == "phalanx" then
                self._trackers:CallFunction(self._assault_time.name, "CaptainArrived")
            else
                self._trackers:CallFunction(self._assault_time.name, "CaptainDefeated")
            end
            self._endless_assault = nil
        end)
        -- Crime Spree
        local _Active = false
        local function ActivateHooks()
            local function f()
                self._trackers:CallFunction(self._assault_time.name, "OnMinionCountChanged")
            end
            EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, f)
            EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, f)
        end
        local function CheckIfModifierIsActive()
            if _Active then
                return
            end
            local tracker = EHIAssaultTracker or {}
            local mod = managers.modifiers
            for category, data in pairs(mod._modifiers) do
                if category == "crime_spree" then
                    for _, modifier in ipairs(data) do
                        if modifier._type == "ModifierAssaultExtender" then
                            tracker._cs_duration = modifier:value("duration") * 0.01
                            tracker._cs_deduction = modifier:value("deduction") * 0.01
                            tracker._cs_max_hostages = modifier:value("max_hostages")
                            tracker._cs_assault_extender = true
                            ActivateHooks()
                            _Active = true
                            break
                        end
                    end
                end
            end
        end
        EHI:AddCallback(EHI.CallbackMessage.Spawned, CheckIfModifierIsActive)
        manager:AddInternalListener("assault", "sustain_t", function(duration)
            self:OnEnterSustain(duration)
        end)
    end
    if EHI:IsHost() then
        ---@class ListenerModifier : BaseModifier
        local ListenerModifier = class(BaseModifier)
        ---@param duration number
        function ListenerModifier:OnEnterSustainPhase(duration)
            manager:NotifyInternalListeners("assault", "sustain_t", duration)
            manager._assault._internal.sustain_app_t = managers.game_play_central:get_heist_timer()
        end
        managers.modifiers:add_modifier(ListenerModifier, "EHI")
    end
    EHI:AddCallback(EHI.CallbackMessage.SyncAssaultDiff, callback(self, self, "SetDiff"))
end

---@param hud HUDManager
function EHIAssaultManager:init_hud(hud)
    self._hud = hud
    self._control_info_f = function(_, data)
        self._trackers:CallFunction(self._assault_delay.name, "SetHostages", data.nr_hostages > 0)
    end
    EHI:HookWithID(hud, "set_control_info", "EHI_Assault_set_control_info", self._control_info_f)
end

---@param params ParseTriggersTable.assault?
function EHIAssaultManager:Parse(params)
    if not params then
        return
    end
    self:SetDiff(params.diff or 0)
    self._force_assault_start = params.force_assault_start
    if params.wave_move_elements_block then
        self._blocked_wave_mode_elements = {}
        for _, element in ipairs(params.wave_move_elements_block) do
            self._blocked_wave_mode_elements[element] = true
        end
    end
    if params.fake_assault_block then
        self._assault_block = true
        EHI:AddOnAlarmCallback(callback(self, self, "SetAssaultBlock", false))
    end
end

---@param diff number
function EHIAssaultManager:SetDiff(diff)
    if self._diff == diff then
        return
    end
    self._diff = diff
    self:CallFunction("UpdateDiff", diff)
end

---@param block boolean
---@param t number
function EHIAssaultManager:SetControlStateBlock(block, t)
    self._control_block = block
    if self._trackers:TrackerExists(self._assault_delay.name) then
        self._trackers:CallFunction(self._assault_delay.name, "SetControlStateBlock", block, t)
    elseif not block then
        self:StartAssaultCountdown(t, true)
    end
end

---@param t number
---@param block_if_exists boolean?
function EHIAssaultManager:StartAssaultCountdown(t, block_if_exists)
    if self._assault_delay.blocked or self._control_block or self._internal.is_assault then
        return
    end
    if block_if_exists and self._trackers:TrackerExists(self._assault_delay.name) then
        return
    end
    self._trackers:AddTracker({
        id = self._assault_delay.name,
        time = t,
        diff_visual = self._diff,
        hint = self._assault_delay.hint,
        class = EHI.Trackers.Assault
    }, 0)
end

---@param t number
function EHIAssaultManager:AnticipationStartHost(t)
    self._trackers:CallFunction(self._assault_delay.name, "StartAnticipation", t)
end

function EHIAssaultManager:AnticipationStart()
    if self._assault_delay.blocked then
        return
    end
    self._trackers:CallFunction(self._assault_delay.name, self._anticipation.sync_f, self._anticipation.t)
    EHI:Unhook("Assault_set_control_info")
end

function EHIAssaultManager:AssaultStart()
    EHI:Unhook("Assault_set_control_info")
    if self._assault_delay.delete_on_assault then
        self._trackers:ForceRemoveTracker(self._assault_delay.name)
    end
    if self._assault_time.blocked or (self._endless_assault and not self._assault_time.show_endless_assault) or self._internal.is_assault or self._assault_block then
        self._internal.is_assault = true
        if self._force_assault_start and not self._endless_assault then
            self._trackers:CallFunction(self._assault_time.name, "AssaultStart", self._diff)
        end
        return
    elseif self._trackers:TrackerExists(self._assault_time.name) then
        if self._endless_assault then
            self._trackers:CallFunction(self._assault_time.name, "CalculateDifficultyRamp", self._diff)
            self._trackers:CallFunction(self._assault_time.name, "SetEndlessAssault", true)
        else
            self._trackers:CallFunction(self._assault_time.name, "AssaultStart", self._diff)
        end
    elseif self._diff > 0 or self._is_skirmish then
        self._trackers:AddTracker({
            id = self._assault_time.name,
            assault = true,
            diff = self._diff,
            endless_assault = self._endless_assault,
            hint = self._assault_time.hint,
            class = EHI.Trackers.Assault
        }, 0)
    end
    self._internal.is_assault = true
end

function EHIAssaultManager:AssaultEnd()
    self._internal.is_assault = false
    if self._assault_time.combine_skirmish_remove or self._assault_time.delete_on_delay or self._endless_assault then
        self._trackers:ForceRemoveTracker(self._assault_time.name)
    end
    if self._assault_block or self._assault_delay.blocked then
        return
    elseif self._trackers:TrackerExists(self._assault_delay.name) and not self._assault_delay.delete_on_assault then
        local f = self._control_block and "AssaultEndWithBlock" or "AssaultEnd"
        self._trackers:CallFunction(self._assault_delay.name, f, self._diff)
    elseif self._diff > 0 and not self._control_block then
        self._trackers:AddTracker({
            id = self._assault_delay.name,
            diff = self._diff,
            hint = self._assault_delay.hint,
            class = EHI.Trackers.Assault
        }, 0)
    end
    EHI:HookWithID(self._hud, "set_control_info", "EHI_Assault_set_control_info", self._control_info_f)
end

---@param t number
function EHIAssaultManager:OnEnterSustain(t)
    self._trackers:CallFunction(self._assault_time.name, "OnEnterSustain", t)
end

---@param block boolean?
function EHIAssaultManager:SetAssaultBlock(block)
    self._assault_block = block
    if block then
        self:CallFunction("PoliceActivityBlocked")
    end
end

---@param f string
function EHIAssaultManager:CallFunction(f, ...)
    self._trackers:CallFunction("Assault", f, ...)
    self._trackers:CallFunction("AssaultDelay", f, ...)
    self._trackers:CallFunction("AssaultTime", f, ...)
end

function EHIAssaultManager:SetEndlessAssaultFromLoad()
    EHI:CallCallback(EHI.CallbackMessage.AssaultWaveModeChanged, "endless")
end

function EHIAssaultManager:TrackerExists()
    return self._trackers:TrackerExists("Assault") or self._trackers:TrackerExists("AssaultDelay") or self._trackers:TrackerExists("AssaultTime")
end

function EHIAssaultManager:save(data)
    local state = {}
    state.diff = self._diff
    data.EHIAssaultManager = state
end

function EHIAssaultManager:load(data)
    local state = data.EHIAssaultManager
    if state then
        self._diff = state.diff
    end
end