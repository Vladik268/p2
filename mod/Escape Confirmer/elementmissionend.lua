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

if RequiredScript == "lib/managers/chatmanager" then
Hooks:PostHook(ChatManager, "send_message", "inttester", function(self, channel_id, sender, message,...)
	if managers.network:session() then

		if message == "escape" then

		_G._can_escape = true

			if delayed_escape then
			delayed_escape()
			end

		end
	end
end)

elseif RequiredScript == "lib/managers/mission/elementmissionend"
then
    local orig_exec_end = ElementMissionEnd.on_executed
function ElementMissionEnd:delayed_execute(instigator,...)
return orig_exec_end(self,instigator,...)
    end

function ElementMissionEnd:on_executed(instigator,...)
_G.delayed_escape = callback(self,self,"delayed_execute",instigator,...)
if _G._can_escape then

return orig_exec_end(self,instigator,...)
end
    
end

    

end