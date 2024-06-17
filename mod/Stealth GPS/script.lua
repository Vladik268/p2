local class_name = "Stealth_GPS"
local loaded = rawget(_G, class_name)
local c = loaded or rawset(_G, class_name, {
    crosshair = {
        use_crosshair = true,
        crosshair_fov = 0.6,
        crosshair_distance = 9999999
    },
    aura = {
        use_aura = true,
        aura_distance = 9999999
    },
    draw_last_pos = true,
    draw_nav_aura = true,
    draw_civilians = true,
    draw_enemies = true,
    draw_guided_path = true,
    draw_unit_id = true
}) and _G[class_name]
local unit_colors = {}

math.randomseed(os.time())

local function draw_unit(self, unit_b_id, unit_id, unit, camera)
    unit_colors[unit_b_id] = unit_colors[unit_b_id] or {r = math.random(), g = math.random(), b = math.random()}

    local movement = unit:movement()
    local color = unit_colors[unit_b_id]
    local r, g, b = color.r, color.g, color.b
    local name_brush = Draw:brush(Color(r, g, b))
    local cam_rot = camera:rotation()
    local cam_up = cam_rot:z()
    local cam_right = cam_rot:x()
    local text = WolfHUD and WolfHUD:getCharacterName(unit:base()._tweak_table, true) or unit:base()._tweak_table or "UNKNOWN"
    local positions = self._nav_path

    name_brush:set_font(Idstring("fonts/font_medium"), 16)
    name_brush:set_render_template(Idstring("OverlayVertexColorTextured"))
    name_brush:center_text(movement:m_head_pos() + Vector3(0, 0, 30), text, cam_right, -cam_up)

    if not positions or unit_b_id ~= unit_id then
        return
    end

    local app = Application
    local unit_pos = unit:position()
    local last_nav_pos = self._nav_point_pos(positions[#positions])

    for i = 2, #positions, 1 do
        local next_pos = positions[i]
        local current_pos = positions[i - 1]
        local current_nav_pos = self._nav_point_pos(current_pos)
        local next_nav_pos = self._nav_point_pos(next_pos)

        if c.draw_guided_path then
            app:draw_cylinder(next_nav_pos, current_nav_pos, 1, r, g, b)
        end

        if c.draw_nav_aura then
            app:draw_circle(next_nav_pos + Vector3(0, 0, 10), unit:bounding_sphere_radius(), r, g, b)
        end

        if c.draw_unit_id then
            name_brush:center_text(next_nav_pos + Vector3(0, 0, 10), text .. " / " .. unit_b_id, cam_right, -cam_up)
        end
    end

    if c.draw_last_pos then
        app:draw_cylinder(last_nav_pos, unit_pos, 1, r, g, b)
    end

    app:draw_sphere(last_nav_pos, 5, r, g, b)
end

local function slots()
    local tb = {}
    tb[#tb + 1] = c.draw_enemies and "enemies" or nil
    tb[#tb + 1] = c.draw_civilians and "civilians" or nil
    return managers.slot:get_mask(unpack(tb))
end

local orig_upd_actions = CopActionWalk.update
function CopActionWalk:update(t)
    orig_upd_actions(self, t)

    local player_unit = managers.player:player_unit()

    if not alive(player_unit) or not managers.groupai:state():whisper_mode() then
        return
    end

    local camera = managers.viewport:get_current_camera()
    local unit = self._unit

    for _, sunit in pairs(c.aura.use_aura and World:find_units_quick("sphere", player_unit:movement():m_head_pos(), c.aura.aura_distance, slots()) or {}) do
        draw_unit(self, sunit:id(), unit:id(), sunit, camera)
    end

    for _, cunit in pairs(c.crosshair.use_crosshair and World:find_units("camera_cone", camera, Vector3(0, 0), c.crosshair.crosshair_fov, c.crosshair.crosshair_distance, slots()) or {}) do
        draw_unit(self, cunit:id(), unit:id(), cunit, camera)
    end
end