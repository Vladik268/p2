local EHI = EHI
if EHI:CheckLoadHook("ECMJammerBase") or not EHI:GetOption("show_equipment_tracker") then
    return
end

---@class ECMJammerBase
---@field _feedback_duration number?
---@field _owner UnitPlayer
---@field _owner_id number
---@field _position Vector3
---@field _unit UnitECM
---@field battery_life fun(self: self): number
---@field owner fun(self: self): UnitPlayer

local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_ecmjammer")
local WWaypoint = EHI.Waypoints.Warning

local original =
{
    spawn = ECMJammerBase.spawn,
    set_server_information = ECMJammerBase.set_server_information,
    set_owner = ECMJammerBase.set_owner,
    sync_setup = ECMJammerBase.sync_setup,
    destroy = ECMJammerBase.destroy
}

---@param pos Vector3
---@param rot Rotation
---@param battery_life_upgrade_lvl number
---@param owner NetworkPeer
---@param peer_id number
---@return UnitECM
function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
    local unit = original.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
    unit:base():SetPeerID(peer_id)
	return unit
end

---@param peer_id number
function ECMJammerBase:set_server_information(peer_id, ...)
    original.set_server_information(self, peer_id, ...)
    self:SetPeerID(peer_id)
end

function ECMJammerBase:sync_setup(upgrade_lvl, peer_id, ...)
    original.sync_setup(self, upgrade_lvl, peer_id, ...)
    self:SetPeerID(peer_id)
end

function ECMJammerBase:set_owner(...)
    original.set_owner(self, ...)
    self:SetPeerID(self._owner_id or 0)
    managers.ehi_tracker:CallFunction("ECMJammer", "UpdateOwnerID", self._ehi_peer_id)
    managers.ehi_tracker:CallFunction("ECMFeedback", "UpdateOwnerID", self._ehi_peer_id)
end

---@param peer_id number
function ECMJammerBase:SetPeerID(peer_id)
    local id = peer_id or 0
    self._ehi_peer_id = id
    self._ehi_local_peer = id == managers.network:session():local_peer():id()
end

function ECMJammerBase:GetECMPosition()
    local body = self._unit:get_object(Idstring("g_ecm"))
    return body and body:position() or self._position
end

if EHI:GetOption("show_equipment_ecmjammer") then
    local BlockECMsWithoutPagerBlocking = EHI:GetOption("ecmjammer_block_ecm_without_pager_delay")
    original.set_active = ECMJammerBase.set_active
    function ECMJammerBase:set_active(active, ...)
        original.set_active(self, active, ...)
        if active then
            local battery_life = self:battery_life()
            if battery_life == 0 then
                return
            end
            if BlockECMsWithoutPagerBlocking then
                if self._ehi_local_peer and not managers.player:has_category_upgrade("ecm_jammer", "affects_pagers") then
                    return
                elseif self._ehi_peer_id ~= 0 then
                    local peer = managers.network:session():peer(self._ehi_peer_id)
                    if peer and peer._unit and peer._unit.base and not peer._unit:base():upgrade_value("ecm_jammer", "affects_pagers") then
                        return
                    end
                end
            end
            if not show_waypoint_only then
                if managers.ehi_tracker:CallFunction2("ECMJammer", "SetTimeIfLower", battery_life, self._ehi_peer_id, self._unit) then
                    managers.ehi_tracker:AddTracker({
                        id = "ECMJammer",
                        time = battery_life,
                        icons = { { icon = "ecm_jammer", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) } },
                        unit = self._unit,
                        hint = "ecm_jammer",
                        class = "EHIECMTracker"
                    })
                end
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(tostring(self._unit:key()), {
                    time = battery_life,
                    icon = "ecm_jammer",
                    position = self:GetECMPosition(),
                    class = WWaypoint
                })
            end
        end
    end
end

if EHI:GetOption("show_equipment_ecmfeedback") then
    EHI:HookWithID(ECMJammerBase, "_set_feedback_active", "EHI_ECMJammerBase_set_feedback_active_true",
    ---@param self ECMJammerBase
    ---@param state boolean
    function(self, state)
        if state and self._feedback_duration then
            if managers.ehi_tracker:CallFunction2("ECMFeedback", "SetTimeIfLower", self._feedback_duration, self._ehi_peer_id, self._unit) then
                managers.ehi_tracker:AddTracker({
                    id = "ECMFeedback",
                    time = self._feedback_duration,
                    icons = { { icon = "ecm_feedback", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) } },
                    unit = self._unit,
                    hint = "ecm_feedback",
                    class = "EHIECMTracker"
                })
            end
        end
    end)
end

if EHI:GetOption("show_ecmfeedback_refresh") then
    EHI:HookWithID(ECMJammerBase, "_set_feedback_active", "EHI_ECMJammerBase_set_feedback_active_false",
    ---@param self ECMJammerBase
    ---@param state boolean
    function(self, state)
        if not state and not self.__ehi_destroying then
            if alive(self._owner) then
                local retrigger = false
				if self._ehi_local_peer then
					retrigger = managers.player:has_category_upgrade("ecm_jammer", "can_retrigger")
				else
					retrigger = self:owner():base():upgrade_value("ecm_jammer", "can_retrigger")
				end
				if retrigger then
                    local key = "ECMFeedbackRetrigger_" .. tostring(self._unit:key())
                    local retrigger_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
                    if not show_waypoint_only then
                        managers.ehi_tracker:AddTracker({
                            id = key,
                            time = retrigger_t,
                            icons = { { icon = "ecm_feedback", color = EHI:GetPeerColorByPeerID(self._ehi_peer_id) }, "restarter" },
                            hint = "ecm_feedback_refresh"
                        })
                    end
                    if show_waypoint then
                        managers.ehi_waypoint:AddWaypoint(key, {
                            time = retrigger_t,
                            icon = "restarter",
                            position = self:GetECMPosition()
                        })
                    end
				end
            end
        end
    end)
end

function ECMJammerBase:destroy(...)
    self.__ehi_destroying = true
    original.destroy(self, ...)
    managers.ehi_tracker:CallFunction("ECMJammer", "Destroyed", self._unit)
    managers.ehi_tracker:CallFunction("ECMFeedback", "Destroyed", self._unit)
    managers.ehi_waypoint:RemoveWaypoint(tostring(self._unit:key()))
    managers.ehi_manager:Remove("ECMFeedbackRetrigger_" .. tostring(self._unit:key()))
end