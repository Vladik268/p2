local permission = Global.game_settings.permission

if permission == "friends_only" or "private" then
	managers.player:set_player_state("throw_grenade")
	managers.hud:show_hint( { text = "shh..." } )
end