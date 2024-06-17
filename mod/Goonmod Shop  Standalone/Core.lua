
if not _G.GageModShop then
	_G.GageModShop = {}
	GageModShop.mod_path = ModPath
end

GageModShop.dofiles = {
	"mod_shop.lua"
}

GageModShop.hook_files = {
	["lib/managers/menu/blackmarketgui"] = "Lua/BlackMarketGUI.lua",
	["lib/managers/blackmarketmanager"] = "Lua/BlackMarketManager.lua"
}

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_GageModShop", function( loc )
	for _, filename in pairs(file.GetFiles( GageModShop.mod_path .. "Localization/")) do
		local str = filename:match('^(.*).json$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			loc:load_localization_file( GageModShop.mod_path .. "Localization/" .. filename)
			break
		end
	end
	loc:load_localization_file( GageModShop.mod_path .. "Localization/english.json", false)
end)

if not GageModShop.setup then

	for p, d in pairs(GageModShop.dofiles) do
		dofile(ModPath .. d)
	end
	GageModShop.setup = true
	log("[GageModShop] Loaded options")
end

if RequiredScript then
	local requiredScript = RequiredScript:lower()
	if GageModShop.hook_files[requiredScript] then
		dofile( ModPath .. GageModShop.hook_files[requiredScript] )
	end
end


