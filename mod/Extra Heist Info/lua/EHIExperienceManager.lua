local EHI = EHI

---@class EHIExperienceManager
EHIExperienceManager = {}
EHIExperienceManager.XPElementLevel =
{
    jewelry_store = true,
    ukrainian_job = true,
    election_day_1 = true,
    alex_1 = true,
    firestarter_1 = true,
    safehouse = true
}
EHIExperienceManager.XPElementLevelNoCheck =
{
    mallcrasher = true, -- Mallcrasher
    rat = true, -- Cook Off

    -- Custom Missions
    ratdaylight = true,
    lid_cookoff_methslaves = true
}
EHIExperienceManager._XPElement = 0
---@param level_id string
---@return boolean
function EHIExperienceManager:IsOneXPElementHeist(level_id)
    if self.XPElementLevelNoCheck[level_id] then
        return false
    end
    return self._XPElement <= 1 or self.XPElementLevel[level_id]
end

---@param element MissionScriptElement
function EHIExperienceManager:AddXPElement(element)
    if element._values.amount and element._values.amount > 0 then
        self._XPElement = self._XPElement + 1
    end
end

---@param trackers EHITrackerManager
function EHIExperienceManager:TrackersInit(trackers)
    self._trackers = trackers
end

---@param xp ExperienceManager
function EHIExperienceManager:ExperienceInit(xp)
    if self._xp_class then
        return
    end
    self._xp_class = xp
    self.cash_string = xp.cash_string
    self.experience_string = xp.experience_string
    self._cash_sign = xp._cash_sign
    self._cash_tousand_separator = xp._cash_tousand_separator
    self:ExperienceReload(xp)
    if EHI:CheckNotLoad() or EHI:IsXPTrackerDisabled() then
        self._xp_disabled = true
        if Global.load_level and not Global.editor_mode and EHI:GetOption("show_xp_in_mission_briefing_only") then
            EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "LoadData"))
        end
        return
    end
    self._config =
    {
        xp_format = EHI:GetOption("xp_format") --[[@as 1|2|3]],
        xp_panel = EHI:GetOption("xp_panel") --[[@as 1|2|3|4]],
        show_total_xp_diff = EHI:GetOption("total_xp_difference") --[[@as 1|2|3|4]]
    }
    self._config.show_xp_diff = self._config.show_total_xp_diff ~= 1
    self._base_xp = 0
    self._total_xp = 0
    self._ehi_xp = self:CreateXPTable()
    EHI:AddCallback(EHI.CallbackMessage.Spawned, callback(self, self, "RecalculateSkillXPMultiplier"))
    EHI:HookWithID(HUDManager, "mark_cheater", "EHI_ExperienceManager_mark_cheater", function()
        self:RecalculateSkillXPMultiplier()
    end)
    EHI:AddCallback(EHI.CallbackMessage.SyncGagePackagesCount, function(picked_up, max_units, client_sync_load)
        local multiplier = 1
        if picked_up > 0 then -- Don't use the in-game function because it is inaccurate by one package
            local ratio = 1 - (max_units - picked_up) / max_units
            multiplier = managers.gage_assignment._tweak_data:get_experience_multiplier(ratio)
        end
        self:SetGagePackageBonus(multiplier)
    end)
    EHI:AddCallback(EHI.CallbackMessage.InitManagers, callback(self, self, "LoadData"))
    if not EHI:GetOption("show_xp_in_mission_briefing_only") then
        EHI:AddCallback(EHI.CallbackMessage.InitFinalize, callback(self, self, "HookAwardXP"))
    end
end

function EHIExperienceManager:CreateXPTable()
    return
    {
        mutator_xp_reduction = 0,
        level_to_stars = math.clamp(math.ceil((self._xp.level + 1) / 10), 1, 10),
        in_custody = false,
        alive_players = Global.game_settings.single_player and 1 or 0,
        gage_bonus = 1,
        stealth = true,
        bonus_xp = 0,
        skill_xp_multiplier = 1, -- Recalculated in `EHIExperienceManager:RecalculateSkillXPMultiplier()`
        difficulty_multiplier = 1,
        projob_multiplier = 1 -- Unavailable since `Update 109`, however mods can still enable Pro Job modifier in heists
    }
end

---@param xp ExperienceManager
function EHIExperienceManager:ExperienceReload(xp)
    self._xp = self._xp or {}
    self._xp.level = xp:current_level()
    local max_level = self._xp.level >= xp:level_cap()
    self._xp.level_xp_to_100 = max_level and 0 or self:GetRemainingXPToMaxLevel()
    self._xp.level_xp_to_next_level = max_level and 0 or math.max(xp:next_level_data_points() - xp:next_level_data_current_points(), 0)
    self._xp.prestige_xp = xp:get_current_prestige_xp()
    self._xp.prestige_xp_remaining = xp:get_max_prestige_xp() - self._xp.prestige_xp
    self._xp.prestige_xp_overflowed = self._xp.prestige_xp_remaining < 0 ---Not possible in Vanilla, mod check
    self._xp.prestige_enabled = max_level and xp:current_rank() > 0
end

---@param managers managers
function EHIExperienceManager:LoadData(managers)
    self._ehi_xp = self._ehi_xp or self:CreateXPTable()
    -- Job
    local job = managers.job
    local difficulty_stars = job:current_difficulty_stars()
    self._ehi_xp.job_stars = job:current_job_stars()
    self._ehi_xp.stealth_bonus = job:get_ghost_bonus()
    if job:is_current_job_professional() then
        self._ehi_xp.projob_multiplier = tweak_data:get_value("experience_manager", "pro_job_multiplier") or 1
    end
    local heat = job:get_job_heat_multipliers(job:current_job_id())
    self._ehi_xp.heat = heat and heat ~= 0 and heat or 1
    self._ehi_xp.is_level_limited = self._ehi_xp.level_to_stars < self._ehi_xp.job_stars
    if xp_format ~= 1 then
        self._ehi_xp.difficulty_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", difficulty_stars) or 1
    end
    -- Player
    local player = managers.player
    self._ehi_xp.infamy_bonus = player:get_infamy_exp_multiplier()
    local multiplier = tweak_data:get_value("experience_manager", "limited_bonus_multiplier") or 1
    if tweak_data.levels:IsLevelChristmas() then
        multiplier = multiplier + (tweak_data:get_value("experience_manager", "limited_xmas_bonus_multiplier") or 1) - 1
    end
    self._ehi_xp.limited_xp_bonus = multiplier
    -- Mutators
    local mutator = managers.mutators
    if mutator:can_mutators_be_active() then
        self._ehi_xp.mutator_xp_reduction = mutator:get_experience_reduction() * -1
    end
end

function EHIExperienceManager:HookAwardXP()
    local level_id = Global.game_settings.level_id
    if tweak_data.levels:IsLevelSafehouse(level_id) then
        return
    elseif self:IsOneXPElementHeist(level_id) and self._config.xp_panel == 2 then
        self._config.xp_panel = 1 -- Force one XP panel when the heist gives you the XP at the escape zone -> less screen clutter
        if self._config.show_xp_diff and self._config.show_total_xp_diff > 1 then
            self._config.xp_panel = self._config.show_total_xp_diff
        end
    end
    if self._config.xp_panel <= 2 then
        if self._config.xp_panel == 1 or self._config.show_total_xp_diff == 2 then
            ---@param id number
            ---@param amount number
            self._show = function(id, amount)
                local _id = string.format("XP%d", id)
                if self._trackers:CallFunction3(_id, "AddXPToTracker", amount) then
                    self._trackers:AddTracker({
                        id = _id,
                        amount = amount,
                        class = "EHIXPTracker"
                    })
                end
            end
        elseif self._config.show_total_xp_diff >= 3 then
            ---@param id number
            ---@param amount number
            self._show = function(id, amount)
                if self._trackers:TrackerExists("XPHidden") then
                    self._trackers:AddXPToTracker("XPHidden", amount)
                end
            end
        end
        if self._config.xp_panel == 2 then
            if self._config.xp_format == 1 then
                ---@param id number
                ---@param amount number
                self._xp_awarded = function(id, amount)
                    self._trackers:AddXPToTracker("XPTotal", amount)
                    if self._config.show_xp_diff then
                        self:ShowGainedXP(id, amount, amount)
                    end
                end
            elseif self._config.xp_format == 2 then
                ---@param id number
                ---@param amount number
                self._xp_awarded = function(id, amount)
                    local multiplied = amount * self._ehi_xp.difficulty_multiplier
                    self._trackers:AddXPToTracker("XPTotal", multiplied)
                    if self._config.show_xp_diff then
                        self:ShowGainedXP(id, amount, multiplied)
                    end
                end
            else
                ---@param id number
                ---@param amount number
                self._xp_awarded = function(id, amount)
                    self._base_xp = self._base_xp + amount
                    local new_total = self:MultiplyXPWithAllBonuses(self._base_xp)
                    self._trackers:SetXPInTracker("XPTotal", new_total)
                    if self._config.show_xp_diff then
                        self:ShowGainedXP(id, 0, new_total, true)
                    end
                end
            end
        end
    else
        ---@param id number
        ---@param amount number
        self._show = function(id, amount)
            if self._trackers:TrackerExists("XPHidden") then
                self._trackers:AddXPToTracker("XPHidden", amount)
            else
                self._xp_to_award = (self._xp_to_award or 0) + amount
            end
        end
    end
    if self._config.xp_panel ~= 2 then
        if self._config.xp_format == 1 then
            ---@param id number
            ---@param amount number
            self._xp_awarded = function(id, amount)
                self:ShowGainedXP(id, amount, amount)
            end
        elseif self._config.xp_format == 2 then
            ---@param id number
            ---@param amount number
            self._xp_awarded = function(id, amount)
                self:ShowGainedXP(id, amount, amount * self._ehi_xp.difficulty_multiplier)
            end
        else
            ---@param id number
            ---@param amount number
            self._xp_awarded = function(id, amount)
                self:ShowGainedXP(id, amount)
            end
        end
    end
    EHI:Hook(self._xp_class, "on_loot_drop_xp", function(xp, value_id)
        local amount = tweak_data:get_value("experience_manager", "loot_drop_value", value_id) or 0
        if amount <= 0 then
            return
        end
        self._ehi_xp.bonus_xp = self._ehi_xp.bonus_xp + amount
        self:RecalculateXP(1)
        EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
    end)
    if self._config.xp_panel ~= 1 then
        local one_element = self:IsOneXPElementHeist(level_id)
        if self._config.xp_panel == 2 then
            local xp_limit = self:GetPlayerXPLimit()
            if xp_limit > 0 and not one_element then
                self._trackers:AddTracker({
                    id = "XPTotal",
                    xp_limit = xp_limit,
                    xp_overflow_enabled = self._xp.prestige_enabled and EHI:IsModInstalled("Infamy Pool Overflow", "Dr_Newbie"),
                    class = "EHITotalXPTracker"
                })
            end
        end
        if self._config.xp_panel >= 3 or (self._config.xp_panel == 2 and self._config.show_total_xp_diff >= 3) then
            self._trackers:AddHiddenTracker({
                id = "XPHidden",
                amount = self._xp_to_award,
                panel = self._config.xp_panel == 2 and self._config.show_total_xp_diff or self._config.xp_panel,
                format = self._config.xp_format,
                refresh_t = one_element and 0,
                class = "EHIHiddenXPTracker"
            })
            self._xp_to_award = nil
        end
    end
end

function EHIExperienceManager:SwitchToLoudMode()
    if self._xp_disabled then
        return
    end
    self._ehi_xp.stealth = false
    self:RecalculateSkillXPMultiplier()
end

---@param amount number
function EHIExperienceManager:MissionXPAwarded(amount)
    if amount <= 0 or self._xp_disabled then
        return
    end
    if self._xp_awarded then
        self._xp_awarded(0, amount)
    end
end

---@param multiplier number
function EHIExperienceManager:UpdateSkillXPMultiplier(multiplier)
    self._ehi_xp.skill_xp_multiplier = multiplier
    self:RecalculateXP(2)
end

function EHIExperienceManager:RecalculateSkillXPMultiplier()
    self:UpdateSkillXPMultiplier(managers.player:get_skill_exp_multiplier(self._ehi_xp.stealth))
end

---@param bonus number
function EHIExperienceManager:SetGagePackageBonus(bonus)
    self._ehi_xp.gage_bonus = bonus
    self:RecalculateXP(3)
end

---@param in_custody boolean
function EHIExperienceManager:SetInCustody(in_custody)
    if self._xp_disabled then
        return
    end
    self._ehi_xp.in_custody = in_custody
    if in_custody then
        self._ehi_xp.alive_players = math.max(self._ehi_xp.alive_players - 1, 0)
    else
        self._ehi_xp.alive_players = math.min(self._ehi_xp.alive_players + 1, 4)
    end
    self:RecalculateXP(4)
end

function EHIExperienceManager:IncreaseAlivePlayers()
    self._ehi_xp.alive_players = self._ehi_xp.alive_players + 1
    self:RecalculateXP(5)
end

function EHIExperienceManager:QueryAmountOfAllPlayers()
    local previous_value = self._ehi_xp.alive_players
    local human_players = managers.network:session() and managers.network:session():amount_of_alive_players()
    local bots = managers.groupai:state() and managers.groupai:state():amount_of_winning_ai_criminals()
    self._ehi_xp.alive_players = math.clamp(human_players + bots, 0, 4)
    if previous_value ~= self._ehi_xp.alive_players then
        self:RecalculateSkillXPMultiplier()
    end
end

function EHIExperienceManager:QueryAmountOfAlivePlayers()
    self._ehi_xp.alive_players = managers.network:session() and managers.network:session():amount_of_alive_players()
    self:RecalculateSkillXPMultiplier()
end

---@param human_player boolean?
function EHIExperienceManager:DecreaseAlivePlayers(human_player)
    self._ehi_xp.alive_players = math.max(self._ehi_xp.alive_players - 1, 0)
    if human_player then
        self:RecalculateSkillXPMultiplier()
    else
        self:RecalculateXP(6)
    end
end

---@param id number
---@param base_xp number
---@param xp_gained number?
---@param xp_set boolean?
function EHIExperienceManager:ShowGainedXP(id, base_xp, xp_gained, xp_set)
    self._base_xp = self._base_xp + base_xp
    local new_total = xp_gained and (xp_set and xp_gained or (self._total_xp + xp_gained)) or self:MultiplyXPWithAllBonuses(self._base_xp)
    if self._total_xp ~= new_total then
        local diff = new_total - self._total_xp
        self._total_xp = new_total
        if self._show then
            self._show(id, diff)
        end
    end
end

local math_round = math.round
---@param xp number?
---@param default_xp_if_zero number?
function EHIExperienceManager:MultiplyXPWithAllBonuses(xp, default_xp_if_zero)
    if not xp or xp <= 0 then
        return default_xp_if_zero or 0
    end
    local job_stars = self._ehi_xp.job_stars
    local num_winners = self._ehi_xp.alive_players
    local player_stars = self._ehi_xp.level_to_stars
    local pro_job_multiplier = self._ehi_xp.projob_multiplier or 1
    local ghost_multiplier = 1 + (self._ehi_xp.stealth_bonus or 0)
    local xp_multiplier = self._ehi_xp.difficulty_multiplier or 1
    local contract_xp = 0
    local total_xp = 0
    local stage_xp_dissect = 0
    local job_xp_dissect = 0
    local risk_dissect = 0
    local personal_win_dissect = 0
    local alive_crew_dissect = 0
    local skill_dissect = 0
    local base_xp = 0
    local job_heat_dissect = 0
    local ghost_dissect = 0
    local infamy_dissect = 0
    local extra_bonus_dissect = 0
    local gage_assignment_dissect = 0
    local mission_xp_dissect = xp
    local pro_job_xp_dissect = 0
    local bonus_xp = 0

    base_xp = job_xp_dissect + stage_xp_dissect + mission_xp_dissect
    pro_job_xp_dissect = math_round(base_xp * pro_job_multiplier - base_xp)
    base_xp = base_xp + pro_job_xp_dissect

    if self._ehi_xp.is_level_limited then
        local diff_in_stars = job_stars - player_stars
        local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
        base_xp = math_round(base_xp * tweak_multiplier)
    end

    contract_xp = base_xp
    risk_dissect = math_round(contract_xp * xp_multiplier)
    contract_xp = contract_xp + risk_dissect

    if self._ehi_xp.in_custody then
        local multiplier = tweak_data:get_value("experience_manager", "in_custody_multiplier") or 1
        personal_win_dissect = math_round(contract_xp * multiplier - contract_xp)
        contract_xp = contract_xp + personal_win_dissect
    end

    total_xp = contract_xp
    local total_contract_xp = total_xp
    bonus_xp = self._ehi_xp.skill_xp_multiplier or 1
    skill_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
    total_xp = total_xp + skill_dissect
    bonus_xp = self._ehi_xp.infamy_bonus
    infamy_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
    total_xp = total_xp + infamy_dissect

    local num_players_bonus = num_winners and tweak_data:get_value("experience_manager", "alive_humans_multiplier", num_winners) or 1
    alive_crew_dissect = math_round(total_contract_xp * num_players_bonus - total_contract_xp)
    total_xp = total_xp + alive_crew_dissect

    bonus_xp = self._ehi_xp.gage_bonus
    gage_assignment_dissect = math_round(total_contract_xp * bonus_xp - total_contract_xp)
    total_xp = total_xp + gage_assignment_dissect
    ghost_dissect = math_round(total_xp * ghost_multiplier - total_xp)
    total_xp = total_xp + ghost_dissect
    local heat_xp_mul = self._ehi_xp.heat
    job_heat_dissect = math_round(total_xp * heat_xp_mul - total_xp)
    total_xp = total_xp + job_heat_dissect
    bonus_xp = self._ehi_xp.limited_xp_bonus
    extra_bonus_dissect = math_round(total_xp * bonus_xp - total_xp)
    total_xp = total_xp + extra_bonus_dissect
    local bonus_mutators_dissect = total_xp * self._ehi_xp.mutator_xp_reduction
    total_xp = total_xp + bonus_mutators_dissect
    total_xp = total_xp + self._ehi_xp.bonus_xp
    return total_xp
end

---@param id number
function EHIExperienceManager:RecalculateXP(id)
    if self._base_xp == 0 then
        return
    elseif self._config.xp_format == 3 then
        if self._config.xp_panel == 2 then
            if self._xp_awarded then
                self._xp_awarded(id, 0)
            end
        else
            self:ShowGainedXP(id, 0)
        end
    end
end

---@return number
function EHIExperienceManager:GetRemainingXPToMaxLevel()
    local totalXpTo100 = 0
    for _, level in ipairs(tweak_data.experience_manager.levels) do
        totalXpTo100 = totalXpTo100 + Application:digest_value(level.points, false)
    end
    return math.max(totalXpTo100 - self._xp_class:total(), 0)
end

function EHIExperienceManager:GetPlayerXPLimit()
    if self._xp.prestige_enabled then
        if self._xp.prestige_xp_overflowed then
            return self._xp.prestige_xp
        end
        return self._xp.prestige_xp_remaining
    end
    return self._xp.level_xp_to_100
end

function EHIExperienceManager:IsInfamyPoolEnabled()
    return self._xp.prestige_enabled
end

---Not possible in Vanilla, mod check
function EHIExperienceManager:IsInfamyPoolOverflowed()
    return self._xp.prestige_xp_overflowed
end

function EHIExperienceManager:SetAIOnDeathListener()
    EHI:UpdateExistingHookIfExistsOrHook(TradeManager, "on_AI_criminal_death", "EHI_ExperienceManager_AICriminalDeath", function(...)
        self:DecreaseAlivePlayers()
        EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
    end)
end

---@param ub boolean?
function EHIExperienceManager:SetCriminalsListener(ub)
    if ub then
        local EHIHookFunction = EHI:HookExists(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character") and EHI.UpdateExistingHook or EHI.HookWithID
        local function Query(...)
            self:QueryAmountOfAllPlayers()
            EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
        end
        EHIHookFunction(EHI, CriminalsManager, "add_character", "EHI_CriminalsManager_add_character", Query)
        EHIHookFunction(EHI, CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit", Query)
        EHIHookFunction(EHI, CriminalsManager, "on_peer_left", "EHI_CriminalsManager_on_peer_left", Query)
        EHI:UpdateExistingHookIfExistsOrHook(CriminalsManager, "_remove", "EHI_CriminalsManager_remove", Query)
    else
        local function Query(...)
            self:QueryAmountOfAlivePlayers()
            EHI:CallCallback("ExperienceManager_RefreshPlayerCount")
        end
        EHI:HookWithID(CriminalsManager, "add_character", "EHI_CriminalsManager_add_character", Query)
        EHI:HookWithID(CriminalsManager, "set_unit", "EHI_CriminalsManager_set_unit", Query)
        EHI:HookWithID(CriminalsManager, "on_peer_left", "EHI_CriminalsManager_on_peer_left", Query)
    end
end