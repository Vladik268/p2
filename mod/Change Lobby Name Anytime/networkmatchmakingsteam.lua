--#########################################--
--############## GLOBAL VARS ##############--
--#########################################--
desired_name = desired_name or ""
function NetworkMatchMakingSTEAM:set_desired_lobby_name(message)
	desired_name = message
	self:change_lobby_name(message)
	managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "Set the lobby's name to: \"" .. message .. "\"") --Tell everyone in the lobby what's going on
end

function NetworkMatchMakingEPIC:set_desired_lobby_name(message)
	desired_name = message
	self:change_lobby_name(message)
	managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "Set the lobby's name to: \"" .. message .. "\"") --Tell everyone in the lobby what's going on
end

desired_desc = desired_desc or ""
function NetworkMatchMakingSTEAM:set_desired_lobby_desc(message)
	desired_desc = message
	if string.is_nil_or_empty(message) then
		managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "Cleared lobby description.") --Tell everyone in the lobby what's going on
	else
		managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "Set the lobby's description to: \"" .. message .. "\"") --Tell everyone in the lobby what's going on
	end
end

function NetworkMatchMakingEPIC:set_desired_lobby_desc(message)
	desired_desc = message
	if string.is_nil_or_empty(message) then
		managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "Cleared lobby description.") --Tell everyone in the lobby what's going on
	else
		managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", "Set the lobby's description to: \"" .. message .. "\"") --Tell everyone in the lobby what's going on
	end
end

--##########################################--
--############## NAME CHANGER ##############--
--##########################################--
function NetworkMatchMakingSTEAM:change_lobby_name(message)
	if self._lobby_attributes and not string.is_nil_or_empty(message) then
		self._lobby_attributes.owner_name = message
		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

function NetworkMatchMakingEPIC:change_lobby_name(message)
	if self._lobby_attributes and not string.is_nil_or_empty(message) then
		self._lobby_attributes.owner_name = message
		self.lobby_handler:set_lobby_data(self._lobby_attributes)
	end
end

--Your lobby name sort of replaces your in-game name when people join, this changes it back (called in a hook in a delayed call below)
function NetworkMatchMakingSTEAM:restore_host_name(peer)
	peer:send("request_player_name_reply", managers.network.account:username())
end

function NetworkMatchMakingEPIC:restore_host_name(peer)
	peer:send("request_player_name_reply", managers.network.account:username())
end

--Prevent the name from resetting after every heist.
local _set_attributes_real = _set_attributes_real or NetworkMatchMakingSTEAM.set_attributes --Original call gets stored here
function NetworkMatchMakingSTEAM:set_attributes(...)
	_set_attributes_real(self, ...) --Original call
	self:change_lobby_name(desired_name)
end

local _set_attributes_real_epic = _set_attributes_real_epic or NetworkMatchMakingEPIC.set_attributes
function NetworkMatchMakingEPIC:set_attributes(...)
	_set_attributes_real_epic(self, ...) 
	self:change_lobby_name(desired_name)
end

--Clear lobby name and description when the lobby closes
local _destroy_game_real = _destroy_game_real or NetworkMatchMakingSTEAM.destroy_game --Original call gets stored here
function NetworkMatchMakingSTEAM:destroy_game(...) 
	desired_name = ""
	desired_desc = ""
	_destroy_game_real(self, ...) --Original call
end

function NetworkMatchMakingEPIC:destroy_game(...) 
	desired_name = ""
	desired_desc = ""
	_destroy_game_real(self, ...) --Original call
end

--#######################################--
--############## ANNOUNCER ##############--
--#######################################--
Hooks:Add("NetworkManagerOnPeerAdded", "ChangeLobbyNameAnytime", function(peer, peer_id)
	if Network:is_server() then
		DelayedCalls:Add("UpdateHostName" .. tostring(peer_id), 1.5, function() --Happens slightly before the lobby info announcement
			local peer2 = managers.network:session() and managers.network:session():peer(peer_id)
			if peer2 then
				managers.network.matchmake:restore_host_name(peer2) --Important! Even with this, people will see the lobby name as YOUR name for a split second but I don't think there's a "true" fix
			end
		end)
		DelayedCalls:Add("AnnounceLobbyInfo" .. tostring(peer_id), 2, function()
			local peer2 = managers.network:session() and managers.network:session():peer(peer_id)
			if peer2 then
				if not string.is_nil_or_empty(desired_name) or not string.is_nil_or_empty(desired_desc) then --ONLY send a startup message when we have set a custom name or description!
					managers.network.matchmake:broadcast_lobby_info(peer2)
				end --it all, returns, to nothing
			end --it all comes
		end) --tumbling down
	end --tumbling down
end) --tumbling down~

function NetworkMatchMakingSTEAM:lobby_info()
	local lobbyinfo = "Lobby Name: \"" .. managers.network.matchmake._lobby_attributes.owner_name .. "\""
	if not string.is_nil_or_empty(desired_desc) then
		lobbyinfo = lobbyinfo .. "\nLobby Description: \"" .. desired_desc .. "\""
	end
	return lobbyinfo
end

function NetworkMatchMakingEPIC:lobby_info()
	local lobbyinfo = "Lobby Name: \"" .. managers.network.matchmake._lobby_attributes.owner_name .. "\""
	if not string.is_nil_or_empty(desired_desc) then
		lobbyinfo = lobbyinfo .. "\nLobby Description: \"" .. desired_desc .. "\""
	end
	return lobbyinfo
end

function NetworkMatchMakingSTEAM:broadcast_lobby_info(peer) --Pass a peer to only broadcast to that peer, otherwise, show it to everyone.
	if peer == nil then
		managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", self:lobby_info())
	else
		peer:send("send_chat_message", ChatManager.GAME, self:lobby_info())
	end
end

function NetworkMatchMakingEPIC:broadcast_lobby_info(peer) 
	if peer == nil then
		managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", self:lobby_info())
	else
		peer:send("send_chat_message", ChatManager.GAME, self:lobby_info())
	end
end