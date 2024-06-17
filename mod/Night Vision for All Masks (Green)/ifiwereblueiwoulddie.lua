for k, v in pairs(tweak_data.blackmarket.masks) do
	v.night_vision = {
			effect = "color_night_vision",
			light = not _G.IS_VR and 0.3 or 0.1
		}
end