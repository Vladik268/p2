local playedmapescape = tostring(Global.game_settings.level_id)
if	playedmapescape == "chill_combat"
	or playedmapescape == "haunted"
	or playedmapescape == "nmh"
	or playedmapescape == "pal"
	or playedmapescape == "cage"
	or playedmapescape == "mad"
	or playedmapescape == "pbr2"
	or playedmapescape == "jolly"
	or playedmapescape == "pbr"
	or playedmapescape == "wwh"
	or playedmapescape == "hvh"
	or playedmapescape == "moon" 
	or playedmapescape == "skm_mus" 
	or playedmapescape == "skm_red2" 
	or playedmapescape == "skm_run" 
	or playedmapescape == "skm_bex" 
	or playedmapescape == "skm_arena" 
	or playedmapescape == "skm_big2" 
	or playedmapescape == "skm_cas" 
	or playedmapescape == "skm_mallcrasher" 
	or playedmapescape == "skm_watchdogs_stage2" 
then return end
if managers.network:session() then
	if not _G._can_escape then
		_G._can_escape = true
		if delayed_escape then
		delayed_escape() 
		end
	end
end
