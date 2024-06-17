Hooks:PostHook( BlackMarketTweakData , "_init_melee_weapons" , "MeleeDecapBlackMarketTweakDataPostInitMeleeWeapons" , function( self , tweak_data )

	for k , v in pairs( self.melee_weapons ) do
		if not v.melee_type then
			v.melee_type = MeleeDecap:MeleeType( k )
		end
	end

	-- Fixes the null DLC error in M.O.RE's databasae
	self.melee_weapons.ballistic.dlc = nil

end )