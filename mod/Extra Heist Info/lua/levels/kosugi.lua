local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
---@class EHIkosugi5Tracker : EHIAchievementProgressGroupTracker
---@field super EHIAchievementProgressGroupTracker
EHIkosugi5Tracker = class(EHIAchievementProgressGroupTracker)
---@param params EHITracker.params
function EHIkosugi5Tracker:post_init(params)
    EHIkosugi5Tracker.super.post_init(self, params)
    EHI:AddAchievementToCounter({
        achievement = "kosugi_5",
        counter =
        {
            check_type = EHI.LootCounter.CheckType.CustomCheck,
            f = function(loot)
                self:SetProgress(loot:GetSecuredBagsTypeAmount("samurai_suit"), "armor")
                self:SetProgress(loot:GetSecuredBagsAmount(), "bags")
                if self._counters == self._completed_counters then
                    EHI:RemoveEventListener("kosugi_5")
                end
            end
        },
        no_sync = true
    })
end

if EHI:GetOption("show_mission_trackers") then
    local show_waypoint, show_waypoint_only = EHI:GetWaypointOptionWithOnly("show_waypoints_mission")
    for _, unit_id in ipairs({ 100098, 102897, 102899, 102900 }) do
        managers.mission:add_runned_unit_sequence_trigger(unit_id, "interact", function(unit)
            if not show_waypoint_only then
                managers.ehi_tracker:AddTracker({
                    id = tostring(unit_id),
                    time = 10,
                    icons = { Icon.Fire },
                    hint = Hints.Thermite
                })
            end
            if show_waypoint then
                managers.ehi_waypoint:AddWaypoint(tostring(unit_id), {
                    time = 10,
                    icon = Icon.Fire,
                    position = managers.ehi_manager:GetUnitPositionOrDefault(unit_id)
                })
            end
        end)
    end
end

local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local DisableTriggerAndExecute = EHI:RegisterCustomSF(function(self, trigger, ...)
    self:UnhookTrigger(trigger.data.id)
    self:CreateTracker(trigger)
end)
local triggers = {
    [103492] = { time = 300, id = "Blackhawk", icons = { Icon.Heli, Icon.Goto }, hint = Hints.kosugi_Heli, trigger_times = 1 },
    [101219] = { time = 27, id = "BlackhawkDropLoot", icons = { Icon.Heli, Icon.Loot, Icon.Goto }, hint = Hints.kosugi_Loot },
    [100303] = { time = 30, id = "BlackhawkDropGuards", icons = { Icon.Heli, "pager_icon", Icon.Goto }, class = TT.Warning, hint = Hints.kosugi_Guards },

    [100955] = { time = 10, id = "KeycardLeft", icons = { Icon.Keycard }, class = TT.Warning, special_function = DisableTriggerAndExecute, data = { id = 100957 }, hint = Hints.kosugi_Keycard },
    [100957] = { time = 10, id = "KeycardRight", icons = { Icon.Keycard }, class = TT.Warning, special_function = DisableTriggerAndExecute, data = { id = 100955 }, hint = Hints.kosugi_Keycard },
    [100967] = { special_function = SF.RemoveTracker, data = { "KeycardLeft", "KeycardRight" } }
}

---@type ParseAchievementTable
local achievements =
{
    kosugi_2 =
    {
        elements =
        {
            [102700] = { max = 6, class = TT.Achievement.Progress, status_is_overridable = true, show_finish_after_reaching_target = true },
            [102796] = { special_function = SF.SetAchievementFailed },
            [100311] = { special_function = SF.IncreaseProgress }
        }
    },
    kosugi_3 =
    {
        elements =
        {
            [102700] = { max = 7, class = TT.Achievement.Progress }
        },
        load_sync = function(self)
            local counter = 0
            for _, loot_type in ipairs({ "artifact_statue", "money", "coke", "gold", "circuit", "weapon", "painting" }) do
                local amount = managers.loot:GetSecuredBagsTypeAmount(loot_type)
                counter = counter + math.min(amount, 1)
            end
            if counter < 7 then
                self._achievements:AddAchievementProgressTracker("kosugi_3", 7, counter)
            end
        end,
        preparse_callback = function(data)
            local trigger = { special_function = SF.IncreaseProgress }
            -- Artifact, Money, Coke, Server, Gold, Weapon, Painting
            for _, id in ipairs({ 104040, 104041, 104042, 104044, 104047, 104048, 104049 }) do
                data.elements[id] = trigger
            end
        end
    },
    kosugi_5 =
    {
        elements =
        {
            [102700] = { class = "EHIkosugi5Tracker", counter = {
                { max = 16, id = "bags" },
                { max = 4, id = "armor" }
            } }
        },
        load_sync = function(self)
            local counter_armor = managers.loot:GetSecuredBagsTypeAmount("samurai_suit")
            local counter_loot = managers.loot:GetSecuredBagsAmount()
            if counter_loot < 16 or counter_armor < 4 then
                self._achievements:AddAchievementProgressTracker("kosugi_5", 0, 0, nil, "EHIkosugi5Tracker")
                self._trackers:CallFunction("kosugi_5", "AddFromSync", {
                    { progress = math.min(counter_loot, 16), max = 16, id = "bags" },
                    { progress = math.min(counter_armor, 4), max = 4, id = "armor" }
                })
            end
        end,
        cleanup_callback = function()
            EHIkosugi5Tracker = nil ---@diagnostic disable-line
        end
    }
}

local sidejob = {}
if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
    local IncreaseProgress = { special_function = SF.IncreaseProgress }
    local elements = {
        [103427] = { max = 9, icons = { "daily_secret_identity" }, class = TT.SideJob.Progress, show_finish_after_reaching_target = true },
        [100484] = IncreaseProgress,
        [100515] = IncreaseProgress,
        [100534] = IncreaseProgress,
        [100536] = IncreaseProgress
    }
    for i = 100491, 100509, 2 do
        elements[i] = IncreaseProgress
    end
    for i = 100519, 100531, 2 do
        elements[i] = IncreaseProgress
    end
    for i = 100539, 100555, 2 do
        elements[i] = IncreaseProgress
    end
    tweak_data.ehi.icons.daily_secret_identity = { texture = "guis/textures/pd2_mod_ehi/icons_atlas", texture_rect = {0, 170, 64, 64} }
    tweak_data.hud_icons.daily_secret_identity = tweak_data.ehi.icons.daily_secret_identity
    sidejob.daily_secret_identity = { elements = elements }
end

local other = {}
if EHI:IsLootCounterVisible() then
    local function CheckForBrokenWeapons()
        local table_of_weapons = { 100863, 100864, 100865, 100866, 100867, 100372 }
        return tweak_data.ehi.functions.GetNumberOfVisibleWeapons(table_of_weapons)
    end
    local function CheckForBrokenCocaine()
        local table_of_coke = { 100686, 100687, 100688, 100689, 100690, 100691, 100692, 100374 }
        return tweak_data.ehi.functions.GetNumberOfVisibleOtherLoot(table_of_coke)
    end
    -- Loot Counter  
    -- 2 cocaine; disabled due to check above  
    -- 1 server  
    -- 2 random money bundles inside the warehouse  
    -- 4 random money bundles outside  
    -- 4 pieces of armor
    local base_amount = 0 + 1 + 2 + 4 + 4
    local random_weapons = 0 -- Disabled due to check above; should be 2
    local random_paintings = 2
    local crates = 4 -- (Normal + Hard)
    if EHI:IsBetweenDifficulties(EHI.Difficulties.VeryHard, EHI.Difficulties.OVERKILL) then
        crates = 5
    elseif EHI:IsMayhemOrAbove() then
        crates = 6
        --random_weapons = 1
        random_paintings = 1
    end
    other[102700] = EHI:AddLootCounter2(function()
        local loot_correction = CheckForBrokenWeapons() + CheckForBrokenCocaine()
        EHI:ShowLootCounterNoChecks({
            max = base_amount + crates + random_weapons + random_paintings + loot_correction,
            max_xp_bags = 16,
            triggers =
            {
                [103396] = { special_function = SF.IncreaseProgressMax2 }
            },
            hook_triggers = true,
            no_triggers_if_max_xp_bags_gt_max = true
        })
    end)
    -- Not included bugged loot, this is checked after spawn -> 102700
    -- Reported here:
    -- https://steamcommunity.com/app/218620/discussions/14/5710018482972011532/
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    sidejob = sidejob,
    other = other
})

EHI:ShowAchievementLootCounter({
    achievement = "kosugi_1",
    max = 4
})
EHI:ShowAchievementLootCounter({
    achievement = "kosugi_4",
    max = 4,
    counter =
    {
        check_type = EHI.LootCounter.CheckType.CheckTypeOfLoot,
        loot_type = "samurai_suit"
    }
})
local min_bags = EHI:GetValueBasedOnDifficulty({
    normal = 3,
    hard = 5,
    veryhard = 7,
    overkill = 9,
    mayhem_or_above = 12
})
EHI:AddXPBreakdown({
    objective =
    {
        escape =
        {
            { amount = 4000, stealth = true }
        }
    },
    loot =
    {
        samurai_suit = { amount = 6000, to_secure = 4 },
        _else = { amount = 500, times = 16 },
        xp_bonus = { amount = 4000, to_secure = 3, times = 1 }
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    samurai_suit = { max = 1 },
                    _else = { min = min_bags, max = 16 },
                    xp_bonus = { min_max = 1 }
                },
                bonus_xp = { max = 4000 } -- Stealth Escape
            }
        }
    }
})