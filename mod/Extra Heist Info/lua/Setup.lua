local EHI = EHI
EHI._cache.is_vr = _G.IS_VR
managers.ehi_experience = EHIExperienceManager
if EHI:CheckLoadHook("Setup") then
    return
end
EHI:InitEventListener()
dofile(EHI.LuaPath .. "EHIBaseManager.lua")
dofile(EHI.LuaPath .. "EHITrackerManager.lua")
dofile(EHI.LuaPath .. "EHIWaypointManager.lua")
dofile(EHI.LuaPath .. "EHIBuffManager.lua")
dofile(EHI.LuaPath .. "EHIDeployableManager.lua")
if EHI:IsVR() then
    dofile(EHI.LuaPath .. "EHITrackerManagerVR.lua")
    dofile(EHI.LuaPath .. "EHIDeployableManagerVR.lua")
end
dofile(EHI.LuaPath .. "EHITradeManager.lua")
dofile(EHI.LuaPath .. "EHIEscapeChanceManager.lua")
dofile(EHI.LuaPath .. "EHIAssaultManager.lua")
dofile(EHI.LuaPath .. "EHIAchievementManager.lua")
dofile(EHI.LuaPath .. "EHIPhalanxManager.lua")
dofile(EHI.LuaPath .. "EHITimerManager.lua")
dofile(EHI.LuaPath .. "EHILootManager.lua")
dofile(EHI.LuaPath .. "EHISyncManager.lua")
dofile(EHI.LuaPath .. "EHIManager.lua")

local original =
{
    init_managers = Setup.init_managers,
    init_finalize = Setup.init_finalize
}

---@param managers managers
function Setup:init_managers(managers, ...)
    original.init_managers(self, managers, ...)
    managers.ehi_tracker = EHITrackerManager:new()
    managers.ehi_waypoint = EHIWaypointManager:new()
    managers.ehi_buff = EHIBuffManager:new()
    managers.ehi_trade = EHITradeManager:new(managers.ehi_tracker)
    managers.ehi_escape = EHIEscapeChanceManager:new(managers.ehi_tracker)
    managers.ehi_deployable = EHIDeployableManager:new(managers.ehi_tracker)
    managers.ehi_assault = EHIAssaultManager:new(managers.ehi_tracker)
    managers.ehi_experience:TrackersInit(managers.ehi_tracker)
    managers.ehi_achievement = EHIAchievementManager:new(managers.ehi_tracker)
    managers.ehi_phalanx = EHIPhalanxManager
    managers.ehi_timer = EHITimerManager:new(managers.ehi_tracker)
    managers.ehi_loot = EHILootManager:new(managers.ehi_tracker)
    managers.ehi_sync = EHISyncManager
    managers.ehi_manager = EHIManager:new(managers)
    EHI:CallCallbackOnce(EHI.CallbackMessage.InitManagers, managers)
end

function Setup:init_finalize(...)
    original.init_finalize(self, ...)
    managers.ehi_manager:init_finalize()
end