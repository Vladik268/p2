---@class EHIColoredCodesTracker : EHITracker
---@field super EHITracker
EHIColoredCodesTracker = class(EHITracker)
EHIColoredCodesTracker._update = false
EHIColoredCodesTracker._forced_icons = { "code" }
EHIColoredCodesTracker._forced_hint_text = "color_codes"
EHIColoredCodesTracker._init_create_text = false
function EHIColoredCodesTracker:OverridePanel()
    local third = self._bg_box:w() / 3
    self._text = self:CreateText({
        name = "red",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color.red,
        left = 0
    })
    self._text2 = self:CreateText({
        name = "green",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color.green,
        left = self._text:right()
    })
    self._text3 = self:CreateText({
        name = "blue",
        text = "?",
        w = third,
        h = self._icon_size_scaled,
        color = Color(0, 1, 1), -- Aqua
        left = self._text2:right()
    })
end

---@param code string?
function EHIColoredCodesTracker:Format(code)
    if code then
        return tostring(code)
    end
    return "?"
end

---@param color string
---@param code string
function EHIColoredCodesTracker:SetCode(color, code)
    local text = self._bg_box:child(color) --[[@as PanelText]]
    text:set_text(self:Format(code))
    self:FitTheText(text)
    self:AnimateBG()
end