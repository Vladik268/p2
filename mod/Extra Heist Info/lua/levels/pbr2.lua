local EHI = EHI
---@class EHIcac33Tracker : EHIAchievementStatusTracker, EHIProgressTracker
---@field super EHIAchievementStatusTracker
EHIcac33Tracker = class(EHIAchievementStatusTracker)
EHIcac33Tracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIcac33Tracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIcac33Tracker.SetProgress = EHIProgressTracker.SetProgress
function EHIcac33Tracker:init(...)
    self._progress = 0
    self._max = 200
    EHIcac33Tracker.super.init(self, ...)
    self._flash_times = 1
end

function EHIcac33Tracker:OverridePanel()
    self._progress_text = self:CreateText({
        text = self:FormatProgress(),
        visible = false,
        FitTheText = true
    })
end

function EHIcac33Tracker:Activate()
    self._progress_text:set_visible(true)
    self._text:set_visible(false)
end

function EHIcac33Tracker:SetCompleted()
    EHIcac33Tracker.super.SetCompleted(self)
    self._disable_counting = true
    self._progress_text:set_color(Color.green)
    self._progress = 200
    self._progress_text:set_text(self:FormatProgress())
end

function EHIcac33Tracker:SetFailed()
    EHIcac33Tracker.super.SetFailed(self)
    self._disable_counting = true
    self._progress_text:set_color(Color.red)
end

local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local ovk_and_up = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
local thermite = { time = 300/30, id = "ThermiteSewerGrate", icons = { Icon.Fire }, hint = EHI.Hints.Thermite }
local triggers = {
    [101985] = thermite, -- First grate
    [101984] = thermite -- Second grate
}
-- Flare is handled in CoreWorldInstanceManager.lua

---@type ParseAchievementTable
local achievements =
{
    jerry_3 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102453] = { class = TT.Achievement.Status },
            [102816] = { special_function = SF.SetAchievementFailed },
            [101314] = { special_function = SF.SetAchievementComplete }
        }
    },
    jerry_4 =
    {
        difficulty_pass = ovk_and_up,
        elements =
        {
            [102453] = { time = 83, class = TT.Achievement.Base },
            [102452] = { special_function = SF.SetAchievementComplete },
        }
    },
    cac_33 =
    {
        difficulty_pass = EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish),
        elements =
        {
            [102504] = { status = "land", class = "EHIcac33Tracker" },
            [103486] = { status = "ok", special_function = SF.SetAchievementStatus },
            [103479] = { special_function = SF.SetAchievementComplete },
            [103475] = { special_function = SF.SetAchievementFailed },
            [103487] = { special_function = SF.CallCustomFunction, f = "Activate" },
            [103477] = { special_function = SF.IncreaseProgress },
        },
        sync_params = { from_start = true }
    }
}

local other =
{
    [100653] = EHI:AddAssaultDelay({ control = 2 + 15, trigger_times = 1 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    other[100161] = { chance = 10, time = 10 + 25, on_fail_refresh_t = 25, on_success_refresh_t = 20 + 10 + 25, id = "Snipers", class = TT.Sniper.Loop, sniper_count = 3 }
    other[100153] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100159] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100155] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100152] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100156] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%
    other[100148] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100146] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})
local ring = { special_function = SF.IncreaseProgress }
local voff_4_triggers =
{
    [103248] = ring
}
for i = 103252, 103339, 3 do
    voff_4_triggers[i] = ring
end
EHI:ShowAchievementLootCounter({
    achievement = "voff_4",
    max = 9,
    triggers = voff_4_triggers,
    load_sync = function(self)
        self._trackers:SetTrackerProgressRemaining("voff_4", self:CountInteractionAvailable("ring_band"))
    end
})
EHI:AddXPBreakdown({
    objectives =
    {
        { amount = 3000, name = "bos_cargo_door_open" },
        { amount = 3000, name = "bos_money_released" },
        { amount = 2500, name = "bos_money_pallet_found" },
        { amount = 500, name = "flare" },
        { amount = 700, name = "bos_found_scattered_money" },
        { amount = 1500, name = "bos_heli_picked_up_money" },
        { escape = 6000 }
    },
    total_xp_override =
    {
        objectives =
        {
            bos_money_pallet_found = { times = 3 },
            flare = { times = 3 },
            bos_found_scattered_money = { times = 8 },
            bos_heli_picked_up_money = { times = 3 }
        }
    }
})