local EHI = EHI
if EHI:CheckLoadHook("SmokeScreenEffect") then
    return
end
local show_waypoint, show_waypoint_only = false, true
if EHI:GetOption("show_mission_trackers") then
    show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_mission")
end
local buffs = EHI:GetBuffAndBuffDeckOption("sicario", "smoke_bomb")

if show_waypoint then
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, function(managers)
        ---@class EHISmokeBombWaypoint : EHIWaypoint
        EHISmokeBombWaypoint = class(EHIWaypoint)
        ---@param params table
        function EHISmokeBombWaypoint:post_init(params)
            self:SetColor(params.color)
        end
    end)
end

local original_init = SmokeScreenEffect.init
---@param position Vector3
---@param normal number math.UP
---@param time number
---@param has_dodge_bonus boolean
---@param grenade_unit Unit?
function SmokeScreenEffect:init(position, normal, time, has_dodge_bonus, grenade_unit, ...)
    original_init(self, position, normal, time, has_dodge_bonus, grenade_unit, ...)
    local key, color_id
    if grenade_unit and alive(grenade_unit:base():thrower_unit()) then
        local thrower = grenade_unit:base():thrower_unit()
        key = self._mine and "Mine" or tostring(thrower:key())
        color_id = managers.criminals:character_color_id_by_unit(thrower)
    else
        key = "ThrowerUnitInCustody_" .. TimerManager:game():time()
        color_id = #tweak_data.chat_colors
    end
    local color = tweak_data.chat_colors[color_id] or Color.white
    if not show_waypoint_only then
        managers.ehi_tracker:AddTracker({
            id = "SmokeScreenGrenade_" .. key,
            time = time,
            icons = {
                {
                    icon = "smoke",
                    color = color
                }
            }
        })
    end
    if show_waypoint then
        managers.ehi_waypoint:AddWaypoint("SmokeScreenGrenade_" .. key, {
            time = time,
            icon = "smoke",
            position = position,
            color = color,
            class = "EHISmokeBombWaypoint"
        })
    end
    if self._mine and buffs then
        managers.ehi_buff:AddBuff("smoke_screen_grenade", time)
    end
end