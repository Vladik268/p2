local EHI = EHI
if EHI:CheckLoadHook("VehicleDrivingExt") then
    return
end

if EHI:IsTradeTrackerDisabled() or EHI:GetOption("show_trade_delay_option") == 2 then
    return
end

---@class VehicleDrivingExt
---@field _unit UnitVehicle
---@field _seats table
---@field _vehicle C_Vehicle

local original =
{
	init = VehicleDrivingExt.init,
	_detect_npc_collisions = VehicleDrivingExt._detect_npc_collisions
}

function VehicleDrivingExt:init(...)
	original.init(self, ...)
	self._ehi_flesh_slotmask = managers.slot:get_mask("flesh")
	self._ehi_all_criminals_slotmask = managers.slot:get_mask("all_criminals")
end

function VehicleDrivingExt:_detect_npc_collisions(...)
	local vel = self._vehicle:velocity()
	if vel:length() < 150 then
		return
	end
	local oobb = self._unit:oobb()
	local units = World:find_units("intersect", "obb", oobb:center(), oobb:x(), oobb:y(), oobb:z(), self._ehi_flesh_slotmask) ---@type UnitCivilian[]
	for _, unit in ipairs(units) do
		if not unit:in_slot(self._ehi_all_criminals_slotmask) and unit:character_damage() and not unit:character_damage():dead() and unit:base():has_tag("civilian") then
            local attacker_unit = nil
            if self._seats.driver.occupant ~= managers.player:local_player() then
				attacker_unit = self._seats.driver.occupant --[[@as UnitPlayer]]
			end
			unit:character_damage():_on_car_damage_received(attacker_unit)
		end
	end
    original._detect_npc_collisions(self, ...)
end