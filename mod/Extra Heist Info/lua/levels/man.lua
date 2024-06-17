local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local deal = { Icon.Car, Icon.Goto }
local delay = 4 + 356/30
local start_chance = 15 -- Normal
if EHI:IsBetweenDifficulties(EHI.Difficulties.Hard, EHI.Difficulties.VeryHard) then
    start_chance = 10
elseif ovk_and_up then
    start_chance = 5
end
local CodeChance = { chance = start_chance, id = "CodeChance", icons = { Icon.Hostage, Icon.PCHack }, flash_times = 1, class = TT.Chance, hint = Hints.man_Code }
---@type ParseTriggerTable
local triggers = {
    [101587] = { time = 30 + delay, id = "DealGoingDown", icons = deal, hint = Hints.Wait },
    [101588] = { time = 40 + delay, id = "DealGoingDown", icons = deal, hint = Hints.Wait },
    [101589] = { time = 50 + delay, id = "DealGoingDown", icons = deal, hint = Hints.Wait },
    [101590] = { time = 60 + delay, id = "DealGoingDown", icons = deal, hint = Hints.Wait },
    [101591] = { time = 70 + delay, id = "DealGoingDown", icons = deal, hint = Hints.Wait },

    [102891] = { id = "CodeChance", special_function = SF.RemoveTracker },

    [101825] = CodeChance, -- First hack
    [102016] = CodeChance, -- Second and Third Hack
    [102121] = { time = 10, id = "Escape", icons = { Icon.Escape }, hint = Hints.Escape },

    [103163] = { additional_time = 1.5 + 25, random_time = 10, id = "Faint", icons = { "hostage", Icon.Wait }, hint = Hints.Wait },

    [102866] = { time = 5, id = "GotCode", icons = { Icon.Wait }, hint = Hints.Wait },

    [102887] = { amount = 5, id = "CodeChance", special_function = SF.IncreaseChance }
}

---@type ParseAchievementTable
local achievements =
{
    man_2 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [100698] = { status = EHI.Const.Trackers.Achievement.Status.NoDown, class = TT.Achievement.Status, trigger_times = 1 },
            [103963] = { special_function = SF.SetAchievementFailed },
            [103964] = { special_function = SF.SetAchievementComplete }
        }
    },
    man_3 =
    {
        elements =
        {
            [100698] = { class = TT.Achievement.Status, trigger_times = 1 },
            [103957] = { special_function = SF.SetAchievementFailed },
            [103958] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            if self.ConditionFunctions.IsStealth() then
                self._achievements:AddAchievementStatusTracker("man_3")
            end
        end
    },
    man_4 =
    {
        elements =
        {
            [100698] = { max = 10, class = TT.Achievement.Progress, trigger_times = 1 },
            [103989] = { special_function = SF.IncreaseProgress }
        },
        load_sync = function(self)
            -- Achievement count used planks on windows, vents, ...
            -- There are total 49 positions and 10 planks
            self._achievements:AddAchievementProgressTracker("man_4", 10, 49 - self:CountInteractionAvailable("stash_planks"))
        end
    }
}

local other =
{
    [100116] = EHI:AddAssaultDelay({ control_additional_time = 20 + 1, random_time = 10 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102161] = { chance = 20, time = 30 + 20, recheck_t = 20, id = "Snipers", class = TT.Sniper.TimedChance, trigger_times = 1 }
    other[103169] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[101756] = { special_function = EHI:RegisterCustomSF(function(self, trigger, element, enabled)
        if EHI:IsHost() and not element:_values_ok() then
            return
        end
        if self._trackers:CallFunction2("Snipers", "SnipersKilled", 40) then -- 20 + 20
            self._trackers:AddTracker({
                id = "Snipers",
                time = 40,
                recheck_t = 20,
                chance = 20,
                class = TT.Sniper.TimedChance
            })
        end
    end)}
    other[102185] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[102186] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 20%
    other[103104] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 100%
    other[100557] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 100%
    other[102181] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102180] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl =
{
    -- Saws
    [102034] = { remove_vanilla_waypoint = 102303 },
    [102035] = { remove_vanilla_waypoint = 102301 },
    [102040] = { remove_vanilla_waypoint = 101837 },
    [102041] = { remove_vanilla_waypoint = 101992 }
}

EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 2500, name = "undercover_deal_stealth" },
        { amount = 500, name = "undercover_deal_loud" },
        { amount = 4000, name = "undercover_limo_open" },
        { amount = 4000, name = "undercover_taxman_is_in_chair" },
        { amount = 4000, name = "pc_hack", times = 3 },
        { amount = 1000, name = "undercover_hack_fixed" },
        { escape = 3000 }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                objectives =
                {
                    undercover_deal_stealth = { min = 0 },
                    undercover_deal_loud = { max = 0 },
                    undercover_hack_fixed = { min = 0, max = 3 }
                }
            }
        }
    }
})