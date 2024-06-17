local EHI = EHI
local triggers =
{
    [100806] = { time = 62 + 24, id = "HeliEscape", icons = EHI.Icons.HeliEscape, hint = EHI.Hints.Escape }
}

EHI:ParseTriggers({ mission = triggers })
EHI:AddXPBreakdown({
    objective =
    {
        escape = 13000
    },
    no_total_xp = true
})