local EHI = EHI
if EHI:CheckLoadHook("GageAssignmentManager") then
    return
end

---@class GageAssignmentManager
---@field _tweak_data GageAssignmentTweakData
---@field count_all_units fun(self: self): number
---@field count_active_units fun(self: self): number

local original =
{
    sync_load = GageAssignmentManager.sync_load,
    present_progress = GageAssignmentManager.present_progress
}

---@param self GageAssignmentManager
---@param client_sync_load boolean?
local function UpdateTracker(self, client_sync_load)
    local max_units = self:count_all_units()
    local picked_up = self:GetCountOfRemainingPackages()
    if client_sync_load and not Global.statistics_manager.playing_from_start then
        picked_up = math.max(picked_up - 1, 0)
    end
    EHI:CallCallback(EHI.CallbackMessage.SyncGagePackagesCount, picked_up, max_units, client_sync_load)
end

function GageAssignmentManager:GetCountOfRemainingPackages()
    local max_units = self:count_all_units()
    local remaining = self:count_active_units() - 1
    return max_units - remaining
end

function GageAssignmentManager:present_progress(...)
    original.present_progress(self, ...)
    UpdateTracker(self)
end

function GageAssignmentManager:sync_load(...)
    original.sync_load(self, ...)
    UpdateTracker(self, true)
end

if not EHI:GetOption("show_gage_tracker") then
    return
end

if EHI:GetOption("gage_tracker_panel") == 1 then
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, function(picked_up, max_units, client_sync_load)
        managers.ehi_tracker:SetTrackerProgress("Gage", picked_up)
    end)
else
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, function(picked_up, max_units, client_sync_load)
        if (client_sync_load and Global.statistics_manager.playing_from_start) or not EHI:AreGagePackagesSpawned() then
            return
        end
        managers.hud:custom_ingame_popup_text(managers.localization:text("ehi_popup_gage_packages"), tostring(picked_up) .. "/" .. tostring(max_units), "EHI_Gage")
    end)
end