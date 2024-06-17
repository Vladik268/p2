local EHI = EHI
---@class EHIAchievementManager
EHIAchievementManager = {}
EHIAchievementManager.GetAchievementIcon = EHI.GetAchievementIcon
EHIAchievementManager.IsHost = EHI:IsHost()
EHIAchievementManager._achievement_data_sync =
{
    [EHI.Trackers.Achievement.Base] =
    {
        time = 0
    },
    [EHI.Trackers.Achievement.Progress] =
    {
        progress = 0
    },
    [EHI.Trackers.Achievement.Status] =
    {
        status = "ok"
    }
}
---@param ehi_tracker EHITrackerManager
function EHIAchievementManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._mission_achievements = {} --[[@as table<string, {class: string, started: boolean, sync_params: ParseAchievementDefinitionTable.sync_params, data: table, app_t: number }> ]]
    return self
end

function EHIAchievementManager:load(data)
    local load_data = data.EHIAchievementManager
    if load_data and EHI:ShowMissionAchievements() then
        for key, save_data in pairs(load_data) do
            local achievement = self._mission_achievements[key]
            if achievement and self._trackers:TrackerDoesNotExist(key) then
                achievement.started = true
                self._trackers:AddTracker({
                    id = key,
                    time = 1,
                    icons = self:GetAchievementIcon(key),
                    class = save_data.class or EHI.Trackers.Achievement.Base
                })
                self._trackers:CallFunction(key, "load", save_data.data)
            end
        end
    end
end

function EHIAchievementManager:save(data)
    local save_data = {}
    local all_trackers = self._trackers._trackers --[[@as table<string, { tracker: EHIAchievementTracker }>]]
    for key, def in pairs(all_trackers) do
        if def.tracker.save then
            local tracker_save_data = { data = {} }
            def.tracker:save(tracker_save_data.data)
            tracker_save_data.class = self._mission_achievements[key].class
            save_data[key] = tracker_save_data
        end
    end
    for key, value in pairs(self._mission_achievements) do
        if not save_data[key] and value.started then
            local achievement_save_data = { data = {} }
            for var_name, achievement_data in pairs(value.data) do
                achievement_save_data.data[var_name] = achievement_data
            end
            achievement_save_data.class = value.class
            achievement_save_data.app_t = value.app_t
            save_data[key] = achievement_save_data
        end
    end
    data.EHIAchievementManager = save_data
end

---@param achievement_id string
---@param id string
function EHIAchievementManager:AddTFCallback(achievement_id, id)
    local cleanup_callback = function()
        managers.mission:remove_global_event_listener(id)
    end
    managers.mission:add_global_event_listener(id, { "TheFixes_AchievementFailed" }, function(a_id)
        if a_id == achievement_id then
            self:SetAchievementFailed(achievement_id)
        end
    end)
    return cleanup_callback
end

---@param def table<string, ParseAchievementDefinitionTable>
function EHIAchievementManager:ParseAchievementDefinition(def)
    for key, value in pairs(def) do
        if value.difficulty_pass ~= false and not ((value.sync_params and value.sync_params.from_start) or value.load_sync) then -- Don't sync achievements that requires playing from start or clients have defined syncing function
            local achievement = { data = {} }
            for _, trigger in pairs(value.elements or {}) do
                if trigger.class then
                    achievement.class = trigger.class
                    local data_sync = value.data_sync or self._achievement_data_sync[trigger.class or ""] or self._achievement_data_sync[EHI.Trackers.Achievement.Base]
                    if data_sync then
                        for sync_key, default_value in pairs(data_sync) do
                            achievement.data[sync_key] = trigger[sync_key] or default_value
                        end
                    else
                        EHI:Log("[EHIAchievementManager:ParseAchievementDefinition()] data_sync does not exist! Nothing will get synced to clients! Game may also crash due to nil value!")
                    end
                    break
                end
            end
            if not achievement.class then
                EHI:Log("[EHIAchievementManager:ParseAchievementDefinition()] class does not exist! Using base achievement class to not crash")
                achievement.class = EHI.Trackers.Achievement.Base
            end
            achievement.sync_params = value.sync_params or {}
            self._mission_achievements[key] = achievement
        end
    end
end

---@param id string
function EHIAchievementManager:SetAchievementStarted(id)
    local achievement = self._mission_achievements[id]
    if achievement then
        achievement.started = true
        achievement.app_t = managers.game_play_central:get_heist_timer()
    end
end

---@param id string
---@param key string
---@param value any
function EHIAchievementManager:SetAchievementData(id, key, value)
    local achievement = self._mission_achievements[id]
    if achievement and achievement.data then
        achievement.data[key] = value
    end
end

---@param id string
function EHIAchievementManager:SetAchievementDone(id)
    local achievement = self._mission_achievements[id]
    if achievement then
        achievement.started = nil
    end
end

---@param trigger ElementTrigger
function EHIAchievementManager:StartAchievement(trigger)
    self:SetAchievementStarted(trigger.id)
    self._trackers:AddTracker(trigger)
end

---@param id string
---@param time_max number
function EHIAchievementManager:AddTimedAchievementTracker(id, time_max)
    local t = time_max - math.max(managers.ehi_manager._t, self._trackers._t)
    if t <= 0 then
        return
    end
    self:SetAchievementStarted(id)
    self:SetAchievementData(id, "time", t)
    self._trackers:AddTracker({
        id = id,
        time = t,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Base
    })
end

---@param id string
---@param max number
---@param progress number?
---@param show_finish_after_reaching_target boolean?
---@param class string?
function EHIAchievementManager:AddAchievementProgressTracker(id, max, progress, show_finish_after_reaching_target, class)
    self:SetAchievementStarted(id)
    self:SetAchievementData(id, "progress", progress or 0)
    self._trackers:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = self:GetAchievementIcon(id),
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = class or EHI.Trackers.Achievement.Progress
    })
end

---@param id string
---@param status string?
function EHIAchievementManager:AddAchievementStatusTracker(id, status)
    self:SetAchievementStarted(id)
    self:SetAchievementData(id, "status", status or "ok")
    self._trackers:AddTracker({
        id = id,
        status = status,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Status
    })
end

---@param id string
---@param max number
---@param loot_counter_on_fail boolean?
---@param start_silent boolean?
function EHIAchievementManager:AddAchievementLootCounter(id, max, loot_counter_on_fail, start_silent)
    self._trackers:AddTracker({
        id = id,
        max = max,
        icons = self:GetAchievementIcon(id),
        loot_counter_on_fail = loot_counter_on_fail,
        start_silent = start_silent,
        class = EHI.Trackers.Achievement.LootCounter
    })
end

---@param id string
---@param max number
---@param show_finish_after_reaching_target boolean?
function EHIAchievementManager:AddAchievementBagValueCounter(id, max, show_finish_after_reaching_target)
    self._trackers:AddTracker({ -- `uno_1` achievement gets synced via `LootLoadSync` callback
        id = id,
        max = max,
        icons = self:GetAchievementIcon(id),
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        class = EHI.Trackers.Achievement.BagValue
    })
end

---@param id string
---@param progress number
---@param max number
function EHIAchievementManager:AddAchievementKillCounter(id, progress, max)
    self._trackers:AddTracker({ -- Both `ranc_9` and `ranc_11` achievements are local only, no need to sync
        id = id,
        progress = progress,
        max = max,
        icons = self:GetAchievementIcon(id),
        class = EHI.Trackers.Achievement.Progress
    })
end

---@param id string
---@param force boolean?
function EHIAchievementManager:SetAchievementComplete(id, force)
    self:SetAchievementDone(id)
    self._trackers:CallFunction(id, "SetCompleted", force)
end

---@param id string
function EHIAchievementManager:SetAchievementFailed(id)
    self:SetAchievementDone(id)
    self._trackers:CallFunction(id, "SetFailed")
end

---@param id string
function EHIAchievementManager:SetAchievementFailedSilent(id)
    self:SetAchievementDone(id)
    self._trackers:CallFunction(id, "SetFailedSilent")
end

---@param id string
---@param status string
function EHIAchievementManager:SetAchievementStatus(id, status)
    self:SetAchievementData(id, "status", status or "ok")
    self._trackers:CallFunction(id, "SetStatus", status)
end