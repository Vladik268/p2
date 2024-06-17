local EHI = EHI
if EHI:CheckLoadHook("WorldDefinition") then
    return
end

---@alias WorldDefinition.Continent { base_id: number }

---@class WorldDefinition
---@field _all_units table
---@field _continents table<string, WorldDefinition.Continent>
---@field get_unit fun(self: self, id: number): Unit?

local units = {}
EHI:HookWithID(WorldDefinition, "init", "EHI_WorldDefinition_init", function(...)
    units = tweak_data.ehi.units
end)

EHI:HookWithID(WorldDefinition, "create", "EHI_WorldDefinition_create", function(self, ...)
    if self._definition.statics then
        for _, values in ipairs(self._definition.statics) do
            if units[values.unit_data.name] and not values.unit_data.instance then
                EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
            end
        end
    end
    for _, continent in pairs(self._continent_definitions) do
        if continent.statics then
            for _, values in ipairs(continent.statics) do
                if units[values.unit_data.name] and not values.unit_data.instance then
                    EHI._cache.MissionUnits[values.unit_data.unit_id] = units[values.unit_data.name]
                end
            end
        end
    end
end)

local Icon = EHI.Icons
local Hints = EHI.Hints
local used_start_indexes_unit = {}
---@type table<string, table<number, UnitUpdateDefinition>>
local instances =
{
    ["levels/instances/unique/mus_chamber_controller/world"] =
    {
        [100347] = { icons = { Icon.Wait }, remove_on_pause = true, warning = true, hint = Hints.roberts_GenSecWarning }
    },
    ["levels/instances/unique/mus_security_barrier/world"] =
    {
        [100020] = { icons = { Icon.Keycard } }
    },
    ["levels/instances/unique/mus_security_room/world"] =
    {
        [100041] = { remove_vanilla_waypoint = 100050 } -- PC
    },
    ["levels/instances/unique/hox_breakout_road001/world"] =
    {
        [100058] = { remove_vanilla_waypoint = 100090 } -- Drill
    },
    ["levels/instances/unique/hox_breakout_serverroom001/world"] =
    {
        [100025] = { remove_vanilla_waypoint = 100072, restore_waypoint_on_done = true } -- PC
    },
    ["levels/instances/unique/hox_fbi_forensic_device/world"] =
    {
        [100018] = { icons = { "equipment_evidence" }, hint = Hints.hox_2_Evidence } -- PC
    },
    ["levels/instances/unique/hox_fbi_security_office/world"] =
    {
        [100068] = { icons = { "equipment_harddrive" }, remove_vanilla_waypoint = 100019 } -- PC
    },
    ["levels/instances/unique/kenaz/the_drill/world"] =
    {
        [100000] = { icons = { Icon.Drill }, ignore_visibility = true, hint = "drill" }
    },
    ["levels/instances/unique/hox_estate_alarmbox/world"] =
    {
        [100021] = { icons = { Icon.Alarm }, warning = true, remove_on_pause = true, hint = Hints.Alarm }
    },
    ["levels/instances/unique/hox_estate_panic_room/world"] =
    {
        [100068] = { remove_vanilla_waypoint = 100089 }, -- Drill
        [100090] = { icons = { Icon.Vault }, remove_on_pause = true }
    },
    ["levels/instances/unique/holly_2/safe_van/world"] =
    {
        [100019] = { remove_vanilla_waypoint = 100070 } -- Saw
    },
    ["levels/instances/unique/nail_cloaker_safe/world"] =
    {
        [100014] = { ignore = true },
        [100056] = { ignore = true },
        [100226] = { ignore = true },
        [100227] = { icons = { Icon.Vault }, remove_on_pause = true, completion = true, hint = Hints.cane_Safe }
    },
    ["levels/instances/unique/red/red_gates/world"] =
    {
        [100006] = { remove_vanilla_waypoint = 100014 } -- Drill
    },
    ["levels/instances/unique/red/red_hacking_computer/world"] =
    {
        [100000] = { remove_vanilla_waypoint = 100018 } -- PC
    },
    ["levels/instances/unique/cane/cane_trap_flame/world"] =
    {
        -- OVK decided to use one timer for fire and fire recharge
	    -- This ignores them and that timer is implemented in CoreWorldInstanceManager
        [100002] = { ignore = true }
    },
    ["levels/instances/unique/hvh/hvh_event/world"] =
    {
        [100027] = { ignore = true },
        [100028] = { ignore = true },
        [100029] = { icons = { Icon.Vault }, completion = true, hint = Hints.cane_Safe }
    },
    ["levels/instances/unique/pbr/pbr_mountain_control_console/world"] =
    {
        -- Poseidon
        [100005] = { icons = { Icon.Vault }, position = Vector3(-6845, -2202, -800) },
        -- Ares
        [100007] = { icons = { Icon.Vault }, position = Vector3(-8737.18, -5842.67, -800) },
        -- Chronos
        [100008] = { icons = { Icon.Vault }, position = Vector3(-11417.6, -3197.62, -799.999) },
        -- Demeter
        [100039] = { icons = { Icon.Vault }, position = Vector3(-12702, -1630, -800) },
        -- Hades
        [100040] = { icons = { Icon.Vault }, position = Vector3(-9298, -195, -800) },
        -- Zeus
        [100041] = { icons = { Icon.Vault }, position = Vector3(-6845, -4202, -800) }
    },
    ["levels/instances/unique/pbr/pbr_mountain_entrance/world"] =
    {
        [100113] = { icons = { Icon.C4 }, hint = Hints.Explosion }
    },
    ["levels/instances/unique/help/door_switch/world"] =
    {
        [100072] = { icons = { Icon.Wait }, warning = true }
    },
    ["levels/instances/unique/help/lottery_wheel/world"] =
    {
        [100033] = { icons = { Icon.Wait }, icon_on_pause = { Icon.Loop } }
    },
    ["levels/instances/unique/spa/spa_storage/world"] =
    {
        [100063] = { remove_vanilla_waypoint = 100061 } -- Drill
    },
    ["levels/instances/unique/brb/brb_vault/world"] =
    {
        [100058] = { remove_vanilla_waypoint = 100003 } -- Drill
    },
    ["levels/instances/unique/des/des_drill/world"] =
    {
        [100030] = { remove_vanilla_waypoint = 100009 } -- Interact
    },
    ["levels/instances/unique/sah/sah_office/world"] =
    {
        [100064] = { remove_vanilla_waypoint = 100068 }, -- Drill
        [100168] = { remove_vanilla_waypoint = 100084 } -- PC
    },
    ["levels/instances/unique/sah/sah_vault_door/world"] =
    {
        [100001] = { icons = { Icon.Vault } }
    },
    ["levels/instances/unique/vit/vit_mainframe/world"] =
    {
        [100058] = { remove_vanilla_waypoint = 100018, restore_waypoint_on_done = true }, -- PC
        [100191] = { remove_vanilla_waypoint = 100018, restore_waypoint_on_done = true }, -- PC
        [100192] = { remove_vanilla_waypoint = 100018, restore_waypoint_on_done = true } -- PC
    },
    ["levels/instances/unique/vit/vit_peoc_workstation/world"] =
    {
        [100045] = { remove_vanilla_waypoint = 100058 } -- PC
    },
    ["levels/instances/unique/vit/vit_safe/world"] =
    {
        [100239] = { remove_vanilla_waypoint = 100254 } -- Drill
    },
    ["levels/instances/unique/mex/mex_explosives/world"] =
    {
        [100032] = { icons = { Icon.C4 } }
    },
    ["levels/instances/unique/mex/mex_vault/world"] =
    {
        [100003] = { icons = { Icon.Vault }, remove_on_pause = true }
    },
    ["levels/instances/unique/fex/fex_serverhack/world"] =
    {
        [100100] = { remove_vanilla_waypoint = 100038, restore_waypoint_on_done = true }, -- PC
        [100101] = { remove_vanilla_waypoint = 100038, restore_waypoint_on_done = true }, -- PC
        [100102] = { remove_vanilla_waypoint = 100038, restore_waypoint_on_done = true } -- PC
    },
    ["levels/instances/unique/chas/chas_vault_crate/world"] =
    {
        [100140] = { hint = Hints.Explosion }
    },
    ["levels/instances/unique/chas/chas_vault_door/world"] =
    {
        [100065] = { icons = { Icon.Vault }, remove_on_pause = true }
    },
    ["levels/instances/unique/chas/chas_store_computer/world"] =
    {
        [100037] = { remove_vanilla_waypoint = 100017 } -- PC
    },
    ["levels/instances/unique/sand/sand_chinese_computer_hackable/world"] =
    {
        [100037] = { remove_vanilla_waypoint = 100017 } -- PC
    },
    ["levels/instances/unique/sand/sand_computer_code_display/world"] =
    {
        [100150] = { remove_on_pause = true, remove_on_alarm = true }
    },
    ["levels/instances/unique/sand/sand_computer_hackable/world"] =
    {
        [100140] = { remove_vanilla_waypoint = 100034 } -- PC
    },
    ["levels/instances/unique/sand/sand_defibrillator/world"] =
    {
        [100009] = { icons = { Icon.Power }, hint = Hints.Charging }
    },
    ["levels/instances/unique/sand/sand_server_hack/world"] =
    {
        [100037] = { remove_vanilla_waypoint = 100017 } -- PC
    },
    ["levels/instances/unique/sand/sand_swat_van_drillable/world"] =
    {
        [100022] = { remove_vanilla_waypoint = 100023 } -- Drill
    },
    ["levels/instances/unique/corp/corp_display_case/world"] =
    {
        [100023] = { remove_vanilla_waypoint = 100050 } -- Saw
    }
}
instances["levels/instances/unique/cane/cane_santa_event/world"] = instances["levels/instances/unique/nail_cloaker_safe/world"]
---@param instance CoreWorldInstanceManager.Instance
function WorldDefinition:OverrideUnitsInTheInstance(instance)
    --EHI:PrintTable(instance, "Overriding instance")
    local start_index = instance.start_index
    -- Don't compute the indexes again if the instance on this start_index has been computed already  
    -- `start_index` is unique for each instance in a heist, so this shouldn't break anything
    if not used_start_indexes_unit[start_index] then
        local tbl = {}
        local continent_data = self._continents[instance.continent] or {}
        for id, unit in pairs(instances[instance.folder]) do
            local final_index = EHI:GetInstanceUnitID(id, start_index, continent_data.base_id)
            local unit_data = deep_clone(unit)
            if unit.remove_vanilla_waypoint then
                unit_data.remove_vanilla_waypoint = EHI:GetInstanceElementID(unit.remove_vanilla_waypoint, start_index, continent_data.base_id)
            end
            tbl[final_index] = unit_data
        end
        EHI:UpdateInstanceMissionUnits(tbl, self._all_units == nil)
        used_start_indexes_unit[start_index] = true
    end
end

---@param instance CoreWorldInstanceManager.Instance
function WorldDefinition:OverrideUnitsInMissionPlacedInstance(instance)
    if instances[instance.folder or ""] then
        self:OverrideUnitsInTheInstance(instance)
    end
end

EHI:HookWithID(WorldDefinition, "_insert_instances", "EHI_WorldDefinition_insert_instances", function(self, ...)
    for _, data in pairs(self._continent_definitions) do
        if data.instances then
            for _, instance in ipairs(data.instances) do
                if instances[instance.folder] and not instance.mission_placed then
                    self:OverrideUnitsInTheInstance(instance)
                end
            end
        end
    end
end)

EHI:PreHookWithID(WorldDefinition, "init_done", "EHI_WorldDefinition_init_done", function(...)
    EHI:FinalizeUnitsClient()
end)

function WorldDefinition:IgnoreDeployable(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetIgnore then
        unit:base():SetIgnore()
    end
end

function WorldDefinition:IgnoreChildDeployable(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetIgnoreChild then
        unit:base():SetIgnoreChild()
    end
end

function WorldDefinition:SetDeployableOffset(unit_id, unit_data, unit)
    if unit:base() and unit:base().SetOffset then
        unit:base():SetOffset(unit_data.offset or 1)
    end
end

---@param unit_id number
---@param unit_data UnitUpdateDefinition
---@param unit UnitDigitalTimer
function WorldDefinition:chasC4(unit_id, unit_data, unit)
    if not unit:digital_gui()._ehi_key then
        return
    end
    unit:digital_gui():SetHint(Hints.Explosion)
    if not unit_data.instance then
        unit:digital_gui():SetIcons(unit_data.icons)
        return
    end
    if EHI:GetBaseUnitID(unit_id, unit_data.instance.start_index, unit_data.continent_index) == 100054 then
        unit:digital_gui():SetIcons(unit_data.icons)
    else
        unit:digital_gui():SetIgnore(true)
    end
end