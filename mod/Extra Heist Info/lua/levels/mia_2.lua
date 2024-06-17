local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local element_sync_triggers =
{
    [100428] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427, hint = Hints.DrillDelivery }, -- 20s
    [100430] = { time = 24, id = "HeliDropDrill", icons = Icon.HeliDropDrill, hook_element = 100427, hint = Hints.DrillDelivery } -- 30s
}
---@type ParseTriggerTable
local triggers = {
    -- 5 = Base Delay
    -- 5 = Delay when executed
    -- 22 = Heli door anim delay
    -- Total: 32 s
    [100224] = { time = 5 + 5 + 22, id = "EscapeHeli", icons = Icon.HeliEscape, hint = Hints.LootEscape, waypoint = { icon = Icon.Escape, position_by_element = 100926 } },
    [101858] = { time = 5 + 5 + 22, id = "EscapeHeli", icons = Icon.HeliEscape, hint = Hints.LootEscape, waypoint = { icon = Icon.Escape, position_by_element = 101854 } },

    -- Bugged because of retarded use of ENABLED in ElementTimer and ElementTimerTrigger
    [101240] = { time = 540, id = "CokeTimer", icons = { { icon = Icon.Loot, color = Color.red } }, class = TT.Warning, hint = Hints.mia_2_Loot },
    [101282] = { id = "CokeTimer", special_function = SF.RemoveTracker }
}

local start_index = { 3500, 3750, 3900, 4450, 4900, 6100, 17600, 17650 }
---@type ParseAchievementTable
local achievements =
{
    pig_2 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [101228] = { time = 210, class = TT.Achievement.Base },
            [100788] = { special_function = SF.SetAchievementComplete }
        }
    },
    pig_7 =
    {
        preparse_callback = function(data)
            data.elements = {}
            local start = { time = 5, class = TT.Achievement.Base }
            local fail = { special_function = SF.SetAchievementFailed } -- Hostage blew out
            local complete = { special_function = SF.SetAchievementComplete } -- Hostage saved
            for _, index in ipairs(start_index) do
                data.elements[EHI:GetInstanceElementID(100024, index)] = start
                data.elements[EHI:GetInstanceElementID(100016, index)] = fail
                data.elements[EHI:GetInstanceElementID(100027, index)] = complete
            end
        end
    }
}

if not EHI:CanShowAchievement("pig_7") then
    local start = { time = 5, id = "HostageBomb", icons = { Icon.Hostage, Icon.C4 }, class = TT.Warning, hint = Hints.Explosion }
    local fail = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage blew out
    local complete = { id = "HostageBomb", special_function = SF.RemoveTracker } -- Hostage saved
    for _, index in ipairs(start_index) do
        triggers[EHI:GetInstanceElementID(100024, index)] = start
        triggers[EHI:GetInstanceElementID(100016, index)] = fail
        triggers[EHI:GetInstanceElementID(100027, index)] = complete
    end
end

if EHI:IsClient() then
    triggers[100426] = { id = "HeliDropDrill", icons = Icon.HeliDropDrill, special_function = SF.SetRandomTime, data = { 44, 54 } }
end

local other =
{
    --[100520] = EHI:AddAssaultDelay({}) -- 30s; Diff is applied earlier
}
if EHI:IsLootCounterVisible() then
    local MoneyBagsInVault = 1
    if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
        MoneyBagsInVault = 2
    elseif EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL) then
        MoneyBagsInVault = 3
    end
    local MoneyAroundHostage = 0
    local HostageMoneyTaken = 0
    local _HostageExploded = false
    local function HostageMoneyInteracted(...)
        if _HostageExploded then
            return
        end
        HostageMoneyTaken = HostageMoneyTaken + 1
    end
    local function HostageExploded()
        _HostageExploded = true
        local count = MoneyAroundHostage - HostageMoneyTaken
        if count > 0 then
            managers.ehi_loot:DecreaseLootCounterProgressMax(count)
        end
    end
    other[100043] = EHI:AddLootCounter3(function(self, ...)
        local loot_triggers = {}
        MoneyAroundHostage = self:CountInteractionAvailable("money_small")
        for _, index in ipairs(start_index) do
            if managers.game_play_central:GetMissionEnabledUnit(EHI:GetInstanceElementID(100000, index)) then -- Bomb guy is here
                for i = 100003, 100006, 1 do
                    managers.mission:add_runned_unit_sequence_trigger(EHI:GetInstanceElementID(i, index), "interact", HostageMoneyInteracted )
                end
                loot_triggers[EHI:GetInstanceElementID(100029, index)] = { special_function = SF.CustomCode, f = HostageExploded }
                break
            end
        end
        EHI:ShowLootCounterNoChecks({
            max = 9 + MoneyBagsInVault + MoneyAroundHostage,
            max_xp_bags = 10,
            offset = true,
            triggers = loot_triggers,
            hook_triggers = true,
            client_from_start = true
        })
    end)
    -- coke, money, meth
    EHI:HookLootRemovalElement({ 101681, 101700, 101701 })
    local CokeDestroyedTrigger = { special_function = EHI:RegisterCustomSF(function(self, ...)
        self._loot:DecreaseLootCounterProgressMax()
    end) }
    other[101264] = CokeDestroyedTrigger
    other[101271] = CokeDestroyedTrigger
    other[101272] = CokeDestroyedTrigger
    other[101274] = CokeDestroyedTrigger
    other[101276] = CokeDestroyedTrigger
    other[101278] = CokeDestroyedTrigger
    other[101279] = CokeDestroyedTrigger
    other[101280] = CokeDestroyedTrigger
    other[101281] = CokeDestroyedTrigger
end
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local ChanceSuccess = EHI:RegisterCustomSF(function(self, trigger, element, ...)
        local id = trigger.id
        local chance = element._values.chance
        if self._trackers:CallFunction2(id, "OnChanceSuccess", chance) then -- 10%/15%
            self._trackers:AddTracker({
                id = id,
                chance = chance,
                on_fail_refresh_t = 0.5 + 35,
                reset_t = 1 + 35,
                chance_success = true,
                class = TT.Sniper.LoopRestart
            })
        end
    end)
    other[100667] = { chance = 100, time = 35, on_fail_refresh_t = 0.5 + 35, reset_t = 1 + 35, id = "Snipers", class = TT.Sniper.LoopRestart }
    other[100682] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100683] = { id = "Snipers", special_function = SF.DecreaseCounter }
    other[100685] = { id = "Snipers", special_function = ChanceSuccess }
    other[100686] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[100687] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100512] = { chance = 100, time = 35, on_fail_refresh_t = 0.5 + 35, reset_t = 1 + 35, id = "Snipers2", class = TT.Sniper.LoopRestart }
    other[101202] = { id = "Snipers2", special_function = SF.IncreaseChanceFromElement } -- +10%
    other[101197] = { id = "Snipers2", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[101208] = { id = "Snipers2", special_function = ChanceSuccess }
    other[101266] = { id = "Snipers2", special_function = SF.DecreaseCounter }
    other[101267] = { id = "Snipers2", special_function = SF.IncreaseCounter }
end
EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other,
    sync_triggers = { element = element_sync_triggers }
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2000, name = "hm2_enter_building" },
        { amount = 2000, name = "hm2_yellow_gate_open" },
        { amount = 2000, name = "hm2_hostage_rescued", optional = true },
        { amount = 2000, name = "hm2_magnetic_door_open" },
        { amount = 2000, name = "hm2_enter_apartment" },
        { amount = 2000, name = "vault_open" },
        { amount = 2000, name = "hm2_commissar_dead" },
        { escape = 2000 }
    },
    loot_all = { amount = 1000, times = 10 },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot_all = { max = 10 }
            }
        }
    }
})