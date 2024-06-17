local EHI = EHI
---@class EHIECMTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIECMTracker = class(EHIWarningTracker)
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIECMTracker:init(panel, params, parent_class)
    EHIECMTracker.super.init(self, panel, params, parent_class)
    self._unit = params.unit
end

function EHIECMTracker:SetTime(time)
    EHIECMTracker.super.SetTime(self, time)
    self:SetTextColor(Color.white)
end

function EHIECMTracker:SetTimeIfLower(time, owner_id, unit)
    if self._time >= time then
        return
    end
    self:SetTime(time)
    self:_UpdateOwnerID(owner_id)
    self._unit = unit
end

function EHIECMTracker:UpdateOwnerID(owner_id, unit)
    if self._unit == unit then
        self:SetIconColor(EHI:GetPeerColorByPeerID(owner_id))
    end
end

function EHIECMTracker:_UpdateOwnerID(owner_id)
    self:SetIconColor(EHI:GetPeerColorByPeerID(owner_id))
end

function EHIECMTracker:Destroyed(unit)
    if self._unit == unit then
        self:delete()
    end
end