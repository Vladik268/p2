local BAI = BAI
if BAI:CheckLoadHook("GameSetup") then
    return
end

BAI:Hook(GameSetup, "load", function(...)
    LuaNetworking:SendToPeer(1, BAI.SyncMessage, BAI.data.BAI_Q)
    BAI:LoadSync()
end)