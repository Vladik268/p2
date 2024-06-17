local EHI = EHI
if EHI:CheckLoadHook("ElementTerminateAssault") then
    return
end

if not EHI:IsAssaultTrackerEnabled() then
    return
end

local original =
{
    on_executed = ElementTerminateAssault.on_executed,
    client_on_executed = ElementTerminateAssault.client_on_executed
}

local function Block()
    local state = managers.groupai:state()
    if state.terminate_assaults then
        managers.ehi_assault:SetAssaultBlock(true)
    end
end

function ElementTerminateAssault:client_on_executed(...)
    original.client_on_executed(self, ...)
    Block()
end

function ElementTerminateAssault:on_executed(...)
    Block()
    original.on_executed(self, ...)
end