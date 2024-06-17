local function circle_ui_custom_colors(value)
    local c = {
        pastel_pink = {255, 161, 220},
        purple = {128, 0, 128},
        aqua = {0, 255, 221},
        strawb = {251, 41, 65},
        orange = {255, 85, 0},
        red = {255, 0, 0},
        navy = {56, 63, 255},
        pink = {255, 0, 160},
        lilac = {223, 168, 255},
        black = {0, 0, 0},
        blue_violet = {169, 48, 255},
        white = {255, 255, 255},
        green = {0,255,0}
    }

    local convert = {
        "pastel_pink",
        "purple",
        "aqua",
        "strawb",
        "orange",
        "red",
        "navy",
        "pink",
        "lilac",
        "black",
        "blue_violet",
        "white",
        "green"
    }

    if not value then
        return c.white[1]/255, c.white[2]/255, c.white[3]/255
    end

    return c[convert[value]][1]/255, c[convert[value]][2]/255, c[convert[value]][3]/255
end

local circleRadius = 0
local maxRadius = tweak_data.player.omniscience.sense_radius or 0
local animationSpeed = maxRadius
local circle_red_c, circle_green_c, circle_blue_c = 1,1,1
local circleColor = Color(1, 1, 1, 1)
local blendMode = "mul"
local hasRun = false

local function get_custom_color()
    CircleUI:Load()
    local get_custom_option = CircleUI._data.circle_ui_color
    circle_red_c, circle_green_c, circle_blue_c = circle_ui_custom_colors(get_custom_option)
end

local function check_experimental_feature()
    return CircleUI._data.experimentalFeature or 1
end

function HUDManager:init_circle_ui(allowed)
    Hooks:Add("GameSetupUpdate", "Sixth_Sense_UI", function(t, dt)
        local playerUnit = managers.player:player_unit()
        if alive(playerUnit) then
            local playerPosition = playerUnit:position()
            local alpha = 0.1 - ((circleRadius / maxRadius) / 10)

            get_custom_color()
            circleColor = Color(alpha, circle_red_c, circle_green_c, circle_blue_c)
            circleRadius = math.min(circleRadius + animationSpeed * dt, maxRadius)

            if circleRadius == maxRadius then
                circleRadius = 0
            end

            local hit = false
            if check_experimental_feature() == 2 then
                local result = World:raycast("ray", playerPosition, playerPosition + Vector3(0, -maxRadius, 5), "slot_mask", managers.slot:get_mask("statics"))
                if result then
                    hit = true
                end
            end

            if not allowed and self._drawing_circles then
                if hasRun then
                    return
                end

                circleRadius = 0
                circleColor = Color(0, 1, 1, 1)

                managers.hud:_draw_circle(playerPosition, circleRadius, circleColor, blendMode)
                self._drawing_circles = false
                hasRun = true

                return
            end

            if hit then
                playerPosition = playerPosition + Vector3(0,0,20)
              --log("collision")
            end

            managers.hud:_draw_circle(playerPosition, circleRadius, circleColor, blendMode)
            self._drawing_circles = true
        else
            circleRadius = 0
        end
    end)
end

function HUDManager:_draw_circle(position, radius, color, blend)
    local brush = Draw:brush(color)
    brush:set_blend_mode(blend)
    brush:cylinder(position, position + Vector3(0, 0, 5), radius)
end

function HUDManager:reset_circle_ui()
    circleRadius = 0
    hasRun = false
end