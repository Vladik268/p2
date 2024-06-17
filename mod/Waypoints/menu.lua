--Original by SilentSeduction (silentseduction@web.de)

local menu_id = "waypoints_menu"

_G.Waypoints = {}
Waypoints.path = ModPath
Waypoints.settings_path = SavePath .. "Waypoints.json"
Waypoints.settings = {}
Waypoints.keys = {"showDistance", "showGagePickups", "showPlanks", "showSmallLoot", "showCrates", "showDoors", "showCameraComputers", "showDrills", "showThermite", "showSewerManhole", "showLocks", "showSecretLoot", "makeNoise", "sheaterNewb"}

function Waypoints:Save()
	local file = io.open(self.settings_path, "w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function Waypoints:Load()
	local file = io.open(self.settings_path, "r")
	if file then
		self.settings = json.decode(file:read("*all"))
		file:close()
	end
	self.settings["showDistance"] = self.settings["showDistance"] or false
	self.settings["showGagePickups"] = self.settings["showGagePickups"] or true
	self.settings["showPlanks"] = self.settings["showPlanks"] or false
	self.settings["showSmallLoot"] = self.settings["showSmallLoot"] or true
	self.settings["showCrates"] = self.settings["showCrates"] or true
	self.settings["showDoors"] = self.settings["showDoors"] or true
	self.settings["showCameraComputers"] = self.settings["showCameraComputers"] or true
	self.settings["showDrills"] = self.settings["showDrills"] or true
	self.settings["showThermite"] = self.settings["showThermite"] or true
	self.settings["showSewerManhole"] = self.settings["showSewerManhole"] or false
	self.settings["showLocks"] = self.settings["showLocks"] or false
	self.settings["showSecretLoot"] = self.settings["showSecretLoot"] or true
	self.settings["makeNoise"] = self.settings["makeNoise"] or false
	self.settings["sheaterNewb"] = self.settings["sheaterNewb"] or true
end

Waypoints:Load()
Waypoints:Save()

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_Waypoints", function(menu_manager, nodes)
	MenuHelper:NewMenu(menu_id)
end)

MenuCallbackHandler.callback_waypoint_toggle = function(self, item)
	Waypoints.settings[item:name()] = (item:value() == "on")
	Waypoints:Save()
end

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_Waypoints", function(menu_manager, nodes)
	for _,setting in pairs(Waypoints.keys) do
		MenuHelper:AddToggle({
				id = setting,
				title = "waypoints_" .. setting,
				desc = "waypoints_" .. setting .. "_desc",
				callback = "callback_waypoint_toggle",
				value = Waypoints.settings[setting],
				menu_id = menu_id
			})
	end
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_Waypoints", function(menu_manager, nodes)
	nodes[menu_id] = MenuHelper:BuildMenu(menu_id)
	MenuHelper:AddMenuItem(nodes["blt_options"], menu_id, "waypoints_menu_title", "waypoints_menu_desc")
end)

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_Waypoints", function(loc)
	loc:load_localization_file(Waypoints.path .. "en.json")
end)