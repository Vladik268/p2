local EHI = EHI
local SF = EHI.SpecialFunctions
local bilbo_baggin_bags = 8
local function bilbo_baggin()
    bilbo_baggin_bags = bilbo_baggin_bags - 1
    if bilbo_baggin_bags == 0 then
        managers.ehi_achievement:AddAchievementProgressTracker("bilbo_baggin", 8, 0, true)
        EHI:AddAchievementToCounter({
            achievement = "bilbo_baggin"
        })
    end
end
---@type ParseAchievementTable
local achievements =
{
    bilbo_baggin =
    {
        elements =
        {
            [104263] = { special_function = SF.CustomCode, f = bilbo_baggin }
        }
    }
}

local other = {}
if EHI:IsLootCounterVisible() then
    other[104263] = EHI:AddLootCounter3(function(self, ...)
        if not self._cache.CreateCounter then
            EHI:ShowLootCounterNoCheck({})
            self._cache.CreateCounter = true
        end
        self._loot:IncreaseLootCounterProgressMax()
    end)
end

EHI:ParseTriggers({
    achievement = achievements,
    other = other
})
EHI:AddXPBreakdown({
    objective =
    {
        escape = 4000
    },
    no_total_xp = true
})