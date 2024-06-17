---@class GroupAITweakData
---@field special_unit_spawn_limits table

---@param enemy_name string
function GroupAITweakData:IsSpecialEnemyAllowedToSpawn(enemy_name)
    if self.special_unit_spawn_limits then
        local spawn_limit = self.special_unit_spawn_limits[enemy_name] or 0
        return spawn_limit > 0
    end
    return false
end