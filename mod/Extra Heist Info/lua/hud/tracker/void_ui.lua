local bg_visibility = EHI:GetOption("show_tracker_bg") --[[@as boolean]]

---@param panel Panel
---@param params table
---@return Panel
local function CreateHUDBGBox(panel, params)
    local box_panel = panel:panel(params)
	box_panel:bitmap({
        name = "bg",
        halign = "grow",
		layer = -2,
		valign = "grow",
		color = Color.black:with_alpha(0.6),
        visible = bg_visibility
	})
	return box_panel
end

---@param background PanelRectangle
---@param times number
local function AnimateBG(background, times)
    local TOTAL_T = 0.4
    local t = 0
    local color = 1
    for _ = 1, times or 1 do
        while TOTAL_T > t do
            local dt = coroutine.yield()
            t = t + dt
            color = math.lerp(1, 0, t / TOTAL_T)
            background:set_color(Color(color, color, color))
        end
        t = 0
    end
    background:set_color(Color.black:with_alpha(0.6))
end

EHITracker.SetCustomBGFunctions(CreateHUDBGBox, AnimateBG)