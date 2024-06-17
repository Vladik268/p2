local EHI = EHI
if EHI:CheckLoadHook("MissionBriefingGui") or EHI:IsXPTrackerDisabled() or not EHI:GetOption("show_mission_xp_overview") then
    return
end

---@class MissionBriefingGui
---@field _assets_item table
---@field _displaying_asset boolean
---@field _enabled boolean
---@field _fullscreen_panel Panel
---@field _full_workspace Workspace
---@field _items table
---@field _panel Panel
---@field _selected_item number
---@field close_asset fun(self: self)

local colors =
{
    loot_secured = EHI:GetColorFromOption("mission_briefing", "loot_secured"),
    total_xp = EHI:GetColorFromOption("mission_briefing", "total_xp"),
    optional = EHI:GetColorFromOption("mission_briefing", "optional")
}

local percent_format, localization = "%", "english"
EHI:AddCallback(EHI.CallbackMessage.LocLoaded, function(loc, loc_loaded)
    localization = loc_loaded
    if loc_loaded == "czech" then
        percent_format = " %"
    end
end)

local reloading_outfit = false -- Fix for Beardlib stack overflow crash
local xp_format = EHI:GetOption("xp_format")
local diff_multiplier = tweak_data:get_value("experience_manager", "difficulty_multiplier", EHI:DifficultyIndex()) or 1

---@type XPBreakdownPanel[]?, XPBreakdownItem[]?
local _panels, _buttons, TacticSelected, TacticMax = nil, nil, 1, 1
---@class XPBreakdownItem
---@field new fun(self: self, gui: MissionBriefingGui, ws_panel: Panel, string: string, add_string: string?, loc: LocalizationManager, index: number?): self
local XPBreakdownItem = class()
---@param gui MissionBriefingGui
---@param ws_panel Panel
---@param string string
---@param add_string string?
---@param loc LocalizationManager
---@param index number?
function XPBreakdownItem:init(gui, ws_panel, string, add_string, loc, index)
    self._gui = gui
    self._index = index or 1
    local text = loc:text(string)
    if add_string then
        text = string.format("%s (%s)", text, loc:text("ehi_experience_" .. add_string))
    end
    self._button = ws_panel:text({
        align = "center",
        blend_mode = "add",
        layer = 2,
        text = text,
        font_size = tweak_data.menu.pd2_large_font_size / 2,
        font = tweak_data.menu.pd2_large_font,
        color = tweak_data.screen_colors.button_stage_3,
        visible = false
    })
    local _, _, w, h = self._button:text_rect()
    self._button:set_size(w + 15, h)
    self._button:set_position(math.round(self._button:x()), math.round(self._button:y()))
    self._tab_select_rect = ws_panel:bitmap({
        texture = "guis/textures/pd2/shared_tab_box",
        visible = false,
        layer = 1,
        color = tweak_data.screen_colors.text
    })
    self._tab_select_rect:set_shape(self._button:shape())
    if self._index == 1 then
        self:Select(true)
    end
end

---@param panel Panel
function XPBreakdownItem:SetPosByPanel(panel)
    self._button:set_bottom(panel:top())
    self._button:set_left(panel:left())
    self._tab_select_rect:set_bottom(self._button:bottom())
    self._tab_select_rect:set_left(self._button:left())
end

---@param item XPBreakdownItem
function XPBreakdownItem:SetPosByPreviousItem(item)
    local button = item._button
    self._button:set_bottom(button:bottom())
    self._button:set_left(button:right() + 10)
    self._tab_select_rect:set_bottom(self._button:bottom())
    self._tab_select_rect:set_left(self._button:left())
end

---@param offset number
function XPBreakdownItem:SetVisibleWithOffset(offset)
    self._button:set_y(self._button:y() + offset)
    self._button:set_visible(true)
    self._tab_select_rect:set_y(self._button:y())
end

---@param no_change boolean?
---@param previous_tactic number?
function XPBreakdownItem:Select(no_change, previous_tactic)
    if self._selected then
        return
    end
    self._button:set_color(tweak_data.screen_colors.button_stage_1)
    self._button:set_blend_mode("normal")
    self._tab_select_rect:show()
    self._selected = true
    if no_change then
        return
    end
    managers.menu_component:post_event("menu_enter")
    self._gui:OnTacticChanged(self._index, previous_tactic)
end

function XPBreakdownItem:Unselect()
    if not self._selected then
        return
    end
    self._button:set_color(tweak_data.screen_colors.button_stage_3)
    self._button:set_blend_mode("add")
    self._tab_select_rect:hide()
    self._selected = false
end

---@param x number
---@param y number
---@return boolean
function XPBreakdownItem:mouse_moved(x, y)
    if not self._selected then
        if self._button:inside(x, y) then
            if not self._highlighted then
                self._highlighted = true
                self._button:set_color(tweak_data.screen_colors.button_stage_2)
                managers.menu_component:post_event("highlight")
            end
            return true
        elseif self._highlighted then
            self._button:set_color(tweak_data.screen_colors.button_stage_3)
            self._highlighted = false
        end
    end
    return false
end

---@param button string
---@param x number
---@param y number
function XPBreakdownItem:mouse_pressed(button, x, y)
    if button ~= Idstring("0") then
        return
    end
    if not self._selected and self._button and alive(self._button) and self._button:inside(x, y) then
        self:Select()
    end
end

function XPBreakdownItem:destroy()
    if self._button and alive(self._button) then
        self._button:parent():remove(self._button)
    end
    if self._tab_select_rect and alive(self._tab_select_rect) then
        self._tab_select_rect:parent():remove(self._tab_select_rect)
    end
end

local XPBreakdownItemSwitch = {}
---@param ws_panel Panel
---@param max_tactics number
---@param loc LocalizationManager
---@param button PanelText
function XPBreakdownItemSwitch:new(ws_panel, max_tactics, loc, button)
    local text = max_tactics > 2 and "ehi_mission_briefing_next_tactic_text" or "ehi_mission_briefing_toggle_tactic_text"
    self._text = ws_panel:text({
        text = string.format("%s %s", loc:get_default_macro("BTN_X"), loc:text(text)),
        blend_mode = "add",
        layer = 2,
        font_size = tweak_data.menu.pd2_large_font_size / 2,
        font = tweak_data.menu.pd2_large_font,
        color = Color.white,
        alpha = 1
    })
    EHIMenu:make_fine_text(self._text)
    self._text:set_bottom(button:bottom())
    self._text:set_left(button:right() + 10)
    self._text:set_visible(true)
end

function XPBreakdownItemSwitch:IsCreated()
    return self._text ~= nil
end

---@param alpha number
function XPBreakdownItemSwitch:set_alpha(alpha)
    self._text:set_alpha(alpha)
end

function XPBreakdownItemSwitch:destroy()
    if self._text and alive(self._text) then
        self._text:parent():remove(self._text)
    end
end

---@class XPBreakdownPanel
---@field new fun(self: self, gui: MissionBriefingGui, panel: Panel, panel_params: table, xp_params: table, loc: LocalizationManager, params: XPBreakdown|_XPBreakdown, index: number?): self
local XPBreakdownPanel = class()
XPBreakdownPanel._format_time = tweak_data.ehi.functions.ReturnMinutesAndSeconds
---@param gui MissionBriefingGui
---@param ws_panel Panel
---@param panel_params table
---@param loc LocalizationManager
---@param params XPBreakdown|_XPBreakdown
---@param index number?
function XPBreakdownPanel:init(gui, ws_panel, panel_params, xp_params, loc, params, index)
    self._gui = gui
    self._panel = ws_panel:panel(panel_params)
    self._panel:set_rightbottom(40 + panel_params.w, 144)
    self._panel:set_top(75)
    self:_recreate_bg()
    self._panel:set_visible((index or 1) == 1)
    self._xp = gui._xp
    self._loc = loc
    self._params = params
    self._gage = xp_params.gage --[[@as boolean]]
    self._disable_updates = xp_params.disable_updates --[[@as boolean]]
    self._diff_multiplier = xp_params.diff_multiplier --[[@as boolean]]
    self._no_overview_multipliers = xp_params.no_overview_multipliers --[[@as boolean]]
    self._lines = 0
    self:ProcessBreakdown()
end

function XPBreakdownPanel:_recreate_bg()
    self._panel:rect({
        name = "bg",
        halign = "grow",
        valign = "grow",
        layer = 1,
        color = Color(0.5, 0, 0, 0)
    })
end

function XPBreakdownPanel:ProcessBreakdown()
    if self._destroyed or self._created_and_disable_updates then
        return
    end
    self:_add_xp_overview_text()
    if self._params.wave_all then
        local data = self._params.wave_all
        if type(data) == "table" then
            local xp_multiplied = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
            local total_xp = self._xp:cash_string(xp_multiplied, "+")
            self:_add_xp_text(string.format("%s (%s): ", self._loc:text("ehi_experience_each_wave_survived"), self._loc:text("ehi_experience_trigger_times", { times = data.times })), total_xp)
            self:_add_total_xp(self._xp:cash_string(xp_multiplied * data.times, "+"))
        else
            local total_xp = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data), "+")
            self:_add_xp_text(string.format("%s: %s", self._loc:text("ehi_experience_each_wave_survived")), total_xp)
        end
    elseif self._params.wave then
        local total_xp = 0
        for wave, xp in ipairs(self._params.wave) do
            local xp_computed = self._xp:FakeMultiplyXPWithAllBonuses(xp)
            total_xp = total_xp + xp_computed
            self:_add_xp_text(self._loc:text("ehi_experience_wave_survived", { wave = wave }), self._xp:cash_string(xp_computed, "+"))
        end
        self:_add_total_xp(self._xp:cash_string(total_xp, "+"))
    elseif self._params.objective then
        local total_xp = { base = 0, add = not self._params.no_total_xp }
        for key, data in pairs(self._params.objective) do
            local str = self:_get_translated_key(key)
            if key == "escape" then
                self:_process_escape(str, data, total_xp)
            elseif key == "random" then
                self:_process_random_objectives(data, total_xp)
            elseif type(data) == "table" then
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if self._gage then
                    xp_with_gage = self._gui:FormatXPWithAllGagePackages(data.amount)
                end
                local text_color = data.optional and colors.optional
                if data.times then
                    local times_formatted = self._loc:text("ehi_experience_trigger_times", { times = data.times })
                    local s
                    if data.stealth then
                        total_xp.add = false
                        s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_stealth") .. ")"
                    elseif data.loud then
                        total_xp.add = false
                        s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_loud") .. ")"
                    else
                        s = str .. " (" .. times_formatted .. ")"
                        total_xp.base = total_xp.base + (data.amount * data.times)
                    end
                    self:_add_xp_text(s .. ": ", xp, xp_with_gage, text_color)
                elseif data.stealth then
                    total_xp.add = false
                    self:_add_xp_text(str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", xp, xp_with_gage, text_color)
                elseif data.loud then
                    total_xp.add = false
                    self:_add_xp_text(str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", xp, xp_with_gage, text_color)
                else
                    total_xp.base = total_xp.base + data
                    self:_add_xp_text(str .. ": ", xp, xp_with_gage, text_color)
                end
            else
                total_xp.base = total_xp.base + data
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if self._gage then
                    xp_with_gage = self._gui:FormatXPWithAllGagePackages(data)
                end
                self:_add_xp_text(str .. ": ", xp, xp_with_gage)
            end
        end
        self:_process_loot(total_xp)
        self:_process_total_xp(total_xp)
    elseif self._params.objectives then
        local total_xp = { base = 0, add = not self._params.no_total_xp }
        for _, data in ipairs(self._params.objectives) do
            if type(data) == "table" then
                if data._or then
                    self:_add_line(self._loc:text("ehi_experience_or"))
                elseif type(data.stealth) == "number" and type(data.loud) == "number" then
                    total_xp.add = false
                    local str = data.name and self:_get_translated_key(data.name, data.additional_name) or "<Unknown objective>"
                    if data.times then
                    else
                        local stealth_value = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data.stealth), "+")
                        local stealth_value_gage
                        if self._gage then
                            stealth_value_gage = self._gui:FormatXPWithAllGagePackages(data.stealth)
                        end
                        self:_add_xp_text(str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", stealth_value, stealth_value_gage)
                        local loud_value = self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(data.loud), "+")
                        local loud_value_gage
                        if self._gage then
                            loud_value_gage = self._gui:FormatXPWithAllGagePackages(data.loud)
                        end
                        self:_add_xp_text(str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", loud_value, loud_value_gage)
                    end
                elseif data.escape then
                    self:_process_escape(self:_get_translated_key("escape"), data.escape, total_xp)
                elseif data.random then
                    self:_process_random_objectives(data.random, total_xp)
                else
                    local amount = data.amount or 0
                    local value = self._xp:FakeMultiplyXPWithAllBonuses(amount)
                    local xp = self._xp:cash_string(value, "+")
                    local xp_with_gage
                    if self._gage then
                        xp_with_gage = self._gui:FormatXPWithAllGagePackages(amount)
                    end
                    local str = "<Unknown objective>"
                    if data.name_format then
                        str = self._loc:text("ehi_experience_" .. data.name_format.id, data.name_format.macros)
                    elseif data.name then
                        str = self:_get_translated_key(data.name, data.additional_name)
                    end
                    local text_color = data.optional and colors.optional ---@cast text_color Color?
                    local add_xp_to_base = true
                    if data.times then
                        local times_formatted = self._loc:text("ehi_experience_trigger_times", { times = data.times })
                        local s
                        if data.stealth then
                            total_xp.add = false
                            add_xp_to_base = false
                            s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_stealth") .. ")"
                        elseif data.loud then
                            total_xp.add = false
                            add_xp_to_base = false
                            s = str .. " (" .. times_formatted .. "; " .. self._loc:text("ehi_experience_loud") .. ")"
                        else
                            s = str .. " (" .. times_formatted .. ")"
                        end
                        self:_add_xp_text(s .. ": ", xp, xp_with_gage, text_color)
                    elseif data.stealth then
                        total_xp.add = false
                        add_xp_to_base = false
                        self:_add_xp_text(str .. " (" .. self._loc:text("ehi_experience_stealth") .. "): ", xp, xp_with_gage, text_color)
                    elseif data.loud then
                        total_xp.add = false
                        add_xp_to_base = false
                        self:_add_xp_text(str .. " (" .. self._loc:text("ehi_experience_loud") .. "): ", xp, xp_with_gage, text_color)
                    else
                        self:_add_xp_text(str .. ": ", xp, xp_with_gage, text_color)
                    end
                    if add_xp_to_base then
                        local times = data.times or 1
                        total_xp.base = total_xp.base + (amount * times)
                    end
                end
            end
        end
        self:_process_loot(total_xp)
        self:_process_total_xp(total_xp)
    elseif self._params.loot or self._params.loot_all then
        local total_xp = { base = 0, add = not self._params.no_total_xp }
        self:_process_loot(total_xp)
        self:_process_total_xp(total_xp)
    else
        for key, params in pairs(self._params) do
            EHI:Log("[XPBreakdownPanel] Unknown key! " .. tostring(key))
            if type(params) == "table" then
                EHI:PrintTable(params, tostring(key))
            else
                EHI:Log("[XPBreakdownPanel] params: " .. tostring(params))
            end
        end
    end
    self._panel:set_h(self:_get_panel_height())
    self._created_and_disable_updates = self._disable_updates
end

---@return number
function XPBreakdownPanel:_get_panel_height()
    return 10 + (self._lines * 22)
end

---@param txt string
---@param value string
---@param value_with_gage string?
---@param text_color Color?
function XPBreakdownPanel:_add_xp_text(txt, value, value_with_gage, text_color)
    local xp = self._loc:text("ehi_experience_xp")
    local text
    if value_with_gage then
        text = string.format("%s%s-%s %s", txt, value, value_with_gage, xp)
    else
        text = string.format("%s%s %s", txt, value, xp)
    end
    self:_add_line(text, text_color)
end

---@param total string?
---@param total_with_gage string?
function XPBreakdownPanel:_add_total_xp(total, total_with_gage)
    local xp = self._loc:text("ehi_experience_xp")
    local txt
    if total_with_gage then
        txt = string.format("%s%s-%s %s", self._loc:text("ehi_experience_total_xp"), total, total_with_gage, xp)
    elseif total then
        txt = string.format("%s%s %s", self._loc:text("ehi_experience_total_xp"), total, xp)
    else
        txt = self._loc:text("ehi_experience_total_xp")
    end
    self:_add_line(txt, colors.total_xp)
end

---@param str string
---@param params table|number
---@param total_xp table
function XPBreakdownPanel:_process_escape(str, params, total_xp)
    if type(params) == "table" then
        for _, value in ipairs(params) do
            local s
            local _value = self._xp:FakeMultiplyXPWithAllBonuses(value.amount)
            local xp = self._xp:cash_string(_value, "+")
            local xp_with_gage
            if self._gage then
                xp_with_gage = self._gui:FormatXPWithAllGagePackages(value.amount)
            end
            if value.stealth then
                s = self._loc:text("ehi_experience_stealth_escape")
                if value.timer then
                    s = s .. " (<" .. self:_format_time(value.timer) .. ")"
                end
                s = s .. ": "
            else
                s = self._loc:text("ehi_experience_loud_escape")
                if value.c4_used then
                    s = s .. " (" .. self._loc:text("ehi_experience_c4_used") .. ")"
                end
                s = s .. ": "
            end
            self:_add_xp_text(s, xp, xp_with_gage)
        end
        if next(params) then
            total_xp.add = false
        end
    elseif type(params) == "number" then
        local value = self._xp:FakeMultiplyXPWithAllBonuses(params)
        local xp = self._xp:cash_string(value, "+")
        local xp_with_gage
        if self._gage then
            xp_with_gage = self._gui:FormatXPWithAllGagePackages(params)
        end
        self:_add_xp_text(str .. ": ", xp, xp_with_gage)
        total_xp.base = total_xp.base + params
    end
end

---@param max number
---@return string
function XPBreakdownPanel:_format_random_objectives_header(max)
    if localization == "czech" then
        if max == 1 then
            return self._loc:text("ehi_experience_random_objectives", { count = max, suffix1 = "ý", suffix2 = "" })
        elseif math.within(max, 2, 4) then
            return self._loc:text("ehi_experience_random_objectives", { count = max, suffix1 = "é", suffix2 = "y" })
        else
            return self._loc:text("ehi_experience_random_objectives", { count = max, suffix1 = "ých", suffix2 = "ů" })
        end
    elseif localization == "english" then
        if max == 1 then
            return self._loc:text("ehi_experience_random_objectives", { count = max, suffix = "" })
        else
            return self._loc:text("ehi_experience_random_objectives", { count = max, suffix = "s" })
        end
    end
    return self._loc:text("ehi_experience_random_objectives", { count = max })
end

---@param max number?
function XPBreakdownPanel:_add_random_objectives_header(max)
    local text = max and self:_format_random_objectives_header(max) or self._loc:text("ehi_experience_random_objectives_no_count")
    self:_add_line(text)
end

---@param random table
---@param total_xp table
function XPBreakdownPanel:_process_random_objectives(random, total_xp)
    if type(random) ~= "table" then
        return
    end
    total_xp.add = false
    self:_add_random_objectives_header(random.max)
    local c1 = Color("bfdd7d") -- Dark green
    local c2 = Color.yellow
    local final_color = c2
    local color_pos = 2
    for obj, data in pairs(random) do
        if obj ~= "max" then
            if color_pos == 1 then
                color_pos = 2
                final_color = c2
            else
                color_pos = 1
                final_color = c1
            end
            if type(data) == "table" then
                for _, xp in ipairs(data) do
                    local str = "- " .. self:_get_translated_key(xp.name)
                    local value = self._xp:FakeMultiplyXPWithAllBonuses(xp.amount)
                    local _xp = self._xp:cash_string(value, "+")
                    local xp_with_gage
                    if self._gage then
                        xp_with_gage = self._gui:FormatXPWithAllGagePackages(xp.amount)
                    end
                    if data.times then
                        self:_add_xp_text(str .. " (" .. tostring(data.times) .. "): ", _xp, xp_with_gage, final_color)
                    else
                        self:_add_xp_text(str .. ": ", _xp, xp_with_gage, final_color)
                    end
                end
            else
                local str = "- " .. self:_get_translated_key(obj)
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local _xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if self._gage then
                    xp_with_gage = self._gui:FormatXPWithAllGagePackages(data)
                end
                self:_add_xp_text(str .. ": ", _xp, xp_with_gage, final_color)
            end
        end
    end
end

---@param mandatory number
function XPBreakdownPanel:_format_loot_mandatory_bags(mandatory)
    if localization == "czech" then
        if mandatory == 1 then
            return self._loc:text("ehi_experience_mandatory_bags", { count = mandatory, suffix1 = "ý", suffix2 = "tel" })
        elseif math.within(mandatory, 2, 4) then
            return self._loc:text("ehi_experience_mandatory_bags", { count = mandatory, suffix1 = "é", suffix2 = "tle" })
        else
            return self._loc:text("ehi_experience_mandatory_bags", { count = mandatory, suffix1 = "ých", suffix2 = "tlů" })
        end
    elseif localization == "english" then
        if mandatory == 1 then
            return self._loc:text("ehi_experience_mandatory_bags", { count = mandatory, suffix = "" })
        else
            return self._loc:text("ehi_experience_mandatory_bags", { count = mandatory, suffix = "s" })
        end
    end
    return self._loc:text("ehi_experience_mandatory_bags", { count = mandatory })
end

---@param loot string
---@param times number
---@param mandatory number
---@param additional_bag boolean
---@param to_secure number
---@param value string
---@param value_with_gage string?
function XPBreakdownPanel:_add_loot_secured(loot, times, to_secure, mandatory, additional_bag, value, value_with_gage)
    local loot_name
    if loot == "_else" then
        loot_name = self._loc:text("ehi_experience_loot_else")
    elseif loot == "xp_bonus" then
        loot_name = self._loc:text("ehi_experience_xp_bonus")
    elseif loot == "any" then
        loot_name = self._loc:text("ehi_experience_loot_any")
    else
        loot_name = tweak_data.carry:FormatCarryNameID(loot, loot)
    end
    local str = "- " .. loot_name
    if times > 0 or to_secure > 0 or mandatory > 0 or additional_bag then
        str = str .. " ("
        if times > 0 then
            str = str .. self._loc:text("ehi_experience_trigger_times", { times = times })
        end
        if to_secure > 0 then
            local prefix = times > 0 and "; " or ""
            str = str .. prefix .. self._loc:text("ehi_experience_to_secure", { amount = to_secure })
        end
        if mandatory > 0 then
            local prefix = (times > 0 or to_secure > 0) and "; " or ""
            str = str .. prefix .. self:_format_loot_mandatory_bags(mandatory)
        end
        if additional_bag then
            local prefix = (times > 0 or to_secure > 0 or mandatory > 0) and "; " or ""
            str = str .. prefix .. self._loc:text("ehi_experience_additional_bag")
        end
        str = str .. ")"
    end
    local xp = self._loc:text("ehi_experience_xp")
    if value_with_gage then
        str = str .. ": " .. tostring(value) .. "-" .. tostring(value_with_gage) .. " " .. xp
    else
        str = str .. ": " .. tostring(value) .. " " .. xp
    end
    self:_add_line(str, colors.loot_secured)
end

---@param total_xp table
function XPBreakdownPanel:_process_loot(total_xp)
    if self._params.loot_all then
        local data = self._params.loot_all
        local secured_bag = self._loc:text("ehi_experience_each_loot_secured")
        if type(data) == "table" then
            local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if self._gage then
                xp_with_gage = self._gui:FormatXPWithAllGagePackages(data.amount)
            end
            if data.text then
                secured_bag = self._loc:text("ehi_experience_" .. data.text)
            end
            if data.times then
                self:_add_xp_text(string.format("%s (%s): ", secured_bag, self._loc:text("ehi_experience_trigger_times", { times = data.times })), xp, xp_with_gage, colors.loot_secured)
            else
                self:_add_xp_text(string.format("%s: ", secured_bag), xp, xp_with_gage, colors.loot_secured)
            end
            if total_xp.add and not data.times then
                total_xp.add = false
            end
            total_xp.base = total_xp.base + data.amount
        else
            local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if self._gage then
                xp_with_gage = self._gui:FormatXPWithAllGagePackages(data)
            end
            self:_add_xp_text(string.format("%s: ", secured_bag), xp, xp_with_gage, colors.loot_secured)
            total_xp.add = false
        end
    elseif self._params.loot then
        self:_add_line(self._loc:text("ehi_experience_loot_secured"), colors.loot_secured)
        for loot, data in pairs(self._params.loot) do
            if type(data) == "table" then
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data.amount)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if self._gage then
                    xp_with_gage = self._gui:FormatXPWithAllGagePackages(data.amount)
                end
                self:_add_loot_secured(data.name or loot, data.times or 0, data.to_secure or 0, data.mandatory or 0, data.additional, xp, xp_with_gage)
                if total_xp.add and not data.times then
                    total_xp.add = false
                end
                total_xp.base = total_xp.base + data.amount
            else
                local value = self._xp:FakeMultiplyXPWithAllBonuses(data)
                local xp = self._xp:cash_string(value, "+")
                local xp_with_gage
                if self._gage then
                    xp_with_gage = self._gui:FormatXPWithAllGagePackages(data)
                end
                self:_add_loot_secured(loot, 0, 0, 0, false, xp, xp_with_gage)
                total_xp.add = false
            end
        end
    end
end

---@param total_xp table
function XPBreakdownPanel:_process_total_xp(total_xp)
    if self._params.total_xp_override then
        local override = self._params.total_xp_override
        local override_objective = override.objective or {}
        local override_objectives = override.objectives or {}
        local override_loot = override.loot or {}
        local o_params = override.params
        if o_params then
            if o_params.custom then
                self:_params_custom(o_params.custom)
            elseif o_params.min_max then
                self:_params_minmax(o_params.min_max)
            elseif o_params.min then
                self:_params_min_with_max(o_params)
            elseif o_params.max_only then
                self:_params_max_only(o_params.max_only)
            elseif o_params.escape then
                self:_params_escape(o_params.escape)
            end
        else
            local base = 0
            for key, data in pairs(self._params.objective or {}) do
                if override_objective[key] then
                    local o_override = override_objective[key]
                    local times = o_override.times or 1
                    if type(data) == "table" then
                        base = base + (data.amount * times)
                    else
                        base = base + (data * times)
                    end
                elseif type(data) == "table" then
                elseif type(data) == "number" then
                    base = base + data
                end
            end
            for _, data in ipairs(self._params.objectives or {}) do
                if override_objectives[data.name or "unknown"] then
                    local o_override = override_objectives[data.name or "unknown"]
                    local times = o_override.times or 1
                    base = base + ((data.amount or 0) * times)
                elseif data.escape then
                    if type(data.escape) == "number" then
                        base = base + data.escape
                    else
                        EHI:Log("[XPBreakdownPanel] Unknown type for escape!")
                    end
                else
                    base = base + (data.amount or 0)
                end
            end
            for key, data in pairs(self._params.loot or {}) do
                if override_loot[key] then
                    local o_override = override_loot[key]
                    local times = o_override.times or 1
                    if type(data) == "table" then
                        base = base + (data.amount * times)
                    else
                        base = base + (data * times)
                    end
                elseif type(data) == "table" then
                elseif type(data) == "number" then
                    base = base + data
                end
            end
            local value = self._xp:FakeMultiplyXPWithAllBonuses(base)
            local xp = self._xp:cash_string(value, "+")
            local xp_with_gage
            if self._gage then
                xp_with_gage = self._gui:FormatXPWithAllGagePackages(base)
            end
            self:_add_total_xp(xp, xp_with_gage)
        end
    elseif total_xp.add and total_xp.base > 0 then
        local total = self._xp:FakeMultiplyXPWithAllBonuses(total_xp.base)
        local xp_with_gage
        if self._gage then
            xp_with_gage = self._gui:FormatXPWithAllGagePackages(total_xp.base)
        end
        self:_add_total_xp(self._xp:cash_string(total, "+"), xp_with_gage)
    end
end

---@param o_params table
function XPBreakdownPanel:_params_custom(o_params)
    for _, c_params in ipairs(o_params) do
        if c_params.type == "min_max" then
            self:_params_minmax(c_params)
        elseif c_params.type == "min_with_max" then
            self:_params_min_with_max(c_params)
        elseif c_params.type == "max_only" then
            self:_params_max_only(c_params)
        else
            EHI:Log("Custom type not recognized! " .. tostring(c_params.type))
        end
    end
end

---@param o_params table
function XPBreakdownPanel:_params_minmax(o_params)
    local min, max = 0, 0
    if o_params.objective then
        local o_min, o_max = {}, {}
        for key, value in pairs(o_params.objective) do
            if value.min_max then
                local times = { times = value.min_max }
                o_min[key] = times
                o_max[key] = times
            else
                if value.min then
                    o_min[key] = { times = value.min }
                end
                if value.max then
                    o_max[key] = { times = value.max }
                end
            end
        end
        min = self:_sum_objective(o_min, true)
        max = self:_sum_objective(o_max)
    else
        min = self:_sum_objective({}, true)
        max = self:_sum_objective()
    end
    if o_params.objectives then
        local o_min, o_max = {}, {}
        for key, value in pairs(o_params.objectives) do
            if value.min_max then
                local times = { times = value.min_max }
                o_min[key] = times
                o_max[key] = times
            else
                if value.min then
                    o_min[key] = { times = value.min }
                end
                if value.max then
                    o_max[key] = { times = value.max }
                end
            end
        end
        local random = o_params.objectives.random or {}
        min = min + self:_sum_objectives(o_min, random.min, true)
        max = max + self:_sum_objectives(o_max, random.max)
    else
        min = min + self:_sum_objectives({}, nil, true)
        max = max + self:_sum_objectives()
    end
    for key, data in pairs(o_params.loot or {}) do
        local loot = self._params.loot and self._params.loot[key]
        if loot then
            local amount = 0
            if type(loot) == "table" then
                amount = loot.amount
            elseif type(loot) == "number" then
                amount = loot
            end
            min = min + (amount * (data.min_max or data.min or 0))
            max = max + (amount * (data.min_max or data.max or 0))
        end
    end
    if o_params.loot_all then
        local data = o_params.loot_all
        local amount = 0
        if type(self._params.loot_all) == "table" then
            amount = self._params.loot_all.amount
        elseif type(self._params.loot_all) == "number" then
            amount = self._params.loot_all --[[@as number]]
        end
        min = min + (amount * (data.min_max or data.min or 0))
        max = max + (amount * (data.min_max or data.max or 0))
    end
    if o_params.bonus_xp then
        local bonus = o_params.bonus_xp
        min = min + (bonus.min_max or bonus.min or 0)
        max = max + (bonus.min_max or bonus.max or 0)
    end
    self:_add_total_minmax_xp(min, max, true, o_params.name)
end

---@param o_params table
function XPBreakdownPanel:_params_min_with_max(o_params)
    local override_objective = self._params.total_xp_override.objective or {}
    local override_objectives = self._params.total_xp_override.objectives or {}
    --local override_loot = self._params.total_xp_override.loot or {}
    local min = 0
    local max
    local format_max = true
    if o_params.min.objective then
        if type(o_params.min.objective) == "table" then
            local params = self._params.objective
            for key, value in pairs(o_params.min.objective) do
                local actual_value = 0
                local objective = params[key]
                if type(objective) == "table" then
                    actual_value = objective.amount
                elseif type(objective) == "number" then
                    actual_value = objective
                end
                if type(value) == "table" then
                    min = min + (actual_value * (value.times or 1))
                elseif override_objective[key] then
                    min = min + (actual_value * (override_objective[key].times or 1))
                else
                    min = min + actual_value
                end
            end
        else
            min = min + self:_sum_objective(override_objective, true)
        end
    end
    if o_params.min.objectives then
        if type(o_params.min.objectives) == "table" then
            local objectives = o_params.min.objectives
            for _, data in ipairs(self._params.objectives or {}) do
                local key = data.name or "unknown"
                if objectives[key] or (data.escape and objectives.escape) or (data.random and objectives.random) then -- Count this objective
                    local actual_value = data.amount or 0
                    if data.escape then
                        if type(data.escape) == "number" then
                            min = min + data.escape
                        else
                            EHI:Log("[XPBreakdownPanel] Unknown type for escape!")
                        end
                    elseif data.random then
                        for random, _ in pairs(objectives.random) do
                            local r_data = data.random[random]
                            if r_data and random ~= "max" then
                                if type(r_data) == "table" then
                                    for _, ro_data in ipairs(r_data) do
                                        min = min + (ro_data.amount * (ro_data.times or 1))
                                    end
                                else -- Number
                                    min = min + r_data
                                end
                            end
                        end
                    elseif type(objectives[key]) == "table" then
                        min = min + (actual_value * (objectives[key].times or 1))
                    elseif override_objectives[key] then
                        min = min + (actual_value * (override_objectives[key].times or 1))
                    else
                        min = min + actual_value
                    end
                end
            end
        else
            min = min + self:_sum_objectives(override_objectives, nil, true)
        end
    end
    if o_params.min.loot then
        local params_loot = self._params.loot
        for key, value in pairs(o_params.min.loot) do
            local loot = params_loot and params_loot[key]
            local times = type(value) == "table" and (value.times or 1) or 1
            local amount = 0
            if type(loot) == "table" then
                amount = loot.amount
                times = times == 1 and (loot.times or 1) or times
            elseif type(loot) == "number" then
                amount = loot
            end
            min = min + (amount * times)
        end
    elseif o_params.min.loot_all then
        local times = o_params.min.loot_all.times or 1
        if type(self._params.loot_all) == "table" then
            min = min + (self._params.loot_all.amount * times)
        elseif type(self._params.loot_all) == "number" then
            min = min + (self._params.loot_all * times)
        end
    end
    min = min + (o_params.min.bonus_xp or 0)
    if o_params.max then
        max = 0
        if o_params.max.objective then
            if type(o_params.max.objective) == "table" then
                local params = self._params.objective
                for key, _ in pairs(o_params.max.objective) do
                    local actual_value = 0
                    local objective = params[key]
                    if type(objective) == "table" then
                        actual_value = objective.amount
                    elseif type(objective) == "number" then
                        actual_value = objective
                    end
                    if override_objective[key] then
                        max = max + (actual_value * (override_objective[key].times or 1))
                    else
                        max = max + actual_value
                    end
                end
            else
                max = max + self:_sum_objective(override_objective)
            end
        end
        if o_params.max.objectives then
            if type(o_params.max.objectives) == "table" then
                local objectives = o_params.max.objectives
                for _, data in pairs(self._params.objectives or {}) do
                    local key = data.name or "unknown"
                    if objectives[key] or (data.escape and objectives.escape) or (data.random and objectives.random) then
                        local actual_value = data.amount or 0
                        if data.escape then
                            if type(data.escape) == "number" then
                                max = max + data.escape
                            else
                                EHI:Log("[XPBreakdownPanel] Unknown type for escape!")
                            end
                        elseif data.random then
                            for random, random_data in pairs(objectives.random) do
                                local r_data = data.random[random]
                                if r_data and random ~= "max" then
                                    if type(random_data) == "table" and type(r_data) == "table" then
                                        local n = #random_data
                                        if n == #r_data then
                                            for i = 1, n, 1 do
                                                local r = r_data[i]
                                                if type(random_data[i]) == "table" then
                                                    max = max + (r.amount * (random_data[i].times or r.times or 1))
                                                else -- Assume "true" value
                                                    max = max + (r.amount * (r.times or 1))
                                                end
                                            end
                                        else
                                            EHI:Log("Table length does not match for random objective '" .. tostring(random) .. "'; skipping")
                                        end
                                    elseif type(r_data) == "table" then -- Assume "true" value -> compute
                                        for _, ro_data in ipairs(r_data) do
                                            max = max + (ro_data.amount * (ro_data.times or 1))
                                        end
                                    else -- Number
                                        max = max + r_data
                                    end
                                end
                            end
                        elseif type(objectives[key]) == "table" then
                            max = max + (actual_value * (objectives[key].times or 1))
                        elseif override_objectives[key] then
                            max = max + (actual_value * (override_objectives[key].times or 1))
                        else
                            max = max + actual_value
                        end
                    end
                end
            else
                max = max + self:_sum_objectives(override_objectives)
            end
        end
        if o_params.max.loot then
            local params_loot = self._params.loot
            for key, value in pairs(o_params.max.loot) do
                local loot = params_loot and params_loot[key]
                local times = type(value) == "table" and (value.times or 1) or 1
                local amount = 0
                if type(loot) == "table" then
                    amount = loot.amount
                    times = times ~= 1 and (loot.times or 1) or times
                elseif type(loot) == "number" then
                    amount = loot
                end
                max = max + (amount * times)
            end
        elseif o_params.max.loot_all then
            local times = o_params.max.loot_all.times or 1
            if type(self._params.loot_all) == "table" then
                max = max + (self._params.loot_all.amount * times)
            elseif type(self._params.loot_all) == "number" then
                max = max + (self._params.loot_all * times)
            end
        end
        max = max + (o_params.max.bonus_xp or 0)
    elseif o_params.max_level then
        format_max = false
        local max_n = self._xp:GetPlayerXPLimit()
        max = self._xp:experience_string(max_n)
        local xp = self._loc:text("ehi_experience_xp")
        if o_params.max_level_bags then
            if false then --self._xp:FakeMultiplyXPWithAllBonuses(min) > max_n then

            else
                local loot_xp = self._xp:FakeMultiplyXPWithAllBonuses(self._params.loot_all --[[@as number]])
                local loot_xp_gage = self._gage and self._gui:FormatXPWithAllGagePackagesNoString(self._params.loot_all --[[@as number]]) or loot_xp
                local bags_to_secure = math.ceil(max_n / loot_xp)
                local bags_to_secure_gage = math.ceil(max_n / loot_xp_gage)
                local to_secure = self._loc:text("ehi_experience_to_secure", { amount = bags_to_secure })
                if bags_to_secure == bags_to_secure_gage then -- Securing gage packages does not matter -> you still need to secure the same amount of bags
                    max = string.format("+%s %s (%s)", max, xp, to_secure)
                else -- Securing gage packages will make a difference in bags, reflect it
                    max = string.format("+%s %s (%s; %s %s)", max, xp, to_secure, self._loc:text("ehi_experience_all_gage_packages"), tostring(bags_to_secure_gage))
                end
            end
        elseif o_params.max_level_bags_with_objective then
            local sum_of_min_objective = self:_sum_objective()
            local min_objective_xp = self._xp:FakeMultiplyXPWithAllBonuses(sum_of_min_objective)
            local min_objective_xp_gage = self._gage and self._gui:FormatXPWithAllGagePackagesNoString(sum_of_min_objective) or min_objective_xp
            local loot_xp = self._xp:FakeMultiplyXPWithAllBonuses(self._params.loot_all --[[@as number]])
            local loot_xp_gage = self._gage and self._gui:FormatXPWithAllGagePackagesNoString(self._params.loot_all --[[@as number]]) or loot_xp
            local bags_to_secure = math.ceil((max_n - min_objective_xp) / loot_xp)
            local bags_to_secure_gage = math.ceil((max_n - min_objective_xp_gage) / loot_xp_gage)
            local to_secure = self._loc:text("ehi_experience_to_secure", { amount = bags_to_secure })
            if bags_to_secure == bags_to_secure_gage then -- Securing gage packages does not matter -> you still need to secure the same amount of bags
                max = string.format("+%s %s (%s)", max, xp, to_secure)
            else -- Securing gage packages will make a difference in bags, reflect it
                max = string.format("+%s %s (%s; %s %s)", max, xp, to_secure, self._loc:text("ehi_experience_all_gage_packages"), tostring(bags_to_secure_gage))
            end
        elseif o_params.max_level_bags_with_objectives then
            local sum_of_min_objectives = self:_sum_objectives()
            local min_objectives_xp = self._xp:FakeMultiplyXPWithAllBonuses(sum_of_min_objectives)
            local min_objectives_xp_gage = self._gage and self._gui:FormatXPWithAllGagePackagesNoString(sum_of_min_objective) or min_objectives_xp
            local loot_xp = self._xp:FakeMultiplyXPWithAllBonuses(self._params.loot_all --[[@as number]])
            local loot_xp_gage = self._gage and self._gui:FormatXPWithAllGagePackagesNoString(self._params.loot_all --[[@as number]]) or loot_xp
            local bags_to_secure = math.ceil((max_n - min_objectives_xp) / loot_xp)
            local bags_to_secure_gage = math.ceil((max_n - min_objectives_xp_gage) / loot_xp_gage)
            local to_secure = self._loc:text("ehi_experience_to_secure", { amount = bags_to_secure })
            if bags_to_secure == bags_to_secure_gage then -- Securing gage packages does not matter -> you still need to secure the same amount of bags
                max = string.format("+%s %s (%s)", max, xp, to_secure)
            else -- Securing gage packages will make a difference in bags, reflect it
                max = string.format("+%s %s (%s; %s %s)", max, xp, to_secure, self._loc:text("ehi_experience_all_gage_packages"), tostring(bags_to_secure_gage))
            end
        else
            max = "+" .. max .. " " .. xp
        end
    elseif not o_params.no_max then -- Max is missing, is not set to Player level max or is not disabled, assume all objectives to compute
        max = 0
        for key, data in pairs(self._params.objective or {}) do
            local times = 1
            if override_objective[key] then
                times = override_objective[key].times or 1
            end
            if type(data) == "table" then
                max = max + (data.amount * times)
            elseif type(data) == "number" then
                max = max + (data * times)
            end
        end
        for _, data in ipairs(self._params.objectives or {}) do
            if data.escape then
                if type(data.escape) == "number" then
                    max = max + data.escape
                else
                    EHI:Log("[XPBreakdownPanel] Unknown type for escape!")
                end
            else
                local key = data.name or "unknown"
                local times = 1
                if override_objectives[key] then
                    times = override_objectives[key].times or 1
                end
                max = max + ((data.amount or 0) * times)
            end
        end
    end
    self:_add_total_minmax_xp(min, max, format_max, o_params.name)
end

---@param o_params table
function XPBreakdownPanel:_params_max_only(o_params)
    local o_max = o_params.max or {}
    local max = 0
    if type(self._params.objective) == "table" then
        max = self:_sum_objective(o_max)
    end
    if type(self._params.objectives) == "table" then
        for _, data in ipairs(self._params.objectives or {}) do
            local key = data.name or "unknown"
            local actual_value = data.amount or 0
            if data.escape then
                if type(data.escape) == "number" then
                    actual_value = data.escape --[[@as number]]
                else
                    EHI:Log("[XPBreakdownPanel] Unknown type for escape!")
                end
            end
            if o_max[key] then
                max = max + (actual_value * (o_max[key].times or data.times or 1))
            else
                max = max + (actual_value * (data.times or 1))
            end
        end
    else
        max = max + self:_sum_objectives(o_max)
    end
    for key, data in pairs(o_params.loot or {}) do
        local loot = self._params.loot and self._params.loot[key]
        if loot then
            local amount = 0
            if type(loot) == "table" then
                amount = loot.amount
            elseif type(loot) == "number" then
                amount = loot
            end
            max = max + (amount * (data.min_max or data.max or 0))
        end
    end
    if o_params.loot_all then
        local data = o_params.loot_all
        local amount = 0
        if type(self._params.loot_all) == "table" then
            amount = self._params.loot_all.amount
        elseif type(self._params.loot_all) == "number" then
            amount = self._params.loot_all --[[@as number]]
        end
        max = max + (amount * (data.min_max or data.max or 0))
    end
    self:_add_line(("Max (" .. o_params.name .. "): +") .. self._gui:FormatXPWithAllGagePackages(max) .. " " .. self._loc:text("ehi_experience_xp"), colors.total_xp)
end

---@param o_params table
function XPBreakdownPanel:_params_escape(o_params)
    local min, max, max_stealth = 0, 0, 0
    if o_params.loot then
        local params_loot = self._params.loot
        for key, data in pairs(o_params.loot) do
            local loot = params_loot and params_loot[key]
            if loot then
                local amount = 0
                if type(loot) == "table" then
                    amount = loot.amount
                elseif type(loot) == "number" then
                    amount = loot
                end
                min = min + (amount * (data.min_max or data.min or 0))
                max = max + (amount * (data.min_max or data.max or 0))
                if data.no_loud_xp then
                    max_stealth = max_stealth + (amount * (data.min_max or data.max or 0))
                end
            end
        end
    elseif o_params.loot_all then
        local data = o_params.loot_all
        local amount = 0
        if type(self._params.loot_all) == "table" then
            amount = self._params.loot_all.amount
        elseif type(self._params.loot_all) == "number" then
            amount = self._params.loot_all --[[@as number]]
        end
        min = amount * (data.min_max or data.min or 0)
        max = amount * (data.min_max or data.max or 0)
    end
    self:_add_total_xp()
    for _, value in ipairs(self._params.objective and self._params.objective.escape or {}) do ---@diagnostic disable-line
        local s
        local max_xp = 0
        if value.stealth then
            s = self._loc:text("ehi_experience_stealth_escape")
            if value.timer then
                s = s .. " (<" .. self:_format_time(value.timer) .. ")"
            end
            max_xp = max
        else
            s = self._loc:text("ehi_experience_loud_escape")
            if value.c4_used then
                s = s .. " (" .. self._loc:text("ehi_experience_c4_used") .. ")"
            end
            max_xp = max - max_stealth
        end
        local _min = self._xp:FakeMultiplyXPWithAllBonuses(value.amount + min)
        local _max = self._xp:FakeMultiplyXPWithAllBonuses(value.amount + max_xp)
        local xp_min = self._xp:cash_string(_min, "+")
        local xp_max = self._xp:cash_string(_max, "+")
        local xp_min_with_gage, xp_max_with_gage
        if self._gage then
            xp_min_with_gage = self._gui:FormatXPWithAllGagePackages(value.amount + min)
            xp_max_with_gage = self._gui:FormatXPWithAllGagePackages(value.amount + max_xp)
        end
        self:_add_xp_text(string.format("%s - Min: ", s), xp_min, xp_min_with_gage, colors.total_xp)
        self:_add_xp_text(string.format("%s - Max: ", s), xp_max, xp_max_with_gage, colors.total_xp)
    end
end

---@param override_objective table?
---@param skip_optional boolean?
---@return number
function XPBreakdownPanel:_sum_objective(override_objective, skip_optional)
    local xp = 0
    override_objective = override_objective or {}
    for key, obj in pairs(self._params.objective or {}) do
        local actual_value = 0
        local times = 1
        local count = true
        local override = override_objective[key]
        if type(obj) == "table" then
            actual_value = obj.amount or 0
            times = obj.times or 1
            count = not obj.optional or (obj.optional and not skip_optional)
        elseif type(obj) == "number" then
            actual_value = obj
        end
        if count then
            if override then
                xp = xp + (actual_value * (override.times or times or 1))
            else
                xp = xp + (actual_value * (times or 1))
            end
        end
    end
    return xp
end

---@param override_objectives table?
---@param random_objectives table?
---@param skip_optional boolean?
---@return number
function XPBreakdownPanel:_sum_objectives(override_objectives, random_objectives, skip_optional)
    local xp = 0
    override_objectives = override_objectives or {}
    for _, data in ipairs(self._params.objectives or {}) do
        if data.escape then
            if type(data.escape) == "number" then
                xp = xp + data.escape
            else
                EHI:Log("[XPBreakdownPanel] Unknown type for escape!")
            end
        elseif data.random then
            if type(random_objectives) == "table" then
                for random, random_data in pairs(data.random) do
                    local ro_data = random_objectives[random]
                    if ro_data then
                        if type(ro_data) == "table" then
                            local n = #random_data
                            if n == #ro_data then
                                for i = 1, n, 1 do
                                    local r = random_data[i]
                                    if type(ro_data[i]) == "table" then
                                        xp = xp + (r.amount * (ro_data[i].times or r.times or 1))
                                    else -- Assume "true" value
                                        xp = xp + (r.amount * (r.times or 1))
                                    end
                                end
                            else
                                EHI:Log("Table length does not match for random objective '" .. tostring(random) .. "'; skipping")
                            end
                        elseif type(ro_data) == "boolean" then -- Boolean, count all objectives
                            for _, _ro_data in ipairs(random_data) do
                                xp = xp + (_ro_data.amount * (_ro_data.times or 1))
                            end
                        end
                    end
                end
            else
                EHI:Log("[XPBreakdownPanel] Random objectives cannot be counted! Use min or max and count them manually")
            end
        elseif not data.optional or (data.optional and not skip_optional) then
            local key = data.name or "unknown"
            local amount = data.amount or 0
            local o_override = override_objectives[key] or {}
            xp = xp + (amount * (o_override.times or data.times or 1))
        end
    end
    return xp
end

---@param min number
---@param max number|string?
---@param format_max boolean
---@param post_fix string?
function XPBreakdownPanel:_add_total_minmax_xp(min, max, format_max, post_fix)
    local post_fix_text = post_fix and self._loc:text("ehi_experience_" .. post_fix) or ""
    local xp = self._loc:text("ehi_experience_xp")
    if not post_fix then
        self:_add_total_xp()
    end
    self:_add_line((post_fix and ("Min (" .. post_fix_text .. "): ") or "Min: ") .. self._xp:cash_string(self._xp:FakeMultiplyXPWithAllBonuses(min), "+") .. " " .. xp, colors.total_xp)
    if max then
        if format_max then
            self:_add_line((post_fix and ("Max (" .. post_fix_text .. "): +") or "Max: +") .. self._gui:FormatXPWithAllGagePackages(max or 0 --[[@as number]]) .. " " .. xp, colors.total_xp)
        else
            self:_add_line((post_fix and ("Max (" .. post_fix_text .. "): ") or "Max: ") .. tostring(max), colors.total_xp)
        end
    end
end

---@param txt string
---@param txt_color Color?
function XPBreakdownPanel:_add_line(txt, txt_color)
    self._panel:text({
        blend_mode = "add",
        x = 10,
        y = self:_get_panel_height(),
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = txt_color or Color.white,
        text = txt,
        layer = 10
    })
    self._lines = self._lines + 1
end

function XPBreakdownPanel:_add_xp_overview_text()
    local text_panel = self._panel:text({
        blend_mode = "add",
        x = 10,
        y = 10,
        font = tweak_data.menu.pd2_large_font,
        font_size = tweak_data.menu.pd2_small_font_size,
        color = Color.white,
        text = self._loc:text("ehi_experience_xp_overview"),
        layer = 10
    })
    self._lines = self._lines + 1
    if self._no_overview_multipliers then
        return
    end
    managers.hud:make_fine_text(text_panel)
    local xp = self._xp._ehi_xp
    local last_modifier = text_panel
    if self._diff_multiplier and diff_multiplier > 1 then
        local diff = self._panel:text({
            name = "0_diff",
            blend_mode = "add",
            x = text_panel:right() + 2,
            y = 10,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.menu.pd2_small_font_size,
            color = tweak_data.screen_colors.risk,
            text = string.format("%s +%dx", self._loc:get_default_macro("BTN_SKULL"), diff_multiplier),
            layer = 10
        })
        managers.hud:make_fine_text(diff)
        if self._disable_updates then
            return
        end
        last_modifier = diff
    end
    if xp.projob_multiplier and xp.projob_multiplier > 1 then
        local pro = self._panel:text({
            name = "0_pro_job",
            blend_mode = "add",
            x = last_modifier:right() + 2,
            y = 10,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.menu.pd2_small_font_size,
            color = tweak_data.screen_colors.pro_color,
            text = string.format("PRO +%d%s", (xp.projob_multiplier - 1) * 100, percent_format),
            layer = 10
        })
        managers.hud:make_fine_text(pro)
        last_modifier = pro
    end
    if xp.stealth_bonus and xp.stealth_bonus > 0 then
        local percent = xp.stealth_bonus * 100
        local stealth = self._panel:text({
            name = "0_stealth",
            blend_mode = "add",
            x = last_modifier:right() + 2,
            y = 10,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.menu.pd2_small_font_size,
            color = tweak_data.screen_colors.ghost_color,
            text = string.format("%s +%d%s", self._loc:get_default_macro("BTN_GHOST"), percent, percent_format),
            layer = 10
        })
        managers.hud:make_fine_text(stealth)
        last_modifier = stealth
    end
    if xp.heat and xp.heat ~= 1 then
        local text
        local range_color
        if xp.heat < 1 then -- Negative XP
            range_color = tweak_data.screen_colors.heat_cold_color
            local percent = (1 - xp.heat) * 100
            text = string.format("-%d%s", percent, percent_format)
        else -- Positive XP
            range_color = tweak_data.screen_colors.heat_warm_color
            local percent = (xp.heat - 1) * 100
            text = string.format("+%d%s", percent, percent_format)
        end
        local heat_icon = self._panel:bitmap({
            name = "0_heat_icon",
            blend_mode = "add",
            x = last_modifier:right() + 2,
            y = 10,
            w = 16,
            h = 16,
            texture = "guis/textures/pd2/pd2_waypoints",
            texture_rect = { 128, 32, 32, 32 },
            color = range_color,
            layer = 10
        })
        local heat = self._panel:text({
            name = "0_heat",
            blend_mode = "add",
            x = heat_icon:right() + 2,
            y = 10,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.menu.pd2_small_font_size,
            color = range_color,
            text = text,
            layer = 10
        })
        managers.hud:make_fine_text(heat)
        last_modifier = heat
    end
    if tweak_data.levels:IsLevelChristmas() then
        local bonus = (tweak_data:get_value("experience_manager", "limited_xmas_bonus_multiplier") or 1) - 1
        if bonus > 0 then
            local percent = tostring(bonus * 100)
            local xmas = self._panel:text({
                name = "0_xmas",
                blend_mode = "add",
                x = last_modifier:right() + 2,
                y = 10,
                font = tweak_data.menu.pd2_large_font,
                font_size = tweak_data.menu.pd2_small_font_size,
                color = tweak_data.screen_colors.event_color,
                text = string.format("%s +%s%s", self._loc:get_default_macro("BTN_XMAS"), percent, percent_format),
                layer = 10
            })
            managers.hud:make_fine_text(xmas)
            last_modifier = xmas
        end
    end
    if xp.is_level_limited then
        local diff_in_stars = xp.job_stars - xp.level_to_stars
        local tweak_multiplier = tweak_data:get_value("experience_manager", "level_limit", "pc_difference_multipliers", diff_in_stars) or 0
        if tweak_multiplier > 0 then
            local reduction_percent = tostring((1 - tweak_multiplier) * 100)
            local level_limit_icon = self._panel:bitmap({
                name = "0_level_limit_icon",
                blend_mode = "add",
                x = last_modifier:right() + 2,
                y = 10,
                texture = "guis/textures/pd2/shared_level_symbol",
                color = tweak_data.screen_colors.important_1,
                layer = 10
            })
            local level_limit = self._panel:text({
                name = "0_level_limit",
                blend_mode = "add",
                x = level_limit_icon:right() + 2,
                y = 10,
                font = tweak_data.menu.pd2_large_font,
                font_size = tweak_data.menu.pd2_small_font_size,
                color = tweak_data.screen_colors.important_1,
                text = string.format("-%s%s", reduction_percent, percent_format),
                layer = 10
            })
            managers.hud:make_fine_text(level_limit)
            last_modifier = level_limit
        end
    end
    if self._gui._skill_bonus > 1 then
        local passive_xp_reduction = managers.player:upgrade_value("player", "passive_xp_multiplier", 1) - 1
        local real_bonus = EHI.RoundNumber(self._gui._skill_bonus - passive_xp_reduction - 1, 2)
        if real_bonus > 0 then
            local percent = real_bonus * 100
            local skill_icon = self._panel:bitmap({
                name = "0_skill_icon",
                blend_mode = "add",
                x = last_modifier:right() + 2,
                y = 10,
                texture = "guis/dlcs/cash/textures/pd2/safe_raffle/teamboost_icon",
                color = tweak_data.screen_colors.button_stage_2,
                layer = 10
            })
            local skill = self._panel:text({
                name = "0_skill_bonus",
                blend_mode = "add",
                x = skill_icon:right() + 2,
                y = 10,
                font = tweak_data.menu.pd2_large_font,
                font_size = tweak_data.menu.pd2_small_font_size,
                color = tweak_data.screen_colors.button_stage_2,
                text = string.format("+%d%s", percent, percent_format),
                layer = 10
            })
            managers.hud:make_fine_text(skill)
            last_modifier = skill
        end
    end
    if math.clamp(self._gui._num_winners, 1, 4) > 1 then
        local bonus = (tweak_data:get_value("experience_manager", "alive_humans_multiplier", self._gui._num_winners) or 1) - 1
        if bonus > 0 then
            local percent = EHI:RoundChanceNumber(bonus)
            local player_icon = self._panel:bitmap({
                name = "0_player_icon",
                blend_mode = "add",
                x = last_modifier:right() + 2,
                y = 10,
                w = 16,
                h = 16,
                texture = "guis/textures/pd2/pd2_waypoints",
                texture_rect = { 32, 0, 32, 32 },
                color = tweak_data.screen_colors.risk,
                layer = 10
            })
            local player = self._panel:text({
                name = "0_player_bonus",
                blend_mode = "add",
                x = player_icon:right() + 2,
                y = 10,
                font = tweak_data.menu.pd2_large_font,
                font_size = tweak_data.menu.pd2_small_font_size,
                color = tweak_data.screen_colors.risk,
                text = string.format("+%d%s", percent, percent_format),
                layer = 10
            })
            managers.hud:make_fine_text(player)
            last_modifier = player
        end
    end
    if xp.mutator_xp_reduction < 0 then
        local reduction = xp.mutator_xp_reduction * 100
        local mutator_icon = self._panel:bitmap({
            name = "0_mutator_icon",
            blend_mode = "add",
            x = last_modifier:right() + 2,
            y = 10,
            w = 16,
            h = 16,
            texture = "guis/dlcs/new/textures/pd2/crimenet/crimenet_sidebar_icons",
            texture_rect = { 0, 0, 64, 64 },
            color = tweak_data.screen_colors.important_1,
            layer = 10
        })
        local mutator = self._panel:text({
            name = "0_mutator",
            blend_mode = "add",
            x = mutator_icon:right() + 2,
            y = 10,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.menu.pd2_small_font_size,
            color = tweak_data.screen_colors.important_1,
            text = string.format("%s%s", tostring(reduction), percent_format),
            layer = 10
        })
        managers.hud:make_fine_text(mutator)
        last_modifier = mutator
    end
    if xp.MutatorCG22 then
        local CG22_icon = self._panel:bitmap({
            name = "0_MutatorCG22_icon",
            blend_mode = "add",
            x = last_modifier:right() + 2,
            y = 10,
            w = 16,
            h = 16,
            texture = "guis/textures/pd2/blackmarket/xp_drop",
            color = tweak_data.screen_colors.event_color,
            layer = 10
        })
        local CG22 = self._panel:text({
            name = "0_MutatorCG22",
            blend_mode = "add",
            x = CG22_icon:right() + 2,
            y = 10,
            font = tweak_data.menu.pd2_large_font,
            font_size = tweak_data.menu.pd2_small_font_size,
            color = tweak_data.screen_colors.event_color,
            text = string.format("+100%s", percent_format),
            layer = 10
        })
        managers.hud:make_fine_text(CG22)
        last_modifier = CG22
    end
end

---@param key string
---@param additional_name string?
---@return string
function XPBreakdownPanel:_get_translated_key(key, additional_name)
    local string_id = "ehi_experience_" .. key
    local add_string_id = nil
    if additional_name then
        add_string_id = "ehi_experience_" .. additional_name
    end
    if self._loc:exists(string_id) then
        if add_string_id then
            if self._loc:exists(add_string_id) then
                return string.format("%s (%s)", self._loc:text(string_id), self._loc:text(add_string_id))
            end
            return string.format("%s (%s)", self._loc:text(string_id), additional_name)
        end
        return self._loc:text(string_id)
    end
    if add_string_id then
        if self._loc:exists(add_string_id) then
            return string.format("%s (%s)", key, self._loc:text(add_string_id))
        end
        return string.format("%s (%s)", key, additional_name)
    end
    return key
end

---@param offset number
function XPBreakdownPanel:AddOffset(offset)
    if self._destroyed then
        return
    end
    self._panel:set_y(self._panel:y() + offset)
end

function XPBreakdownPanel:RefreshXPOverview()
    if self._destroyed then
        return
    end
    self._panel:clear()
    self:_recreate_bg()
    self._lines = 0
end

function XPBreakdownPanel:destroy()
    self._destroyed = true
    if self._panel and alive(self._panel) then
        self._panel:parent():remove(self._panel)
    end
end

local original =
{
    init = MissionBriefingGui.init,
    set_slot_outfit = TeamLoadoutItem.set_slot_outfit,
    lobby_code_init = LobbyCodeMenuComponent.init
}

function MissionBriefingGui:init(...)
    original.init(self, ...)
    self:ProcessXPBreakdown()
end

function MissionBriefingGui:ProcessXPBreakdown()
    if _panels then
        if TacticMax > 1 then
            self:HookMouseFunctions()
        end
        if self._disable_panels_update then
            return
        end
        self:FakeExperienceMultipliers()
        for _, panel in ipairs(_panels) do
            panel:RefreshXPOverview()
            panel:ProcessBreakdown()
        end
    elseif tweak_data.levels:IsLevelSkirmish() then
        -- Hardcoded in shared instance "obj_skm"
        ---@type XPBreakdown
        local params =
        {
            wave = { 8000, 9200, 10600, 12200, 14100, 16300, 18800, 21700, 25000 }
        }
        self:AddXPBreakdown(params)
    else
        EHI:CallCallbackOnce("MissionBriefingGuiInit", self)
    end
end

---@param params XPBreakdown
function MissionBriefingGui:AddXPBreakdown(params)
    if type(params) ~= "table" or not next(params) or _panels then
        return
    end
    self:FakeExperienceMultipliers()
    self._disable_panels_update = xp_format <= 2
    _panels = {}
    local panel_params =
    {
        layer = 9,
        w = self._fullscreen_panel:w() * 0.45
    }
    local xp_params =
    {
        no_overview_multipliers = xp_format == 1,
        disable_updates = self._disable_panels_update,
        diff_multiplier = xp_format >= 2,
        gage = xp_format == 3 and EHI:AreGagePackagesSpawned()
    }
    local ws_panel = self._full_workspace:panel()
    local loc = managers.localization
    self._xp = managers.ehi_experience
    if xp_format == 1 then
        ---@param ex EHIExperienceManager
        ---@param xp number
        self._xp.FakeMultiplyXPWithAllBonuses = function(ex, xp) ---@diagnostic disable-line
            return xp
        end
    elseif xp_format == 2 then
        ---@param ex EHIExperienceManager
        ---@param xp number
        ---@return number
        self._xp.FakeMultiplyXPWithAllBonuses = function(ex, xp) ---@diagnostic disable-line
            return xp * diff_multiplier
        end
    else
        ---@param ex EHIExperienceManager
        ---@param xp number
        self._xp.FakeMultiplyXPWithAllBonuses = function(ex, xp) ---@diagnostic disable-line
            local alive_original = ex._ehi_xp.alive_players
            local skill_original = ex._ehi_xp.skill_xp_multiplier
            local gage_original = ex._ehi_xp.gage_bonus
            ex._ehi_xp.alive_players = self._num_winners or 1
            ex._ehi_xp.skill_xp_multiplier = self._skill_bonus or 1
            ex._ehi_xp.gage_bonus = self._gage_bonus or 1
            local value = ex:MultiplyXPWithAllBonuses(xp)
            ex._ehi_xp.alive_players = alive_original
            ex._ehi_xp.skill_xp_multiplier = skill_original
            ex._ehi_xp.gage_bonus = gage_original
            return value
        end
    end
    if params.tactic then
        _buttons = {}
        local tactic = params.tactic
        if tactic.custom then
            TacticMax = table.size(tactic.custom)
            for i, custom in ipairs(tactic.custom) do
                if custom.objectives_override then
                    local new_objectives = {}
                    local override = custom.objectives_override
                    if override.stop_at then
                        local delimiter = override.stop_at
                        local mark_optional = override.mark_optional or {}
                        for j, objective in ipairs(custom.tactic.objectives) do
                            if objective.name == delimiter then
                                break
                            end
                            if mark_optional[objective.name] then
                                objective.optional = true
                            end
                            new_objectives[j] = objective
                        end
                        custom.tactic.objectives = new_objectives
                    elseif override.stop_at_inclusive then
                        local delimiter = override.stop_at_inclusive
                        local mark_optional = override.mark_optional or {}
                        for j, objective in ipairs(custom.tactic.objectives) do
                            if objective.name == delimiter then
                                if mark_optional[objective.name] then
                                    objective.optional = true
                                end
                                new_objectives[j] = objective
                                break
                            end
                            if mark_optional[objective.name] then
                                objective.optional = true
                            end
                            new_objectives[j] = objective
                        end
                        custom.tactic.objectives = new_objectives
                    elseif override.stop_at_inclusive_and_add_objectives then
                        local stop_and_add = override.stop_at_inclusive_and_add_objectives
                        local delimiter = stop_and_add.stop_at
                        local mark_optional = stop_and_add.mark_optional or {}
                        local size = 0
                        for j, objective in ipairs(custom.tactic.objectives) do
                            if objective.name == delimiter then
                                if mark_optional[objective.name] then
                                    objective.optional = true
                                end
                                new_objectives[j] = objective
                                size = j
                                break
                            end
                            if mark_optional[objective.name] then
                                objective.optional = true
                            end
                            new_objectives[j] = objective
                            size = j
                        end
                        size = size + 1
                        if stop_and_add.add_objectives then
                            for _, value in ipairs(stop_and_add.add_objectives) do
                                new_objectives[size] = value
                                size = size + 1
                            end
                        elseif stop_and_add.add_objectives_with_pos then
                            for _, value in ipairs(stop_and_add.add_objectives_with_pos) do
                                if value.pos then
                                    table.insert(new_objectives, value.pos, value.objective)
                                else
                                    new_objectives[size] = value.objective
                                end
                                size = size + 1
                            end
                        end
                        custom.tactic.objectives = new_objectives
                    elseif override.add_objectives then
                        local more_objectives = override.add_objectives
                        local size = table.size(custom.tactic.objectives) + 1
                        new_objectives = deep_clone(custom.tactic.objectives)
                        for _, value in ipairs(more_objectives) do
                            new_objectives[size] = value
                            size = size + 1
                        end
                        custom.tactic.objectives = new_objectives
                    elseif override.add_objectives_with_pos then
                        new_objectives = deep_clone(custom.tactic.objectives)
                        for _, value in ipairs(override.add_objectives_with_pos) do
                            if value.pos then
                                table.insert(new_objectives, value.pos, value.objective)
                            else
                                table.insert(new_objectives, value.objective)
                            end
                        end
                        custom.tactic.objectives = new_objectives
                    end
                    custom.objectives_override = nil
                end
                _panels[i] = XPBreakdownPanel:new(self, ws_panel, panel_params, xp_params, loc, custom.tactic, i)
                local button = XPBreakdownItem:new(self, ws_panel, "ehi_experience_" .. custom.name, custom.additional_name, loc, i)
                if i == 1 then
                    button:SetPosByPanel(_panels[i]._panel)
                else
                    button:SetPosByPreviousItem(_buttons[i - 1])
                end
                _buttons[i] = button
            end
        else
            -- Process stealth tactic first
            _panels[1] = XPBreakdownPanel:new(self, ws_panel, panel_params, xp_params, loc, tactic.stealth)
            _buttons[1] = XPBreakdownItem:new(self, ws_panel, "ehi_experience_stealth", nil, loc)
            _buttons[1]:SetPosByPanel(_panels[1]._panel)
            -- Loud
            _buttons[2] = XPBreakdownItem:new(self, ws_panel, "ehi_experience_loud", nil, loc, 2)
            _buttons[2]:SetPosByPreviousItem(_buttons[1])
            _panels[2] = XPBreakdownPanel:new(self, ws_panel, panel_params, xp_params, loc, tactic.loud, 2)
            TacticMax = 2
        end
        local offset = Global.game_settings.single_player and 20 or 25
        for i = 1, TacticMax, 1 do
            _panels[i]:AddOffset(offset)
            _buttons[i]:SetVisibleWithOffset(offset)
        end
        if not managers.menu:is_pc_controller() then
            XPBreakdownItemSwitch:new(ws_panel, TacticMax, loc, _buttons[TacticMax]._button)
        end
        self:HookMouseFunctions()
    else
        _panels[1] = XPBreakdownPanel:new(self, ws_panel, panel_params, xp_params, loc, params)
    end
end

function MissionBriefingGui:HookMouseFunctions()
    if original.mouse_pressed or original.special_btn_pressed then
        return
    end
    original.close = self.close
    ---@param gui MissionBriefingGui
    self.close = function(gui, ...)
        original.close(gui, ...)
        -- Remove hooks; the gui will refresh or is closing
        if original.mouse_pressed then
            gui.mouse_pressed = original.mouse_pressed
            gui.mouse_moved = original.mouse_moved
            original.mouse_pressed = nil
            original.mouse_moved = nil
        end
        if original.special_btn_pressed then
            gui.special_btn_pressed = original.special_btn_pressed
            original.special_btn_pressed = nil
        end
        -- No need to restore original function; these will get recreated
        original.assets_select = nil
        original.assets_deselect = nil
    end
    if XPBreakdownItemSwitch:IsCreated() then
        original.special_btn_pressed = self.special_btn_pressed
        ---@param gui MissionBriefingGui
        ---@param button string
        self.special_btn_pressed = function(gui, button, ...)
            if not alive(gui._panel) or not alive(gui._fullscreen_panel) or not gui._enabled then
                return false
            end
            if gui._displaying_asset then
                gui:close_asset()
                return false
            end
            if game_state_machine:current_state().blackscreen_started and game_state_machine:current_state():blackscreen_started() then
                return false
            end
            if button == Idstring("menu_toggle_pp_breakdown") then
                if gui._assets_item and gui._items[gui._selected_item] ~= gui._assets_item then
                    gui:NextTacticSelection()
                end
            end
            return original.special_btn_pressed(gui, button, ...)
        end
        original.assets_select = self._assets_item.select
        self._assets_item.select = function(...)
            XPBreakdownItemSwitch:set_alpha(0.25)
            original.assets_select(...)
        end
        original.assets_deselect = self._assets_item.deselect
        self._assets_item.deselect = function(...)
            XPBreakdownItemSwitch:set_alpha(1)
            original.assets_deselect(...)
        end
    else
        original.mouse_pressed = self.mouse_pressed
        ---@param gui MissionBriefingGui
        ---@param button string
        self.mouse_pressed = function(gui, button, ...)
            local result = original.mouse_pressed(gui, button, ...)
            if result then
                local fx, fy = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
                for _, ehi_button in ipairs(_buttons or {}) do
                    ehi_button:mouse_pressed(button, fx, fy)
                end
            end
            return result
        end
        original.mouse_moved = self.mouse_moved
        ---@param gui MissionBriefingGui
        self.mouse_moved = function(gui, ...)
            if not alive(gui._panel) or not alive(gui._fullscreen_panel) or not gui._enabled then
                return false, "arrow"
            end
            if gui._displaying_asset then
                return false, "arrow"
            end
            if game_state_machine:current_state().blackscreen_started and game_state_machine:current_state():blackscreen_started() then
                return false, "arrow"
            end
            local fx, fy = managers.mouse_pointer:modified_fullscreen_16_9_mouse_pos()
            for _, button in ipairs(_buttons or {}) do
                if button:mouse_moved(fx, fy) then
                    return true, "link"
                end
            end
            return original.mouse_moved(gui, ...)
        end
    end
end

function MissionBriefingGui:FakeExperienceMultipliers()
    if EHI:IsRunningBB() or EHI:IsRunningUsefulBots() then
        self._num_winners = 4
    end
    if Global.block_update_outfit_information then -- Outfit update is late when "managers.player:get_skill_exp_multiplier(true)" is called, update it now to stay accurate
        local outfit_string = managers.blackmarket:outfit_string()
        local local_peer = managers.network:session():local_peer()
        reloading_outfit = true
        local_peer:set_outfit_string(outfit_string)
        reloading_outfit = false
    end
    self._skill_bonus = managers.player:get_skill_exp_multiplier(true)
end

---@param base_xp number
---@return number
function MissionBriefingGui:FormatXPWithAllGagePackagesNoString(base_xp)
    self._gage_bonus = 1.05
    local value = self._xp:FakeMultiplyXPWithAllBonuses(base_xp)
    self._gage_bonus = 1
    return value
end

---@param base_xp number
---@return string
function MissionBriefingGui:FormatXPWithAllGagePackages(base_xp)
    return self._xp:cash_string(self:FormatXPWithAllGagePackagesNoString(base_xp), "")
end

function MissionBriefingGui:RefreshXPOverview()
    self._num_winners = managers.network:session() and managers.network:session():amount_of_players()
    self:ProcessXPBreakdown()
end

---@diagnostic disable
function MissionBriefingGui:NextTacticSelection()
    _buttons[TacticSelected]:Unselect()
    local PreviousTactic = TacticSelected
    TacticSelected = math.increment_with_limit(TacticSelected, 1, TacticMax)
    _buttons[TacticSelected]:Select(false, PreviousTactic)
end

---@param index number
---@param PreviousTactic number?
function MissionBriefingGui:OnTacticChanged(index, PreviousTactic)
    local tactic = PreviousTactic or TacticSelected
    _panels[index]._panel:set_visible(true)
    _panels[tactic]._panel:set_visible(false)
    _buttons[tactic]:Unselect()
    TacticSelected = index
end
---@diagnostic enable

function TeamLoadoutItem:set_slot_outfit(slot, ...)
    original.set_slot_outfit(self, slot, ...)
    local player_slot = slot and self._player_slots[slot]
    if not player_slot or reloading_outfit then
        return
    end
    local mcm = managers.menu_component
    if mcm and mcm._mission_briefing_gui then
        mcm._mission_briefing_gui:RefreshXPOverview()
    end
end

function LobbyCodeMenuComponent:init(...)
    original.lobby_code_init(self, ...)
    if self._panel:alpha() ~= 0 then
        self._panel:set_y(0)
        if managers.hud._hud_mission_briefing and managers.hud._hud_mission_briefing.MoveJobName then
            managers.hud._hud_mission_briefing:MoveJobName(self._panel:w())
        end
    end
end

EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
    if _panels then
        for _, panel in ipairs(_panels) do
            panel:destroy()
        end
        _panels = nil
    end
    if _buttons then
        for _, button in ipairs(_buttons) do
            button:destroy()
        end
        _buttons = nil
    end
    XPBreakdownItemSwitch:destroy()
    XPBreakdownItemSwitch = nil
end)