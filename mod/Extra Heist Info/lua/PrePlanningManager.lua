local EHI = EHI
if EHI:CheckLoadHook("PrePlanningManager") then
    return
end

---@class PrePlanningManager
---@field _finished_preplan table
---@field _reserved_mission_elements table
---@field get_current_majority_votes fun(self: self): table
---@field get_mission_element_id fun(self: self, type: string, index: number): number?
---@field has_current_level_preplanning fun(self: self): boolean

local preplan_reserved = nil
local preplan_voted = nil

local original = PrePlanningManager.on_execute_preplanning
function PrePlanningManager:on_execute_preplanning(...)
    if self:has_current_level_preplanning() then
        preplan_reserved = deep_clone(self._reserved_mission_elements)
        local winners = self:get_current_majority_votes()
        if winners then
            preplan_voted = {}
            for _, data in pairs(winners) do
                local type, index = unpack(data)
                if type and index then
                    local element_id = self:get_mission_element_id(type, index)
                    if element_id then
                        preplan_voted[element_id] = true
                    end
                end
            end
        end
    end
    original(self, ...)
end

---@param asset_id number
---@return boolean
function PrePlanningManager:IsAssetBought(asset_id)
    if self._finished_preplan then
        local voted = self._finished_preplan[1]
        for _, assets in pairs(voted or {}) do
            if assets[asset_id] then
                return true
            end
        end
        local reserved = self._finished_preplan[2]
        for _, assets in pairs(reserved or {}) do
            if assets[asset_id] then
                return true
            end
        end
    elseif preplan_reserved and preplan_reserved[asset_id] then
        return true
    elseif preplan_voted and preplan_voted[asset_id] then
        return true
    end
    return false
end