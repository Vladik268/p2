local origfunc = MenuCallbackHandler.build_mods_list
function MenuCallbackHandler:build_mods_list(...)
	origfunc(self, ...)
	
	return {
		{'SuperBLT', 'SuperBLT'},
		{'unlock_all_dlcs', 'unlock_all_dlcs'},
		{'BeardLib', 'BeardLib'},
		
		
		
		
		}
end