local EHI = EHI

---@class EHISyncManager
EHISyncManager = {}
function EHISyncManager:save(data)
    local state = {}
    state.has_useful_bots = UsefulBots ~= nil
    state.has_bots_enabled = Global.game_settings.team_ai
    data.EHISyncManager = state
end

function EHISyncManager:load(data)
    local state = data.EHISyncManager
    if state and state.has_useful_bots then
        EHI._cache.HostHasUsefulBots = true
        EHI._cache.HostHasBots = state.has_bots_enabled
        local briefing = managers.menu_component and managers.menu_component._mission_briefing_gui
        if briefing and briefing.RefreshXPOverview then
            briefing:RefreshXPOverview()
        end
        if EHI:IsXPTrackerEnabledAndVisible() then
            managers.ehi_experience:SetAIOnDeathListener()
            managers.ehi_experience:SetCriminalsListener(true)
        end
    end
end