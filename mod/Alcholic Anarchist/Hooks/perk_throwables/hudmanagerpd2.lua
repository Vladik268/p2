function HUDManager:activate_local_ability_radial_with_fullscreen(time_left)
    local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

    function make_bitmap()
        return hud.panel:bitmap({
			name = "custom_fullscreen_effect",
			visible = false,
			texture = "guis/textures/full_screen_effect_1",
			layer = 0,
			color = Color(1, 0.1, 0),
			blend_mode = "add",
			w = hud.panel:w(),
			h = hud.panel:h(),
			x = 0,
			y = 0 
		})
    end

    local custom_fullscreen_effect = hud.panel:child("custom_fullscreen_effect") or make_bitmap()

	local function anim(o)
		custom_fullscreen_effect:set_visible(true)
		over(time_left, function (p)
			
		end)
		custom_fullscreen_effect:set_visible(false)
	end

	custom_fullscreen_effect:stop()
	custom_fullscreen_effect:animate(anim)
    -- TODO add this? managers.hud:activate_teammate_ability_radial(HUDManager.PLAYER_PANEL, duration)
end