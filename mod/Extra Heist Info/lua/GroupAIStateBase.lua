local EHI = EHI
if EHI:CheckLoadHook("GroupAIStateBase") then
    return
end

local dropin = false
local original =
{
    init = GroupAIStateBase.init,
    on_successful_alarm_pager_bluff = GroupAIStateBase.on_successful_alarm_pager_bluff,
    sync_alarm_pager_bluff = GroupAIStateBase.sync_alarm_pager_bluff,
    load = GroupAIStateBase.load,
    convert_hostage_to_criminal = GroupAIStateBase.convert_hostage_to_criminal,
    sync_converted_enemy = GroupAIStateBase.sync_converted_enemy,
    remove_minion = GroupAIStateBase.remove_minion
}

function GroupAIStateBase:init(...)
	original.init(self, ...)
    self:add_listener("EHI_EnemyWeaponsHot", { "enemy_weapons_hot" }, function()
        EHI:RunOnAlarmCallbacks(dropin)
    end)
end

function GroupAIStateBase:on_successful_alarm_pager_bluff(...) -- Called by host
    original.on_successful_alarm_pager_bluff(self, ...)
    managers.ehi_tracker:SetTrackerProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
    managers.ehi_tracker:SetChancePercent("PagersChance", tweak_data.player.alarm_pager.bluff_success_chance_w_skill[self._nr_successful_alarm_pager_bluffs + 1] or 0)
end

function GroupAIStateBase:sync_alarm_pager_bluff(...) -- Called by client
    original.sync_alarm_pager_bluff(self, ...)
    managers.ehi_tracker:SetTrackerProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
end

function GroupAIStateBase:load(...)
    dropin = managers.ehi_manager:GetDropin()
    original.load(self, ...)
    if self._enemy_weapons_hot then
        EHI:RunOnAlarmCallbacks(dropin)
        local law1team = self._teams[tweak_data.levels:get_default_team_ID("combatant")]
        if law1team and law1team.damage_reduction then -- PhalanxDamageReduction is created before this gets set; see GameSetup:load()
            managers.ehi_tracker:SetChancePercent("PhalanxDamageReduction", law1team.damage_reduction or 0)
        elseif self._hunt_mode then -- Assault and AssaultTime is created before this is checked; see GameSetup:load()
            managers.ehi_assault:SetEndlessAssaultFromLoad()
        end
    else
        managers.ehi_tracker:SetTrackerProgress("Pagers", self._nr_successful_alarm_pager_bluffs)
	end
end

if EHI:ShowDramaTracker() and not tweak_data.levels:IsStealthRequired() then
    local assault_mode = "normal"
    local function Create()
        if managers.ehi_tracker:TrackerExists("Drama") then
            return
        end
        local pos = managers.ehi_assault:TrackerExists() and 1 or 0
        managers.ehi_tracker:AddTracker({
            id = "Drama",
            icons = { "C_Escape_H_Street_Bullet" },
            disable_anim = true,
            flash_bg = false,
            hint = "drama",
            class = EHI.Trackers.Chance
        }, pos)
    end
    original._add_drama = GroupAIStateBase._add_drama
    function GroupAIStateBase:_add_drama(...)
        original._add_drama(self, ...)
        managers.ehi_tracker:SetChance("Drama", self._drama_data.amount, 2)
    end
    EHI:AddOnAlarmCallback(Create)
    EHI:AddCallback(EHI.CallbackMessage.AssaultWaveModeChanged, function(mode)
        if mode == "endless" then
            managers.ehi_tracker:RemoveTracker("Drama")
        elseif managers.ehi_tracker:TrackerDoesNotExist("Drama") then
            Create()
        end
        assault_mode = mode
    end)
    EHI:AddCallback(EHI.CallbackMessage.AssaultModeChanged, function(mode)
        if mode == "normal" and assault_mode == "endless" then
            assault_mode = "normal"
            Create()
        end
    end)
end

if EHI:GetOption("show_minion_tracker") then
    local UpdateTracker
    if EHI:GetOption("show_minion_option") ~= 2 then
        dofile(EHI.LuaPath .. "trackers/EHIMinionTracker.lua")
        UpdateTracker = function(key, amount, peer_id)
            if managers.ehi_tracker:TrackerDoesNotExist("Converts") and amount ~= 0 then
                managers.ehi_tracker:AddTracker({
                    id = "Converts",
                    class = "EHIMinionTracker"
                })
            end
            if amount == 0 then -- Removal
                managers.ehi_tracker:CallFunction("Converts", "RemoveMinion", key)
            else
                managers.ehi_tracker:CallFunction("Converts", "AddMinion", key, amount, peer_id)
            end
        end
    else
        UpdateTracker = function(key, amount, peer_id)
            if managers.ehi_tracker:TrackerDoesNotExist("Converts") and amount ~= 0 then
                managers.ehi_tracker:AddTracker({
                    id = "Converts",
                    dont_show_placed = true,
                    icons = { "minion" },
                    hint = "converts",
                    class = "EHIEquipmentTracker"
                })
            end
            managers.ehi_tracker:CallFunction("Converts", "UpdateAmount", nil, key, amount)
        end
    end
    if EHI:GetOption("show_minion_option") == 1 then -- Only you
        EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(key, local_peer, peer_id)
            if local_peer then
                UpdateTracker(key, 1, peer_id)
            end
        end)
    else -- Everyone
        EHI:AddCallback(EHI.CallbackMessage.OnMinionAdded, function(key, local_peer, peer_id)
            UpdateTracker(key, 1, peer_id)
        end)
    end
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, local_peer, peer_id)
        UpdateTracker(key, 0, peer_id)
    end)
end

if EHI:GetOption("show_minion_killed_message") then
    EHI:SetNotificationAlert("MINION", "ehi_popup_minion")
    local show_popup_type = EHI:GetOption("show_minion_killed_message_type")
    local game_is_running = true
    local function GameEnd()
        game_is_running = false
    end
    EHI:AddCallback(EHI.CallbackMessage.GameRestart, GameEnd)
    EHI:AddCallback(EHI.CallbackMessage.GameEnd, GameEnd)
    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, GameEnd)
    EHI:AddCallback(EHI.CallbackMessage.OnMinionKilled, function(key, local_peer, peer_id)
        if game_is_running and local_peer then
            if show_popup_type == 1 then
                managers.hud:custom_ingame_popup_text("MINION", managers.localization:text("ehi_popup_minion_killed"), "EHI_Minion")
            else
                managers.hud:show_hint({ text = managers.localization:text("ehi_popup_minion_killed") })
            end
        end
    end)
end

---@param params table
---@param unit UnitEnemy
function GroupAIStateBase:EHIConvertDied(params, unit)
    params.killed_callback = nil
    self:EHIRemoveConvert(params, unit)
end

---@param params table
---@param unit UnitEnemy
function GroupAIStateBase:EHIConvertDestroyed(params, unit)
    params.destroyed_callback = nil
    self:EHIRemoveConvert(params, unit)
end

---@param params table
---@param unit UnitEnemy
function GroupAIStateBase:EHIRemoveConvert(params, unit)
    EHI:CallCallback(EHI.CallbackMessage.OnMinionKilled, params.unit_key, params.local_peer, params.peer_id)
    if params.killed_callback then
        unit:character_damage():remove_listener("EHIConvert")
    end
    if params.destroyed_callback then
        unit:base():remove_destroy_listener("EHIConvert")
    end
end

---@param unit UnitEnemy
---@param local_peer boolean
---@param peer_id number
function GroupAIStateBase:EHIAddConvert(unit, local_peer, peer_id)
    if not unit.key then
        EHI:Log("Convert does not have a 'key()' function! Aborting to avoid crashing the game.")
        return
    end
    local key = tostring(unit:key())
    EHI:CallCallback(EHI.CallbackMessage.OnMinionAdded, key, local_peer, peer_id)
    local data = { unit_key = key, local_peer = local_peer, peer_id = peer_id, killed_callback = true, destroyed_callback = true }
    unit:base():add_destroy_listener("EHIConvert", callback(self, self, "EHIConvertDestroyed", data))
    unit:character_damage():add_listener("EHIConvert", { "death" }, callback(self, self, "EHIConvertDied", data))
end

function GroupAIStateBase:convert_hostage_to_criminal(unit, peer_unit, ...)
    original.convert_hostage_to_criminal(self, unit, peer_unit, ...)
    if unit:brain()._logic_data.is_converted then
        local peer_id = peer_unit and managers.network:session():peer_by_unit(peer_unit):id() or managers.network:session():local_peer():id()
        local local_peer = not peer_unit
        self:EHIAddConvert(unit, local_peer, peer_id)
    end
end

function GroupAIStateBase:sync_converted_enemy(converted_enemy, owner_peer_id, ...)
    if self._police[converted_enemy:key()] then
        local peer_id = owner_peer_id or 0
        self:EHIAddConvert(converted_enemy, peer_id == managers.network:session():local_peer():id(), peer_id)
    end
    return original.sync_converted_enemy(self, converted_enemy, owner_peer_id, ...)
end

function GroupAIStateBase:remove_minion(minion_key, ...)
    if self._converted_police[minion_key] then
        EHI:CallCallback(EHI.CallbackMessage.OnMinionKilled, minion_key, false, 0)
    end
    original.remove_minion(self, minion_key, ...)
end

if EHI:IsHost() and EHI:GetOption("civilian_count_tracker_format") >= 2 then
    original.on_civilian_tied = GroupAIStateBase.on_civilian_tied
    function GroupAIStateBase:on_civilian_tied(u_key, ...)
        original.on_civilian_tied(self, u_key, ...)
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianTied", u_key)
    end
end

if EHI:GetOption("show_hostage_count_tracker") then
    dofile(EHI.LuaPath .. "trackers/EHIHostageCountTracker.lua")
    if EHI:IsHost() then
        original.on_hostage_state = GroupAIStateBase.on_hostage_state
        function GroupAIStateBase:on_hostage_state(state, key, police, ...)
            local original_count = self._hostage_headcount
            original.on_hostage_state(self, state, key, police, ...)
            if original_count == self._hostage_headcount then
                return
            end
            managers.ehi_tracker:CallFunction("HostageCount", "SetHostageCount", self._hostage_headcount, self._police_hostage_headcount)
        end
    else
        original.sync_hostage_headcount = GroupAIStateBase.sync_hostage_headcount
        function GroupAIStateBase:sync_hostage_headcount(...)
            original.sync_hostage_headcount(self, ...)
            managers.ehi_tracker:CallFunction("HostageCount", "SetHostageCount", self._hostage_headcount)
        end
    end
    EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
        managers.ehi_tracker:AddTracker({
            id = "HostageCount",
            class = "EHIHostageCountTracker"
        })
        local police = EHI:IsHost() and managers.groupai:state():police_hostage_count()
        managers.ehi_tracker:CallFunction("HostageCount", "SetHostageCount", managers.groupai:state():hostage_count(), police)
    end)
end