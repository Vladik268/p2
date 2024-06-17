local EHI = EHI
---@class EHIManager : EHIBaseManager
---@field new fun(self: self, managers: managers): self
---@field FormatTimer fun(self: self, t: number): string
EHIManager = class(EHIBaseManager)
EHIManager._element_hook_function = EHI:IsClient() and EHI.ClientElement or EHI.HostElement
EHIManager.Trackers = EHI.Trackers
EHIManager.Waypoints = EHI.Waypoints
EHIManager.FilterTracker =
{
    show_timers =
    {
        waypoint = "show_waypoints_timers",
        table_name = "Timer"
    }
}
EHIManager.ConditionFunctions = EHI.ConditionFunctions
EHIManager.SFF = {}
EHIManager._cache = {}
EHIManager._internal = {}
EHIManager._internal_listeners = {}
EHIManager._sync_tracker = "EHISyncAddTracker"
---@param managers managers
function EHIManager:init(managers)
    self._trackers = managers.ehi_tracker
    self._waypoints = managers.ehi_waypoint
    self._buff = managers.ehi_buff
    self._escape = managers.ehi_escape
    self._deployable = managers.ehi_deployable
    self._achievements = managers.ehi_achievement
    self._experience = managers.ehi_experience
    self._assault = managers.ehi_assault
    self._phalanx = managers.ehi_phalanx
    self._timer = managers.ehi_timer
    self._loot = managers.ehi_loot
    self._level_started_from_beginning = true
    self._t = 0
    self.TrackerWaypointsClass =
    {
        [self.Trackers.Pausable] = self.Waypoints.Pausable,
        [self.Trackers.Progress] = self.Waypoints.Progress,
        [self.Trackers.Warning] = self.Waypoints.Warning,
        [self.Trackers.Inaccurate] = self.Waypoints.Inaccurate,
        [self.Trackers.InaccuratePausable] = self.Waypoints.InaccuratePausable,
        [self.Trackers.InaccurateWarning] = self.Waypoints.InaccurateWarning,
        [self.Trackers.Group.Warning] = self.Waypoints.Warning
    }
    self.TrackerToInaccurate =
    {
        [self.Trackers.Base] = self.Trackers.Inaccurate,
        [self.Trackers.Pausable] = self.Trackers.InaccuratePausable,
        [self.Trackers.Warning] = self.Trackers.InaccurateWarning
    }
    self.WaypointToInaccurate =
    {
        [self.Waypoints.Base] = self.Waypoints.Inaccurate,
        [self.Waypoints.Pausable] = self.Waypoints.InaccuratePausable,
        [self.Waypoints.Warning] = self.Waypoints.InaccurateWarning
    }
    self.WaypointIconRedirect =
    {
        [EHI.Icons.Heli] = "EHI_Heli"
    }
    local SF = EHI.SpecialFunctions
    self.TriggerFunction =
    {
        [SF.TriggerIfEnabled] = true,
        [SF.Trigger] = true
    }
    self.SyncFunctions =
    {
        [SF.GetElementTimerAccurate] = true,
        [SF.UnpauseTrackerIfExistsAccurate] = true
    }
    self.ClientSyncFunctions =
    {
        [SF.GetElementTimerAccurate] = true,
        [SF.UnpauseTrackerIfExistsAccurate] = true
    }
    self.GroupingTrackers =
    {
        [self.Trackers.Group.Warning] = true
    }
    if EHI:IsClient() then
        self.HookOnLoad = {}
    end
    self:_post_init()
end

function EHIManager:_post_init()
    self._phalanx:init_finalize(self)
end

function EHIManager:init_finalize()
    self._trackers:init_finalize(self)
    self._assault:init_finalize(self)
    self._loot:init_finalize()
    EHI:AddOnAlarmCallback(callback(self, self, "SwitchToLoudMode"))
    EHI:AddOnCustodyCallback(callback(self, self, "SetCustodyState"))
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "Spawned"))
    managers.network:add_event_listener("EHIManagerDropIn", "on_set_dropin", callback(self, self, "DisableStartFromBeginning"))
    if EHI:IsClient() then
        self:AddReceiveHook(self._sync_tracker, callback(self, self, "SyncAddTracker"))
    end
end

function EHIManager:SyncAddTracker(data, sender)
    local tbl = json.decode(data)
    self:AddTrackerSynced(tbl.id, tbl.delay)
end

---@param name string
function EHIManager:CreateInternal(name)
    self._internal[name] = {}
end

---@param name string
---@return table
function EHIManager:CreateAndCopyInternal(name)
    self:CreateInternal(name)
    return self._internal[name]
end

---@param name string
---@param data_name string
function EHIManager:SaveInternalData(name, data_name, value)
    if not self._internal[name] then
        return
    end
    self._internal[name][data_name] = value
end

---@param name string
---@param data_name string
function EHIManager:GetInternalData(name, data_name)
    local tbl = self._internal[name] or {}
    return tbl[data_name]
end

---@param name string
---@param data_name string
function EHIManager:NotifyInternalListeners(name, data_name, value)
    self:SaveInternalData(name, data_name, value)
    for key, tbl in pairs(self._internal_listeners[name] or {}) do
        if key == data_name then
            for _, f in ipairs(tbl) do
                f(value)
            end
            break
        end
    end
end

---@param name string
---@param data_name string
---@param f function
function EHIManager:AddInternalListener(name, data_name, f)
    local tbl = self._internal_listeners[name]
    if tbl then
        local tbl_name = tbl[data_name]
        if tbl_name then
            table.insert(tbl_name, f)
        else
            tbl[data_name] = { f }
        end
    else
        self._internal_listeners[name] = { [data_name] = { f } }
    end
end

---@param state boolean
function EHIManager:SetCustodyState(state)
    self._trackers:OnPlayerCustody(state)
    self._buff:SetCustodyState(state)
    self._experience:SetInCustody(state)
end

---@param dropin boolean
function EHIManager:SwitchToLoudMode(dropin)
    self._trackers:SwitchToLoudMode()
    self._waypoints:SwitchToLoudMode()
    self._buff:SwitchToLoudMode()
    self._deployable:SwitchToLoudMode()
    self._experience:SwitchToLoudMode()
    self._phalanx:SwitchToLoudMode(dropin)
end

function EHIManager:Spawned()
    self._trackers:Spawned()
    self._deployable:DisableGrenades()
    self._buff:ActivateUpdatingBuffs()
    self._loot:Spawned()
end

---@param tweak_data string
---@return boolean
function EHIManager:InteractionExists(tweak_data)
    local interactions = managers.interaction._interactive_units
    for _, unit in ipairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            return true
        end
    end
    return false
end

---@param data table
function EHIManager:load(data)
    local state = data.EHIManager
    if state and state.SyncedSFF then
        for key, value in pairs(state.SyncedSFF) do
            self.SyncedSFF[key] = value
        end
    end
    self:SyncLoad() -- Add missing positions from elements and remove waypoints
    self:LoadSync() -- Run LoadSync functions
    self:SetInSync(false)
end

---@param data table
function EHIManager:save(data)
    if self.SyncedSFF and next(self.SyncedSFF) then
        local state = {}
        state.SyncedSFF = {}
        for key, value in pairs(self.SyncedSFF) do
            state.SyncedSFF[key] = value
        end
        data.EHIManager = state
    end
end

---@param t number
function EHIManager:LoadTime(t)
    self._t = t
    self._trackers:LoadTime(t)
end

---@param state boolean
function EHIManager:SetInSync(state)
    self._syncing = state
end

---@return boolean
function EHIManager:GetInSyncState()
    return self._syncing
end

---@param id number
---@return boolean?
function EHIManager:IsMissionElementEnabled(id)
    local element = managers.mission:get_element_by_id(id)
    return element and element:enabled()
end

---@param id number
---@return boolean
function EHIManager:IsMissionElementDisabled(id)
    return not self:IsMissionElementEnabled(id)
end

---@param tweak_data string
---@return integer
function EHIManager:CountInteractionAvailable(tweak_data)
    local count = 0
    local interactions = managers.interaction._interactive_units
    for _, unit in ipairs(interactions) do
        if unit:interaction().tweak_data == tweak_data then
            count = count + 1
        end
    end
    return count
end

---@param offset integer?
---@return integer
function EHIManager:CountLootbagsOnTheGround(offset)
    local lootbags = {}
    local excluded = { value_multiplier = true, dye = true, types = true, small_loot = true }
    for key, data in pairs(tweak_data.carry) do
        if not (excluded[key] or data.is_unique_loot or data.skip_exit_secure) then
            lootbags[key] = true
        end
    end
    local count = 0 - (offset or 0)
    local interactions = managers.interaction._interactive_units ---@cast interactions UnitCarry[]
    for _, unit in ipairs(interactions) do
        if unit:carry_data() and lootbags[unit:carry_data():carry_id()] then
            count = count + 1
        end
    end
    return count
end

---@param path string
---@param slotmask integer
---@return integer
function EHIManager:CountUnitsAvailable(path, slotmask)
    local _, n = self:GetUnits(path, slotmask)
    return n - 1
end

---@param path string
---@param slotmask integer
function EHIManager:GetUnits(path, slotmask)
    local tbl = {}
    local tbl_i = 1
    local idstring = Idstring(path)
    local units = World:find_units_quick("all", slotmask)
    for _, unit in ipairs(units) do
        if unit and unit:name() == idstring then
            tbl[tbl_i] = unit
            tbl_i = tbl_i + 1
        end
    end
    return tbl, tbl_i
end

---@param id number Element ID
---@return Vector3?
function EHIManager:GetElementPosition(id)
    local element = managers.mission:get_element_by_id(id)
    return element and element:value("position")
end

---@param id number Element ID
function EHIManager:GetElementPositionOrDefault(id)
    return self:GetElementPosition(id) or Vector3()
end

---@param id number Unit ID
---@return Vector3?
function EHIManager:GetUnitPosition(id)
    local unit = managers.worlddefinition:get_unit(id)
    return unit and unit.position and unit:position()
end

---@param id number Unit ID
function EHIManager:GetUnitPositionOrDefault(id)
    return self:GetUnitPosition(id) or Vector3()
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHIManager:AddPositionFromElement(data, id, check)
    local vector = self:GetElementPosition(data.position_by_element)
    if vector then
        data.position = vector
        data.position_by_element = nil
    elseif check then
        data.position = Vector3()
        EHI:Log(string.format("Element with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_by_element, tostring(id)))
    end
end

---@param data ElementWaypointTrigger
---@param id number|string
---@param check boolean?
function EHIManager:AddPositionFromUnit(data, id, check)
    local vector = self:GetUnitPosition(data.position_by_unit)
    if vector then
        data.position = vector
        data.position_by_unit = nil
    elseif check then
        data.position = Vector3()
        EHI:Log(string.format("Unit with ID '%d' has not been found. Element ID to hook '%s'. Position vector set to default value to avoid crashing.", data.position_by_unit, tostring(id)))
    end
end

---@param f fun(self: EHIManager)
function EHIManager:AddLoadSyncFunction(f)
    if EHI:IsHost() then
        return
    end
    self._load_sync = self._load_sync or {}
    self._load_sync[#self._load_sync + 1] = f
end

---@param f fun(self: EHIManager)
function EHIManager:AddFullSyncFunction(f)
    if EHI:IsHost() then
        return
    end
    self._full_sync = self._full_sync or {}
    self._full_sync[#self._full_sync + 1] = f
end

function EHIManager:LoadSync()
    if self._level_started_from_beginning then
        for _, f in ipairs(self._full_sync or {}) do
            f(self)
        end
    else
        for _, f in ipairs(self._load_sync or {}) do
            f(self)
        end
    end
    -- Clear used memory
    self._full_sync = nil
    self._load_sync = nil
end

function EHIManager:DisableStartFromBeginning()
    self._level_started_from_beginning = false
end

function EHIManager:GetStartedFromBeginning()
    return self._level_started_from_beginning
end

function EHIManager:GetDropin()
    return not self:GetStartedFromBeginning()
end

---@param dt number
function EHIManager:update(t, dt)
    self._trackers:update(nil, dt)
    self._waypoints:update(dt)
end

---@param t number
function EHIManager:update_client(t)
    local dt = t - self._t
    self._t = t
    self:update(nil, dt)
end

---@param id string
---@param new_id string
function EHIManager:UpdateID(id, new_id)
    self._trackers:UpdateTrackerID(id, new_id)
    self._waypoints:UpdateWaypointID(id, new_id)
end

---@param id string
function EHIManager:Exists(id)
    return self._trackers:TrackerExists(id) or self._waypoints:WaypointExists(id)
end

---@param id string
function EHIManager:DoesNotExist(id)
    return not self:Exists(id)
end

---@param id string
function EHIManager:Remove(id)
    self._trackers:RemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

---@param timer_id string
---@param unit_id string
---@param remove boolean?
function EHIManager:RemoveUnit(timer_id, unit_id, remove)
    self._trackers:CallFunction(timer_id, remove and "RemoveUnit" or "RemoveByID", unit_id)
    self._waypoints:RemoveWaypoint(unit_id)
end

---@param id string
function EHIManager:ForceRemove(id)
    self._trackers:ForceRemoveTracker(id)
    self._waypoints:RemoveWaypoint(id)
end

---@param id string
---@param pause boolean
function EHIManager:SetPaused(id, pause)
    self._trackers:SetTrackerPaused(id, pause)
    self._waypoints:SetWaypointPause(id, pause)
end

---@param id string
function EHIManager:Pause(id)
    self:SetPaused(id, true)
end

---@param id string
function EHIManager:Unpause(id)
    self:SetPaused(id, false)
end

---@param id string
---@param t number
function EHIManager:SetAccurate(id, t)
    self._trackers:SetTrackerAccurate(id, t)
    self._waypoints:SetWaypointAccurate(id, t)
end

---@param id string
---@param icon string
function EHIManager:SetIcon(id, icon)
    self._trackers:SetTrackerIcon(id, icon)
    self._waypoints:SetWaypointIcon(id, icon)
end

---@param id string
---@param jammed boolean
function EHIManager:SetTimerJammed(id, jammed)
    self._timer:SetTimerJammed(id, jammed)
    self._waypoints:SetTimerWaypointJammed(id, jammed)
end

---@param id string
---@param powered boolean
function EHIManager:SetTimerPowered(id, powered)
    self._timer:SetTimerPowered(id, powered)
    self._waypoints:SetTimerWaypointPowered(id, powered)
end

---@param id string
function EHIManager:SetTimerRunning(id)
    self._timer:SetTimerRunning(id)
    self._waypoints:SetTimerWaypointRunning(id)
end

---@param id string
---@param state boolean
function EHIManager:SetTimerAutorepair(id, state)
    self._timer:SetTimerAutorepair(id, state)
    self._waypoints:CallFunction(id, "SetAutorepair", state)
end

---@param id string
---@return boolean
function EHIManager:IsTimerMergeRunning(id)
    return self._timer:IsTimerMergeRunning(id) or self._waypoints:WaypointExists(id)
end

function EHIManager:TimerExists(id)
    return self._timer:TimerExists(id) or self._waypoints:WaypointExists(id)
end

function EHIManager:RemoveTimer(id)
    self._timer:StopTimer(id)
    self._waypoints:RemoveWaypoint(id)
end

---@param id string
---@param t number
function EHIManager:SetTime(id, t)
    self._trackers:SetTrackerTime(id, t)
    self._waypoints:SetWaypointTime(id, t)
end

---@param id string
---@param t number
function EHIManager:SetTimeNoAnim(id, t)
    self._trackers:SetTrackerTimeNoAnim(id, t)
    self._waypoints:SetWaypointTime(id, t)
end

---@param id string
function EHIManager:IncreaseProgress(id)
    self._trackers:IncreaseTrackerProgress(id)
    self._waypoints:IncreaseWaypointProgress(id)
end

---@param id string
---@param f string
function EHIManager:Call(id, f, ...)
    self._trackers:CallFunction(id, f, ...)
    self._waypoints:CallFunction(id, f, ...)
end

function EHIManager:destroy()
    self._trackers:destroy()
    self._waypoints:destroy()
end

---------------------------------
local SF = EHI.SpecialFunctions
---@type table<number, ElementTrigger?>
local triggers = {}
---@type table<number, ElementTrigger>
local host_triggers, base_delay_triggers, element_delay_triggers = nil, nil, nil
---Adds trigger to mission element when they run
---@param new_triggers table<number, ElementTrigger>
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHIManager:AddTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for key, value in pairs(new_triggers) do
        if triggers[key] then
            EHI:Log("key: " .. tostring(key) .. " already exists in triggers!")
        else
            triggers[key] = value
            if not value.id then
                triggers[key].id = trigger_id_all
            end
            if not value.icons and not value.run then
                triggers[key].icons = trigger_icons_all
            end
        end
    end
end

---Adds trigger to mission element when they run. If trigger already exists, it is moved and added into table
---@param new_triggers table<number, ElementTrigger>
---@param params table?
---@param trigger_id_all string
---@param trigger_icons_all table?
function EHIManager:AddTriggers2(new_triggers, params, trigger_id_all, trigger_icons_all)
    local function FillRestOfProperties(key, value)
        if not value.id then
            triggers[key].id = trigger_id_all
        end
        if not value.icons and not value.run then
            triggers[key].icons = trigger_icons_all
        end
    end
    for key, value in pairs(new_triggers) do
        local t = triggers[key]
        if t then
            if t.special_function and self.TriggerFunction[t.special_function] then
                if value.special_function and self.TriggerFunction[value.special_function] then
                    if t.data then
                        local data = value.data or {}
                        for i = 1, #data, 1 do
                            t.data[#t.data + 1] = data[i]
                        end
                    else
                        EHI:Log("key: " .. tostring(key) .. " does not have 'data' table, new triggers won't be added!")
                    end
                elseif t.data then
                    local new_key = (key * 10) + 1
                    while triggers[new_key] do
                        new_key = new_key + 1
                    end
                    triggers[new_key] = value
                    FillRestOfProperties(new_key, value)
                    t.data[#t.data + 1] = new_key
                else
                    EHI:Log("key: " .. tostring(key) .. " does not have 'data' table, the trigger " .. tostring(new_key) .. " will not be called!")
                end
            elseif value.special_function and self.TriggerFunction[value.special_function] then
                if value.data then
                    local new_key = (key * 10) + 1
                    while table.get_vector_index(value.data, new_key) or new_triggers[new_key] or triggers[new_key] do
                        new_key = new_key + 1
                    end
                    triggers[new_key] = t
                    triggers[key] = value
                    FillRestOfProperties(key, value)
                    value.data[#value.data + 1] = new_key
                else
                    EHI:Log("key: " .. tostring(key) .. " with ID: " .. tostring(value.id) .. " does not have 'data' table, the former trigger won't be moved and triggers assigned to this one will not be called!")
                end
            else
                local new_key = (key * 10) + 1
                local key2 = new_key + 1
                triggers[key] = { special_function = params and params.SF or SF.Trigger, data = { new_key, key2 } }
                triggers[new_key] = t
                triggers[key2] = value
                FillRestOfProperties(key2, value)
            end
        else
            triggers[key] = value
            FillRestOfProperties(key, value)
        end
    end
end

---@param type
---|"base" # Random delay is defined in the BASE DELAY
---|"element" # Random delay is defined when calling the elements
---@param new_triggers table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:_add_host_triggers(type, new_triggers, trigger_id_all, trigger_icons_all)
    if EHI:IsClient() then
        return
    end
    host_triggers = host_triggers or {}
    for key, value in pairs(new_triggers) do
        if host_triggers[key] then
            EHI:Log("key: " .. tostring(key) .. " already exists in host triggers!")
        else
            host_triggers[key] = value
            if not value.id then
                host_triggers[key].id = trigger_id_all --[[@as string]]
            end
            if not value.icons then
                host_triggers[key].icons = trigger_icons_all
            end
        end
        if type == "base" then
            base_delay_triggers = base_delay_triggers or {}
            if base_delay_triggers[key] then
                EHI:Log("key: " .. tostring(key) .. " already exists in host base delay triggers!")
            else
                base_delay_triggers[key] = true
            end
        elseif value.hook_element or value.hook_elements then
            element_delay_triggers = element_delay_triggers or {}
            if value.hook_element then
                element_delay_triggers[value.hook_element] = element_delay_triggers[value.hook_element] or {}
                element_delay_triggers[value.hook_element][key] = true
            else
                for _, element in pairs(value.hook_elements) do
                    element_delay_triggers[element] = element_delay_triggers[element] or {}
                    element_delay_triggers[element][key] = true
                end
            end
        else
            EHI:Log("key: " .. tostring(key) .. " does not have element to hook!")
        end
    end
end

---@param new_triggers ParseTriggersTable
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:ParseTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    new_triggers = new_triggers or {}
    if new_triggers.pre_parse and new_triggers.pre_parse.filter_out_not_loaded_trackers then
        local filter = new_triggers.pre_parse.filter_out_not_loaded_trackers
        if type(filter) == "string" then
            self:FilterOutNotLoadedTrackers(new_triggers.mission, filter)
        else
            for _, option in ipairs(filter) do
                self:FilterOutNotLoadedTrackers(new_triggers.mission, option)
            end
        end
    end
    if new_triggers.sync_triggers then
        local host = EHI:IsHost()
        for key, tbl in pairs(new_triggers.sync_triggers) do
            if host then
                self:_add_host_triggers(key, tbl)
            else
                self:_set_sync_triggers(tbl)
            end
        end
    end
    self._assault:Parse(new_triggers.assault)
    self:PreloadTrackers(new_triggers.preload or {}, trigger_id_all or "Trigger", trigger_icons_all or {})
    ---@param data ParseAchievementDefinitionTable
    ---@param id string
    local function ParseParams(data, id)
        if type(data.alarm_callback) == "function" then
            EHI:AddOnAlarmCallback(data.alarm_callback)
        end
        if type(data.load_sync) == "function" then
            self:AddLoadSyncFunction(data.load_sync)
        end
        if data.failed_on_alarm then
            EHI:AddOnAlarmCallback(function()
                self._achievements:SetAchievementFailed(id)
            end)
        end
        if data.mission_end_callback then
            EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                if success then
                    self._achievements:SetAchievementComplete(id, true)
                else
                    self._achievements:SetAchievementFailed(id)
                end
            end)
        end
        if type(data.parsed_callback) == "function" then
            data.parsed_callback()
            data.parsed_callback = nil
        end
    end
    ---@param data ParseAchievementDefinitionTable
    local function PreparseParams(data)
        if type(data.preparse_callback) == "function" then
            data.preparse_callback(data)
            data.preparse_callback = nil
        end
    end
    local function Cleanup(data)
        for _, element in pairs(data.elements or {}) do
            if element.special_function and element.special_function > SF.CustomSF then
                self:UnregisterCustomSF(element.special_function)
            end
        end
        if type(data.cleanup_callback) == "function" then
            data.cleanup_callback()
        end
    end
    self:ParseOtherTriggers(new_triggers.other or {}, trigger_id_all or "Trigger", trigger_icons_all)
    local trophy = new_triggers.trophy or {}
    if next(trophy) then
        if EHI:GetUnlockableAndOption("show_trophies") then
            for id, data in pairs(trophy) do
                if data.difficulty_pass ~= false and EHI:IsTrophyLocked(id) then
                    PreparseParams(data)
                    for _, element in pairs(data.elements or {}) do
                        if element.class and not element.icons then
                            element.icons = { EHI.Icons.Trophy }
                        end
                    end
                    self:AddTriggers2(data.elements or {}, nil, id)
                    ParseParams(data, id)
                end
            end
        else
            for _, data in pairs(trophy) do
                Cleanup(data)
            end
        end
    end
    local sidejob = new_triggers.sidejob or {}
    if next(sidejob) then
        if EHI:GetUnlockableAndOption("show_dailies") then
            for id, data in pairs(sidejob) do
                if data.difficulty_pass ~= false and EHI:IsSHSideJobAvailable(id) then
                    PreparseParams(data)
                    for _, element in pairs(data.elements or {}) do
                        if element.class and not element.icons then
                            element.icons = { EHI.Icons.Trophy }
                        end
                    end
                    self:AddTriggers2(data.elements or {}, nil, id)
                    ParseParams(data, id)
                else
                    Cleanup(data)
                end
            end
        else
            for _, data in pairs(sidejob) do
                Cleanup(data)
            end
        end
    end
    local achievement_triggers = new_triggers.achievement or {}
    if next(achievement_triggers) then
        self._achievements:ParseAchievementDefinition(achievement_triggers)
        if EHI:ShowMissionAchievements() then
            ---@param data ParseAchievementDefinitionTable
            ---@param id string
            local function Parser(data, id)
                PreparseParams(data)
                for _, element in pairs(data.elements or {}) do
                    if element.class then
                        element.beardlib = data.beardlib
                        if not element.icons then
                            if data.beardlib then
                                element.icons = { "ehi_" .. id }
                            else
                                element.icons = EHI:GetAchievementIcon(id)
                            end
                        end
                    end
                end
                self:AddTriggers2(data.elements or {}, nil, id)
                ParseParams(data, id)
            end
            local function IsAchievementLocked(data, id)
                if data.beardlib then
                    return not EHI:IsBeardLibAchievementUnlocked(data.package, id)
                else
                    return EHI:IsAchievementLocked(id)
                end
            end
            for id, data in pairs(achievement_triggers) do
                if data.difficulty_pass ~= false and IsAchievementLocked(data, id) then
                    Parser(data, id)
                else
                    Cleanup(data)
                end
            end
        else
            for _, data in pairs(achievement_triggers) do
                Cleanup(data)
            end
        end
    end
    self:ParseMissionTriggers(new_triggers.mission or {}, trigger_id_all, trigger_icons_all)
end

---@param new_triggers table<number, ElementTrigger>
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:ParseOtherTriggers(new_triggers, trigger_id_all, trigger_icons_all)
    for id, data in pairs(new_triggers) do
        -- Don't bother with trackers that have "condition" set to false, they will never run and just occupy memory for no reason
        -- Unregister custom special function if it is there
        if data.condition == false then
            if data.special_function and data.special_function > SF.CustomSF then
                self:UnregisterCustomSF(data.special_function)
            end
            new_triggers[id] = nil
        elseif data.special_function == SF.ShowWaypoint and data.data then
            self:_parse_vanilla_waypoint_trigger(data) -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
        end
    end
    self:AddTriggers(new_triggers, trigger_id_all or "Trigger", trigger_icons_all)
end

---@param new_triggers table<number, ElementTrigger>
---@param trigger_id_all string?
---@param trigger_icons_all table?
---@param no_host_override boolean?
function EHIManager:ParseMissionTriggers(new_triggers, trigger_id_all, trigger_icons_all, no_host_override)
    if not EHI:GetOption("show_mission_trackers") then
        for id, data in pairs(new_triggers) do
            if data.special_function then
                if self.SyncFunctions[data.special_function] then
                    self:AddTriggers2({ [id] = data }, nil, trigger_id_all or "Trigger", trigger_icons_all)
                elseif data.special_function > SF.CustomSF then
                    self:UnregisterCustomSF(data.special_function)
                end
            end
        end
        return
    end
    local host = EHI:IsHost()
    if no_host_override then
        host = false
    end
    local configure_waypoints = EHI:GetOption("show_waypoints_mission")
    for id, data in pairs(new_triggers) do
        -- Don't bother with trackers that have "condition" set to false, they will never run and just occupy memory for no reason
        -- Unregister custom special function if it is there
        if data.condition == false then
            if data.special_function and data.special_function > SF.CustomSF then
                self:UnregisterCustomSF(data.special_function)
            end
            new_triggers[id] = nil
        else
            data.condition = nil
            -- Mark every tracker, that has random time, as inaccurate
            if data.random_time then
                data.class = self.TrackerToInaccurate[data.class or self.Trackers.Base]
                if not data.class then
                    EHI:Log(string.format("Trigger %d with random time is using unknown tracker! Tracker class has been set to %s", id, self.Trackers.Inaccurate))
                    data.class = self.Trackers.Inaccurate
                end
            end
            -- Fill the rest table properties for Waypoints (Vanilla settings in ElementWaypoint)
            if data.special_function == SF.ShowWaypoint and data.data then
                self:_parse_vanilla_waypoint_trigger(data)
            -- Fill the rest table properties if SF.SetRandomTime is provided
            elseif data.special_function == SF.SetRandomTime then
                data.class = self.Trackers.Inaccurate
            end
            -- Fill the rest table properties for EHI Waypoints
            if configure_waypoints then
                if data.waypoint then
                    data.waypoint.class = data.waypoint.class or self.TrackerWaypointsClass[data.class or ""]
                    data.waypoint.time = data.waypoint.time or data.time
                    data.waypoint.remove_on_alarm = data.remove_on_alarm
                    if not data.waypoint.icon then
                        local icon
                        if data.icons then
                            icon = data.icons[1] and data.icons[1].icon or data.icons[1]
                        elseif trigger_icons_all then
                            icon = trigger_icons_all[1] and trigger_icons_all[1].icon or trigger_icons_all[1]
                        end
                        if icon then
                            data.waypoint.icon = self.WaypointIconRedirect[icon] or icon
                        end
                    end
                    if data.waypoint.position_by_element_and_remove_vanilla_waypoint then
                        local wp_id = data.waypoint.position_by_element_and_remove_vanilla_waypoint
                        data.waypoint.position_by_element = wp_id
                        data.waypoint.remove_vanilla_waypoint = wp_id
                        data.waypoint.position_by_element_and_remove_vanilla_waypoint = nil
                    end
                    if data.waypoint.position_by_element then
                        self:AddPositionFromElement(data.waypoint, data.id, host)
                    elseif data.waypoint.position_by_unit then
                        self:AddPositionFromUnit(data.waypoint, data.id, host)
                    end
                end
            else
                data.waypoint = nil
                data.waypoint_f = nil
            end
            if data.class and self.GroupingTrackers[data.class] then
                data.tracker_group = true
            end
            if data.client and self.ClientSyncFunctions[data.special_function or 0] then
                data.additional_time = (data.additional_time or 0) + data.client.time
                data.random_time = data.client.random_time
                data.delay_only = true
                if data.class then
                    data.synced = { class = data.class }
                end
                data.class = self.TrackerToInaccurate[data.class or self.Trackers.Base]
                if data.waypoint then
                    if data.waypoint.class then
                        data.waypoint.synced = { class = data.waypoint.class }
                    end
                    data.waypoint.class = self.WaypointToInaccurate[data.waypoint.class or data.class or self.Waypoints.Base]
                end
                data.special_function = data.client.special_function or SF.AddTrackerIfDoesNotExist
                data.icons = data.icons or trigger_icons_all
                data.client = nil
                self:AddSyncTrigger(id, data)
                data.synced = nil
                if data.waypoint then
                    data.waypoint.synced = nil
                end
                data.delay_only = nil
            end
        end
    end
    self:AddTriggers2(new_triggers, nil, trigger_id_all or "Trigger", trigger_icons_all)
end

---@param new_triggers ParseTriggersTable
---@param defer_loading_waypoints boolean?
function EHIManager:ParseMissionInstanceTriggers(new_triggers, defer_loading_waypoints)
    self:ParseMissionTriggers(new_triggers, nil, nil, defer_loading_waypoints)
end

---@param preload table
---@param trigger_id_all string?
---@param trigger_icons_all table?
function EHIManager:PreloadTrackers(preload, trigger_id_all, trigger_icons_all)
    for _, params in ipairs(preload) do
        params.id = params.id or trigger_id_all
        params.icons = params.icons or trigger_icons_all
        self._trackers:PreloadTracker(params)
    end
end

---@param data ElementTrigger
function EHIManager:_parse_vanilla_waypoint_trigger(data)
    data.data.distance = true
    data.data.state = "sneak_present"
    data.data.present_timer = 0
    data.data.no_sync = true -- Don't sync them to others. They may get confused and report it as a bug :p
    if data.data.position_by_element then
        data.id = data.id or data.data.position_by_element
        self:AddPositionFromElement(data.data, data.id, host)
    elseif data.data.position_by_unit then
        self:AddPositionFromUnit(data.data, data.id, host)
    end
    if data.data.icon then
        local redirect = self.WaypointIconRedirect[data.data.icon]
        if redirect then
            data.data.icon = redirect
            data.data.icon_redirect = true
        end
    end
end

---@param trigger_table table<number, ElementTrigger>
---@param option string
---| "show_timers" Filters out not loaded trackers with option show_timers
function EHIManager:FilterOutNotLoadedTrackers(trigger_table, option)
    local config = option and self.FilterTracker[option]
    if not config then
        return
    end
    local visible = EHI:GetOption(option)
    if config.waypoint then
        local _, show_waypoints_only = EHI:GetWaypointOptionWithOnly(config.waypoint)
        if show_waypoints_only then
            visible = false
        end
    end
    if visible then
        return
    end
    local not_loaded_tt = self.Trackers[config.table_name]
    if type(not_loaded_tt) ~= "table" then
        EHI:Log(string.format("Provided table name '%s' is not a table in EHI.Trackers! Nothing will be changed and the game may crash unexpectly!", config.table_name))
        return
    end
    for _, trigger in pairs(trigger_table) do
        if trigger.class then
            local key = table.get_key(not_loaded_tt, trigger.class) --[[@as string?]]
            if key then
                trigger.class = self.Trackers[key] --[[@as string]]
            end
        end
    end
end

function EHIManager:InitElements()
    if self.__init_done then
        return
    end
    self.__init_done = true
    self:HookElements(triggers)
    if EHI:IsClient() then
        return
    end
    self:AddPositionToWaypointFromLoad()
    local scripts = managers.mission._scripts or {}
    if base_delay_triggers and next(base_delay_triggers) then
        self._base_delay = {} ---@type table<number, fun(e: MissionScriptElement): number>
        for id, _ in pairs(base_delay_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._base_delay[id] = element._calc_base_delay
                    element._calc_base_delay = function(e)
                        local delay = self._base_delay[e._id](e)
                        self:CreateTrackerAndSync(e._id, delay)
                        return delay
                    end
                end
            end
        end
        base_delay_triggers = nil
    end
    if element_delay_triggers and next(element_delay_triggers) then
        self._element_delay = {} ---@type table<number, fun(e: MissionScriptElement, params: table): number>
        for id, _ in pairs(element_delay_triggers) do
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self._element_delay[id] = element._calc_element_delay
                    element._calc_element_delay = function(e, params)
                        local delay = self._element_delay[e._id](e, params)
                        if element_delay_triggers[e._id][params.id] then
                            if host_triggers[params.id] then
                                local trigger = host_triggers[params.id]
                                if trigger.remove_trigger_when_executed then
                                    self:CreateTrackerAndSync(params.id, delay)
                                    element_delay_triggers[e._id][params.id] = nil
                                elseif trigger.set_time_when_tracker_exists then
                                    if self._trackers:TrackerExists(trigger.id) then
                                        self._trackers:SetTrackerTimeNoAnim(trigger.id, delay)
                                        self._trackers:Sync(id, delay)
                                    else
                                        self:CreateTrackerAndSync(params.id, delay)
                                    end
                                else
                                    self:CreateTrackerAndSync(params.id, delay)
                                end
                            else
                                self:CreateTrackerAndSync(params.id, delay)
                            end
                        end
                        return delay
                    end
                end
            end
        end
    end
end

---@param element MissionScriptElement
---@param post_call fun(element: MissionScriptElement, instigator: Unit?)
function EHIManager:HookElement(element, post_call)
    Hooks:PostHook(element, self._element_hook_function, string.format("EHI_Element_%d", element._id), post_call)
end

---@param elements_to_hook table<number, _>
function EHIManager:HookElements(elements_to_hook)
    local client = EHI:IsClient()
    local f = client and function(element, ...)
        self:Trigger(element._id, element, true)
    end or function(element, ...)
        self:Trigger(element._id, element, element._values.enabled)
    end
    local scripts = managers.mission._scripts or {}
    for id, _ in pairs(elements_to_hook) do
        if math.within(id, 100000, 999999) then
            for _, script in pairs(scripts) do
                local element = script:element(id)
                if element then
                    self:HookElement(element, f)
                elseif client then
                    --[[
                        On client, the element was not found
                        This is because the element is from an instance that is mission placed
                        Mission Placed instances are preloaded and all elements are not cached until
                        ElementInstancePoint is called
                        These instances are synced when you join
                        Delay the hook until the sync is complete (see: EHIManager:SyncLoad())
                    ]]
                    self.HookOnLoad[id] = true
                end
            end
        end
    end
end

function EHIManager:AddPositionToWaypointFromLoad()
    for _, trigger in pairs(triggers) do
        if trigger.special_function == SF.ShowWaypoint and trigger.data and not trigger.data.position then
            if trigger.data.position_by_element then
                self:AddPositionFromElement(trigger.data, trigger.id, true)
            elseif trigger.data.position_by_unit then
                self:AddPositionFromUnit(trigger.data, trigger.id, true)
            end
        elseif trigger.waypoint and not trigger.waypoint.position then
            if trigger.waypoint.position_by_element then
                self:AddPositionFromElement(trigger.waypoint, trigger.id, true)
            elseif trigger.waypoint.position_by_unit then
                self:AddPositionFromUnit(trigger.waypoint, trigger.id, true)
            end
        end
    end
    for _, sync_trigger in pairs(self._sync_triggers or {}) do
        if sync_trigger.waypoint and not sync_trigger.waypoint.position then
            if sync_trigger.waypoint.position_by_element then
                self:AddPositionFromElement(sync_trigger.waypoint, sync_trigger.id, true)
            elseif sync_trigger.waypoint.position_by_unit then
                self:AddPositionFromUnit(sync_trigger.waypoint, sync_trigger.id, true)
            end
        end
    end
end

function EHIManager:SyncLoad()
    self:AddPositionToWaypointFromLoad()
    for id, _ in pairs(self.HookOnLoad) do
        local trigger = triggers[id]
        if trigger then
            if trigger.special_function == SF.ShowWaypoint and trigger.data then
                if trigger.data.position_by_element then
                    trigger.id = trigger.id or trigger.data.position_by_element
                    self:AddPositionFromElement(trigger.data, trigger.id, true)
                elseif trigger.data.position_by_unit then
                    self:AddPositionFromUnit(trigger.data, trigger.id, true)
                end
            elseif trigger.waypoint then
                if trigger.waypoint.position_by_element then
                    self:AddPositionFromElement(trigger.waypoint, trigger.id, true)
                elseif trigger.waypoint.position_by_unit then
                    self:AddPositionFromUnit(trigger.waypoint, trigger.id, true)
                end
            end
        end
    end
    self:HookElements(self.HookOnLoad)
    self.HookOnLoad = nil
    EHI:DisableWaypoints(EHI.DisableOnLoad)
    EHI:DisableWaypointsOnInit()
    EHI.DisableOnLoad = nil
end

---@param trigger ElementTrigger
function EHIManager:_AddTracker(trigger)
    if trigger.random_time then
        trigger.time = self:GetRandomTime(trigger)
        if trigger.waypoint then
            trigger.waypoint.time = trigger.time
        end
    end
    self._trackers:AddTracker(trigger, trigger.pos)
end

---@param trigger ElementTrigger
---@return number
function EHIManager:GetRandomTime(trigger)
    local full_time = trigger.additional_time or 0
    full_time = full_time + math.rand(trigger.random_time)
    return full_time
end

---@param trigger ElementTrigger
function EHIManager:CreateTracker(trigger)
    if trigger.condition_function and not trigger.condition_function() then
        return
    elseif trigger.run then
        self._trackers:RunTracker(trigger.id, trigger.run)
    elseif trigger.tracker_merge and self._trackers:TrackerExists(trigger.id) then
        self._trackers:SetTrackerTime(trigger.id, trigger.time)
    elseif trigger.tracker_group and self._trackers:TrackerExists(trigger.id) then
        self._trackers:CallFunction(trigger.id, "AddFromTrigger", trigger)
    else
        self:_AddTracker(trigger)
    end
    if trigger.waypoint_f then
        trigger.waypoint_f(self, trigger)
    elseif trigger.waypoint then
        self._waypoints:AddWaypoint(trigger.timer_id or trigger.id, trigger.waypoint)
    end
end

---@param id number
---@param delay number
function EHIManager:CreateTrackerAndSync(id, delay)
    local trigger = host_triggers[id]
    self._trackers:AddTrackerAndSync({
        id = trigger.id,
        time = (trigger.time or 0) + (delay or 0),
        icons = trigger.icons,
        hint = trigger.hint,
        class = trigger.class
    }, id, delay)
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.waypoint_f(self, trigger)
    elseif trigger.waypoint then
        self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param self EHIManager
---@param trigger ElementTrigger
---@param id number
local function GetElementTimer(self, trigger, id)
    if EHI:IsHost() then
        local element = managers.mission:get_element_by_id(trigger.element)
        if element then
            local t = (element._timer or 0) + (trigger.additional_time or 0)
            trigger.time = t
            if trigger.waypoint then
                trigger.waypoint.time = t
            end
            self:CreateTracker(trigger)
            self._trackers:Sync(id, t)
        end
    else
        self:CreateTracker(trigger)
    end
end

---@param id number
function EHIManager:UnhookElement(id)
    Hooks:RemovePostHook(string.format("EHI_Element_%d", id))
end

---@param id number
function EHIManager:UnhookTrigger(id)
    self:UnhookElement(id)
    triggers[id] = nil
end

---@param id number
---@param element MissionScriptElement
---@param enabled boolean
---@overload fun(self: EHIManager, id: number)
---@overload fun(self: EHIManager, id: number, element: MissionScriptElement)
function EHIManager:Trigger(id, element, enabled)
    local trigger = triggers[id]
    if trigger then
        local f = trigger.special_function
        if f then
            if f == SF.RemoveTracker then
                if trigger.data then
                    for _, tracker in ipairs(trigger.data) do
                        self:ForceRemove(tracker)
                    end
                else
                    self:ForceRemove(trigger.id)
                end
            elseif f == SF.PauseTracker then
                self:Pause(trigger.id)
            elseif f == SF.UnpauseTracker then
                self:Unpause(trigger.id)
            elseif f == SF.UnpauseTrackerIfExists then
                if self:Exists(trigger.id) then
                    self:Unpause(trigger.id)
                else
                    self:CreateTracker(trigger)
                end
            elseif f == SF.AddTrackerIfDoesNotExist then
                if self:DoesNotExist(trigger.id) then
                    self:CreateTracker(trigger)
                end
            elseif f == SF.ReplaceTrackerWithTracker then
                self:ForceRemove(trigger.data.id)
                self:CreateTracker(trigger)
            elseif f == SF.ShowAchievementFromStart then -- Achievement unlock is checked during level load
                if not managers.statistics:is_dropin() then
                    self:CreateTracker(trigger)
                end
            elseif f == SF.SetAchievementComplete then
                self._achievements:SetAchievementComplete(trigger.id, true)
            elseif f == SF.SetAchievementStatus then
                self._achievements:SetAchievementStatus(trigger.id, trigger.status or "ok")
            elseif f == SF.SetAchievementFailed then
                self._achievements:SetAchievementFailed(trigger.id)
            elseif f == SF.AddAchievementToCounter then
                local data = trigger.data or {}
                data.achievement = data.achievement or trigger.id
                data.max = data.max or trigger.max or 0
                EHI:AddAchievementToCounter(data)
                self:CreateTracker(trigger)
            elseif f == SF.IncreaseChance then
                self._trackers:IncreaseChance(trigger.id, trigger.amount)
            elseif f == SF.TriggerIfEnabled then
                if enabled then
                    if trigger.data then
                        for _, t in ipairs(trigger.data) do
                            self:Trigger(t, element, enabled)
                        end
                    else
                        self:Trigger(trigger.id --[[@as number]], element, enabled)
                    end
                end
            elseif f == SF.CreateAnotherTrackerWithTracker then
                self:CreateTracker(trigger)
                self:Trigger(trigger.data.fake_id, element, enabled)
            elseif f == SF.SetChanceWhenTrackerExists then
                if self._trackers:TrackerExists(trigger.id) then
                    self._trackers:SetChance(trigger.id, trigger.chance)
                    if trigger.tracker_merge then
                        self._trackers:SetTrackerTime(trigger.id, trigger.time)
                    end
                else
                    self:CreateTracker(trigger)
                end
            elseif f == SF.Trigger then
                if trigger.data then
                    for _, t in ipairs(trigger.data) do
                        self:Trigger(t, element, enabled)
                    end
                else
                    self:Trigger(trigger.id --[[@as number]], element, enabled)
                end
            elseif f == SF.RemoveTrigger then
                if trigger.data then
                    for _, trigger_id in ipairs(trigger.data) do
                        self:UnhookTrigger(trigger_id)
                    end
                else
                    self:UnhookTrigger(trigger.id --[[@as number]])
                end
            elseif f == SF.SetTimeOrCreateTracker then
                local key = trigger.id
                if trigger.tracker_merge then
                    if self._trackers:TrackerExists(key) then
                        self._trackers:SetTrackerTime(key, trigger.time)
                    else
                        self:_AddTracker(trigger)
                    end
                    if trigger.waypoint_f then
                        trigger.waypoint_f(self, trigger)
                    elseif trigger.waypoint then
                        if self._waypoints:WaypointExists(key) then
                            self._waypoints:SetWaypointTime(key, trigger.time)
                        else
                            self._waypoints:AddWaypoint(key, trigger.waypoint)
                        end
                    end
                elseif self:Exists(key) then
                    local time = trigger.run and trigger.run.time or trigger.time or 0
                    self:SetTime(key, time)
                else
                    self:CreateTracker(trigger)
                end
            elseif f == SF.SetTimeOrCreateTrackerIfEnabled then
                if enabled then
                    if self:Exists(trigger.id) then
                        self:SetTime(trigger.id, trigger.time)
                    else
                        self:CreateTracker(trigger)
                    end
                end
            elseif f == SF.ExecuteIfElementIsEnabled then
                if enabled then
                    self:CreateTracker(trigger)
                end
            elseif f == SF.SetTimeByPreplanning then
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    trigger.time = trigger.data.yes
                else
                    trigger.time = trigger.data.no
                end
                if trigger.waypoint then
                    trigger.waypoint.time = trigger.time
                end
                self:CreateTracker(trigger)
            elseif f == SF.IncreaseProgress then
                self:IncreaseProgress(trigger.id)
            elseif f == SF.SetTrackerAccurate then
                if self:Exists(trigger.id) then
                    self:SetAccurate(trigger.id, trigger.time)
                else
                    self:CreateTracker(trigger)
                end
            elseif f == SF.SetRandomTime then
                if self._trackers:TrackerDoesNotExist(trigger.id) then
                    trigger.time = trigger.data[math.random(#trigger.data)]
                    self:CreateTracker(trigger)
                end
            elseif f == SF.DecreaseChance then
                self._trackers:DecreaseChance(trigger.id, trigger.amount)
            elseif f == SF.GetElementTimerAccurate then
                GetElementTimer(self, trigger, id)
            elseif f == SF.UnpauseTrackerIfExistsAccurate then
                if self:Exists(trigger.id) then
                    self:Unpause(trigger.id)
                else
                    GetElementTimer(self, trigger, id)
                end
            elseif f == SF.UnpauseOrSetTimeByPreplanning then
                if self:Exists(trigger.id) then
                    self:Unpause(trigger.id)
                else
                    if trigger.time then
                        self:CreateTracker(trigger)
                        return
                    end
                    if managers.preplanning:IsAssetBought(trigger.data.id) then
                        trigger.time = trigger.data.yes
                    else
                        trigger.time = trigger.data.no
                    end
                    self:CreateTracker(trigger)
                end
            elseif f == SF.FinalizeAchievement then
                self._trackers:CallFunction(trigger.id, "Finalize")
            elseif f == SF.IncreaseChanceFromElement then
                self._trackers:IncreaseChance(trigger.id, element._values.chance)
            elseif f == SF.DecreaseChanceFromElement then
                self._trackers:DecreaseChance(trigger.id, element._values.chance)
            elseif f == SF.SetChanceFromElement then
                self._trackers:SetChance(trigger.id, element._values.chance)
            elseif f == SF.PauseTrackerWithTime then
                local t_id = trigger.id
                self:Pause(t_id)
                self:SetTimeNoAnim(t_id, trigger.time)
            elseif f == SF.IncreaseProgressMax then
                self._trackers:IncreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.IncreaseProgressMax2 then
                if self._trackers:TrackerExists(trigger.id) then
                    self._trackers:IncreaseTrackerProgressMax(trigger.id, trigger.max)
                else
                    local new_trigger =
                    {
                        id = trigger.id,
                        max = trigger.max or 1,
                        class = trigger.class or "EHILootTracker"
                    }
                    self:CreateTracker(new_trigger)
                end
            elseif f == SF.SetTimeIfLoudOrStealth then
                if managers.groupai:state():whisper_mode() then
                    trigger.time = trigger.data.stealth
                else
                    trigger.time = trigger.data.loud
                end
                if trigger.waypoint then
                    trigger.waypoint.time = trigger.time
                end
                self:CreateTracker(trigger)
            elseif f == SF.AddTimeByPreplanning then
                local t = 0
                if managers.preplanning:IsAssetBought(trigger.data.id) then
                    t = trigger.data.yes
                else
                    t = trigger.data.no
                end
                trigger.time = trigger.time + t
                if trigger.waypoint then
                    trigger.waypoint.time = trigger.time
                end
                self:CreateTracker(trigger)
            elseif f == SF.ShowWaypoint then
                managers.hud:AddWaypointFromTrigger(trigger.id, trigger.data)
            elseif f == SF.DecreaseProgressMax then
                self._trackers:DecreaseTrackerProgressMax(trigger.id, trigger.max)
            elseif f == SF.DecreaseProgress then
                self._trackers:DecreaseTrackerProgress(trigger.id, trigger.progress)
            elseif f == SF.IncreaseCounter then
                self._trackers:IncreaseTrackerCount(trigger.id, trigger.count)
            elseif f == SF.DecreaseCounter then
                self._trackers:DecreaseTrackerCount(trigger.id)
            elseif f == SF.SetCounter then
                self._trackers:SetTrackerCount(trigger.id, trigger.count)
            elseif f == SF.CallCustomFunction then
                if trigger.arg then
                    self:Call(trigger.id, trigger.f --[[@as string]], unpack(trigger.arg))
                else
                    self:Call(trigger.id, trigger.f --[[@as string]])
                end
            elseif f == SF.CallTrackerManagerFunction then
                local _tf = self._trackers[trigger.f --[[@as string]]]
                if _tf then
                    if trigger.arg then
                        _tf(self._trackers, unpack(trigger.arg))
                    else
                        _tf(self._trackers)
                    end
                end
            elseif f == SF.CallWaypointManagerFunction then
                local _tf = self._waypoints[trigger.f --[[@as string]]]
                if _tf then
                    if trigger.arg then
                        _tf(self._waypoints, unpack(trigger.arg))
                    else
                        _tf(self._waypoints)
                    end
                end
            elseif f == SF.Debug then
                managers.hud:Debug(id)
            elseif f == SF.DebugElement then
                managers.hud:DebugElement(element:id(), element:editor_name(), enabled)
            elseif f == SF.CustomCode then
                trigger.f(trigger.arg)
            elseif f == SF.CustomCodeIfEnabled then
                if enabled then
                    trigger.f(trigger.arg)
                end
            elseif f == SF.CustomCodeDelayed then
                EHI:DelayCall(tostring(id), trigger.t or 0, trigger.f --[[@as function]])
            elseif f >= SF.CustomSF then
                self.SFF[f](self, trigger, element, enabled)
            end
        else
            self:CreateTracker(trigger)
        end
        if trigger.trigger_times and trigger.trigger_times > 0 then
            trigger.trigger_times = trigger.trigger_times - 1
            if trigger.trigger_times == 0 then
                self:UnhookTrigger(id)
            end
        end
    end
end

---@param sync_triggers table
function EHIManager:_set_sync_triggers(sync_triggers)
    if self._sync_triggers then
        for key, value in pairs(sync_triggers) do
            if self._sync_triggers[key] then
                EHI:Log("key: " .. tostring(key) .. " already exists in sync!")
            else
                self._sync_triggers[key] = deep_clone(value)
            end
        end
    else
        self._sync_triggers = deep_clone(sync_triggers)
    end
end

---@param id number
---@param trigger ElementTrigger
function EHIManager:AddSyncTrigger(id, trigger)
    self._sync_triggers = self._sync_triggers or {} ---@type table<number, ElementTrigger>
    if self._sync_triggers[id] then
        EHI:Log(tostring(id) .. " already exists in sync!")
        return
    end
    local sync_trigger = deep_clone(trigger)
    if sync_trigger.synced then
        sync_trigger.class = sync_trigger.synced.class
        sync_trigger.synced = nil
    end
    if sync_trigger.waypoint and sync_trigger.waypoint.synced then
        sync_trigger.waypoint.class = sync_trigger.waypoint.synced.class
        sync_trigger.waypoint.synced = nil
    end
    if sync_trigger.delay_only then
        sync_trigger.random_time = nil
        sync_trigger.additional_time = nil
    end
    self._sync_triggers[id] = sync_trigger
end

---@param id number
---@param delay number
function EHIManager:AddTrackerSynced(id, delay)
    if self._sync_triggers and self._sync_triggers[id] then
        local trigger = self._sync_triggers[id]
        local trigger_id = trigger.id
        if self:Exists(trigger_id) then
            if trigger.delay_only then
                self:SetAccurate(trigger_id, delay)
            else
                self:SetAccurate(trigger_id, (trigger.time or trigger.additional_time or 0) + delay)
            end
        else
            self:CreateSyncedTracker(trigger, delay)
        end
        if trigger.client_on_executed then
            -- Right now there is only SF.RemoveTriggerWhenExecuted
            self._sync_triggers[id] = nil
        end
    end
end

---@param trigger ElementTrigger
---@param delay number
function EHIManager:CreateSyncedTracker(trigger, delay)
    local t = trigger.delay_only and delay or ((trigger.time or trigger.additional_time or 0) + delay)
    self._trackers:AddTracker({
        id = trigger.id,
        time = t,
        icons = trigger.icons,
        hint = trigger.hint,
        class = trigger.class
    }, trigger.pos)
    if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
        trigger.time = t
        trigger.waypoint_f(self, trigger)
        trigger.time = nil
    elseif trigger.waypoint then
        trigger.waypoint.time = t
        self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
    end
end

---@param id number
---@param waypoint table
function EHIManager:AddWaypointToTrigger(id, waypoint)
    if not EHI:GetOption("show_waypoints_mission") then
        return
    end
    local t = triggers[id]
    if not t then
        return
    end
    local w = deep_clone(waypoint)
    w.time = w.time or t.time
    if not w.icon then
        local icon = t.icons
        if icon and icon[1] then
            if type(icon[1]) == "table" then
                w.icon = icon[1].icon
            elseif type(icon[1]) == "string" then
                w.icon = icon[1]
            end
        end
    end
    t.waypoint = w
end

---@param id number
---@param icon string
function EHIManager:UpdateWaypointTriggerIcon(id, icon)
    local t = triggers[id]
    if not (t and t.waypoint) then
        return
    end
    t.waypoint.icon = icon
    self._waypoints:SetWaypointIcon(t.id, icon)
end

---@param id number
---@param f fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return nil
---@overload fun(self, f: fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)): integer
function EHIManager:RegisterCustomSF(id, f)
    if f then
        self.SFF[id] = f
    else
        local f_id = EHI:GetFreeCustomSFID()
        self.SFF[f_id] = id
        return f_id
    end
end

---@param id number
function EHIManager:UnregisterCustomSF(id)
    self.SFF[id] = nil
end

---@param id number
---@param f fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)
---@return nil
---@overload fun(self, f: fun(self: EHIManager, trigger: ElementTrigger, element: MissionScriptElement, enabled: boolean)): integer
function EHIManager:RegisterCustomSyncedSF(id, f)
    self.SyncedSFF = self.SyncedSFF or {}
    if f then
        self.SFF[id] = f
        if EHI:IsHost() then
            self.SyncFunctions[id] = true
        end
    else
        local f_id = EHI:GetFreeCustomSyncedSFID()
        self.SFF[f_id] = id
        if EHI:IsHost() then
            self.SyncFunctions[f_id] = true
        end
        return f_id
    end
end

if EHI:GetWaypointOption("show_waypoints_only") then
    ---@param trigger ElementTrigger
    function EHIManager:CreateTracker(trigger)
        if trigger.condition_function and not trigger.condition_function() then
            return
        end
        if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            if not trigger.run then
                if trigger.random_time then
                    trigger.time = self:GetRandomTime(trigger)
                end
            end
            trigger.waypoint_f(self, trigger)
        elseif trigger.waypoint then
            if trigger.random_time then
                trigger.waypoint.time = self:GetRandomTime(trigger)
            end
            self._waypoints:AddWaypoint(trigger.timer_id or trigger.id, trigger.waypoint)
        elseif trigger.run then
            self._trackers:RunTracker(trigger.id, trigger.run)
        elseif trigger.tracker_merge and self._trackers:TrackerExists(trigger.id) then
            self._trackers:SetTrackerTime(trigger.id, trigger.time)
        elseif trigger.tracker_group then
            if self._trackers:TrackerExists(trigger.id) then
                self._trackers:CallFunction(trigger.id, "AddFromTrigger", trigger)
            else
                self:_AddTracker(trigger)
            end
        else
            self:_AddTracker(trigger)
        end
    end

    ---@param trigger ElementTrigger
    ---@param delay number
    function EHIManager:CreateSyncedTracker(trigger, delay)
        local t = trigger.delay_only and delay or ((trigger.time or trigger.additional_time or 0) + delay)
        if trigger.waypoint_f then -- In case waypoint needs to be dynamic (different position each call or it depends on a trigger itself)
            trigger.time = t
            trigger.waypoint_f(self, trigger)
            trigger.time = nil
        elseif trigger.waypoint then
            trigger.waypoint.time = t
            self._waypoints:AddWaypoint(trigger.id, trigger.waypoint)
        else
            self._trackers:AddTracker({
                id = trigger.id,
                time = t,
                icons = trigger.icons,
                hint = trigger.hint,
                class = trigger.class
            }, trigger.pos)
        end
    end
end

if not EHI:GetOption("show_mission_trackers") then
    ---@param id number
    ---@param delay number
    function EHIManager:CreateTrackerAndSync(id, delay)
        self._trackers:Sync(id, delay)
    end

    ---@param self EHIManager
    ---@param trigger ElementTrigger
    ---@param id number
    GetElementTimer = function(self, trigger, id)
        if EHI:IsHost() then
            local element = managers.mission:get_element_by_id(trigger.element)
            if element then
                local t = (element._timer or 0) + (trigger.additional_time or 0)
                self._trackers:Sync(id, t)
            end
        end
    end
end

if EHI:GetOption("show_timers") and EHI:GetWaypointOption("show_waypoints_timers") and not EHI:GetOption("show_waypoints_only") then
    if EHI:GetOption("time_format") == 1 then
        EHIManager.FormatTimer = tweak_data.ehi.functions.ReturnSecondsOnly
    else
        EHIManager.FormatTimer = tweak_data.ehi.functions.ReturnMinutesAndSeconds
    end
    ---@param id string
    ---@param t number
    function EHIManager:UpdateTimer(id, t)
        local t_string = self:FormatTimer(t)
        self._timer:SetTimerTimeNoFormat(id, t, t_string)
        self._waypoints:CallFunction(id, "SetTimeNoFormat", t, t_string)
    end
end