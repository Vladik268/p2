---@alias EHIWarningGroupTracker.Timer { label: PanelText, time: number, pos: number, warning: boolean, id: string, check_timer_progress: boolean }
---@alias EHIProgressGroupTracker.Counter { label: PanelText, progress: number, max: number, disable_counter: boolean, set_color_bad_when_reached: boolean }

---@class EHIWarningGroupTracker : EHIWarningTracker
---@field super EHIWarningTracker
EHIWarningGroupTracker = class(EHIWarningTracker)
EHIWarningGroupTracker._init_create_text = false
---@param params EHITracker.params
function EHIWarningGroupTracker:post_init(params)
    self._timers = {} --[[@as EHIWarningGroupTracker.Timer[] ]]
    self._timers_n = 0
    self._panel_override_w = self._panel:w()
    if params.unit then
        self:AddUnit()
    end
    if not self._hide_on_delete then
        self:Add(params.time or 0, params.timer_id)
    end
end

---@param dt number
function EHIWarningGroupTracker:update(dt)
    for i, timer in ipairs(self._timers) do
        timer.time = timer.time - dt
        timer.label:set_text(self:FormatTime(timer.time))
        if timer.time <= 0 then
            self:Remove(i)
        elseif timer.time <= 10 and not timer.warning then
            timer.warning = true
            self:AnimateColor(timer, timer.check_timer_progress)
        end
    end
end

---@param timer EHIWarningGroupTracker.Timer
---@param check_progress boolean?
---@param color Color?
function EHIWarningGroupTracker:AnimateColor(timer, check_progress, color)
    local start_t = check_progress and (1 - math.min(self._parent_class.RoundNumber(timer.time, 1) - math.floor(timer.time), 0.99)) or 1
    timer.label:animate(self._anim_warning, self._text_color, color or (self._show_completion_color and self._completion_color or self._warning_color), start_t, self)
end

---@param t number
---@param id string?
function EHIWarningGroupTracker:Add(t, id)
    local n = self._timers_n + 1
    local label = self:CreateText({
        text = self:FormatTime(t),
        x = self._timers_n * self._default_bg_size,
        w = self._default_bg_size
    })
    self._timers[n] =
    {
        label = label,
        time = t,
        pos = self._timers_n,
        id = id or ""
    }
    self._timers_n = n
    if n >= 2 then
        self:AnimateMovement(n)
    end
end

---@param trigger ElementTrigger
function EHIWarningGroupTracker:AddFromTrigger(trigger)
    self:Add(trigger.time or 0, trigger.timer_id)
end

---@param params AddTrackerTable|ElementTrigger
function EHIWarningGroupTracker:Run(params)
    self:Add(params.time, params.id)
end

---@param i number
function EHIWarningGroupTracker:Remove(i)
    if self._timers_n <= 1 then
        self:delete()
        return
    end
    local timer = table.remove(self._timers, i) --[[@as EHIWarningGroupTracker.Timer]]
    timer.label:stop()
    timer.label:parent():remove(timer.label)
    local pos = timer.pos
    for _, t in ipairs(self._timers) do
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

---@param id string
function EHIWarningGroupTracker:RemoveByID(id)
    if not id then
        return
    end
    for i, timer in ipairs(self._timers) do
        if timer.id == id then
            self:Remove(i)
            return
        end
    end
end

---@param n number
---@param delete boolean?
function EHIWarningGroupTracker:AnimateMovement(n, delete)
    local w = self._default_bg_size * n
    if delete then
        self._panel_override_w = self._panel_override_w - self._default_bg_size
    else
        self._panel_override_w = self._panel_override_w + self._default_bg_size
    end
    self:AnimatePanelWAndRefresh(self._panel_override_w)
    self:ChangeTrackerWidth(self._panel_override_w)
    self:AnimIconsX(w + self._gap_scaled)
    self:SetBGSize(w, "set", true)
end

---@param time number
---@param id string
function EHIWarningGroupTracker:SetTimeNoAnim(time, id)
    if not id then
        return
    end
    for _, timer in ipairs(self._timers) do
        if timer.id == id then
            timer.time = time
            timer.warning = false
            timer.check_timer_progress = time <= 10
            timer.label:stop()
        end
    end
end

function EHIWarningGroupTracker:AddUnit()
    self._units = (self._units or 0) + 1
end

---@param id string
function EHIWarningGroupTracker:RemoveUnit(id)
    self._units = (self._units or 0) - 1
    self._hide_on_delete = self._units > 0
    if self._units <= 0 then
        self:delete()
    else
        self:RemoveByID(id)
    end
end

function EHIWarningGroupTracker:delete()
    for _, timer in ipairs(self._timers) do
        if timer.label and alive(timer.label) then
            timer.label:stop()
            timer.label:parent():remove(timer.label)
        end
    end
    if self._hide_on_delete then
        self._timers = nil
        self._timers = {}
        self._timers_n = 0
    end
    EHIWarningGroupTracker.super.delete(self)
end

---@class EHIProgressGroupTracker : EHIProgressTracker
---@field super EHIProgressTracker
EHIProgressGroupTracker = class(EHIProgressTracker)
EHIProgressGroupTracker._init_create_text = false
---@param params EHITracker.params
function EHIProgressGroupTracker:post_init(params)
    self._call_done_function_on_completion = params.call_done_function
    self._counters = 0
    self._completed_counters = 0
    self._counters_table = {} --[[@as table<string, EHIProgressGroupTracker.Counter> ]]
    if params.counter then
        for _, counter in ipairs(params.counter) do
            self:Add(counter.progress or 0, counter.max or 0, counter.id)
        end
    end
end

---@param progress number
---@param max number
---@param id string
function EHIProgressGroupTracker:Add(progress, max, id)
    local n = self._counters + 1
    local label = self:CreateText({
        text = self:Format(progress, max),
        x = self._counters * self._default_bg_size,
        w = self._default_bg_size
    })
    self._counters_table[id] =
    {
        label = label,
        progress = progress,
        max = max
    }
    self._counters = n
    if n >= 2 then
        self:SetBGSize(self._default_bg_size * n, "set")
        self:SetIconsX()
        self:ChangeTrackerWidth()
    end
end

---@param counters table
function EHIProgressGroupTracker:AddFromSync(counters)
    for _, counter in ipairs(counters) do
        self:Add(counter.progress or 0, counter.max or 0, counter.id)
    end
    for _, counter in pairs(self._counters_table) do
        if counter.progress == counter.max then
            self:_SetCompleted(counter.label)
        end
    end
end

---@param id string
---@return EHIProgressGroupTracker.Counter?
function EHIProgressGroupTracker:GetCounter(id)
    return id and self._counters_table[id]
end

---@param max number
---@param id string
---@param operation boolean
function EHIProgressGroupTracker:SetProgressMax(max, id, operation)
    local counter = self:GetCounter(id)
    if counter then
        if operation then
            counter.max = counter.max + max
        else
            counter.max = max
        end
        counter.label:set_text(self:Format(counter.progress, counter.max))
        self:FitTheText(counter.label)
        self:AnimateBG()
    end
end

---@param max number?
---@param id string
function EHIProgressGroupTracker:IncreaseProgressMax(max, id)
    self:SetProgressMax(max or 1, id, true)
end

---@param max number?
---@param id string
function EHIProgressGroupTracker:DecreaseProgressMax(max, id)
    self:SetProgressMax(-(max or 1), id, true)
end

---@param progress number
---@param id string
function EHIProgressGroupTracker:SetProgress(progress, id)
    local counter = self:GetCounter(id)
    if counter and counter.progress ~= progress and not counter.disable_counter then
        counter.progress = progress
        counter.label:set_text(self:Format(progress, counter.max))
        self:FitTheText(counter.label)
        self:AnimateBG()
        if progress == counter.max then
            counter.disable_counter = true
            if counter.set_color_bad_when_reached then
                self:SetBad(counter.label)
            else
                self:_SetCompleted(counter.label)
            end
        end
    end
end

---@param progress number?
---@param id string
function EHIProgressGroupTracker:IncreaseProgress(progress, id)
    local counter = self:GetCounter(id)
    if counter then
        self:SetProgress(counter.progress + (progress or 1), id)
    end
end

---@param progress number?
---@param id string
function EHIProgressGroupTracker:DecreaseProgress(progress, id)
    local counter = self:GetCounter(id)
    if counter then
        self:SetProgress(counter.progress - (progress or 1), id)
        self:SetTextColor(nil, counter.label)
        counter.disable_counter = false
    end
end

---@param remaining number
---@param id string
function EHIProgressGroupTracker:SetProgressRemaining(remaining, id)
    local counter = self:GetCounter(id)
    if counter then
        self:SetProgress(counter.max - remaining, id)
    end
end

---@param id string
---@param force boolean?
function EHIProgressGroupTracker:SetCompleted(id, force)
    local counter = self:GetCounter(id)
    if counter then
        self:_SetCompleted(counter.label, force)
    end
end

---@param label PanelText
---@param force boolean?
function EHIProgressGroupTracker:_SetCompleted(label, force)
    self._completed_counters = self._completed_counters + 1
    self:SetTextColor(Color.green, label)
    if force or (self._counters == self._completed_counters and not self._status) then
        self._status = "completed"
        if self._call_done_function_on_completion then
            self:CountersDone()
        elseif force or not self._show_finish_after_reaching_target then
            self:DelayForcedDelete()
        elseif not self._show_progress_on_finish then
            self:SetStatusText("finish", label)
        end
    end
end

function EHIProgressGroupTracker:CountersDone()
end

---@param label PanelText
function EHIProgressGroupTracker:SetBad(label)
    self:SetTextColor(self._progress_bad, label)
end

function EHIProgressGroupTracker:Finalize()
    self._completed_counters = 0
    for _, counter in pairs(self._counters_table) do
        if counter.progress >= counter.max then
            self:_SetCompleted(counter.label)
        else
            self:SetFailed(counter)
            break
        end
    end
end

---@param counter EHIProgressGroupTracker.Counter?
function EHIProgressGroupTracker:SetFailed(counter)
    if self._status and not self._status_is_overridable then
        return
    end
    if counter then
        counter.disable_counter = true
        self:SetTextColor(Color.red, counter.label)
    else
        for _, c in pairs(self._counters_table) do
            c.disable_counter = true
            self:SetTextColor(Color.red, c.label)
        end
    end
    self._status = "failed"
    self:AddTrackerToUpdate()
    self:AnimateBG()
end