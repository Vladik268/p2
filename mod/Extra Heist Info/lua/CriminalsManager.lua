local EHI = EHI
if EHI:CheckLoadHook("CriminalsManager") or EHI:IsXPTrackerHidden() then
    return
end

---@class CriminalsManager.CharacterData
---@field taken boolean
---@field data { ai: boolean }

---@class CriminalsManager
---@field _characters CriminalsManager.CharacterData[]
---@field character_by_name fun(self: self, name: string): CriminalsManager.CharacterData?
---@field character_color_id_by_unit fun(self: self, unit: UnitPlayer|UnitTeamAI): number?
---@field character_peer_id_by_unit fun(self: self, unit: UnitPlayer|UnitTeamAI): number?

if EHI:IsRunningBB() then
    EHI:HookWithID(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character",
    ---@param self CriminalsManager
    ---@param name string
    function(self, name)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai then
            managers.ehi_experience:IncreaseAlivePlayers()
            EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
        end
    end)
    EHI:HookWithID(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit",
    ---@param self CriminalsManager
    ---@param name string
    ---@param unit UnitPlayer|UnitTeamAI
    function(self, name, unit)
        local character = self:character_by_name(name)
        if character and character.taken and character.data.ai and not unit:base().is_local_player then
            managers.ehi_experience:IncreaseAlivePlayers()
            EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
        end
    end)
    EHI:PreHookWithID(CriminalsManager, "_remove", "EHI_CriminalsManager_remove",
    ---@param self CriminalsManager
    ---@param id number
    function(self, id)
        local char_data = self._characters[id]
        if char_data.data.ai then
            managers.ehi_experience:DecreaseAlivePlayers()
            EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
        end
    end)
elseif EHI:IsRunningUsefulBots() then
    EHIExperienceManager:SetCriminalsListener(true)
elseif not Global.game_settings.single_player then
    EHIExperienceManager:SetCriminalsListener()
end