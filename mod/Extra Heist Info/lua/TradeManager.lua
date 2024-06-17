---@class TradeManager
---@field _auto_assault_ai_trade_criminal_name string?
---@field _criminals_to_respawn { id: string, peer_id: number, respawn_penalty: number, hostages_killed: number }[]
---@field _trade_countdown boolean
---@field _trade_counter_tick number

local EHI = EHI
if EHI:CheckLoadHook("TradeManager") then
    return
end

if EHI:IsXPTrackerEnabledAndVisible() then
    if EHI:IsRunningBB() or EHI:IsRunningUsefulBots() then
        EHIExperienceManager:SetAIOnDeathListener()
    end
    if not Global.game_settings.single_player then
        EHI:HookWithID(TradeManager, "on_player_criminal_death", "EHI_ExperienceManager_PlayerCriminalDeath", function(...)
            managers.ehi_experience:DecreaseAlivePlayers(true)
            EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
        end)
    end
end

if EHI:IsTradeTrackerDisabled() then
    return
end

dofile(EHI.LuaPath .. "trackers/EHITradeDelayTracker.lua")
local show_trade_for_other_players = EHI:GetOption("show_trade_delay_other_players_only") --[[@as boolean]]
local on_death_show = EHI:GetOption("show_trade_delay_option") == 2
local suppress_in_stealth = EHI:GetOption("show_trade_delay_suppress_in_stealth") --[[@as boolean]]

local original =
{
    init = TradeManager.init,
    pause_trade = TradeManager.pause_trade,
    on_player_criminal_death = TradeManager.on_player_criminal_death,
    _set_auto_assault_ai_trade = TradeManager._set_auto_assault_ai_trade,
    sync_set_auto_assault_ai_trade = TradeManager.sync_set_auto_assault_ai_trade,
    sync_set_trade_spawn = TradeManager.sync_set_trade_spawn,
    load = TradeManager.load
}

---@param peer_id number
---@param respawn_penalty number
---@param civilians_killed number?
local function CreateTracker(peer_id, respawn_penalty, civilians_killed)
    if respawn_penalty <= tweak_data.player.damage.base_respawn_time_penalty then
        return
    end
    if show_trade_for_other_players and peer_id == managers.network:session():local_peer():id() then
        return
    end
    if suppress_in_stealth and managers.groupai:state():whisper_mode() then
        managers.ehi_trade:AddToTradeDelayCache(peer_id, respawn_penalty, civilians_killed, true)
        return
    end
    local tracker = managers.ehi_trade:GetTracker()
    if tracker and not tracker:PeerExists(peer_id) then
        tracker:AddPeerCustodyTime(peer_id, respawn_penalty, civilians_killed)
    else
        managers.ehi_trade:AddCustodyTimeTrackerWithPeer(peer_id, respawn_penalty, civilians_killed)
    end
end

---@param character_name string?
---@param t number
local function SetTrackerPause(character_name, t)
    managers.ehi_trade:SetTrade("ai", character_name ~= nil, t)
end

function TradeManager:init(...)
    original.init(self, ...)
    EHI:Hook(self, "set_trade_countdown", function(s, enabled)
        managers.ehi_trade:SetTrade("normal", enabled, self._trade_counter_tick)
        if not enabled then
            for _, crim in ipairs(self._criminals_to_respawn) do
                if crim.peer_id and crim.respawn_penalty and (crim.hostages_killed and crim.hostages_killed > 0) then
                    managers.ehi_trade:CallFunction("AddOrUpdatePeerCustodyTime", crim.peer_id, crim.respawn_penalty, crim.hostages_killed, true)
                end
            end
        end
    end)
    EHI:AddOnAlarmCallback(function(dropin)
        managers.ehi_trade:LoadFromTradeDelayCache()
        if not dropin then
            managers.ehi_trade:SetTrade("normal", true, self:GetTradeCounterTick())
        end
    end)
    Hooks:Add("BaseNetworkSessionOnPeerRemoved", "BaseNetworkSessionOnPeerRemoved_EHI", function(peer, peer_id, reason)
        managers.ehi_trade:CallFunction("RemovePeerFromCustody", peer_id)
    end)
end

function TradeManager:pause_trade(time, ...)
    original.pause_trade(self, time, ...)
    managers.ehi_trade:CallFunction("SetTradePause", time)
end

function TradeManager:GetTradeCounterTick()
    return self._trade_counter_tick
end

---@param criminal_name string
---@param respawn_penalty number
---@param hostages_killed number
---@param ... unknown
---@return table?
function TradeManager:on_player_criminal_death(criminal_name, respawn_penalty, hostages_killed, ...)
    local crim = original.on_player_criminal_death(self, criminal_name, respawn_penalty, hostages_killed, ...)
    if type(crim) == "table" then -- A nil criminal can be returned (because it is already in custody)
        local peer_id = crim.peer_id
        if not peer_id then
            for _, peer in pairs(managers.network:session():peers()) do
                if peer:character() == criminal_name then
                    peer_id = peer:id()
                    break
                end
            end
            if not peer_id then -- If peer_id is still nil, return the value and GTFO
                return crim
            end
        end
        if on_death_show then
            CreateTracker(peer_id, respawn_penalty, hostages_killed)
        elseif respawn_penalty > tweak_data.player.damage.base_respawn_time_penalty then
            if show_trade_for_other_players and peer_id == managers.network:session():local_peer():id() then
                return crim
            elseif suppress_in_stealth and managers.groupai:state():whisper_mode() then
                managers.ehi_trade:AddToTradeDelayCache(peer_id, respawn_penalty, hostages_killed, true)
                return crim
            end
            local tracker = managers.ehi_trade:GetTracker()
            if tracker then
                if tracker:PeerExists(peer_id) then
                    tracker:UpdatePeerCustodyTime(peer_id, respawn_penalty, hostages_killed)
                else
                    tracker:AddPeerCustodyTime(peer_id, respawn_penalty, hostages_killed)
                end
            else
                managers.ehi_trade:AddCustodyTimeTrackerWithPeer(peer_id, respawn_penalty, hostages_killed)
            end
        end
        managers.ehi_trade:CallFunction("SetPeerInCustody", peer_id)
    end
    return crim
end

---@param character_name string?
---@param ... unknown
function TradeManager:_set_auto_assault_ai_trade(character_name, ...)
    if self._auto_assault_ai_trade_criminal_name ~= character_name then
        SetTrackerPause(character_name, self._trade_counter_tick)
	end
    original._set_auto_assault_ai_trade(self, character_name, ...)
end

---@param character_name string?
function TradeManager:sync_set_auto_assault_ai_trade(character_name, ...)
    original.sync_set_auto_assault_ai_trade(self, character_name, ...)
    SetTrackerPause(character_name, self._trade_counter_tick)
end

---@param criminal_name string
function TradeManager:sync_set_trade_spawn(criminal_name, ...)
    for _, crim in ipairs(self._criminals_to_respawn) do
		if crim.id == criminal_name and crim.peer_id then
            managers.ehi_trade:CallFunction("RemovePeerFromCustody", crim.peer_id)
			break
		end
	end
    original.sync_set_trade_spawn(self, criminal_name, ...)
end

function TradeManager:load(load_data, ...)
    local my_load_data = load_data.trade or {}
    if my_load_data.criminals then
        for _, crim in ipairs(my_load_data.criminals) do
            if crim.peer_id and crim.respawn_penalty and crim.hostages_killed then
                CreateTracker(crim.peer_id, crim.respawn_penalty, crim.hostages_killed)
            end
        end
        if not managers.groupai:state():whisper_mode() then
            managers.ehi_trade:SetTrade("normal", self._trade_countdown, self._trade_counter_tick)
        end
    end
    original.load(self, load_data, ...)
end