local class_name = "g_stoic_logic_and_kingpin_auto_injector"
local loc = _G[class_name.."_loc"]

if not loc then
	return
end

Hooks:Add("LocalizationManagerPostInit", class_name.."Loc", function(loc)
	LocalizationManager:add_localized_strings({
		[class_name.."_menu_title"] = "Perk Logic",
		[class_name.."_menu_desc"] = "Set options for stoic/kingpin/leech perk.",
		
		[class_name.."auto_use_leech_ampule_title"] = "Auto Leech",
		[class_name.."auto_use_leech_ampule_desc"] = "Auto use leech ampule before enemy die.",
		[class_name.."auto_use_king_injector_title"] = "Auto Kingpin",
		[class_name.."auto_use_king_injector_desc"] = "Auto use kingpin injector when armor breaks.",
		[class_name.."auto_use_stoic_flash_title"] = "Auto Stoic",
		[class_name.."auto_use_stoic_flash_desc"] = "Auto use stoic flask when damage over time has reached a set percent.",
		[class_name.."damage_over_time_percentage_title"] = "Auto Stoic Percentage",
		[class_name.."damage_over_time_percentage_desc"] = "Percentage of when the flask will be used. The lower the value, the slower the useage will be. (Requires Auto Stoic Enabled)",
		[class_name.."prevent_miss_press_title"] = "Prevent Flask Mispress",
		[class_name.."prevent_miss_press_desc"] = "Prevents you from using the stoic flask when damage over time is not active.",
		[class_name.."use_armor_for_Stoic_title"] = "Armored Stoic",
		[class_name.."use_armor_for_Stoic_desc"] = "Convert all health into armor and have damage over time as armor instead of health.",
		[class_name.."bullseye_restore_health_title"] = "Bullseye Heal",
		[class_name.."bullseye_restore_health_desc"] = "The bullseye skill will regen health instead of armor when using stoic/kingpin/leech perk.",
		[class_name.."bullseye_restore_percentage_title"] = "Aced Bullseye Percentage",
		[class_name.."bullseye_restore_percentage_desc"] = "Percentage of how much aced bullseye will heal your health. (Requires Bullseye Heal Enabled)                         Bullseye Aced is default 25 and not 20 as the game show.",
		[class_name.."kingpin_health_activation_percentage_title"] = "Auto Kingpin Percentage",
		[class_name.."kingpin_health_activation_percentage_desc"] = "How low your health needs to be before the injector is used after the armor breaks.",
		[class_name.."enemies_in_unit_camera_range_title"] = "FOV trigger For Kingpin",
		[class_name.."enemies_in_unit_camera_range_desc"] = "Minimum amount of enemies in your FOV before triggering kingpin. 0 = Off"
	})
end)

Hooks:Add("MenuManagerSetupCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	MenuHelper:NewMenu(class_name)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	MenuCallbackHandler.auto_use_leech_ampule = function(self, item)
		loc.config.auto_use_leech_ampule = not loc.config.auto_use_leech_ampule
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = "auto_use_leech_ampule",
		title = class_name.."auto_use_leech_ampule_title",
		desc = class_name.."auto_use_leech_ampule_desc",
		callback = "auto_use_leech_ampule",
		value = loc.config.auto_use_leech_ampule,
		menu_id = class_name,  
		priority = 101
	})
	
	MenuCallbackHandler.auto_use_king_injector = function(self, item)
		loc.config.auto_use_king_injector = not loc.config.auto_use_king_injector
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = "auto_use_king_injector",
		title = class_name.."auto_use_king_injector_title",
		desc = class_name.."auto_use_king_injector_desc",
		callback = "auto_use_king_injector",
		value = loc.config.auto_use_king_injector,
		menu_id = class_name,  
		priority = 100
	})
	
	MenuCallbackHandler.auto_use_stoic_flash = function(self, item)
		loc.config.auto_use_stoic_flash = not loc.config.auto_use_stoic_flash
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = "auto_use_stoic_flash",
		title = class_name.."auto_use_stoic_flash_title",
		desc = class_name.."auto_use_stoic_flash_desc",
		callback = "auto_use_stoic_flash",
		value = loc.config.auto_use_stoic_flash,
		menu_id = class_name,  
		priority = 99
	})
	
	MenuCallbackHandler.prevent_miss_press = function(self, item)
		loc.config.prevent_miss_press = not loc.config.prevent_miss_press
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = "prevent_miss_press",
		title = class_name.."prevent_miss_press_title",
		desc = class_name.."prevent_miss_press_desc",
		callback = "prevent_miss_press",
		value = loc.config.prevent_miss_press,
		menu_id = class_name,  
		priority = 98
	})
	
	MenuCallbackHandler.use_armor_for_Stoic = function(self, item)
		loc.config.use_armor_for_Stoic = not loc.config.use_armor_for_Stoic
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = "use_armor_for_Stoic",
		title = class_name.."use_armor_for_Stoic_title",
		desc = class_name.."use_armor_for_Stoic_desc",
		callback = "use_armor_for_Stoic",
		value = loc.config.use_armor_for_Stoic,
		menu_id = class_name,  
		priority = 97
	})
	
	MenuCallbackHandler.bullseye_restore_health = function(self, item)
		loc.config.bullseye_restore_health = not loc.config.bullseye_restore_health
		loc:save_config()
	end
	
	MenuHelper:AddToggle({
		id = "bullseye_restore_health",
		title = class_name.."bullseye_restore_health_title",
		desc = class_name.."bullseye_restore_health_desc",
		callback = "bullseye_restore_health",
		value = loc.config.bullseye_restore_health,
		menu_id = class_name,  
		priority = 96
	})
	
	MenuCallbackHandler.damage_over_time_percentage = function(self, item)
		local value = item:value() / 100
		loc.config.damage_over_time_percentage = tonumber(value)
		loc:save_config()
	end
	
	MenuHelper:AddSlider({
		id = "damage_over_time_percentage",
		title = class_name.."damage_over_time_percentage_title",
		desc = class_name.."damage_over_time_percentage_desc",
		callback = "damage_over_time_percentage",
		value = (tonumber(loc.config.damage_over_time_percentage) * 100),
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = class_name,
		priority = 95
	})

	MenuCallbackHandler.kingpin_health_activation_percentage = function(self, item)
		local value = item:value() / 100
		loc.config.kingpin_health_activation_percentage = tonumber(value)
		loc:save_config()
	end
	
	MenuHelper:AddSlider({
		id = "kingpin_health_activation_percentage",
		title = class_name.."kingpin_health_activation_percentage_title",
		desc = class_name.."kingpin_health_activation_percentage_desc",
		callback = "kingpin_health_activation_percentage",
		value = (tonumber(loc.config.kingpin_health_activation_percentage) * 100),
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = class_name,
		priority = 94
	})

	MenuCallbackHandler.bullseye_restore_percentage = function(self, item)
		local value = item:value() / 100
		loc.config.bullseye_restore_percentage = tonumber(value)
		loc:save_config()
	end
	
	MenuHelper:AddSlider({
		id = "bullseye_restore_percentage",
		title = class_name.."bullseye_restore_percentage_title",
		desc = class_name.."bullseye_restore_percentage_desc",
		callback = "bullseye_restore_percentage",
		value = (tonumber(loc.config.bullseye_restore_percentage) * 100),
		min = 1,
		max = 100,
		step = 1,
		show_value = true,
		menu_id = class_name,
		priority = 93
	})

	MenuCallbackHandler.enemies_in_unit_camera_range = function(self, item)
		loc.config.enemies_in_unit_camera_range = tonumber(item:value())
		loc:save_config()
	end
	
	MenuHelper:AddSlider({
		id = "enemies_in_unit_camera_range",
		title = class_name.."enemies_in_unit_camera_range_title",
		desc = class_name.."enemies_in_unit_camera_range_desc",
		callback = "enemies_in_unit_camera_range",
		value = tonumber(loc.config.enemies_in_unit_camera_range),
		min = 0,
		max = 20,
		step = 1,
		show_value = true,
		menu_id = class_name,
		priority = 92
	})
end)

Hooks:Add("MenuManagerBuildCustomMenus", class_name.."Menu", function(menu_manager, nodes)
	nodes[class_name] = MenuHelper:BuildMenu(class_name)
	MenuHelper:AddMenuItem(nodes["blt_options"], class_name, class_name.."_menu_title", class_name.."_menu_desc")
end)