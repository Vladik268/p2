local EHI = EHI
if EHI:CheckLoadHook("MutatorPiggyBank") then
    return
end
local original =
{
    on_game_started = MutatorPiggyBank.on_game_started,
    sync_load = MutatorPiggyBank.sync_load,
    sync_feed_piggybank = MutatorPiggyBank.sync_feed_piggybank,
    sync_explode_piggybank = MutatorPiggyBank.sync_explode_piggybank
}
function MutatorPiggyBank:on_game_started(...)
    original.on_game_started(self, ...)
    dofile(EHI.LuaPath .. "trackers/EHIPiggyBankMutatorTracker.lua")
    managers.ehi_tracker:AddTracker({
        id = "pda9_event",
        class = "EHIPiggyBankMutatorTracker"
    })
end

function MutatorPiggyBank:sync_load(mutator_manager, load_data, ...)
    original.sync_load(self, mutator_manager, load_data, ...)
    managers.ehi_tracker:CallFunction("pda9_event", "SyncLoad", load_data.piggybank_mutator)
end

function MutatorPiggyBank:sync_feed_piggybank(...)
    original.sync_feed_piggybank(self, ...)
    managers.ehi_tracker:SetTrackerProgress("pda9_event", self._pig_fed_count)
end

function MutatorPiggyBank:sync_explode_piggybank(...)
    if self._exploded_pig_level then
        return
    end
    original.sync_explode_piggybank(self, ...)
    managers.ehi_tracker:RemoveTracker("pda9_event")
end