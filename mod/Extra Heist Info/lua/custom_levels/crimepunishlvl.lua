local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local triggers = {
    [100157] = { time = 60 + 43, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, class = TT.Pausable, hint = Hints.Escape },
    [101137] = { time = 43, id = "EscapeHeli", special_function = SF.PauseTrackerWithTime },
    [101144] = { time = 43, id = "EscapeHeli", icons = Icon.HeliEscapeNoLoot, special_function = SF.UnpauseTrackerIfExists, hint = Hints.Escape }
}

EHI:ParseTriggers({ mission = triggers })