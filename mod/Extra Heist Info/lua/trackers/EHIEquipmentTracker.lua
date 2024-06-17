---@class EHIEquipmentTracker : EHITracker
---@field super EHITracker
EHIEquipmentTracker = class(EHITracker)
EHIEquipmentTracker._update = false
function EHIEquipmentTracker:pre_init(params)
    self._format = params.format or "charges"
    self._dont_show_placed = params.dont_show_placed
    self._amount = 0
    self._placed = 0
    self._deployables = {}
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("%g (%d)", self._parent_class.RoundNumber(self._amount, 2), self._placed)
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("%d (%d)", self._amount, self._placed)
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("(%d) %g", self._placed, self._parent_class.RoundNumber(self._amount, 2))
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("(%d) %d", self._placed, self._amount)
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("(%g) %d", self._parent_class.RoundNumber(self._amount, 2), self._placed)
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("(%d) %d", self._amount, self._placed)
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return string.format("(%d) %g", self._placed, self._parent_class.RoundNumber(self._amount, 2))
            elseif self._dont_show_placed then
                return tostring(self._amount)
            end
            return string.format("(%d) %d", self._placed, self._amount)
        end
    elseif format == 5 then -- Uses
        function EHIEquipmentTracker:Format()
            if self._format == "percent" then
                return tostring(self._parent_class.RoundNumber(self._amount, 2))
            end
            return tostring(self._amount)
        end
    else -- Bags placed
        function EHIEquipmentTracker:Format()
            if self._dont_show_placed then
                if self._format == "percent" then
                    return tostring(self._parent_class.RoundNumber(self._amount, 2))
                end
                return tostring(self._amount)
            end
            return tostring(self._placed)
        end
    end
end

function EHIEquipmentTracker:UpdateAmount(unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    self._deployables[key] = amount
    self._amount = 0
    self._placed = 0
    for _, value in pairs(self._deployables) do
        if value > 0 then
            self._amount = self._amount + value
            self._placed = self._placed + 1
        end
    end
    if self._amount <= 0 then
        self:delete()
    else
        self:SetAndFitTheText()
        self:AnimateBG()
    end
end