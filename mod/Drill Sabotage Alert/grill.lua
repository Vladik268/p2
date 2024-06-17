FOOMD:Load()
local save_the_fucking_saboteur = {}
local function _mark_em(receiver_unit, pos)
    if FOOMD._data.waypoint then
        local _waypoint_data = {
            position = pos or receiver_unit:position(),
            no_sync = true,
            state = "sneak_present",
            present_timer = 0,
            radius = 400,
            blend_mode = "add",
            color = Color.white,
	    }
        managers.hud:add_waypoint("fword_breaking_drill" .. tostring(receiver_unit:key()), _waypoint_data)
    end
    receiver_unit:contour():add("mark_enemy", false, 10, Color(252/255, 173/255, 3/255))
end

local function _reset()
    for i, s in pairs(save_the_fucking_saboteur) do
        managers.hud:remove_waypoint("fword_breaking_drill" .. tostring(s:key()))
        s:contour():remove("mark_enemy")
    end
end

local function _remove_wp(saboteur)
    if not saboteur then _reset() return end
    if next(save_the_fucking_saboteur) == nil then return end
    for i, s in pairs(save_the_fucking_saboteur) do
        if s:key() == saboteur:key() then
            managers.hud:remove_waypoint("fword_breaking_drill" .. tostring(saboteur:key()))
            saboteur:contour():remove("mark_enemy")
            table.remove(save_the_fucking_saboteur, i)
        end
    end
end

local function _do_stuff(receiver_unit, pos)
    local hint_text = managers.localization:text("hint_FOOMD")
    managers.hud:show_hint({
        time = 6,
        text = hint_text
    })

    _mark_em(receiver_unit, pos)
    table.insert(save_the_fucking_saboteur, receiver_unit)
end

Hooks:PostHook(Drill, "on_sabotage_SO_administered", "on_sabotage_SO_administered__", function(self, receiver_unit)
    if not FOOMD._data.Predict_Attempt then
        return
    end
    _do_stuff(receiver_unit, self._unit:get_object(Idstring(self._sabotage_align_obj_name)):position())
end)

Hooks:PostHook(Drill, "on_sabotage_SO_started", "on_sabotage_SO_started__", function(self, receiver_unit)
    if FOOMD._data.Predict_Attempt then
        return
    end
    _do_stuff(receiver_unit, self._unit:get_object(Idstring(self._sabotage_align_obj_name)):position())
end)

Hooks:PostHook(Drill, "on_sabotage_SO_completed", "on_sabotage_SO_completed__", function(self, saboteur)
    _remove_wp(saboteur)
end)

Hooks:PostHook(Drill, "on_sabotage_SO_failed", "on_sabotage_SO_failed__", function(self, saboteur)
    _remove_wp(saboteur)
end)