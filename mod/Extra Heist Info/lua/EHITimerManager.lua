---@class EHITimerManager
EHITimerManager = {}
EHITimerManager._max_timers = EHI:GetOption("show_timers_max_in_group") --[[@as number]]
EHITimerManager._grouping_is_enabled = EHITimerManager._max_timers > 1
---@param ehi_tracker EHITrackerManager
function EHITimerManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._groups = {} --[[@as table<string, { count: number, [number]: { count: number, [number]: { name: string, timer_count: number }}}> ]]
    self._units_in_active_group = {} --[[@as table<string, string?>]]
    return self
end

---@param id string Unit key
---@param group string
---@param subgroup number
---@param i_subgroup number
---@param upgrades table?
---@param visibility_data table
function EHITimerManager:AddTimerSubgroup(id, group, subgroup, i_subgroup, upgrades, visibility_data)
    local tracker_id = self._get_tracker_id(group, subgroup, i_subgroup)
    self._trackers:AddTracker({
        id = tracker_id,
        icons = visibility_data.icons,
        key = id,
        time = 100, -- Set the initial time to 100, the timer will get accurate the next frame
        upgrades = upgrades,
        group = group,
        subgroup = subgroup,
        i_subgroup = i_subgroup,
        hint = visibility_data.hint,
        theme = visibility_data.theme,
        class = "EHITimerGroupTracker"
    })
    local active_group = self._groups[group]
    active_group.count = active_group.count + 1
    active_group[subgroup] = { count = 1, { name = tracker_id, timer_count = 1 } }
    self._units_in_active_group[id] = tracker_id
end

---@param id string Unit key
---@param group string
---@param subgroup number
---@param i_subgroup number
---@param upgrades table?
---@param visibility_data table
function EHITimerManager:AddTimer_iSubgroup(id, group, subgroup, i_subgroup, upgrades, visibility_data)
    local tracker_id = self._get_tracker_id(group, subgroup, i_subgroup)
    self._trackers:AddTracker({
        id = tracker_id,
        icons = visibility_data.icons,
        key = id,
        time = 100, -- Set the initial time to 100, the timer will get accurate the next frame
        upgrades = upgrades,
        group = group,
        subgroup = subgroup,
        i_subgroup = i_subgroup,
        hint = visibility_data.hint,
        theme = visibility_data.theme,
        class = "EHITimerGroupTracker"
    })
    local active_group = self._groups[group]
    active_group.count = active_group.count + 1
    local active_subgroup = active_group[subgroup]
    active_subgroup.count = active_subgroup.count + 1
    active_subgroup[i_subgroup] = { name = tracker_id, timer_count = 1 }
    self._units_in_active_group[id] = tracker_id
end

---@param unit_id string Unit Key
---@param tracker_id string
function EHITimerManager:_add_active_unit(unit_id, tracker_id)
    self._units_in_active_group[unit_id] = tracker_id
end

---@param group string
---@param subgroup number
---@param i_subgroup number
function EHITimerManager._get_tracker_id(group, subgroup, i_subgroup)
    return string.format("timergroup_%s%d%d", group, subgroup, i_subgroup)
end

---@param skills table?
function EHITimerManager._compute_subgroup(skills)
    local subgroup = 0
    if skills then
        --[[
            upgrade_table = {
                faster = (skills.speed_upgrade_level or 0),
                silent = (skills.reduced_alert and 1 or 0) + (skills.silent_drill and 1 or 0),
                restarter = (skills.auto_repair_level_1 or 0) + (skills.auto_repair_level_2 or 0)
            }
        ]]
        subgroup = skills.speed_upgrade_level or 0
        if skills.reduced_alert then
            subgroup = subgroup + 10
        end
        if skills.silent_drill then
            subgroup = subgroup + 20
        end
        if (skills.auto_repair_level_1 or 0) > 0 then
            subgroup = subgroup + 100
        end
        if (skills.auto_repair_level_2 or 0) > 0 then
            subgroup = subgroup + 200
        end
    end
    return subgroup
end

---@param params table
function EHITimerManager:StartTimer(params)
    if self._grouping_is_enabled and not params.no_grouping then
        local group = params.group
        local subgroup = self._compute_subgroup(params.skills)
        local add_subgroup, add_i_subgroup, i_subgroup = false, false, 1
        if self._groups[group] then
            if self._groups[group][subgroup] then
                local group_i = 0
                for i, i_sub in ipairs(self._groups[group][subgroup]) do
                    group_i = i
                    if i_sub.timer_count < self._max_timers then
                        i_sub.timer_count = i_sub.timer_count + 1
                        self._trackers:CallFunction(i_sub.name, "AddTimer", params.time, params.id)
                        self:_add_active_unit(params.id, i_sub.name)
                        return
                    end
                end
                i_subgroup = group_i + 1
                add_i_subgroup = true
            else
                add_subgroup = true
            end
        end
        local tracker_id = self._get_tracker_id(group, subgroup, i_subgroup)
        self:_add_active_unit(params.id, tracker_id)
        params.id = tracker_id
        params.class = "EHITimerGroupTracker"
        params.subgroup = subgroup
        params.i_subgroup = i_subgroup
        if add_i_subgroup then
            local active_subgroup = self._groups[group][subgroup]
            active_subgroup.count = active_subgroup.count + 1
            active_subgroup[i_subgroup] = { name = tracker_id, timer_count = 1 }
        elseif add_subgroup then
            local active_group = self._groups[group]
            active_group.count = active_group.count + 1
            active_group[subgroup] = { count = 1, { name = tracker_id, timer_count = 1 } }
        else -- add group
            self._groups[group] = { [subgroup] = { count = 1, { name = tracker_id, timer_count = 1 } }, count = 1 }
        end
    end
    self._trackers:AddTracker(params)
end

---@param id string Unit Key
function EHITimerManager:StopTimer(id)
    local active_group = table.remove_key(self._units_in_active_group, id)
    if active_group then
        local group, subgroup, i_subgroup = self._trackers:ReturnValue(active_group, "GetGroupData")
        self:RemoveTimerFromGroup(id, group, subgroup, i_subgroup)
    else
        self._trackers:RemoveTracker(id)
    end
end

---@param id string Unit Key
---@param group string
---@param subgroup number
---@param i_subgroup number
function EHITimerManager:RemoveTimerFromGroup(id, group, subgroup, i_subgroup)
    local g = self._groups[group]
    local s = g and g[subgroup]
    local i = s and s[i_subgroup]
    if i then
        i.timer_count = i.timer_count - 1
        if i.timer_count <= 0 then -- Remove the i_subgroup
            self._groups[group][subgroup][i_subgroup] = nil
            self._trackers:ForceRemoveTracker(i.name)
            s.count = s.count - 1
            if s.count <= 0 then
                self._groups[group][subgroup] = nil
                g.count = g.count - 1
                if g.count <= 0 then
                    self._groups[group] = nil
                end
            end
        else
            self._trackers:CallFunction(i.name, "StopTimer", id)
        end
    end
end

---@param id string Unit Key
---@param t number
function EHITimerManager:SetTimerTime(id, t)
    self._trackers:CallFunction(self._units_in_active_group[id] or id, "SetTimeNoAnim", t, id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
---@param t number
---@param t_string string
function EHITimerManager:SetTimerTimeNoFormat(id, t, t_string)
    self._trackers:CallFunction(self._units_in_active_group[id] or id, "SetTimeNoFormat", t, t_string, id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
---@param jammed boolean
function EHITimerManager:SetTimerJammed(id, jammed)
    self._trackers:CallFunction(self._units_in_active_group[id] or id, "SetJammed", jammed, id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
---@param powered boolean
function EHITimerManager:SetTimerPowered(id, powered)
    self._trackers:CallFunction(self._units_in_active_group[id] or id, "SetPowered", powered, id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
---@param state boolean
function EHITimerManager:SetTimerAutorepair(id, state)
    self._trackers:CallFunction(self._units_in_active_group[id] or id, "SetAutorepair", state, id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
function EHITimerManager:SetTimerRunning(id)
    self._trackers:CallFunction(self._units_in_active_group[id] or id, "SetRunning", id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
function EHITimerManager:IsTimerMergeRunning(id)
    return self._trackers:ReturnValue(self._units_in_active_group[id] or id, "IsTimerMergeRunning", id) -- To keep compatibility with `EHITimerTracker`
end

---@param id string Unit Key
function EHITimerManager:TimerExists(id)
    return self._trackers:TrackerExists(self._units_in_active_group[id] or id)
end

---@param timer_gui TimerGui
function EHITimerManager:SetTimerUpgrades(timer_gui)
    local id = timer_gui._ehi_key
    local upgrades, skills = timer_gui:GetUpgrades()
    if self._grouping_is_enabled then
        local unit_group = self._units_in_active_group[id]
        if unit_group then
            local group, subgroup, i_subgroup = self._trackers:ReturnValue(unit_group, "GetGroupData")
            local new_subgroup = self._compute_subgroup(skills)
            if subgroup ~= new_subgroup then
                if self._groups[group] then
                    local visibility_data = timer_gui:GetVisibilityData()
                    local g_i_subgroup = self._groups[group][new_subgroup]
                    if g_i_subgroup then -- New subgroup exists, check to what tracker we can add it
                        local new_i_group = 0
                        for i, sub in ipairs(g_i_subgroup) do
                            new_i_group = i
                            if sub.timer_count < self._max_timers then
                                sub.timer_count = sub.timer_count + 1
                                -- Set the initial time to 100, the timer will get accurate the next frame
                                self._trackers:CallFunction(sub.name, "AddTimer", 100, id)
                                self:RemoveTimerFromGroup(id, group, subgroup, i_subgroup)
                                self._units_in_active_group[id] = sub.name
                                return
                            end
                        end -- Unfortunately all active subgroups are full, create a new i_subgroup
                        self:AddTimer_iSubgroup(id, group, subgroup, new_i_group + 1, upgrades, visibility_data)
                    else -- New subgroup does not exist, needs to be created
                        self:AddTimerSubgroup(id, group, new_subgroup, 1, upgrades, visibility_data)
                    end
                    self:RemoveTimerFromGroup(id, group, subgroup, i_subgroup)
                end
            end
        end
    else
        self._trackers:CallFunction(id, "SetUpgrades", upgrades)
    end
end