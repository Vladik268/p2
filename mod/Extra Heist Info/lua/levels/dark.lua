---@class EHIdark5Tracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIdark5Tracker = class(EHIProgressTracker)
---@param params EHITracker.params
function EHIdark5Tracker:pre_init(params)
    self._bodies = {}
    EHIdark5Tracker.super.pre_init(self, params)
end

function EHIdark5Tracker:SetProgress(progress)
    self:SetTextColor(Color.white)
    EHIdark5Tracker.super.SetProgress(self, progress)
end

function EHIdark5Tracker:GetTotalProgress()
    local total = 0
    for _, value in pairs(self._bodies or {}) do
        if value == 1 then -- Mission Script expects exactly 1 body bag in dumpster
            total = total + 1
        end
    end
    return total
end

function EHIdark5Tracker:IncreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 0) + 1
    self:SetProgress(self:GetTotalProgress())
end

function EHIdark5Tracker:DecreaseProgress(element)
    self._bodies[element] = (self._bodies[element] or 1) - 1
    self:SetProgress(self:GetTotalProgress())
end

function EHIdark5Tracker:SetCompleted(force)
    EHIdark5Tracker.super.SetCompleted(self, force)
    self._disable_counting = false
    self._status = nil
end

local EHI = EHI
local Icon = EHI.Icons
local Hints = EHI.Hints
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local triggers = {
    [106026] = { time = 10, id = "Van", icons = Icon.CarEscape, hint = Hints.LootEscape },

    [106036] = { time = 410/30, id = "Boat", icons = Icon.BoatEscape, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    dark_2 =
    {
        elements =
        {
            [100296] = { time = 420, class = TT.Achievement.Base },
            [100290] = { special_function = SF.SetAchievementComplete }
        },
        load_sync = function(self)
            self._achievements:AddTimedAchievementTracker("dark_2", 420)
        end
    },
    dark_3 =
    {
        elements =
        {
            [100296] = { class = TT.Achievement.Status },
            [100470] = { special_function = SF.SetAchievementFailed }
        }
    },
    dark_5 =
    {
        elements =
        {
            [100296] = { max = 4, class = "EHIdark5Tracker", show_finish_after_reaching_target = true },
        },
        preparse_callback = function(data)
            local AddBodyBag = EHI:RegisterCustomSF(function(self, trigger, ...)
                self._trackers:CallFunction(trigger.id, "IncreaseProgress", trigger.element)
            end)
            local RemoveBodyBag = EHI:RegisterCustomSF(function(self, trigger, ...)
                self._trackers:CallFunction(trigger.id, "DecreaseProgress", trigger.element)
            end)
            for i = 12850, 13600, 250 do
                local inc = EHI:GetInstanceElementID(100011, i)
                data.elements[inc] = { special_function = AddBodyBag, element = i }
                data.elements[inc + 1] = { special_function = RemoveBodyBag, element = i }
            end
        end
    },
    voff_3 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL),
        elements =
        {
            [100296] = { max = 16, class = TT.Achievement.Progress, show_finish_after_reaching_target = true, special_function = SF.AddAchievementToCounter },
            [100470] = { special_function = SF.SetAchievementFailed },
        }
    }
}

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements
})
EHI:ShowLootCounter({ max = 16 })
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 1000, name = "murky_station_equipment_found", times = 1 },
        { amount = 2000, name = "murky_station_found_emp_part", times = 2 },
        { escape = 2000 }
    },
    loot =
    {
        weapon_glock = 1000,
        weapon_scar = 1000,
        drk_bomb_part = 3000
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    weapon_glock = { max = 7 },
                    weapon_scar = { max = 7 },
                    drk_bomb_part = { min_max = 2 }
                }
            }
        }
    }
})