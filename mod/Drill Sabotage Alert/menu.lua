_G.FOOMD = _G.FOOMD or {}
FOOMD._path = ModPath
FOOMD._data_path = SavePath .. "FOOMD_data.txt"
FOOMD._data = {
	Predict_Attempt = true,
    waypoint = true
}

function FOOMD:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function FOOMD:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitializeFOOMD", function(menu_manager)
	MenuCallbackHandler.FOOMD_change_Predict_Attempt = function(self,item)
        local value = item:value() == "on"
		FOOMD._data.Predict_Attempt = value
		FOOMD:Save()
	end
	MenuCallbackHandler.callback_FOOMD_waypoint = function(self,item)
		local value = item:value() == "on"
		FOOMD._data.waypoint = value
		FOOMD:Save()
	end
	MenuCallbackHandler.FOOMD_closed = function(self)
		FOOMD:Save()
	end
	FOOMD:Load()

	MenuHelper:LoadFromJsonFile(FOOMD._path .. "menu/options.txt", FOOMD, FOOMD._data)
end)