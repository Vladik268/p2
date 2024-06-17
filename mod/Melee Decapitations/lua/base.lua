_G.MeleeDecap = _G.MeleeDecap or {}

MeleeDecap.ModPath = ModPath
MeleeDecap.SavePath = SavePath .. "MeleeDecapOptions.txt"
MeleeDecap.Options = MeleeDecap.Options or {}
MeleeDecap.Menu = "MeleeDecapMainMenu"

dofile( MeleeDecap.ModPath .. "lua/options.lua" )

local HookFiles = {
		[ "lib/tweak_data/blackmarket/meleeweaponstweakdata" ] 	= "lua/meleeweaponstweakdata.lua",
		[ "lib/units/beings/player/states/playerstandard" ] 	= "lua/playerstandard.lua",
		[ "lib/units/enemies/cop/copdamage" ] 					= "lua/copdamage.lua",
		[ "lib/units/enemies/cop/copmovement" ] 				= "lua/copmovement.lua"
}

function MeleeDecap:Save()

	local data = io.open( self.SavePath , "w+" )
	
	if data then
		data:write( json.encode( self.Options ) )
		data:close()
	end
	
end

function MeleeDecap:Load()

	local data = io.open( self.SavePath , "r" )
	
	if data then
		self.Options = json.decode( data:read( "*all" ) )
		data:close()
	end
	
end

function MeleeDecap:DefaultSettings()

	for k , v in pairs( MeleeDecap.MenuOptions.Toggle ) do
		if self:HasSetting( k ) == nil then MeleeDecap.Options[ k ] = v[ 4 ] end
	end
	for k , v in pairs( MeleeDecap.MenuOptions.Slider ) do
		if self:HasSetting( k ) == nil then MeleeDecap.Options[ k ] = v[ 7 ] end
	end
	for k , v in pairs( MeleeDecap.MenuOptions.MultipleChoice ) do
		if self:HasSetting( k ) == nil then MeleeDecap.Options[ k ] = v[ 5 ] end
	end
	
	self:Save()

end

function MeleeDecap:HasSetting( s )

	return MeleeDecap.Options[ s ]
	
end

MeleeDecap:Load()
MeleeDecap:DefaultSettings()

function MeleeDecap:MeleeType( m )

	for k , v in ipairs( MeleeDecap.BluntWeapons ) do
		if m == v then return "Blunt" end
	end
	for k , v in ipairs( MeleeDecap.SmallBladedWeapons ) do
		if m == v then return "SmallBladed" end
	end
	return "LargeBladed"

end

Hooks:Add( "MenuManagerSetupCustomMenus" , "MeleeDecapMenuManagerPostSetupCustomMenus" , function( self , nodes )
    
	MenuHelper:NewMenu( MeleeDecap.Menu )
	
	for k , v in pairs( MeleeDecap.MenuOptions.Menu ) do
		MenuHelper:NewMenu( k )
	end
	
end )

Hooks:Add( "LocalizationManagerPostInit" , "MeleeDecapLocalizationManagerPostInit" , function( self )

	self:load_localization_file( MeleeDecap.ModPath .. "loc/english.txt" )
	
	for _ , file in pairs( file.GetFiles( MeleeDecap.ModPath .. "loc/" ) ) do
		local loc = file:match( '^(.*).txt$' )
		
		if loc and Idstring( loc ) and Idstring( loc ):key() == SystemInfo:language():key() then
			self:load_localization_file( MeleeDecap.ModPath .. "loc/" .. file )
		end
	end

end )

Hooks:Add( "MenuManagerBuildCustomMenus" , "MeleeDecapMenuManagerPostBuildCustomMenus" , function( self , nodes )
	
	nodes[ MeleeDecap.Menu ] = MenuHelper:BuildMenu( MeleeDecap.Menu , { focus_changed_callback = "MeleeDecapMenuMOTDFocus" } )
    MenuHelper:AddMenuItem( nodes["blt_options"] , MeleeDecap.Menu , "more_options_menu_title" , "more_options_menu_desc" )
	
	for k , v in pairs( MeleeDecap.MenuOptions.Menu ) do	
		nodes[ k ] = MenuHelper:BuildMenu( k , v[ 4 ] )
		MenuHelper:AddMenuItem( nodes[ MeleeDecap.Menu ] , k , v[ 1 ] , v[ 2 ] , v[ 3 ] )
	end
	
end )

Hooks:Add( "MenuManagerPopulateCustomMenus" , "MeleeDecapMenuManagerPostPopulateCustomMenus" , function( self , nodes )

	MenuCallbackHandler.MeleeDecapMainMenuButtonCallback = function( self ) end
	
	MenuHelper:AddButton({
		id 			= "MeleeDecapMainMenuButton",
		title 		= "",
		desc 		= "",
		callback 	= "MeleeDecapMainMenuButtonCallback",
		menu_id 	= "MeleeDecapMainMenu",
		localized 	= false
	})
	
	for k , v in pairs( MeleeDecap.MenuOptions.Toggle ) do
	
		MenuCallbackHandler[ k .. "Toggle" ] = function( self , item )
			MeleeDecap.Options[ k ] = item:value() == "on" or false
			MeleeDecap:Save()
		end
		
		MenuHelper:AddToggle({
			id 			= "ID" .. k .. "Toggle",
			title 		= v[ 2 ],
			desc 		= v[ 3 ],
			callback 	= k .. "Toggle",
			menu_id 	= v[ 1 ],
			value 		= MeleeDecap.Options[ k ]
		})
		
	end
	
	for k , v in pairs( MeleeDecap.MenuOptions.Slider ) do
	
		MenuCallbackHandler[ k .. "Slider" ] = function( self , item )
			MeleeDecap.Options[ k ] = item:value()
			MeleeDecap:Save()
		end
		
		MenuHelper:AddSlider({
			id 			= "ID" .. k .. "Slider",
			title 		= v[ 2 ],
			desc 		= v[ 3 ],
			callback 	= k .. "Slider",
			value 		= MeleeDecap.Options[ k ],
			min 		= v[ 4 ],
			max 		= v[ 5 ],
			step 		= v[ 6 ],
			show_value 	= true,
			menu_id 	= v[ 1 ]
		})
		
	end
	
	for k , v in pairs( MeleeDecap.MenuOptions.MultipleChoice ) do
		
		local function returnTable( e )
			local t = {}
			for a , b in ipairs( e ) do
				table.insert( t , b[ 1 ] )
			end
			return t
		end
		
		MenuCallbackHandler[ k .. "MultipleChoice" ] = function( self , item )
			MeleeDecap.Options[ k ] = item:value()
			MeleeDecap:Save()
		end
		
		MenuHelper:AddMultipleChoice({
			id 			= "ID" .. k .. "MultipleChoice",
			title 		= v[ 2 ],
			desc 		= v[ 3 ],
			callback 	= k .. "MultipleChoice",
			items 		= returnTable( v[ 4 ] ),
			value 		= MeleeDecap.Options[ k ],
			menu_id 	= v[ 1 ]
		})
	
	end

end )

if RequiredScript then

	local requiredScript = RequiredScript:lower()
	
	if HookFiles[ requiredScript ] then
		dofile( MeleeDecap.ModPath .. HookFiles[ requiredScript ] )
	end
	
end