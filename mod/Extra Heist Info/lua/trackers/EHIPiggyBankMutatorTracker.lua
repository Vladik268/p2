local lerp = math.lerp
local sin = math.sin
local Color = Color
---@class EHIPiggyBankMutatorTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIPiggyBankMutatorTracker = class(EHIProgressTracker)
EHIPiggyBankMutatorTracker._forced_icons = { "piggy" }
---@param panel Panel
---@param params EHITracker.params
---@param parent_class EHITrackerManager
function EHIPiggyBankMutatorTracker:init(panel, params, parent_class)
    self._current_level = 1
    self._max_levels = 7
    params.flash_times = 1
    if params.revenge then
        self._piggy_tweak_data = tweak_data.mutators.piggyrevenge.pig_levels
    else
        self._piggy_tweak_data = tweak_data.mutators.piggybank.pig_levels
    end
    EHIPiggyBankMutatorTracker.super.init(self, panel, params, parent_class)
    self:SetNewMax()
end

function EHIPiggyBankMutatorTracker:OverridePanel()
    self:SetBGSize()
    self._levels_text = self:CreateText({
        text = self:FormatLevels(),
        w = self._bg_box:w() / 2,
        left = self._text:right(),
        FitTheText = true
    })
    self:SetIconX()
end

function EHIPiggyBankMutatorTracker:FormatLevels()
    return self._current_level .. "/" .. self._max_levels
end

function EHIPiggyBankMutatorTracker:SetNewMax()
    local levels = self._piggy_tweak_data[self._current_level]
    local new_max = levels and levels.bag_requirement or 0
    if self._current_level <= 2 then
        new_max = new_max + 1
    end
    self._max = new_max
    self:SetAndFitTheText()
end

function EHIPiggyBankMutatorTracker:CheckLevelFromKills()
    if self._progress == 0 then -- The game has not started yet or players haven't secured bags yet
        return
    end
    local n = table.size(self._piggy_tweak_data)
    local offset = { 1, 1 }
    local done = false
    for i = 1, n, 1 do
        local max = (self._piggy_tweak_data[i].bag_requirement or 0) + (offset[i] or 0)
        if max > self._progress then
            self._current_level = i
            self._max = max
            self:SetAndFitTheText()
            done = true
            break
        end
    end
    if not done and self._progress >= (self._piggy_tweak_data[n].bag_requirement or 0) then
        self._current_level = 6
        self:SetCompleted()
    end
end

function EHIPiggyBankMutatorTracker:SetCompleted(force)
    self._current_level = self._current_level + 1
    if self._current_level == self._max_levels then
        self._disable_counting = true
        self:SetAndFitTheText("MAX")
        self:SetTextColor(Color.green)
    else
        self:SetNewMax()
        self:AnimateNewLevel()
    end
    self._levels_text:set_text(self:FormatLevels())
end

function EHIPiggyBankMutatorTracker:SyncLoad(data)
    if data.exploded_pig_level then
        self:delete()
        return
    end
    self._progress = data.pig_fed_count
    self:CheckLevelFromKills()
end

function EHIPiggyBankMutatorTracker:AnimateNewLevel()
    if self._text and alive(self._text) then
        self._text:stop()
        self._text:animate(function(o)
            local spins = 1
            while spins <= 3 do
                local t = 0
                while t < 1 do
                    t = t + coroutine.yield()
                    local n = 1 - sin(t * 180)
                    --local r = lerp(1, 0, n)
                    local g = lerp(1, 0, n)
                    local c = Color(g, 1, g)
                    self:SetTextColor(c)
                end
                spins = spins + 1
            end
            self:SetTextColor(Color.white)
        end)
    end
end

function EHIPiggyBankMutatorTracker:SetTextColor(color)
    self._levels_text:set_color(color)
    EHIPiggyBankMutatorTracker.super.SetTextColor(self, color)
end

function EHIPiggyBankMutatorTracker:delete()
    if self._text and alive(self._text) then
        self._text:stop()
    end
    EHIPiggyBankMutatorTracker.super.delete(self)
end