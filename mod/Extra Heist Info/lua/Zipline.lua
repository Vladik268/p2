---@class ZipLine
---@field _attached_bag Unit?
---@field _current_time number
---@field _sled_data { object: Unit? }
---@field _unit UnitZipline
---@field ziplines UnitZipline[]
---@field is_usage_type_bag fun(self: self): boolean
---@field is_usage_type_person fun(self: self): boolean
---@field total_time fun(self: self): number

local EHI = EHI
if EHI:CheckLoadHook("ZipLine") or not EHI:GetOption("show_zipline_timer") then
    return
end

local Icon = EHI.Icons

local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_zipline")

local original =
{
    init = ZipLine.init,
    update = ZipLine.update,
    release_bag = ZipLine.release_bag,
    set_usage_type = ZipLine.set_usage_type,
    attach_bag = ZipLine.attach_bag,
    set_user = ZipLine.set_user,
    sync_set_user = ZipLine.sync_set_user,
    destroy = ZipLine.destroy
}

function ZipLine:init(unit, ...)
    original.init(self, unit, ...)
    local key = tostring(unit:key())
    self._ehi_key_bag = key .. "_bag_drop"
    self._ehi_key_user = key .. "_person_drop"
    self._ehi_key_reset = key .. "_reset"
    if not show_waypoint_only then
        managers.ehi_tracker:PreloadTracker({
            id = self._ehi_key_bag,
            icons = { "zipline_bag" },
            hide_on_delete = true,
            hint = "zipline_bag"
        })
        managers.ehi_tracker:PreloadTracker({
            id = self._ehi_key_user,
            icons = { "Other_H_Any_DidntSee" }, -- gage3_13 achievement icon
            hide_on_delete = true,
            hint = "zipline_person"
        })
        managers.ehi_tracker:PreloadTracker({
            id = self._ehi_key_reset,
            icons = { "zipline", Icon.Loop },
            hide_on_delete = true,
            hint = "zipline_reset"
        })
    end
    if self:is_usage_type_bag() then
        self:HookUpdateLoop()
    end
end

function ZipLine:HookUpdateLoop()
    if self.__ehi_update_hooked then
        return
    end
    self.update = function(self, ...)
        original.update(self, ...)
        if self.__ehi_bag_attached and not self._attached_bag then
            self.__ehi_bag_attached = nil
            local t = self:total_time() * self._current_time
            managers.ehi_tracker:RemoveTracker(self._ehi_key_bag)
            managers.ehi_tracker:SetTrackerTimeNoAnim(self._ehi_key_reset, t)
            managers.ehi_waypoint:SetWaypointTime(self._ehi_key_reset, t)
        end
    end
    self.__ehi_update_hooked = true
end

function ZipLine:UnhookUpdateLoop()
    self.update = original.update
    self.__ehi_update_hooked = nil
end

function ZipLine:set_usage_type(...)
    original.set_usage_type(self, ...)
    if self:is_usage_type_bag() then
        self:HookUpdateLoop()
    else
        self:UnhookUpdateLoop()
    end
end

function ZipLine:release_bag(...)
    original.release_bag(self, ...)
    self.__ehi_bag_attached = nil
end

function ZipLine:GetMovingObject()
    return self._sled_data.object or self._unit
end

function ZipLine:attach_bag(...)
    original.attach_bag(self, ...)
    local total_time = self:total_time()
    local total_time_2 = total_time * 2
    managers.ehi_tracker:RunTracker(self._ehi_key_bag, { time = total_time })
    managers.ehi_tracker:RunTracker(self._ehi_key_reset, { time = total_time_2 })
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_reset, {
            time = total_time_2,
            icon = "zipline_bag",
            unit = self:GetMovingObject()
        })
    end
    self.__ehi_bag_attached = true
end

---@param self ZipLine
---@param unit Unit?
local function AddUserZipline(self, unit)
    if not unit then
        return
    end
    local total_time = self:total_time()
    local total_time_2 = total_time * 2
    managers.ehi_tracker:RunTracker(self._ehi_key_user, { time = total_time })
    managers.ehi_tracker:RunTracker(self._ehi_key_reset, { time = total_time_2 })
    if show_waypoint then
        local local_unit = unit == managers.player:player_unit()
        managers.ehi_waypoint:AddWaypoint(self._ehi_key_reset, {
            time = total_time_2,
            present_timer = local_unit and total_time, ---@diagnostic disable-line
            icon = "Other_H_Any_DidntSee",
            unit = self:GetMovingObject()
        })
    end
end

function ZipLine:set_user(unit, ...)
    AddUserZipline(self, unit)
    original.set_user(self, unit, ...)
end

function ZipLine:sync_set_user(unit, ...)
    AddUserZipline(self, unit)
    original.sync_set_user(self, unit, ...)
end

function ZipLine:destroy(...)
    managers.ehi_manager:ForceRemove(self._ehi_key_reset)
    managers.ehi_tracker:ForceRemoveTracker(self._ehi_key_bag)
    managers.ehi_tracker:ForceRemoveTracker(self._ehi_key_user)
    original.destroy(self, ...)
end