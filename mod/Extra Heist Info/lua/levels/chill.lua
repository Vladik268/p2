local EHI = EHI
---@class EHIStopwatchTracker : EHITracker
---@field super EHITracker
EHIStopwatchTracker = class(EHITracker)
EHIStopwatchTracker._forced_icons = { EHI.Icons.Wait }
function EHIStopwatchTracker:update(dt)
	if self._to_delete then
		self._to_delete = self._to_delete - dt
		if self._to_delete <= 0 then
			self:delete()
		end
		return
	end
    self._time = self._time + dt
    self._text:set_text(self:Format())
end

do
	local math_floor = math.floor
    local string_format = string.format
	if EHI:GetOption("time_format") == 1 then
		EHIStopwatchTracker.Format = function(self)
			local t = math_floor(self._time * 10) / 10
			if t < 0 then
				return string_format("%d", 0)
			elseif t < 100 then
				return string_format("%.2f", self._time)
			elseif t < 1000 then
				return string_format("%.1f", self._time)
			else
				return string_format("%d", t)
			end
		end
	else
		EHIStopwatchTracker.Format = function(self)
			local t = math_floor(self._time * 10) / 10
			if t < 0 then
				return string_format("%d", 0)
			elseif t < 60 then
				return string_format("%.2f", self._time)
			else
				return string_format("%d:%02d", t / 60, t % 60)
			end
		end
	end
end

function EHIStopwatchTracker:Stop()
	self._to_delete = 5
	self:AnimateBG()
end

function EHIStopwatchTracker:Reset()
	self._time = 0
	self._to_delete = nil
end

local tbl =
{
    --levels/instances/unique/chill/hockey_game
    --units/pd2_dlc_chill/props/chl_prop_timer_small/chl_prop_timer_small
    [EHI:GetInstanceUnitID(100056, 15620)] = { ignore = true }
}
EHI:UpdateUnits(tbl)