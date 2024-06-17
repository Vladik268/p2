_G.CircleUI = _G.CircleUI or {}
CircleUI._path = ModPath
CircleUI._data_path = SavePath .. "CircleUI_data.txt"
CircleUI._data = {}

function CircleUI:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function CircleUI:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize__", function(menu_manager)
	MenuCallbackHandler.circle_ui_on_state_change_callback = function(self,item)
		CircleUI._data.circle_ui_color = item:value()
		CircleUI:Save()
	end
	MenuCallbackHandler.experimentalFeature_change_callback = function(self,item)
		CircleUI._data.experimentalFeature = item:value()
		CircleUI:Save()
	end
	MenuCallbackHandler.circle_ui_closed = function(self)
		CircleUI:Save()
	end
	CircleUI:Load()
	MenuHelper:LoadFromJsonFile(CircleUI._path .. "menu/options.txt", CircleUI, CircleUI._data)
end)