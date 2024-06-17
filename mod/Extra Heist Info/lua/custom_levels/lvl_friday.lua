local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local OVKOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local OVKOrBelow = EHI:IsDifficultyOrBelow(EHI.Difficulties.OVERKILL)
local CrashIcons = { Icon.PCHack, Icon.Fix, "pd2_question" }
if EHI:GetOption("show_one_icon") then
    CrashIcons = { Icon.Fix }
end

---@type ParseTriggerTable
local triggers =
{
    [300193] = { time = 40 + 25, id = "HeliDrill", icons = Icon.HeliDropDrill, hint = Hints.DrillDelivery },
    [300482] = { time = 30 + 25, id = "HeliEscape", icons = Icon.HeliEscape, hint = Hints.LootEscape }
}

---@type ParseAchievementTable
local achievements =
{
    speedrunner =
    {
        difficulty_pass = OVKOrAbove,
        elements =
        {
            [303036] = { time = 720, class = TT.Achievement.Base },
            [303024] = { special_function = SF.SetAchievementComplete }
        },
        sync_params = { from_start = true }
    },
    window =
    {
        difficulty_pass = OVKOrAbove,
        elements =
        {
            [303036] = { class = TT.Achievement.Status },
            [303039] = { special_function = SF.SetAchievementFailed, trigger_times = 1 }
        },
        sync_params = { from_start = true }
    }
}
EHI:PreparseBeardlibAchievements(achievements, "Mallbank")
EHI:ShowBeardLibAchievementLootCounter_Mallbank("shopper", 15, EHI.Difficulties.OVERKILL)

local FirstAssaultDelay = 350/30 + 20
local other = {}
if EHI:IsMayhemOrAbove() then
    other[301049] = EHI:AddAssaultDelay({ control = FirstAssaultDelay })
else
    other[301138] = EHI:AddAssaultDelay({ control = 50 + 8 + FirstAssaultDelay })
    other[301766] = EHI:AddAssaultDelay({ control = 40 + 8 + FirstAssaultDelay })
    other[301771] = EHI:AddAssaultDelay({ control = 30 + 8 + FirstAssaultDelay })
    other[301772] = EHI:AddAssaultDelay({ control = 20 + 8 + FirstAssaultDelay })
    other[301773] = EHI:AddAssaultDelay({ control = 10 + 8 + FirstAssaultDelay })
end

local DisableWaypoints = {
    --- Defend WPs for saws
    [302329] = true,
    [302330] = true
}

local units = {}
for i = 0, 1500, 250 do --levels/instances/mods/fri_computer_hack/world
    if i ~= 1250 then -- Does not exist on 1250
        local id = "CrashChance" .. tostring(i)
        triggers[EHI:GetInstanceElementID(100006, i, 300000)] = { id = id, chance = OVKOrBelow and 20 or 60, icons = CrashIcons, class = TT.Chance, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.election_day_3_CrashChance }
        if OVKOrBelow then
            triggers[EHI:GetInstanceElementID(100015, i, 300000)] = { id = id, special_function = SF.IncreaseChanceFromElement }
        end
        triggers[EHI:GetInstanceElementID(100035, i, 300000)] = { id = id, special_function = SF.RemoveTracker }
        units[EHI:GetInstanceUnitID(100007, i, 300000)] = { remove_vanilla_waypoint = EHI:GetInstanceElementID(100028, i, 300000) }
        DisableWaypoints[EHI:GetInstanceElementID(100027, i, 300000)] = true -- PC Fix WP
    end
end
for i = 2000, 2500, 500 do
    DisableWaypoints[EHI:GetInstanceElementID(100053, i, 300000)] = true -- Defend Vault Hack
    DisableWaypoints[EHI:GetInstanceElementID(100066, i, 300000)] = true -- Defend Vault Drill
    DisableWaypoints[EHI:GetInstanceElementID(100067, i, 300000)] = true -- Fix Vault Drill
    units[EHI:GetInstanceUnitID(100002, i, 300000)] = { icons = { Icon.Vault } }
end
EHI:DisableWaypoints(DisableWaypoints)
EHI:UpdateUnits(units)

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 400, name = "pc_hack" },
        { amount = 1500, name = "vault_open" },
        { escape = 6000 }
    },
    loot =
    {
        loot_required = { amount = 0, name = "any", mandatory = 3 },
        loot_additional = { amount = 50, name = "any", additional = true },
    },
    total_xp_override =
    {
        params =
        {
            min_max =
            {
                loot =
                {
                    loot_required = { min_max = 0 },
                    loot_additional = { max = 12 }
                }
            }
        }
    }
})