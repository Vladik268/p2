local function _Update_omniscience_addon(omniscience, t)
	if omniscience then
		if omniscience < t then
			HUDManager:init_circle_ui(true)

			if not SC then
				HUDManager:reset_circle_ui()
			end
		end
	else
		HUDManager:init_circle_ui(false)
	end
end

local hook_func = "_update_omniscience"

if SC then
	hook_func = "update"
end

Hooks:PreHook(PlayerStandard, hook_func, "_update_omniscienceSXSV", function(self, t, dt)
	_Update_omniscience_addon(self._state_data.omniscience_t, t)
end)