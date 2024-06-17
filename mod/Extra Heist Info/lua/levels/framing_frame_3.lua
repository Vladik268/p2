local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    [100931] = { time = 23, hint = Hints.Escape },
    [104910] = { time = 24, hint = Hints.Escape },
    [100842] = { time = 50, id = "Lasers", icons = { Icon.Lasers }, class = TT.Warning, remove_on_alarm = true }
}

local other =
{
    [100355] = EHI:AddAssaultDelay({ control = 35 })
}

if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local SetRespawnTime = EHI:RegisterCustomSF(function(self, trigger, ...)
        if self._trackers:CallFunction2(trigger.id, "SetRespawnTime", trigger.time) then
            self._trackers:AddTracker({
                id = trigger.id,
                time = trigger.time,
                count_on_refresh = 3,
                class = TT.Sniper.TimedCount
            })
        end
    end)
    other[100879] = { time = 60 + 75, id = "Snipers", count_on_refresh = 3, class = TT.Sniper.TimedCount }
    other[104455] = { id = "Snipers", time = 45, special_function = SetRespawnTime }
    other[104456] = { id = "Snipers", time = 75, special_function = SetRespawnTime }
    other[104460] = { id = "Snipers", time = 15, special_function = SetRespawnTime }
    other[104468] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({ mission = triggers, other = other }, "Escape", Icon.HeliEscapeNoLoot)
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 300, name = "ff3_item_deployed" },
                { amount = 1000, name = "ff3_cocaine_placed" },
                { amount = 1000, name = "ff3_gold_secured" },
                { escape = 2000 }
            },
            total_xp_override =
            {
                objectives =
                {
                    ff3_item_deployed = { times = 5 },
                    ff3_cocaine_placed = { times = 8 },
                    ff3_gold_secured = { times = 8 }
                }
            }
        },
        loud =
        {
            objectives =
            {
                { amount = 8000, name = "pc_found" },
                { amount = 8000, name = "pc_hack" },
                { escape = 8000 }
            }
        }
    }
})