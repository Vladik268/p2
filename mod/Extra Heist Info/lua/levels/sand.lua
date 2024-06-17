local Color = Color
---@class EHIsand11Tracker : EHIAchievementProgressTracker, EHIChanceTracker
---@field super EHIAchievementProgressTracker
EHIsand11Tracker = class(EHIAchievementProgressTracker)
EHIsand11Tracker._forced_icons = EHI:GetAchievementIcon("sand_11")
EHIsand11Tracker.FormatChance = EHIChanceTracker.FormatChance
function EHIsand11Tracker:pre_init(params)
    params.max = 100
    params.show_finish_after_reaching_target = true
    params.no_failure = true
    self._chance = 0
    EHIsand11Tracker.super.pre_init(self, params)
end

function EHIsand11Tracker:OverridePanel()
    self:SetBGSize()
    self._text_chance = self._bg_box:text({
        text = self:FormatChance(),
        align = "center",
        vertical = "center",
        w = self._bg_box:w() / 2,
        h = self._bg_box:h(),
        font = tweak_data.menu.pd2_large_font,
        font_size = self._panel:h() * self._text_scale,
        color = self._text_color
    })
    self._text_chance:set_right(self._bg_box:right())
    self:SetIconX()
end

function EHIsand11Tracker:SetChance(amount)
    self._chance = amount
    self._text_chance:set_text(self:FormatChance())
    if amount >= 100 then
        self._text_chance:set_color(Color.green)
    else
        self._text_chance:set_color(Color.white)
    end
end

local EHI = EHI
local Icon = EHI.Icons
local SF = EHI.SpecialFunctions
local TT = EHI.Trackers
local Hints = EHI.Hints
local boat_anim = 614/30 + 12 + 1
local skid = { { icon = Icon.Car, color = tweak_data.ehi.colors.CarBlue } }
local triggers = {
    [EHI:GetInstanceElementID(100043, 4800)] = { special_function = SF.Trigger, data = { 1000431, 1000432 } },
    [1000431] = { time = 15, id = "DoorOpenGas", icons = { Icon.Door }, hint = Hints.Wait },
    [1000432] = { additional_time = 20, random_time = 5, id = "RoomGas", icons = { Icon.Teargas }, hint = Hints.Teargas },

    [103333] = { time = 613/30, id = "SkidDriving2", icons = skid, hint = Hints.hox_1_VehicleMove },
    [103178] = { time = 386/30, id = "SkidDriving3", icons = skid, hint = Hints.hox_1_VehicleMove },
    [104043] = { time = 28, id = "SkidDriving4", icons = skid, hint = Hints.hox_1_VehicleMove }, -- More accurate
    [104101] = { time = 7, id = "SkidDriving5", icons = skid, hint = Hints.hox_1_VehicleMove }, -- 100704; More accurate
    [104102] = { time = 477/30, id = "SkidDriving6", icons = skid, hint = Hints.hox_1_VehicleMove },
    [104233] = { time = 30, id = "SkidDriving7", icons = skid, hint = Hints.hox_1_VehicleMove }, -- More accurate
    [104262] = { time = 549/30, id = "SkidDriving8", icons = skid, hint = Hints.hox_1_VehicleMove },
    [104304] = { time = 40, id = "SkidDriving9", icons = skid, hint = Hints.hox_1_VehicleMove }, -- More accurate
    [103667] = { time = 1399/30, id = "SkidDriving10", icons = skid, hint = Hints.hox_1_VehicleMove },
    [100782] = { time = 18, id = "SkidDriving11", icons = skid, hint = Hints.hox_1_VehicleMove }, -- More accurate
    [104227] = { time = 37, id = "SkidDriving12", icons = skid, hint = Hints.hox_1_VehicleMove }, -- More accurate
    [104305] = { time = 25, id = "SkidDriving13", icons = skid, hint = Hints.hox_1_VehicleMove }, -- More accurate
    [101009] = { time = 210/30, id = "RampRaise", icons = { Icon.Wait }, hint = Hints.Wait },
    [101799] = { time = 181/30, id = "RampLower", icons = { Icon.Wait }, hint = Hints.Wait },

    [104528] = { time = 22, id = "Crane", icons = { Icon.Winch }, hint = Hints.des_Crane }, -- 104528 -> 100703

    [103870] = { chance = 34, id = "ReviveVlad", icons = { "equipment_defibrillator" }, class = TT.Chance, special_function = SF.AddTrackerIfDoesNotExist, hint = Hints.sand_Revive },
    [103871] = { id = "ReviveVlad", special_function = SF.RemoveTracker },

    [103925] = { id = "BoatEscape", icons = Icon.BoatEscape, special_function = SF.SetTimeIfLoudOrStealth, data = { loud = 30 + boat_anim, stealth = 19 + boat_anim }, hint = Hints.LootEscape }
}
for i = 16580, 16780, 100 do
    triggers[EHI:GetInstanceElementID(100057, i)] = { id = "ReviveVlad", special_function = SF.IncreaseChanceFromElement } -- +33%
end

---@type ParseAchievementTable
local achievements =
{
    sand_9 =
    {
        elements =
        {
            [EHI:GetInstanceElementID(100024, 31755)] = { special_function = SF.Trigger, data = { 1, 2 } },
            [1] = { max = 10, show_finish_after_reaching_target = true, class = TT.Achievement.Progress, special_function = SF.ShowAchievementFromStart },
            [2] = { special_function = SF.CustomCode, f = function()
                if managers.ehi_tracker:TrackerDoesNotExist("sand_9") then
                    return
                end
                -- Counter is bugged. Teaset is counted too.
                -- Reported in:
                -- https://steamcommunity.com/app/218620/discussions/14/3182363463067457019/
                EHI:AddAchievementToCounter({
                    achievement = "sand_9"
                })
                managers.ehi_tracker:SetTrackerProgress("sand_9", managers.loot:GetSecuredBagsAmount())
            end },
            [103208] = { special_function = SF.FinalizeAchievement }
        },
        sync_params = { from_start = true }
    },
    sand_10 =
    {
        elements =
        {
            [100107] = { max = 8, class = TT.Achievement.Progress },
        },
        preparse_callback = function(data)
            local trigger = { special_function = SF.IncreaseProgress }
            for i = 105290, 105329, 1 do
                data.elements[i] = trigger
            end
        end,
        sync_params = { from_start = true }
    }
}

local other =
{
    [100109] = EHI:AddAssaultDelay({ control = 60 })
}
if EHI:GetOptionAndLoadTracker("show_sniper_tracker") then
    local sniper_count = EHI:GetValueBasedOnDifficulty({
        overkill_or_below = 2,
        mayhem_or_above = 3
    })
    other[100015] = { id = "Snipers", class = TT.Sniper.Count, trigger_times = 1, sniper_count = sniper_count }
    --[[other[100533] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceFail" }
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100537] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +5%
    other[100565] = { id = "Snipers", special_function = SF.SetChanceFromElement } -- 10%
    other[100574] = { id = "Snipers", special_function = SF.IncreaseChanceFromElement } -- +15%]]
    other[100363] = { id = "Snipers", special_function = SF.CallCustomFunction, f = "OnChanceSuccess" }
    other[100380] = { id = "Snipers", special_function = SF.IncreaseCounter }
    other[100381] = { id = "Snipers", special_function = SF.DecreaseCounter }
end

EHI:ParseTriggers({
    mission = triggers,
    achievement = achievements,
    other = other
})

local tbl = {}
if EHI:GetOption("show_waypoints") then
    local function f(id, unit_data, unit)
        local trigger_id = unit_data.trigger_id
        EHI:AddWaypointToTrigger(trigger_id, { unit = unit })
        unit:unit_data():add_destroy_listener("EHIDestroy", function(...)
            managers.ehi_waypoint:RemoveWaypoint(triggers[trigger_id].id)
        end)
    end
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/002
    tbl[104456] = { f = f, trigger_id = 103333 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/003
    tbl[104457] = { f = f, trigger_id = 103178 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/004
    tbl[104458] = { f = f, trigger_id = 104043 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/005
    tbl[104459] = { f = f, trigger_id = 104101 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/006
    tbl[104460] = { f = f, trigger_id = 104102 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/007
    tbl[104461] = { f = f, trigger_id = 104233 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/008
    tbl[104462] = { f = f, trigger_id = 104262 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/009
    tbl[104463] = { f = f, trigger_id = 104304 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/010
    tbl[104464] = { f = f, trigger_id = 103667 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/011
    tbl[104465] = { f = f, trigger_id = 100782 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/012
    tbl[104467] = { f = f, trigger_id = 104227 }
    --units/pd2_dlc_sand/vehicles/anim_vehicle_skidsteerloader/anim_vehicle_skidsteerloader/013
    tbl[104308] = { f = f, trigger_id = 104305 }
end
EHI:UpdateUnits(tbl)
EHI:AddXPBreakdown({
    tactic =
    {
        stealth =
        {
            objectives =
            {
                { amount = 500, name = "china2_entered_dockyard" }, -- Enter the compound
                { amount = 4000, name = "china2_found_vlad" }, -- Located Vlad on cameras
                { amount = 500, name = "china2_hacked_into_control_room" }, -- Hacked into the control room
                { amount = 500, name = "china2_downloaded_manifest" }, -- Downloaded warehouse manifest
                { amount = 1000, name = "china2_found_warehouse_with_vlad" }, -- Reached the warehouse
                { amount = 1000, name = "china2_found_foremans_office" }, -- Found foreman's office (if keycard)
                { amount = 2000, name = "china2_called_foremans_extension" }, -- Called foreman's extension (if keycard)
                { amount = 2000, name = "china2_lured_foreman_out" }, -- Lured foreman out of the office (if keycard)
                { amount = 1000, name = "china2_found_keycard_keypad_keycode" }, -- Obtained keycard/keypad/keycode
                { amount = 500, name = "china2_warehouse_open" }, -- Warehouse opened
                { amount = 2000, name = "china2_opened_vlads_container" }, -- Opened Vlad's container
                { amount = 500, name = "china2_cut_vlad_free" }, -- Cut Vlad free
                { amount = 1000, name = "china2_inject_adrenaline" }, -- Injected adrenalite to Vlad
                { amount = 1000, name = "china2_gathered_at_the_security_gate" }, -- Gathered at the security gate
                { amount = 3000, name = "china2_vlad_at_security_gate" }, -- Vlad arrived at the security gate
                { amount = 3000, name = "china2_second_path", optional = true }, -- Arrived at harbor offices
                { amount = 3000, name = "china2_found_it_room" }, -- Located IT room
                { amount = 6000, name = "china2_copied_documents" }, -- Copied documents onto USB stick
                { amount = 1000, name = "china2_lowered_bollards" }, -- Lowered bollards
                { amount = 500, name = "china2_ramp" }, -- Arrived at ramp
                { amount = 1000, name = "china2_ramp_raised" }, -- Ramp raised
                { amount = 2000, name = "china2_final_area" }, -- Entered the final area in the docks
                { amount = 1000, name = "china2_route_done", times = 5 }, -- Route done
                { amount = 2000, name = "china2_signaled_jiu_feng" }, -- Signaled Jiu Feng for extraction
                { amount = 2000, name = "china2_escape_arrived" }, -- Escape arrived
                { escape = 4000 }
            },
            loot_all = 500
        },
        loud =
        {
            objectives =
            {
                { amount = 500, name = "china2_entered_dockyard" }, -- Enter the compound
                { amount = 4000, name = "china2_found_vlad" }, -- Located Vlad on cameras
                { amount = 500, name = "china2_hacked_into_control_room" }, -- Hacked into the control room
                { amount = 500, name = "china2_downloaded_manifest" }, -- Downloaded warehouse manifest
                { amount = 1000, name = "china2_found_warehouse_with_vlad" }, -- Reached the warehouse
                {
                    random =
                    {
                        max = 1,
                        pc_hack =
                        {
                            { amount = 2500, name = "pc_hack" },
                        },
                        swat_van =
                        {
                            { amount = 2000, name = "diamond_heist_found_keycard" }
                        }
                    }
                },
                { amount = 1000, name = "china2_warehouse_open" }, -- Warehouse opened
                { amount = 2000, name = "china2_opened_vlads_container" }, -- Opened Vlad's container
                { amount = 500, name = "china2_cut_vlad_free" }, -- Cut Vlad free
                { amount = 2000, name = "china2_resuscitated_vlad" }, -- Resuscitated Vlad
                { amount = 6000, name = "china2_vlad_at_security_gate" }, -- Vlad arrived at the security gate
                { amount = 3000, name = "china2_second_path", optional = true }, -- Arrived at harbor offices
                { amount = 2000, name = "china2_found_it_room" }, -- Located IT room
                { amount = 2000, name = "pc_hack" }, -- IT Room PC hack
                { amount = 1500, name = "china2_harddrive_taken" }, -- Took harddrive
                { amount = 1000, name = "china2_lowered_bollards" }, -- Lowered bollards
                { amount = 500, name = "china2_ramp" }, -- Arrived at ramp
                { amount = 1000, name = "china2_ramp_raised" }, -- Ramp raised
                { amount = 2000, name = "china2_final_area" }, -- Entered the final area in the docks
                { amount = 1000, name = "china2_route_done", times = 5 }, -- Route done
                { amount = 2000, name = "china2_found_fireworks" }, -- Found fireworks
                { amount = 500, name = "china2_placed_fireworks" }, -- Placed fireworks
                { amount = 2000, name = "china2_escape_arrived" }, -- Escape arrived
                { escape = 3000 }
            },
            loot_all = 500
        }
    }
})