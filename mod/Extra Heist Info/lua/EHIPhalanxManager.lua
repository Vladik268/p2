local EHI = EHI
---@class EHIPhalanxManager
EHIPhalanxManager = {}
EHIPhalanxManager._requires_manual_on_exec = { dinner = true }
EHIPhalanxManager._disabled_in_levels = { born = true }
EHIPhalanxManager._counter_trigger = 2
EHIPhalanxManager._first_assault = true
---@param manager EHIManager
function EHIPhalanxManager:init_finalize(manager)
    self._manager = manager
    self._trackers = manager._trackers
    if EHI:IsHost() and EHI:GetOptionAndLoadTracker("show_captain_spawn_chance") then
        self._tracker_enabled = true
        self._phalanx_spawn_chance = tweak_data.group_ai.phalanx.spawn_chance or {}
        self._phalanx_spawn_time_check = tweak_data.group_ai.phalanx.check_spawn_intervall or 120
    end
end

---@param element ElementSpecialObjective
function EHIPhalanxManager:OnSOPhalanxCreated(element)
    local level_id = Global.game_settings.level_id
    if self._disabled_in_levels[level_id] then
        return
    elseif self._requires_manual_on_exec[level_id] then
        self._manager:HookElement(element, function(e, ...)
            if EHI:IsHost() and not e._values.enabled then
                return
            end
            self:OnPhalanxAdded(true)
        end)
    else
        self:OnPhalanxAdded()
    end
end

---@param manual boolean?
function EHIPhalanxManager:OnPhalanxAdded(manual)
    if self._so_phalanx or tweak_data.levels:IsLevelSkirmish() then
        return
    end
    self._so_phalanx = true
    if self._alarm and manual then
        self._first_assault = false
        self:ReduceCounter() -- Reduce the counter because Captain Winters is activated now; due to Mission Script
    end
    self:ReduceCounter()
end

---@param dropin boolean
function EHIPhalanxManager:SwitchToLoudMode(dropin)
    if self._alarm or not self._tracker_enabled or dropin then
        self._alarm = true
        return
    end
    self._alarm = true
    self:ReduceCounter()
end

function EHIPhalanxManager:ReduceCounter()
    if self._counter_trigger <= 0 then
        return
    end
    self._counter_trigger = self._counter_trigger - 1
    if self._counter_trigger == 0 then
        self:AddTracker()
    end
end

function EHIPhalanxManager:AddTracker()
    if self:IsPhalanxDisabled() or self._tracker_created then
        return
    end
    self._tracker_created = true
    self._trackers:AddTracker({
        id = "CaptainChance",
        time = self._phalanx_spawn_time_check,
        chance = self._phalanx_spawn_chance.start * 100,
        chance_increase = self._phalanx_spawn_chance.increase * 100,
        first_assault = self._first_assault,
        class = "EHIPhalanxChanceTracker"
    })
    EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
        if mode == "phalanx" then
            self._trackers:ForceRemoveTracker("CaptainChance")
        end
    end)
    if EHI:IsHost() then
        self._manager:AddInternalListener("assault", "sustain_t", function(duration)
            self._trackers:CallFunction("CaptainChance", "OnEnterSustain", duration)
        end)
    end
    EHI:HookWithID(HUDManager, "sync_start_assault", "EHI_PhalanxManager_sync_start_assault", function(...)
        self._trackers:CallFunction("CaptainChance", "AssaultStart")
    end)
    EHI:HookWithID(HUDManager, "sync_end_assault", "EHI_PhalanxManager_sync_end_assault", function(...)
        self._trackers:CallFunction("CaptainChance", "AssaultEnd")
    end)
    EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode)
        self._trackers:CallFunction("CaptainChance", "SetEndlessAssault", mode == "endless")
    end)
end

if EHI:IsModInstalled("Allow Winters Spawn Offline", "Offyerrocker") then
    function EHIPhalanxManager:IsPhalanxDisabled()
        return self._phalanx_spawn_chance.max == 0
    end
else
    function EHIPhalanxManager:IsPhalanxDisabled()
        return Global.game_settings.single_player or self._phalanx_spawn_chance.max == 0
    end
end