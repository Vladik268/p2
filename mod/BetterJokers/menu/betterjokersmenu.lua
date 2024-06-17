dofile(ModPath .. "core.lua")

Hooks:Add('LocalizationManagerPostInit', 'betterjokersmenu_loadlocalization', function(loc)
	loc:load_localization_file(BetterJokers.ModPath .. 'menu/betterjokers_en.json', false)
end)

Hooks:Add('MenuManagerInitialize', 'betterjokersmenu_init', function(menu_manager)

	MenuCallbackHandler.bjsave = function(this, item)
		BetterJokers:Save()
	end

	MenuCallbackHandler.bj_donothing = function(this, item)
		-- do nothing
	end

	MenuCallbackHandler.bj_joker_exclusive_access = function(this, item)
		BetterJokers.settings.joker_exclusive_access = item:value() == 'on'
		BetterJokers:Save()
	end

	MenuCallbackHandler.bj_joker_my_contours = function(this, item)
		BetterJokers.settings.joker_my_contours = item:value() == 'on'
		BetterJokers:Save()
	end

	MenuCallbackHandler.bj_joker_other_contours = function(this, item)
		BetterJokers.settings.joker_other_contours = item:value() == 'on'
		BetterJokers:Save()
	end

	MenuCallbackHandler.bj_disable_incompatibility_warnings = function(this, item)
		BetterJokers.settings.disable_incompatibility_warnings = item:value() == 'on'
		BetterJokers:Save()
	end

	MenuCallbackHandler.bjcwp_show_other_waypoints = function(this, item)
		BetterJokers.settings.waypoint_show_others = item:value() == 'on'
		BetterJokers:Save()
	end

	MenuCallbackHandler.bj_joker_show_health = function(this, item)
		BetterJokers.settings.joker_show_health = item:value() == 'on'
		BetterJokers:Save()
	end	

	MenuHelper:LoadFromJsonFile(BetterJokers.ModPath .. 'menu/betterjokersmenu.json', BetterJokers, BetterJokers.settings)
end)

if not BetterJokers.settings.disable_incompatibility_warnings then
	Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_betterjokers_keepers_warning", function(menu_manager, nodes)
		local kprs = BLT.Mods:GetModByName("Keepers")
		if not kprs or not kprs:IsEnabled() then
			return
		end
	
		QuickMenu:new("Keepers Detected", "You are using Keepers, which has feature overlap with Better Jokers. We strongly recommend removing or disabling either Keepers or Better Jokers to avoid crashing.\n\nYou can disable this warning in the Better Jokers mod options.", {
			[1] = {
				text = "OK",
				is_cancel_button = true
			}
		}):show()
	end)
end
