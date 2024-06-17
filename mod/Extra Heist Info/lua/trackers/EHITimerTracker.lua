local EHI = EHI
local Color = Color

---@alias EHITimerGroupTracker.Timer { label: PanelText, time: number, jammed: boolean, powered: boolean, autorepair: boolean, animate_warning: boolean?, animate_completion: boolean?, anim_started: boolean, pos: number }

---@class EHITimerTracker : EHIWarningTracker, EHIWarningGroupTracker
---@field super EHIWarningTracker
---@field _icon2 PanelBitmap?
---@field _icon3 PanelBitmap?
---@field _icon4 PanelBitmap?
---@field _bg_box_w number Inherited class needs to populate this field
---@field _bg_box_double number Inherited class needs to populate this field
---@field _panel_w number Inherited class needs to populate this field
---@field _panel_double number Inherited class needs to populate this field
EHITimerTracker = class(EHIWarningTracker)
EHITimerTracker._update = false
EHITimerTracker._autorepair_color = EHI:GetTWColor("drill_autorepair")
EHITimerTracker._paused_color = EHIPausableTracker._paused_color
EHITimerTracker.StartTimer = EHITimedChanceTracker.StartTimer
EHITimerTracker.StopTimer = EHITimedChanceTracker.StopTimer
EHITimerTracker.AnimateMovement = EHIWarningGroupTracker.AnimateMovement
---@param params EHITracker.params
function EHITimerTracker:pre_init(params)
    if params.icons[1].icon then
        params.icons[2] = { icon = "faster", visible = false, alpha = 0.25 }
        params.icons[3] = { icon = "silent", visible = false, alpha = 0.25 }
        params.icons[4] = { icon = "restarter", visible = false, alpha = 0.25 }
    end
end

---@param params EHITracker.params
function EHITimerTracker:post_init(params)
    self._theme = params.theme
    self:SetUpgradeable(false)
    self._jammed = false
    self._not_powered = false
    if params.upgrades then
        self:SetUpgradeable(true)
        self:SetUpgrades(params.upgrades)
    end
    self:SetAutorepair(params.autorepair)
    self._animate_warning = params.warning
    if params.completion then
        self._animate_warning = true
        self._show_completion_color = true
    end
end

---@param time number
function EHITimerTracker:SetTimeNoAnim(time) -- No fit text function needed, these timers just run down
    self._time = time
    self._text:set_text(self:Format())
    if time <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

---@param t number
---@param time string
function EHITimerTracker:SetTimeNoFormat(t, time) -- No fit text function needed, these timers just run down
    self._time = t
    self._text:set_text(time)
    if t <= 10 and self._animate_warning and not self._anim_started then
        self._anim_started = true
        self:AnimateColor()
    end
end

---@param completion boolean
function EHITimerTracker:SetAnimation(completion)
    self._animate_warning = true
    if completion then
        self._show_completion_color = true
    end
    if self._time <= 10 and not self._anim_started then
        self._anim_started = true
        self:AnimateColor(true)
    end
end

---@param upgradeable boolean
function EHITimerTracker:SetUpgradeable(upgradeable)
    self._upgradeable = upgradeable
    if self._icon2 then
        self._icon2:set_visible(upgradeable)
        self._icon3:set_visible(upgradeable)
        self._icon4:set_visible(upgradeable)
    end
    if upgradeable and self._icon2 then
        self._panel_override_w = self._panel:w()
        if self._ICON_LEFT_SIDE_START then
            self._bg_box:set_x(self._icon_gap_size_scaled * self._n_of_icons)
        end
    else
        self._panel_override_w = self._bg_box:w() + self._icon_gap_size_scaled
        if self._ICON_LEFT_SIDE_START then
            self._bg_box:set_x(self._icon_gap_size_scaled)
        end
    end
end

---@param upgrades table
function EHITimerTracker:SetUpgrades(upgrades)
    if not (self._upgradeable and upgrades) then
        return
    end
    local icon_definition =
    {
        faster = 2,
        silent = 3,
        restarter = 4
    }
    for upgrade, level in pairs(upgrades) do
        if level > 0 then
            local icon = self["_icon" .. tostring(icon_definition[upgrade])] --[[@as PanelBitmap?]]
            if icon then
                icon:set_color(self:GetUpgradeColor(level))
                icon:set_alpha(1)
            end
        end
    end
end

---@param level number
---@return Color
function EHITimerTracker:GetUpgradeColor(level)
    if not self._theme then
        return TimerGui.upgrade_colors["upgrade_color_" .. level]
    end
    local theme = TimerGui.themes[self._theme]
    return theme and theme["upgrade_color_" .. level] or TimerGui.upgrade_colors["upgrade_color_" .. level]
end

---@param state boolean
function EHITimerTracker:SetAutorepair(state)
    self._icon1:set_color(state and self._autorepair_color or Color.white)
end

---@param jammed boolean
function EHITimerTracker:SetJammed(jammed)
    if self._anim_started then
        self._text:stop()
        self._anim_started = false
    end
    self._jammed = jammed
    self:SetTextColor()
end

---@param powered boolean
function EHITimerTracker:SetPowered(powered)
    if self._anim_started then
        self._text:stop()
        self._anim_started = false
    end
    self._not_powered = not powered
    self:SetTextColor()
end

function EHITimerTracker:SetRunning()
    self:SetJammed(false)
    self:SetPowered(true)
end

---@param color Color? Color is set to `White` or tracker default color if not provided
---@param text PanelText? Defaults to `self._text` if not provided
function EHITimerTracker:SetTextColor(color, text)
    if color then
        EHITimerTracker.super.SetTextColor(self, color, text)
    elseif self._jammed or self._not_powered then
        self._text:set_color(self._paused_color)
    else
        self._text:set_color(Color.white)
        if self._time <= 10 and self._animate_warning and not self._anim_started then
            self._anim_started = true
            self:AnimateColor(true)
        end
    end
end

function EHITimerTracker:IsTimerRunning()
    return self._bg_box:w() == self._bg_box_double
end

---@class EHITimerGroupTracker : EHITimerTracker
---@field super EHITimerTracker
EHITimerGroupTracker = class(EHITimerTracker)
EHITimerGroupTracker._init_create_text = false
---@param params EHITracker.params
function EHITimerGroupTracker:post_init(params)
    self._group = params.group --[[@as string]]
    self._subgroup = params.subgroup or 1 --[[@as number]]
    self._i_subgroup = params.i_subgroup or 1 --[[@as number]]
    self._timers = {} --[[@as table<string, EHITimerGroupTracker.Timer?>]]
    self._timers_n = 0
    if params.key and params.time then
        self:AddTimer(params.time, params.key)
    end
    EHITimerGroupTracker.super.post_init(self, params)
end

---@param timer EHITimerGroupTracker.Timer
---@param check_progress boolean?
---@param color Color?
function EHITimerGroupTracker:AnimateColor(timer, check_progress, color)
    local start_t = check_progress and (1 - math.min(self._parent_class.RoundNumber(timer.time, 1) - math.floor(timer.time), 0.99)) or 1
    timer.label:animate(self._anim_warning, self._text_color, color or (timer.animate_completion and self._completion_color or self._warning_color), start_t, self)
end

---@param t number
---@param id string Unit Key
---@param warning boolean?
function EHITimerGroupTracker:AddTimer(t, id, warning)
    local label = self:CreateText({
        text = self:FormatTime(t),
        x = self._timers_n * self._default_bg_size,
        w = self._default_bg_size
    })
    self._timers[id] =
    {
        label = label,
        time = t,
        powered = true,
        animate_warning = warning,
        pos = self._timers_n
    }
    self._timers_n = self._timers_n + 1
    if self._timers_n >= 2 then
        self:AnimateMovement(self._timers_n)
    end
end

---@param time number
---@param id string Unit Key
function EHITimerGroupTracker:SetTimeNoAnim(time, id) -- No fit text function needed, these timers just run down
    local timer = self._timers[id]
    if timer then
        timer.time = time
        timer.label:set_text(self:FormatTime(time))
        if time <= 10 and timer.animate_warning and not timer.anim_started then
            timer.anim_started = true
            self:AnimateColor(timer)
        end
    end
end

---@param t number
---@param time string
---@param id string Unit Key
function EHITimerGroupTracker:SetTimeNoFormat(t, time, id) -- No fit text function needed, these timers just run down
    local timer = self._timers[id]
    if timer then
        timer.time = t
        timer.label:set_text(time)
        if t <= 10 and timer.animate_warning and not timer.anim_started then
            timer.anim_started = true
            self:AnimateColor(timer)
        end
    end
end

---@param id string Unit Key
function EHITimerGroupTracker:StopTimer(id)
    local timer = self._timers[id]
    if not timer or self._timers_n <= 1 then -- If the amount of timers in this tracker is 1, the manager will delete the tracker
        return
    end
    timer.label:stop()
    timer.label:parent():remove(timer.label)
    local pos = timer.pos
    self._timers[id] = nil
    for _, t in pairs(self._timers) do
        if t.pos > pos then
            local new_pos = t.pos - 1
            t.pos = new_pos
            t.label:set_x(new_pos * self._default_bg_size)
        end
    end
    if self._timers_n >= 2 then
        self:AnimateMovement(self._timers_n - 1, true)
    end
    self._timers_n = self._timers_n - 1
end

function EHITimerGroupTracker:RedrawPanel()
    for _, timer in pairs(self._timers) do
        self:FitTheText(timer.label)
    end
end

---@param jammed boolean
---@param id string
function EHITimerGroupTracker:SetJammed(jammed, id)
    local timer = self._timers[id]
    if timer then
        if timer.anim_started then
            timer.label:stop()
            timer.anim_started = false
        end
        timer.jammed = jammed
        self:SetTextColor(timer)
    end
end

---@param powered boolean
---@param id string
function EHITimerGroupTracker:SetPowered(powered, id)
    local timer = self._timers[id]
    if timer then
        if timer.anim_started then
            timer.label:stop()
            timer.anim_started = false
        end
        timer.powered = powered
        self:SetTextColor(timer)
    end
end

---@param id string
function EHITimerGroupTracker:SetRunning(id)
    self:SetJammed(false, id)
    self:SetPowered(true, id)
end

---@param timer EHITimerGroupTracker.Timer
function EHITimerGroupTracker:SetTextColor(timer)
    local text = timer.label
    if timer.jammed or not timer.powered then
        text:set_color(self._paused_color)
    else
        text:set_color(Color.white)
        if timer.time <= 10 and timer.animate_warning and not timer.anim_started then
            timer.anim_started = true
            self:AnimateColor(timer, true)
        end
    end
end

---@param state boolean
---@param id string
function EHITimerGroupTracker:SetAutorepair(state, id)
    local timer = self._timers[id]
    if timer then
        if timer.jammed or not timer.powered then
            if state then
                self:AnimateColor(timer, false, self._autorepair_color)
            end
            return
        elseif not timer.anim_started then
            timer.label:stop()
            timer.label:set_color(Color.white)
        end
    end
end

---@param completion boolean
---@param id string Unit Key
function EHITimerGroupTracker:SetAnimation(completion, id)
    local timer = self._timers[id]
    if timer then
        timer.animate_warning = true
        timer.animate_completion = completion
        if timer.time <= 10 and not timer.anim_started then
            timer.anim_started = true
            self:AnimateColor(timer, true)
        end
    end
end

function EHITimerGroupTracker:GetGroupData()
    return self._group, self._subgroup, self._i_subgroup
end

---@param id string Unit Key
function EHITimerGroupTracker:IsTimerRunning(id)
    return self._timers[id] ~= nil
end

function EHITimerGroupTracker:delete()
    for _, timer in pairs(self._timers) do
        if timer.label and alive(timer.label) then
            timer.label:stop()
        end
    end
    EHITimerGroupTracker.super.delete(self)
end

---@class EHIProgressTimerTracker : EHITimerTracker, EHIProgressTracker, EHITimedChanceTracker
---@field super EHITimerTracker
EHIProgressTimerTracker = class(EHITimerTracker)
EHIProgressTimerTracker._progress_bad = EHIProgressTracker._progress_bad
EHIProgressTimerTracker.pre_init = EHIProgressTracker.pre_init
EHIProgressTimerTracker.update = EHIProgressTimerTracker.update_fade
EHIProgressTimerTracker.FormatProgress = EHIProgressTracker.FormatProgress
EHIProgressTimerTracker.IncreaseProgressMax = EHIProgressTracker.IncreaseProgressMax
EHIProgressTimerTracker.DecreaseProgressMax = EHIProgressTracker.DecreaseProgressMax
EHIProgressTimerTracker.SetProgressMax = EHIProgressTracker.SetProgressMax
EHIProgressTimerTracker.IncreaseProgress = EHIProgressTracker.IncreaseProgress
EHIProgressTimerTracker.DecreaseProgress = EHIProgressTracker.DecreaseProgress
EHIProgressTimerTracker.SetProgress = EHIProgressTracker.SetProgress
EHIProgressTimerTracker.SetProgressRemaining = EHIProgressTracker.SetProgressRemaining
EHIProgressTimerTracker.SetCompleted = EHIProgressTracker.SetCompleted
EHIProgressTimerTracker.SetBad = EHIProgressTracker.SetBad
---@param params EHITracker.params
function EHIProgressTimerTracker:post_init(params)
    self:PrecomputeDoubleSize()
    self._progress_text = self:CreateText({
        text = self:FormatProgress()
    })
    self._text:set_left(self._progress_text:right())
    if not managers.ehi_manager:GetInSyncState() then
        self:SetBad()
    end
end

function EHIProgressTimerTracker:StartTimer(...)
    EHIProgressTimerTracker.super.StartTimer(self, ...)
    if self._progress ~= self._max then
        self:SetTextColor(Color.white, self._progress_text)
    end
end

function EHIProgressTimerTracker:StopTimer()
    EHIProgressTimerTracker.super.StopTimer(self)
    self:SetBad()
end

---@class EHIChanceTimerTracker : EHITimerTracker, EHIChanceTracker
---@field super EHIChanceTracker
EHIChanceTimerTracker = class(EHITimerTracker)
EHIChanceTimerTracker.pre_init = EHIChanceTracker.pre_init
EHIChanceTimerTracker.FormatChance = EHIChanceTracker.FormatChance
EHIChanceTimerTracker.IncreaseChance = EHIChanceTracker.IncreaseChance
EHIChanceTimerTracker.DecreaseChance = EHIChanceTracker.DecreaseChance
EHIChanceTimerTracker.SetChance = EHIChanceTracker.SetChance
EHIChanceTimerTracker._anim_chance = EHIChanceTracker._anim_chance
EHIChanceTimerTracker.delete = EHIChanceTracker.delete
---@param params EHITracker.params
function EHIChanceTimerTracker:post_init(params)
    self:PrecomputeDoubleSize()
    self._chance_text = self:CreateText({
        text = self:FormatChance()
    })
    self._text:set_left(self._chance_text:right())
end