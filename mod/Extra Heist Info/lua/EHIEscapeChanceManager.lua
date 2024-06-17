local EHI = EHI
---@class EHIEscapeChanceManager
EHIEscapeChanceManager = {}
---@param ehi_tracker EHITrackerManager
---@return EHIEscapeChanceManager
function EHIEscapeChanceManager:new(ehi_tracker)
    self._trackers = ehi_tracker
    self._civilians_killed = 0
    self._disabled = false
    self._synced = false
    return self
end

---@param dropin boolean
---@param chance number 0-100
---@param civilian_killed_multiplier number?
function EHIEscapeChanceManager:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
    if (dropin and not self._synced) or managers.assets:IsEscapeDriverAssetUnlocked() then
        return
    end
    self:DisableIncreaseCivilianKilled()
    self._trackers:AddTracker({
        id = "EscapeChance",
        chance = chance + (self._civilians_killed * (civilian_killed_multiplier or 5)),
        icons = { { icon = EHI.Icons.Car, color = Color.red } },
        class = EHI.Trackers.Chance,
        hint = "van_crash_chance"
    })
end

function EHIEscapeChanceManager:IncreaseCivilianKilled()
    if self._disabled then
        return
    end
    self._civilians_killed = self._civilians_killed + 1
end

function EHIEscapeChanceManager:DisableIncreaseCivilianKilled()
    self._disabled = true
end

---@param dropin boolean
---@param chance number 0-100
---@param civilian_killed_multiplier number?
function EHIEscapeChanceManager:AddChanceWhenDoesNotExists(dropin, chance, civilian_killed_multiplier)
    if self._trackers:TrackerDoesNotExist("EscapeChance") then
        self:AddEscapeChanceTracker(dropin, chance, civilian_killed_multiplier)
    end
end

function EHIEscapeChanceManager:load(data)
    local load_data = data.EHIEscapeChanceManager
    if load_data then
        self._disabled = load_data.disabled
        self._civilians_killed = load_data.civilians_killed
        self._synced = true
    end
end

function EHIEscapeChanceManager:save(data)
    local save_data = {}
    save_data.disabled = self._disabled
    save_data.civilians_killed = self._civilians_killed
    data.EHIEscapeChanceManager = save_data
end