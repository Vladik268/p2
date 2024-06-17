local color =
{
    doctor_bag = EHI:GetEquipmentColor("doctor_bag"),
    ammo_bag = EHI:GetEquipmentColor("ammo_bag"),
    grenade_crate = EHI:GetEquipmentColor("grenade_crate"),
    first_aid_kit = EHI:GetEquipmentColor("first_aid_kit"),
    bodybags_bag = EHI:GetEquipmentColor("bodybags_bag")
}

---@class EHIAggregatedEquipmentTracker : EHITracker
---@field super EHITracker
EHIAggregatedEquipmentTracker = class(EHITracker)
EHIAggregatedEquipmentTracker._update = false
EHIAggregatedEquipmentTracker._dont_show_placed = { first_aid_kit = true }
EHIAggregatedEquipmentTracker._ids = { "doctor_bag", "ammo_bag", "grenade_crate", "first_aid_kit", "bodybags_bag" }
EHIAggregatedEquipmentTracker._init_create_text = false
function EHIAggregatedEquipmentTracker:pre_init(params)
    self._n_of_deployables = 0
    self._amount = {}
    self._placed = {}
    self._deployables = {}
    self._ignore = params.ignore or {}
    self._format = {}
    self._equipment = {}
    for _, id in ipairs(self._ids) do
        self._amount[id] = 0
        self._placed[id] = 0
        self._deployables[id] = {}
        self._format[id] = params.format[id] or "charges"
    end
end

---@param params EHITracker.params
function EHIAggregatedEquipmentTracker:post_init(params)
    self._default_panel_w = self._panel:w()
    self._panel_half = self._default_bg_size / 2
    self._panel_w = self._default_panel_w
end

do
    local format = EHI:GetOption("equipment_format")
    if format == 1 then -- Uses (Bags placed)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return string.format("%g (%d)", self._parent_class.RoundNumber(self._amount[id], 1), self._placed[id])
            elseif self._dont_show_placed[id] then
                return tostring(self._amount[id])
            end
            return string.format("%d (%d)", self._amount[id], self._placed[id])
        end
    elseif format == 2 then -- (Bags placed) Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return string.format("(%d) %g", self._placed[id], self._parent_class.RoundNumber(self._amount[id], 1))
            elseif self._dont_show_placed[id] then
                return tostring(self._amount[id])
            end
            return string.format("(%d) %d", self._placed[id], self._amount[id])
        end
    elseif format == 3 then -- (Uses) Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return string.format("(%g) %d", self._parent_class.RoundNumber(self._amount[id], 1), self._placed[id])
            elseif self._dont_show_placed[id] then
                return tostring(self._amount[id])
            end
            return string.format("(%d) %d", self._amount[id], self._placed[id])
        end
    elseif format == 4 then -- Bags placed (Uses)
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return string.format("%d (%g)", self._placed[id], self._parent_class.RoundNumber(self._amount[id], 1))
            elseif self._dont_show_placed[id] then
                return tostring(self._amount[id])
            end
            return string.format("%d (%d)", self._placed[id], self._amount[id])
        end
    elseif format == 5 then -- Uses
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._format[id] == "percent" then
                return tostring(self._parent_class.RoundNumber(self._amount[id], 2))
            end
            return tostring(self._amount[id])
        end
    else -- Bags placed
        function EHIAggregatedEquipmentTracker:FormatDeployable(id)
            if self._dont_show_placed[id] then
                if self._format[id] == "percent" then
                    return tostring(self._parent_class.RoundNumber(self._amount[id], 2))
                end
                return tostring(self._amount[id])
            end
            return tostring(self._placed[id])
        end
    end
end

---@return number
function EHIAggregatedEquipmentTracker:GetTotalAmount()
    local amount = 0
    for _, count in pairs(self._amount) do
        amount = amount + count
    end
    return amount
end

---@param id string
function EHIAggregatedEquipmentTracker:AddToIgnore(id)
    self._ignore[id] = true
    self._deployables[id] = {}
    self._amount[id] = 0
    self._placed[id] = 0
    self:CheckAmount(id)
end

---@param id string
---@param unit Unit
---@param key string
---@param amount number
function EHIAggregatedEquipmentTracker:UpdateAmount(id, unit, key, amount)
    if not key then
        EHI:DebugEquipment(self._id, unit, key, amount)
        return
    end
    if self._ignore[id] then
        return
    end
    self._deployables[id][key] = amount
    self._amount[id] = 0
    self._placed[id] = 0
    for _, value in pairs(self._deployables[id]) do
        if value > 0 then
            self._amount[id] = self._amount[id] + value
            self._placed[id] = self._placed[id] + 1
        end
    end
    self:CheckAmount(id)
end

---@param id string
function EHIAggregatedEquipmentTracker:CheckAmount(id)
    if self:GetTotalAmount() <= 0 then
        self:delete()
    else
        self:UpdateText(id)
    end
end

---@param id string
function EHIAggregatedEquipmentTracker:UpdateText(id)
    if self._equipment[id] then
        if self._amount[id] <= 0 then
            self:RemoveText(id)
        else
            local text = self._equipment[id] --[[@as PanelText]]
            text:set_text(self:FormatDeployable(id))
            self:FitTheText(text)
        end
        self:AnimateBG()
    elseif not self._ignore[id] then
        if self._amount[id] > 0 then
            self:AddText(id)
            self:AnimateBG()
        end
    end
end

---@param id string
function EHIAggregatedEquipmentTracker:AddText(id)
    self._n_of_deployables = self._n_of_deployables + 1
    local text = self:CreateText({
        name = id,
        color = color[id]
    })
    self._equipment[id] = text
    text:set_text(self:FormatDeployable(id))
    self:Reorganize(true)
end

---@param id string
function EHIAggregatedEquipmentTracker:RemoveText(id)
    self._bg_box:remove(self._equipment[id])
    self._equipment[id] = nil
    self._n_of_deployables = self._n_of_deployables - 1
    if self._n_of_deployables == 1 then
        local _, text = next(self._equipment) ---@cast text PanelText
        text:set_x(0)
        text:set_w(self._bg_box:w())
        self:FitTheText(text)
    end
    self:Reorganize()
end

function EHIAggregatedEquipmentTracker:RedrawPanel()
    for _, text in ipairs(self._bg_box:children()) do ---@cast text PanelText
        if text.set_text then
            self:FitTheText(text)
        end
    end
end

function EHIAggregatedEquipmentTracker:AnimateMovement()
    self:AnimatePanelWAndRefresh(self._panel_w)
    self:ChangeTrackerWidth(self._panel_w)
    self:AnimIconX(self._panel_w - self._icon_size_scaled)
end

function EHIAggregatedEquipmentTracker:AlignTextOnHalfPos()
    local pos = 0
    for _, id in ipairs(self._ids) do
        local text = self._bg_box:child(id) --[[@as PanelText?]]
        if text then
            text:set_w(self._panel_half)
            text:set_x(self._panel_half * pos)
            self:FitTheText(text)
            pos = pos + 1
        end
    end
end

---@param addition boolean?
function EHIAggregatedEquipmentTracker:Reorganize(addition)
    if self._n_of_deployables == 1 then
        return
    elseif self._n_of_deployables == 2 then
        self:AlignTextOnHalfPos()
        if not addition then
            self._panel_w = self._default_panel_w
            self._bg_box:set_w(self._default_bg_size)
            self:AnimateMovement()
        end
    elseif addition then
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w + self._panel_half
        self._bg_box:set_w(self._bg_box:w() + self._panel_half)
        self:AnimateMovement()
    else
        self:AlignTextOnHalfPos()
        self._panel_w = self._panel_w - self._panel_half
        self._bg_box:set_w(self._bg_box:w() - self._panel_half)
        self:AnimateMovement()
    end
end