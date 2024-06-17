local EHI = EHI
if EHI:CheckLoadHook("CivilianLogicSurrender") or EHI:IsClient() or not EHI:CanShowCivilianCountTracker() or EHI:GetOption("civilian_count_tracker_format") == 1 then
    return
end

local original = CivilianLogicSurrender.exit
---@param data table
---@param new_logic_name string
function CivilianLogicSurrender.exit(data, new_logic_name, ...)
    if data.internal_data.is_hostage and new_logic_name ~= "travel" and new_logic_name ~= "surrender" then
        managers.ehi_tracker:CallFunction("CivilianCount", "CivilianUntied", data.key)
    end
    original(data, new_logic_name, ...)
end