local logger = { }

logger.usecolor = true
logger.outfile = 'mods/logs/waypoints.txt'
logger.level = "trace"

local modes = {
  { name = "trace" },
  { name = "debug" },
  { name = "info" },
  { name = "warn" },
  { name = "error" },
  { name = "fatal" },
}

local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end

local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local _tostring = tostring
local tostring = function(...)
local t = {}
	for i = 1, select('#', ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = round(x, .01)
		end
		t[#t + 1] = _tostring(x)
	end
	return table.concat(t, " ")
end

function dump(o)
	if type(o) == 'table' then
		local table_count = 0
		for _ in pairs(o) do table_count = table_count + 1 end
		if table_count > 20 then
			return 'ERROR: !!!TABLE TOO LARGE!!!'
		end
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

for i, x in ipairs(modes) do
	local logging_level = x.name:upper()
	logger[x.name] = function(...)
		-- Return early if we're below the logger level
		if i < levels[logger.level] then
			return
		end
		
		local msg = tostring(...)
		local info = debug.getinfo(2, "Sl")
		local mod_name, lua_file_name = info.short_src:match("\\([^\\]*)\\([^\\]-)$")
		
		-- Output to logger file
		if logger.outfile then
			local fp = io.open(logger.outfile, "a")
			log(string.format("[%s] [%s] %s", logging_level, mod_name, msg))
			--fp:write(os.date("%m/%d/%Y %I:%M:%S %p", os.time(date)) .. " " .. string.format("[%s] [%s] %s:%s %s", logging_level, mod_name, lua_file_name, info.currentline, msg) ..'\n')
			fp:write(os.date("%m/%d/%Y %I:%M:%S %p", os.time(date)) .. " " .. string.format("[%s] [%s] %s", logging_level, mod_name, msg) ..'\n')
			fp:close()
		end
	end
end

function add_waypoint_interactable(unit)
	_waypointCount = _waypointCount + 1
	local waypoint_id = tostring(_waypointCount)
	managers.hud:add_waypoint( waypoint_id, { icon = 'pd2_phone', distance = true, position = unit:interaction():interact_position(), no_sync = true, present_timer = 0, state = "present", radius = 800, color = Color.green, blend_mode = "add" }  )
	local waypoint = managers.hud._hud.waypoints[waypoint_id]
	if ( waypoint ) then
		waypoint._unit = unit
		waypoint.move_speed = 0
	end
end

function add_waypoint_generic_unit(unit)
	_waypointCount = _waypointCount + 1
	local waypoint_id = tostring(_waypointCount)
	managers.hud:add_waypoint( waypoint_id, { icon = 'icon_locked', distance = true, position = unit:position(), no_sync = true, present_timer = 0, state = "present", radius = 800, color = Color.white, blend_mode = "add" }  )
	local waypoint = managers.hud._hud.waypoints[waypoint_id]
	if ( waypoint ) then
		waypoint._unit = unit
		waypoint.move_speed = 0
	end
end

function remove_all_waypoints()
	for id,waypoint in pairs( managers.hud._hud.waypoints ) do
		id = tostring(id)
		if id:sub(1,5) == 'hudz_' then
			if ( waypoint._unit and waypoint._unit:interaction() ) then
				waypoint._unit:interaction()._waypoint_id = nil
			elseif ( alive(waypoint.npc_unit) and waypoint.npc_unit:unit_data() ) then
				waypoint.npc_unit:unit_data()._waypoint_id = nil
			end
		end
		managers.hud:remove_waypoint( id )
	end
	_waypointCount = 0
end

if not _updateWaypoints then _updateWaypoints = HUDManager._update_waypoints end
function HUDManager:_update_waypoints(t, dt)
	_updateWaypoints(self, t, dt)
	for id, data in pairs(self._hud.waypoints) do
		if data.distance then
			data.distance:set_text(tostring(id))
		end
	end
end

remove_all_waypoints()
local ents_infront_of_player = World:find_units_quick("camera_cone", managers.player:player_unit():camera():camera_object(), Vector3(0, 0), 1.0, 300)
for id, unit in ipairs( ents_infront_of_player ) do
	if (managers.viewport:get_current_camera():world_to_screen(unit:position()).z > 100) then
		if (unit:interaction() ~= nil) then
			add_waypoint_interactable(unit)
		else
			add_waypoint_generic_unit(unit)
		end
	end
end

if not SimpleMenu then
	SimpleMenu = class()

	function SimpleMenu:init(title, message, options)
		self.dialog_data = { title = title, text = message, button_list = {},
							 id = tostring(math.random(0,0xFFFFFFFF)) }
		self.visible = false
		for _,opt in ipairs(options) do
			local elem = {}
			elem.text = opt.text
			opt.data = opt.data or nil
			opt.callback = opt.callback or nil
			elem.callback_func = callback(self, self, "_do_callback",
										  { data = opt.data,
											callback = opt.callback})
			elem.cancel_button = opt.is_cancel_button or false
			if opt.is_focused_button then
				self.dialog_data.focus_button = #self.dialog_data.button_list+1
			end
			table.insert(self.dialog_data.button_list, elem)
		end
		return self
	end

	function SimpleMenu:_do_callback(info)
		if info.callback then
			if info.data then
				info.callback(info.data)
			else
				info.callback()
			end
		end
		self.visible = false
	end

	function SimpleMenu:show()
		if self.visible then
			return
		end
		self.visible = true
		managers.system_menu:show(self.dialog_data)
	end

	function SimpleMenu:hide()
		if self.visible then
			managers.system_menu:close(self.dialog_data.id)
			self.visible = false
			return
		end
	end
end

patched_update_input = patched_update_input or function (self, t, dt )
	if self._data.no_buttons then
		return
	end
	
	local dir, move_time
	local move = self._controller:get_input_axis( "menu_move" )

	if( self._controller:get_input_bool( "menu_down" )) then
		dir = 1
	elseif( self._controller:get_input_bool( "menu_up" )) then
		dir = -1
	end
	
	if dir == nil then
		if move.y > self.MOVE_AXIS_LIMIT then
			dir = 1
		elseif move.y < -self.MOVE_AXIS_LIMIT then
			dir = -1
		end
	end

	if dir ~= nil then
		if( ( self._move_button_dir == dir ) and self._move_button_time and ( t < self._move_button_time + self.MOVE_AXIS_DELAY ) ) then
			move_time = self._move_button_time or t
		else
			self._panel_script:change_focus_button( dir )
			move_time = t
		end
	end

	self._move_button_dir = dir
	self._move_button_time = move_time
	
	local scroll = self._controller:get_input_axis( "menu_scroll" )
	-- local sdir
	if( scroll.y > self.MOVE_AXIS_LIMIT ) then
		self._panel_script:scroll_up()
		-- sdir = 1
	elseif( scroll.y < -self.MOVE_AXIS_LIMIT ) then
		self._panel_script:scroll_down()
		-- sdir = -1
	end
end
managers.system_menu.DIALOG_CLASS.update_input = patched_update_input
managers.system_menu.GENERIC_DIALOG_CLASS.update_input = patched_update_input

waypointcallback = function(waypoint)
	logger.info('Unit: ' .. dump(waypoint._unit))
	logger.info('Interaction: ' .. dump(waypoint._unit:interaction()))
	logger.info('Unit Data: ' .. dump(waypoint._unit:unit_data()))
end

cancelcallback = function()
	remove_all_waypoints()
end

local keys = {}
for k in pairs(managers.hud._hud.waypoints) do
    table.insert(keys, k)
end
table.sort(keys, function(a, b) return tonumber(a) < tonumber(b) end)

opts = {}
for _, k in ipairs(keys) do
    local waypoint = managers.hud._hud.waypoints[k]
	if (waypoint._unit) then
		table.insert( opts, { text = k, callback = waypointcallback, data = waypoint, is_focused_button = false } )
	end
end
table.insert( opts, { text = "Close", callback = cancelcallback, is_cancel_button = true } )
mymenu = SimpleMenu:new("Select Waypoint to Dump", "", opts)
mymenu:show()