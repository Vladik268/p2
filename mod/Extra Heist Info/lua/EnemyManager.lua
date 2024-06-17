local EHI = EHI
if EHI:CheckLoadHook("EnemyManager") then
    return
end

---@class EnemyManager
---@field _enemy_data table
---@field _civilian_data table
---@field all_civilians fun(self: self): table
---@field is_enemy fun(self: self, unit: Unit|UnitEnemy|UnitPlayer): boolean

---@return number
function EnemyManager:GetNumberOfEnemies()
    return self._enemy_data.nr_units
end

if not (EHI:GetOption("show_enemy_count_tracker") or EHI:CanShowCivilianCountTracker()) then
    return
end

local original = {}

if EHI:GetOption("show_enemy_count_tracker") then
    original.on_enemy_registered = EnemyManager.on_enemy_registered
    original.on_enemy_unregistered = EnemyManager.on_enemy_unregistered
    dofile(EHI.LuaPath .. "trackers/EHIEnemyCountTracker.lua")
    if EHI:GetOption("show_enemy_count_show_pagers") then
        local alarm_unit = {}
        function EnemyManager:on_enemy_registered(unit, ...)
            original.on_enemy_registered(self, unit, ...)
            if alarm_unit[unit:base()._tweak_table] then
                managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyRegistered")
            else
                managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyRegistered")
            end
        end
        function EnemyManager:on_enemy_unregistered(unit, ...)
            original.on_enemy_unregistered(self, unit, ...)
            if alarm_unit[unit:base()._tweak_table] then
                managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyUnregistered")
            else
                managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyUnregistered")
            end
        end
        for name, data in pairs(tweak_data.character) do
            if type(data) == "table" and data.has_alarm_pager then
                alarm_unit[name] = true
            end
        end
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            managers.ehi_tracker:AddTracker({
                id = "EnemyCount",
                alarm_sounded = EHI.ConditionFunctions.IsLoud(),
                flash_bg = false,
                hint = "enemy_count",
                class = "EHIEnemyCountTracker"
            })
            local enemy_data = managers.enemy._enemy_data
            for _, data in pairs(enemy_data.unit_data or {}) do
                if alarm_unit[data.unit:base()._tweak_table] then
                    managers.ehi_tracker:CallFunction("EnemyCount", "AlarmEnemyRegistered")
                else
                    managers.ehi_tracker:CallFunction("EnemyCount", "NormalEnemyRegistered")
                end
            end
        end)
    else
        function EnemyManager:on_enemy_registered(...)
            original.on_enemy_registered(self, ...)
            managers.ehi_tracker:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
        end
        function EnemyManager:on_enemy_unregistered(...)
            original.on_enemy_unregistered(self, ...)
            managers.ehi_tracker:SetTrackerCount("EnemyCount", self._enemy_data.nr_units)
        end
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            managers.ehi_tracker:AddTracker({
                id = "EnemyCount",
                count = managers.enemy:GetNumberOfEnemies(),
                flash_bg = false,
                hint = "enemy_count",
                class = "EHIEnemyCountTracker"
            })
        end)
    end
end

if EHI:CanShowCivilianCountTracker() then
    dofile(EHI.LuaPath .. "trackers/EHICivilianCountTracker.lua")
    ---@param unit_data table
    ---@param key any Unused
    local function CountCivilian(unit_data, key)
        if not unit_data.unit then
            return false
        end
        if unit_data.unit:base().unintimidateable then
            return false
        end
        if unit_data.unit:character_damage().immortal then -- Husk unit check
            return false
        end
        if not unit_data.char_tweak then
            return false
        end
        if unit_data.char_tweak.is_escort or not unit_data.char_tweak.intimidateable then
            return false
        end
        return true
    end
    ---@param count number
    local function CreateTracker(count)
        managers.ehi_tracker:AddTracker({
            id = "CivilianCount",
            count = count,
            class = "EHICivilianCountTracker"
        })
    end
    if EHI:IsVR() then
        local old_CreateTracker = CreateTracker
        local function Reload(key, data)
            old_CreateTracker(data.count)
        end
        ---@param count number
        CreateTracker = function(count)
            if managers.ehi_tracker:IsLoading() then
                managers.ehi_tracker:AddToLoadQueue("CivilianCount", { count = count }, Reload)
                return
            end
            old_CreateTracker(count)
        end
    end
    ---@param civilian_data table
    ---@param civilian_key string
    ---@param from_destroy boolean?
    local function CivilianDied(civilian_data, civilian_key, from_destroy)
        if managers.ehi_tracker:CallFunction3("CivilianCount", "DecreaseTrackerCount", civilian_key) then
            local count = table.count(civilian_data, CountCivilian)
            local civilians_alive = count - (from_destroy and 1 or 0)
            if civilians_alive > 0 then
                CreateTracker(civilians_alive)
            end
        end
    end
    original.register_civilian = EnemyManager.register_civilian
    function EnemyManager:register_civilian(unit, ...)
        original.register_civilian(self, unit, ...)
        local unit_data = self._civilian_data.unit_data
        if CountCivilian(unit_data[unit:key()]) and managers.ehi_tracker:CallFunction3("CivilianCount", "IncreaseTrackerCount") then
            CreateTracker(table.size(unit_data))
        end
    end
    original.on_civilian_died = EnemyManager.on_civilian_died
    function EnemyManager:on_civilian_died(dead_unit, ...)
        local unit_data = self._civilian_data.unit_data
        local civilian_key = dead_unit:key()
        if CountCivilian(unit_data[civilian_key]) then
            CivilianDied(unit_data, civilian_key)
        end
        original.on_civilian_died(self, dead_unit, ...)
    end
    original.on_civilian_destroyed = EnemyManager.on_civilian_destroyed
    function EnemyManager:on_civilian_destroyed(civilian, ...)
        local civilian_data = self._civilian_data.unit_data
        local civilian_key = civilian:key()
        local unit_data = civilian_data[civilian_key]
        if unit_data and CountCivilian(unit_data) then
            CivilianDied(civilian_data, civilian_key, true)
        end
        original.on_civilian_destroyed(self, civilian, ...)
    end
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        local units = managers.enemy._civilian_data.unit_data
        local count = table.size(units)
        local civilian_count = table.count(units, CountCivilian)
        if count <= 0 or civilian_count <= 0 then
            managers.ehi_tracker:RemoveTracker("CivilianCount")
        elseif managers.ehi_tracker:TrackerExists("CivilianCount") then
            managers.ehi_tracker:CallFunction("CivilianCount", "ResetCounter")
            managers.ehi_tracker:CallFunction("CivilianCount", "SetCount2", civilian_count)
        else
            CreateTracker(civilian_count)
        end
    end)
end