local EHI = EHI
if EHI:CheckLoadHook("GamePlayCentralManager") then
    return
end

---@class GamePlayCentralManager
---@field _mission_disabled_units table
---@field get_heist_timer fun(self: self): number

local original =
{
    load = GamePlayCentralManager.load
}

if EHI:IsHost() then
    original.restart_the_game = GamePlayCentralManager.restart_the_game
    function GamePlayCentralManager:restart_the_game(...)
        EHI:CallCallbackOnce(EHI.CallbackMessage.GameRestart)
        original.restart_the_game(self, ...)
    end
else
    original.stop_the_game = GamePlayCentralManager.stop_the_game
    function GamePlayCentralManager:stop_the_game(...)
        EHI:CallCallbackOnce(EHI.CallbackMessage.GameRestart)
        original.stop_the_game(self, ...)
    end
end

function GamePlayCentralManager:load(data, ...)
    original.load(self, data, ...)
	local state = data.GamePlayCentralManager
    local heist_timer = state.heist_timer or 0
    managers.ehi_manager:LoadTime(heist_timer)
end

---@param id number
---@return boolean
function GamePlayCentralManager:GetMissionDisabledUnit(id)
    return self._mission_disabled_units[id]
end

---@param id number
---@return boolean
function GamePlayCentralManager:GetMissionEnabledUnit(id)
    return not self:GetMissionDisabledUnit(id)
end