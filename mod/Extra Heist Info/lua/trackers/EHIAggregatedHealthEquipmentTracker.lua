---@class EHIAggregatedHealthEquipmentTracker : EHIAggregatedEquipmentTracker
---@field super EHIAggregatedEquipmentTracker
EHIAggregatedHealthEquipmentTracker = class(EHIAggregatedEquipmentTracker)
EHIAggregatedHealthEquipmentTracker._ids = { "doctor_bag", "first_aid_kit" }
EHIAggregatedHealthEquipmentTracker._forced_icons = { { icon = "doctor_bag", visible = false }, { icon = "first_aid_kit", visible = false } }
EHIAggregatedHealthEquipmentTracker._init_create_text = true
function EHIAggregatedHealthEquipmentTracker:Format()
    local s = ""
    for _, id in ipairs(self._ids) do
        if self._amount[id] > 0 then
            if s ~= "" then
                s = s .. " | "
            end
            s = s .. self:FormatDeployable(id)
        end
    end
    return s
end

---@param i number
---@return number
function EHIAggregatedHealthEquipmentTracker:GetIconPosition(i)
    local start = self._bg_box:w()
    local gap = self._gap_scaled
    start = start + (self._icon_size_scaled * i)
    gap = gap + (self._gap_scaled * i)
    return start + gap
end

function EHIAggregatedHealthEquipmentTracker:UpdateIconsVisibility()
    local visibility = {}
    for i = 1, 2, 1 do
        local s_i = tostring(i)
        local icon = self["_icon" .. s_i]
        if icon then
            icon:set_visible(false)
        end
    end
    for i, id in ipairs(self._ids) do
        if self._amount[id] > 0 then
            visibility[#visibility + 1] = i
        end
    end
    local move_x = 0
    local icons = 0
    for _, i in pairs(visibility) do
        local s_i = tostring(i)
        local icon = self["_icon" .. s_i]
        if icon then
            icons = icons + 1
            icon:set_visible(true)
            icon:set_x(self:GetIconPosition(move_x))
        end
        move_x = move_x + 1
    end
    local panel_w = self._bg_box:w()
    self:ChangeTrackerWidth(panel_w + (self._icon_gap_size_scaled * icons))
end

---@param id string
function EHIAggregatedHealthEquipmentTracker:UpdateText(id)
    self:SetAndFitTheText()
    self:UpdateIconsVisibility()
    self:AnimateBG()
end