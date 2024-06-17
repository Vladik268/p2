---@class Drill
---@field _autorepair_clbk_id string?
---@field _autorepair_chance number
---@field _disable_upgrades boolean
---@field _unit UnitTimer
---@field EVENT_IDS table<string, number>
---@field is_drill boolean
---@field is_hacking_device boolean
---@field is_saw boolean
---@field get_skill_upgrades fun(self: self): table

local EHI = EHI
if EHI:CheckLoadHook("Drill") then
    return
end
local highest_id = 0
for _, id in pairs(Drill.EVENT_IDS) do
    if id > highest_id then
        highest_id = id
    end
end
local HasAutorepair = highest_id + 1
local NoAutorepair = highest_id + 2

local original = {}

---@param unit_key string
---@param autorepair boolean
local function SetAutorepair(unit_key, autorepair)
    managers.ehi_manager:SetTimerAutorepair(unit_key, autorepair)
end

if EHI:IsHost() then
    original.set_autorepair = Drill.set_autorepair
    function Drill:set_autorepair(...)
        original.set_autorepair(self, ...)
        SetAutorepair(tostring(self._unit:key()), self._autorepair_clbk_id --[[@as boolean]])
        managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", self._autorepair_clbk_id and HasAutorepair or NoAutorepair)
    end
    original.clbk_autorepair = Drill.clbk_autorepair
    function Drill:clbk_autorepair(...)
        original.clbk_autorepair(self, ...)
        if alive(self._unit) then
            managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", NoAutorepair)
            SetAutorepair(tostring(self._unit:key()), false)
        end
    end
    original.set_jammed = Drill.set_jammed
    function Drill:set_jammed(...)
        original.set_jammed(self, ...)
        if self._autorepair_chance and self._unit and alive(self._unit) then
            SetAutorepair(tostring(self._unit:key()), self._autorepair_clbk_id --[[@as boolean]])
            managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", self._autorepair_clbk_id and HasAutorepair or NoAutorepair)
        end
    end
else
    -- Can't rely on Drill:on_autorepair() anymore as they changed autorepair chance to check every jam and not once the unit is placed or upgraded...
    -- Very well done, OVK. WHYYYYYYYYYYYY
    original.sync_net_event = Drill.sync_net_event
    function Drill:sync_net_event(event_id, ...)
        if event_id == HasAutorepair and self._unit and alive(self._unit) then
            self._autorepair_client = true
            SetAutorepair(tostring(self._unit:key()), true)
        elseif event_id == NoAutorepair and self._unit and alive(self._unit) then
            self._autorepair_client = nil
            SetAutorepair(tostring(self._unit:key()), false)
        end
        original.sync_net_event(self, event_id, ...)
    end
end

function Drill:CanAutorepair()
    return self._autorepair_clbk_id or self._autorepair_client
end