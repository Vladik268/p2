---@class HUDMissionBriefing
---@field _foreground_layer_one Panel

local EHI = EHI
if EHI:CheckLoadHook("HUDMissionBriefing") or Global.game_settings.single_player or EHI:IsXPTrackerDisabled() or not EHI:GetOption("show_mission_xp_overview") then
    return
end

---@param panel_w number
function HUDMissionBriefing:MoveJobName(panel_w)
    if self.__ehi_moved then
        return
    end
    local job = self._foreground_layer_one and self._foreground_layer_one:child("job_text") --[[@as PanelText?]]
    if job then
        job:set_x(job:x() + panel_w) -- +351 | +365 (with controller)
        self.__ehi_moved = true
    end
end