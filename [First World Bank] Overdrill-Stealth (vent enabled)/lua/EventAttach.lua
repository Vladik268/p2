core:module("CoreElementCounter")
core:import("CoreMissionScriptElement")
core:import("CoreClass")
ElementCounter = ElementCounter or class(CoreMissionScriptElement.MissionScriptElement)

if not Global.game_settings or not Global.game_settings.level_id or not Global.game_settings.level_id == "red2" then
	return
end

local PainfullOverdrill_ElementCounter_on_executed = ElementCounter.on_executed

local PainfullOverdrill = {}

function ElementCounter:on_executed(...)
	local _id = tostring(self._id)
	if _id == "132053" or _id == "132056" or _id == "132058" or _id == "132059" or _id == "132061" then
		if PainfullOverdrill['Ready2CloseVent'] and not PainfullOverdrill[_id] then
			PainfullOverdrill[_id] = 1
			PainfullOverdrill['Ready2CloseVent'] = 2
			self._values.counter_target = 1
		end
	end
	if PainfullOverdrill['Ready2CloseVent'] == 3 and PainfullOverdrill[_id] == 1 then
		PainfullOverdrill[_id] = 2
	end
	if _id == "106692" or _id == "106946" or _id == "106947" or _id == "101024" then
		self._values.counter_target = 1
		PainfullOverdrill['Ready2CloseVent'] = 1
	end
	if not PainfullOverdrill['MoreLoot'] and managers and managers.loot and managers.hud and managers.loot:get_mandatory_bags_data().amount < 84 then
		PainfullOverdrill['MoreLoot'] = true
		managers.loot:get_mandatory_bags_data().amount = 84
	end
	PainfullOverdrill_ElementCounter_on_executed(self, ...)
	if PainfullOverdrill['Ready2CloseVent'] == 2 and PainfullOverdrill[_id] and self._values.counter_target <= 0 then
		PainfullOverdrill['Ready2CloseVent'] = 3
		local _run = {
			'103974',
			'104136',
			'104194',
			'104181',
			'104193',
			'104303'
		}
		local _runE = {
		}
		for _, script in pairs(managers.mission:scripts()) do
			for idx, element in pairs(script:elements()) do
				idx = tostring(idx)
				if table.contains(_run, idx) then
					if element then
						table.insert(_runE, element)
					end
				end
			end
		end
		for _, element in pairs(_runE) do
			element:on_executed()
		end
	end
end