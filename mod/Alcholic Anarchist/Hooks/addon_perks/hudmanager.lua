HUDManager = HUDManager or class()

function HUDManager:set_info_meter_fast(i, data)
	if self._teammate_panels[i or HUDManager.PLAYER_PANEL].set_info_meter_fast then
		self._teammate_panels[i or HUDManager.PLAYER_PANEL]:set_info_meter_fast(data)
	else
		self._teammate_panels[i or HUDManager.PLAYER_PANEL]:set_info_meter(data)
	end
end
