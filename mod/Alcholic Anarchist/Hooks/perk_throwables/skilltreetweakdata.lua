Hooks:RegisterHook("VPPP_AddThrowables_Done") -- Added if someone wants to include my mod in their rebalance, just like I hooked my mod to SSO

function AddThrowables(self)
    local name_id_to_upgrade_map = {
        menu_deck12_1 = {
            "yakuza_injector",
            "temporary_yakuza_injector_1"
        },
        menu_deck7_1 = {
            "burglar_luck",
            "temporary_burglar_luck_1"
        },
        menu_deck3_1 = {
            "liquid_armor",
            "temporary_liquid_armor_1"
        },
        menu_deck13_1 = {
            "blood_transfusion",
            "temporary_blood_transfusion_1"
        },
        menu_deck5_1 = {
            "wick_mode",
            "temporary_wick_mode_1"
        },
        menu_deck10_1 = {
            "emergency_requisition",
            "temporary_emergency_requisition_1"
        },
        menu_deck9_1 = {
            "the_mixtape",
            "temporary_the_mixtape_1"
        },
        menu_deck14_1 = {
            "whiff",
            "temporary_whiff_1"
        },
        menu_deck6_1 = {
            "crooks_con",
            "temporary_crooks_con_1"
        },
        menu_deck1_1 = {
            "buff_banner",
            "temporary_buff_banner_1"
        },
        menu_deck16_1 = {
            "crew_synchrony",
            "player_tag_team_base",
            "player_tag_team_cooldown_drain_1",
            "player_tag_team_damage_absorption",
            "player_tag_team_cooldown_drain_2",
        },
    }

    -- Add to perkdecks card
    for k, deck in pairs(self.specializations) do
        for k, card in pairs(deck) do
            if card and type(card) == "table" and card.name_id and name_id_to_upgrade_map[card.name_id] then
                if card.upgrades then
                    for i, upgrade_id in ipairs(name_id_to_upgrade_map[card.name_id]) do
                        table.insert(card.upgrades, upgrade_id)
                    end
                end
            end
        end
    end


    local add_to_default = {
        "med_x",
        "temporary_med_x_1",
        "auto_inject_super_stimpak",
        "adrenaline_shot",
        "temporary_adrenaline_shot_1",
        "spare_armor_plate",
        "temporary_spare_armor_plate_1",
        "jet",
        "temporary_jet_1",
    }

    for i, upgrade in ipairs(add_to_default) do
        table.insert(self.default_upgrades, upgrade)    
    end

    local name_id_to_skill_upgrade_map = {
        more_fire_power = {
            level = 2,
            upgrades = {
                "throwable_trip_mine",
                "temporary_throwable_trip_mine_1",
                "flamethrower_reload_speed_multiplier_1"
            }
        }
    }

    for skill_name, skill_data in pairs(name_id_to_skill_upgrade_map) do
        local skill = self.skills[skill_name]
        if skill and skill[skill_data.level] then
            for i, upgrade in ipairs(skill_data.upgrades) do
                table.insert(skill[skill_data.level].upgrades, upgrade)
            end
        end
    end

    Hooks:Call("VPPP_AddThrowables_Done", self)
end

Hooks:PostHook(SkillTreeTweakData, "init", "VPPP_SkillTreeTweakData_init", AddThrowables)

Hooks:Add("sso_skilltweak_init_complete", "VPPP_sydch_overhaul_compatibility_patch", AddThrowables)

-- DLC Debug shit
-- function WINDLCManager:_verify_dlcs()
--     for dlc_name, dlc_data in pairs(Global.dlc_manager.all_dlc_data) do
--         dlc_data.verified = true
--     end
-- end