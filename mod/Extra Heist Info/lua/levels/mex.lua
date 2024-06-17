local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
---@param block boolean
local function SetAssaultTrackerBlock(block)
    managers.ehi_assault:SetAssaultBlock(block)
end
---@type ParseTriggerTable
local triggers = {
    [102685] = { id = "Refueling", icons = { Icon.Oil }, class = TT.Pausable, special_function = SF.SetTimeIfLoudOrStealth, data = { loud = 121, stealth = 91 }, trigger_times = 1, hint = Hints.FuelTransfer },
    [102678] = { id = "Refueling", special_function = SF.UnpauseTracker },
    [102684] = { id = "Refueling", special_function = SF.PauseTracker },
    [101983] = { time = 15, id = "C4Trap", icons = { Icon.C4 }, class = TT.Warning, special_function = SF.ExecuteIfElementIsEnabled, hint = Hints.Explosion },
    [101722] = { id = "C4Trap", special_function = SF.RemoveTracker }
}
---@type ParseAchievementTable
local achievements =
{
    mex_9 =
    {
        elements =
        {
            [100107] = { max = 4, class = TT.Achievement.Progress }
        },
        preparse_callback = function(data)
            local trigger = { special_function = SF.IncreaseProgress }
            for i = 101502, 101509, 1 do
                data.elements[i] = trigger
            end
        end
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 30 }), -- Arizona (When alarm is raised in Mexico (for the first time), run this trigger instead)
    [100697] = EHI:AddAssaultDelay({ control_additional_time = 30, random_time = 10, condition_function = EHI.ConditionFunctions.IsLoud }), -- Mexico (ElementDifficulty already exists)

    [100880] = { special_function = SF.CustomCode, f = SetAssaultTrackerBlock, arg = true }, -- Entered the tunnel
    [103212] = { special_function = SF.CustomCode, f = SetAssaultTrackerBlock, arg = false } -- Entered in Mexico
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[102495] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, single_sniper = EHI:IsDifficulty(EHI.Difficulties.Normal) }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[102473] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "SniperSpawnsSuccess" }
    other[102485] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[102480] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 1000, name = "mex1_red_door_found" },
                { amount = 2000, name = "mex1_tunnel_found" },
                { amount = 2000, name = "mex1_tunnel_open" },
                { amount = 2000, name = "mex1_plane_found" },
                { amount = 8000, name = "mex1_secured_mandatory_bags" },
                { amount = 2000, name = "mex1_started_fueling" },
                { amount = 3000, name = "mex1_hose_detached" },
                { escape = 1000 },
            },
            loot_all = 1000
        },
        loud =
        {
            objectives =
            {
                { amount = 1000, name = "mex1_tunnel_found" },
                { amount = 3000, name = "mex1_explosives_found" },
                { amount = 3000, name = "mex1_tunnel_open" },
                { amount = 2000, name = "mex1_plane_found" },
                { amount = 6000, name = "mex1_secured_mandatory_bags" },
                { amount = 1000, name = "mex1_started_fueling" },
                { amount = 2000, name = "mex1_hose_detached" },
                { escape = 1000 },
            },
            loot_all = 1000
        }
    }
})