HUDTeammate = HUDTeammate or class()

function HUDTeammate:set_info_meter_fast(data)
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = self._radial_health_panel
	local radial_info_meter = radial_health_panel:child("radial_info_meter")
	local radial_info_meter_bg = radial_health_panel:child("radial_info_meter_bg")
	local red = math.clamp(data.total / data.max, 0, 1)

	radial_info_meter_bg:set_color(Color(1, red, 1, 1))
	radial_info_meter_bg:set_visible(red > 0)
	radial_info_meter_bg:set_rotation(red * 360)

	local red = math.clamp(data.current / data.max, 0, 1)

	radial_info_meter:stop()
	radial_info_meter:animate(function (o)
		local s = radial_info_meter:color().r
		local e = red

		over(0.01, function (p)
			local c = math.lerp(s, e, p)

			radial_info_meter:set_color(Color(1, c, 1, 1))
			radial_info_meter:set_visible(c > 0)
		end)
	end)
end