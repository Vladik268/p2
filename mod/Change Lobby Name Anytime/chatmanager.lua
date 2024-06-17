--We're not doing this with hooks and whatnot because we want the original call to be stopped when we send a message with /lobbyname and such.
--Also not doing this with CloneClass because uhhhhhhh BLT already clones it or something
--Pardon me if I'm an idiot

if SystemInfo:distribution() == Idstring("STEAM") then
	local send_message_real = _send_message_real or ChatManager.send_message --Original call gets stored here

	function ChatManager:send_message(channel_id, sender, message)
		if not string.is_nil_or_empty(message) and Network:is_server() then --Crashes the game if not hosting, for obvious reasons
			if string.sub(message, 1, 10) == "/lobbyname" then --Pretty crude but it works
				local newname = string.sub(message, 12, 43)
				if string.is_nil_or_empty(newname) then --Just "/lobbyname".
					managers.network.matchmake:broadcast_lobby_info() --Tell everyone what the lobby's name is right now
				elseif newname == "reset" or newname == "clear" then
					managers.network.matchmake:set_desired_lobby_name(managers.network.account:username())
				else
					managers.network.matchmake:set_desired_lobby_name(newname)
				end
				return
			end
			if string.sub(message, 1, 10) == "/lobbydesc" or string.sub(message, 1, 10) == "/lobbyinfo" then
				local newname = string.sub(message, 12, 267)
				if string.is_nil_or_empty(newname) then
					managers.network.matchmake:broadcast_lobby_info()
				elseif newname == "reset" or newname == "clear" then
					managers.network.matchmake:set_desired_lobby_desc("")
				else
					managers.network.matchmake:set_desired_lobby_desc(newname)
				end
				return
			end
		end
		send_message_real(self, channel_id, sender, message) --Original call
	end
end