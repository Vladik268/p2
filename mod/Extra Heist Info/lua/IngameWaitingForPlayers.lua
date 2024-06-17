local EHI = EHI
if EHI:CheckLoadHook("IngameWaitingForPlayersState") then
    return
end

if EHI:GetOption("show_gage_tracker") then
    if EHI:GetOption("gage_tracker_panel") == 1 then
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            if managers.ehi_tracker:TrackerDoesNotExist("Gage") and EHI:AreGagePackagesSpawned() then
                local progress = math.max(managers.gage_assignment:GetCountOfRemainingPackages() - 1, 0)
                local max = tweak_data.gage_assignment:get_num_assignment_units()
                if progress < max then
                    managers.ehi_tracker:AddTracker({
                        id = "Gage",
                        icons = { "gage" },
                        progress = progress,
                        max = max,
                        hint = "gage",
                        class = EHI.Trackers.Progress
                    })
                end
            end
        end)
    else
        EHI:AddCallback(EHI.CallbackMessage.Spawned, function()
            if EHI:AreGagePackagesSpawned() and EHI:IsPlayingFromStart() then
                local max = tweak_data.gage_assignment:get_num_assignment_units()
                managers.hud:custom_ingame_popup_text(managers.localization:text("ehi_popup_gage_packages"), "0/" .. tostring(max), "EHI_Gage")
            end
        end)
    end
end

local gage3_13_levels =
{
    pbr = true,
    shoutout_raid = true,
    pent = true
}

local eng_1_levels =
{
    branchbank = true,
    branchbank_gold = true,
    branchbank_cash = true,
    branchbank_deposit = true,
    jewelry_store = true
}

local xm20_1_levels =
{
    mex = true,
    bex = true,
    pex = true,
    fex = true
}

local pent_11_levels =
{
    chas = true,
    sand = true,
    chca = true,
    pent = true
}

-- Daily challenges activated in ChallengeManager
local challenges =
{
    any_25_spooc_kills = { progress_id = "any_spooc_kills", icon = "Other_H_Any_Holy", loud_only = true, check = { enemy_check = "spooc" } },
    any_25_shield_kills = { progress_id = "any_shield_kills", icon = "Other_H_Any_Maximum", loud_only = true, check = { enemy_check = "shield" } },
    any_25_tank_kills = { progress_id = "any_tank_kills", icon = "heavy", loud_only = true, check = { enemy_check = "tank" } },
    any_25_taser_kills = { progress_id = "any_taser_kills", loud_only = true, check = { enemy_check = "taser" } },
    any_25_sniper_kills = { progress_id = "any_sniper_kills", icon = "sniper", loud_only = true },
    any_50_headshot_kills = { progress_id = "any_headshot_kills" },
    any_300_kills = { progress_id = "any_kills", icon = "C_All_H_All_AllJobs_D0" },
    melee_35_kills = { progress_id = "melee_kills", icon = "Other_H_Any_IAintGotTime" },
    any_6_jobs = { progress_id = "any_jobs", icon = "pd2_escape", check_on_completion = true, do_not_track = true },
    dentist_4_jobs = { progress_id = "dentist_jobs", check_on_completion = true, contact = "the_dentist", contact_short_name = "dentist", do_not_track = true },
    butcher_4_jobs = { progress_id = "butcher_jobs", check_on_completion = true, contact = "the_butcher", contact_short_name = "butcher", do_not_track = true },
    elephant_4_jobs = { progress_id = "elephant_jobs", check_on_completion = true, contact = "the_elephant", contact_short_name = "elephant", do_not_track = true },
    hector_4_jobs = { progress_id = "hector_jobs", check_on_completion = true, contact = "hector", do_not_track = true },
    vlad_4_jobs = { progress_id = "vlad_jobs", check_on_completion = true, contact = "vlad", do_not_track = true },
    bain_4_jobs = { progress_id = "bain_jobs", check_on_completion = true, contact = "bain", do_not_track = true },
    assault_rifle_100_kills = { progress_id = "assault_rifle_kills", check = { weapon_type = "assault_rifle" } },
    shotgun_100_kills = { progress_id = "shotgun_kills", check = { weapon_type = "shotgun" } },
    smg_100_kills = { progress_id = "smg_kills", check = { weapon_type = "smg" } },
    pistol_100_kills = { progress_id = "pistol_kills", check = { weapon_type = "pistol" } },
    lmg_100_kills = { progress_id = "lmg_kills", check = { weapon_type = "lmg" } },
    sniper_100_kills = { progress_id = "sniper_kills", check = { weapon_type = "snp" } }
}
challenges.any_100_headshot_kills = challenges.any_50_headshot_kills
challenges.melee_100_kills = challenges.melee_35_kills
for _, challenge in pairs(challenges) do
    if challenge.contact then
        challenge.icon = string.format("C_%s_H_All_AllDiffs_D0", select(1, string.gsub(challenge.contact_short_name or challenge.contact, "^%l", string.upper)))
    end
end

-- Daily challenges activated in CustomSafehouseManager
local sh_dailies =
{
    daily_hangover = { track = true, icon = "daily_hangover", check = { melee = "whiskey" } }, -- Kill with a bottle
    daily_lodsofemone = { hook_secured = true, achievement_icon = "cac_30" }, -- Secure money
    daily_classics = { hook_end = true, icon = "C_Classics_H_All_AllDiffs_D0" }, -- Complete Classics
    daily_discord = { hook_end = true, achievement_icon = "cac_11" }, -- Finish heists with at least 1 convert
    daily_grenades = { track = true, check = { grenades = { "frag", "frag_com", "dada_com", "dynamite" } } }, -- Kill with grenades
    daily_honorable = { track = true, icon = "Other_H_Any_IAintGotTime" }, -- Melee to death surrendered enemies
    daily_candy = { hook_secured = true, first_entry = true } -- Secure cocaine
}

local armored_4_levels = table.list_to_set(tweak_data.achievement.complete_heist_achievements.i_take_scores.jobs)

local primary, secondary, melee, grenade, is_stealth = nil, nil, nil, nil, false ---@type table, table, string, string, boolean
local VeryHardOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.VeryHard)
local OVKOrAbove = EHI:IsDifficultyOrAbove(EHI.Difficulties.OVERKILL)
--local MayhemOrAbove = EHI:IsMayhemOrAbove()
local stats = {}

---@param weapon_id string
---@return boolean
local function HasWeaponEquipped(weapon_id)
    return primary.weapon_id == weapon_id or secondary.weapon_id == weapon_id
end

---@param type string
---@return boolean
local function HasWeaponTypeEquipped(type)
    local primary_categories = tweak_data.weapon[primary.weapon_id] and tweak_data.weapon[primary.weapon_id].categories or {}
    local secondary_categories = tweak_data.weapon[secondary.weapon_id] and tweak_data.weapon[secondary.weapon_id].categories or {}
    return table.contains(primary_categories, type) or table.contains(secondary_categories, type)
end

---@param melee_id string
---@return boolean
local function HasMeleeEquipped(melee_id)
    return melee == melee_id
end

---@param type string
---@return boolean
local function HasMeleeTypeEquipped(type)
    local melee_tweak = tweak_data.blackmarket.melee_weapons[melee]
    return melee_tweak and melee_tweak.type and melee_tweak.type == type
end

---@param grenade_id string
---@return boolean
local function HasGrenadeEquipped(grenade_id)
    return grenade == grenade_id
end

local function HasNonExplosiveGrenadeEquipped()
    local projectile = tweak_data.blackmarket.projectiles[grenade]
    local tweak = tweak_data.projectiles[grenade]
    if projectile and tweak then
        if projectile.ability then
            return false
        elseif not projectile.is_explosive then
            return tweak.damage and tweak.damage > 0
        end
    end
    return false
end

---@param player_style_id string
---@return boolean
local function HasPlayerStyleEquipped(player_style_id)
    return managers.blackmarket:equipped_player_style() == player_style_id
end

---@param variation_id string
---@return boolean
local function HasSuitVariationEquipped(variation_id)
    return managers.blackmarket:equipped_suit_variation() == variation_id
end

local function WeaponsContainBlueprint(blueprint)
    local function CheckWeaponBlueprint(weapon_data)
        return table.contains(weapon_data.blueprint or {}, blueprint)
    end
    return CheckWeaponBlueprint(primary) or CheckWeaponBlueprint(secondary)
end

local function CheckWeaponsBlueprint(blueprint)
    local function CheckWeaponBlueprint(weapon_data)
        return table.contains(weapon_data.blueprint or {}, blueprint)
    end
    local pass, primary_pass, secondary_pass = false, false, false
    if CheckWeaponBlueprint(primary) then
        pass = true
        primary_pass = true
    end
    if CheckWeaponBlueprint(secondary) then
        pass = true
        secondary_pass = true
    end
    return pass, primary_pass, secondary_pass
end

local function ArbiterHasStandardAmmo()
    local function WeaponHasStandardAmmo(factory_id, blueprint)
        local t = managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint)
        return table.size(t or {}) == 0 -- Standard ammo type is not returned in the array, only the ammo upgrades
    end
    if primary.weapon_id == "arbiter" and WeaponHasStandardAmmo(primary.factory_id, primary.blueprint) then
        return true
    end
    if secondary.weapon_id == "arbiter" and WeaponHasStandardAmmo(secondary.factory_id, secondary.blueprint) then
        return true
    end
    return false
end

local function HasViperGrenadesOnLauncherEquipped()
    local function HasViperAmmo(factory_id, blueprint)
        local t = managers.weapon_factory:get_ammo_data_from_weapon(factory_id, blueprint)
        if t and table.size(t) > 0 then
            return table.contains(t, "launcher_poison") or table.contains(t, "launcher_poison_ms3gl_conversion")
        end
        return false
    end
    return HasViperAmmo(primary.factory_id, primary.blueprint) or HasViperAmmo(secondary.factory_id, secondary.blueprint)
end

local function WeaponsContainFiremode(firemode)
    local function FireModeExists(weapon_id)
        local tweak_data = tweak_data.weapon[weapon_id]
        if not tweak_data then
            return false
        end
        local firemode_data = tweak_data.fire_mode_data
        if not firemode_data then
            return false
        end
        if firemode_data[firemode] then
            return true
        end
        local firemode_toggable = firemode_data.toggable
        if not firemode_toggable then
            return false
        end
        return table.contains(firemode_toggable, firemode)
    end
    return FireModeExists(primary.weapon_id) or FireModeExists(secondary.weapon_id)
end

---@param id string
---@param progress number
---@param max number
---@param dont_flash_bg boolean?
---@param show_finish_after_reaching_target boolean?
---@param status_is_overridable boolean?
local function AddAchievementTracker(id, progress, max, dont_flash_bg, show_finish_after_reaching_target, status_is_overridable)
    managers.ehi_tracker:AddTracker({
        id = id,
        progress = progress,
        max = max,
        icons = EHI:GetAchievementIcon(id),
        flash_bg = not dont_flash_bg,
        flash_times = 1,
        show_finish_after_reaching_target = show_finish_after_reaching_target,
        status_is_overridable = status_is_overridable,
        no_failure = true,
        class = EHI.Trackers.Achievement.Progress
    })
end

local persistent_stat_unlocks = tweak_data.achievement.persistent_stat_unlocks
---@param id_stat string
---@param dont_flash_bg boolean?
---@param show_finish_after_reaching_target boolean?
---@param status_is_overridable boolean?
local function AddAchievementTracker2(id_stat, dont_flash_bg, show_finish_after_reaching_target, status_is_overridable)
    local achievement = persistent_stat_unlocks[id_stat] or {}
    local stat = achievement[1]
    if not stat then
        EHI:Log("No statistics found for achievement with stat: " .. tostring(id_stat))
        return
    end
    if not stat.at then
        EHI:Log("No maximum is defined in statistics with stat: " .. tostring(id_stat))
        return
    end
    if not stat.award then
        EHI:Log("No achievement ID is defined in statistics with stat: " .. tostring(id_stat))
        return
    end
    stats[id_stat] = stat.award
    AddAchievementTracker(stat.award, EHI:GetAchievementProgress(id_stat), stat.at, dont_flash_bg, show_finish_after_reaching_target, status_is_overridable)
end

---@param id string
---@param progress number
---@param max number
---@param daily_job boolean?
---@param icon string?
local function AddDailyProgressTracker(id, progress, max, daily_job, icon)
    managers.ehi_tracker:AddTracker({
        id = id,
        daily_job = daily_job,
        progress = progress,
        max = max,
        icons = { icon or EHI.Icons.Trophy },
        flash_bg = true,
        flash_times = 1,
        no_failure = true,
        class = EHI.Trackers.SideJob.Progress
    })
end

---Challenges active in ChallengeManager
---@param id string
---@param progress_id string?
---@param icon string?
local function AddDailyChallengeTracker(id, progress_id, icon)
    local progress, max = EHI:GetDailyChallengeProgressAndMax(id, progress_id)
    AddDailyProgressTracker(id, progress, max, true, icon)
end

---Challenges active in CustomSafehouseManager
---@param id string
---@param progress_id string?
---@param icon string?
local function AddDailySHChallengeTracker(id, progress_id, icon)
    local progress, max = EHI:GetSHSideJobProgressAndMax(id, progress_id)
    AddDailyProgressTracker(id, progress, max, false, icon)
end

---@param id string
---@param icon string?
local function HookMissionEndSHDailyProgress(id, icon)
    local progress, max = EHI:GetSHSideJobProgressAndMax(id)
    if progress + 1 < max then
        icon = icon or "milestone_trophy"
        EHI:HookWithID(CustomSafehouseManager, "award", string.format("EHI_%s_AwardProgress", id), function(csm, id_stat)
            if id_stat == id then
                managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text(id), tostring(progress + 1) .. "/" .. tostring(max), icon)
            end
        end)
    end
end

---@param id string
---@param trophy { carry_id: string|string[] }
---@param icon string?
local function HookSecuredChallenge(id, trophy, icon)
    icon = icon or "milestone_trophy"
    if EHI:GetUnlockableOption("show_daily_started_popup") then
        managers.hud:ShowSideJobStartedPopup(id, false, icon)
    end
    if EHI:GetUnlockableOption("show_daily_description") then
        managers.hud:ShowSideJobDescription(id)
    end
    local progress, max = EHI:GetSHSideJobProgressAndMax(id)
    local current_progress = progress
    ---@param loot LootManager
    EHI:AddEventListener(id, EHI.CallbackMessage.LootSecured, function(loot)
        local new_current_progress = progress + loot:GetSecuredBagsTypeAmount(trophy.carry_id)
        if current_progress == new_current_progress then
            return
        elseif new_current_progress < max then
            managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text(id), tostring(new_current_progress) .. "/" .. tostring(max), icon)
            current_progress = new_current_progress
        else
            EHI:RemoveEventListener(id)
        end
    end)
end

---@param achievement string
---@param weapon_id string
local function HookKillFunction(achievement, weapon_id)
    EHI:HookWithID(StatisticsManager, "killed", string.format("EHI_%s_%s_killed", achievement, weapon_id), function(self, data)
        if data.variant ~= "melee" then
            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
            if name_id == weapon_id then
                managers.ehi_tracker:IncreaseTrackerProgress(achievement)
            end
        end
    end)
end

---@param achievement string
---@param weapon_id string
local function HookKillFunctionNoCivilian(achievement, weapon_id)
    EHI:HookWithID(StatisticsManager, "killed", string.format("EHI_%s_%s_killed", achievement, weapon_id), function(self, data)
        if data.variant ~= "melee" and not CopDamage.is_civilian(data.name) then
            local name_id, _ = self:_get_name_id_and_throwable_id(data.weapon_unit)
            if name_id == weapon_id then
                managers.ehi_tracker:IncreaseTrackerProgress(achievement)
            end
        end
    end)
end

---@param f function
local function ShowTrackerInLoud(f)
    if is_stealth then
        EHI:AddOnAlarmCallback(f)
    else
        f()
    end
end

---@param id string
---@param progress number
---@param max number
local function ShowPopup(id, progress, max)
    managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("achievement_" .. id), tostring(progress) .. "/" .. tostring(max), EHI:GetAchievementIconString(id))
end

local pxp_1_checked = false
-- "Plague Doctor" achievement
local function pxp_1()
    if pxp_1_checked then
        return
    end
    if EHI:IsAchievementLocked2("pxp1_1") then
        local grenade_data = tweak_data.achievement.grenade_achievements.pxp1_1
        local grenade_pass = table.index_of(grenade_data.grenade_types, grenade) ~= -1
        local enemy_kills_data = tweak_data.achievement.enemy_kill_achievements.pxp1_1
        local parts_pass, _, _ = CheckWeaponsBlueprint(enemy_kills_data.parts)
        local melee_pass = table.index_of(tweak_data.achievement.enemy_melee_hit_achievements.pxp1_1.melee_weapons, melee) ~= 1
        local player_style_pass = HasPlayerStyleEquipped(grenade_data.player_style.style)
        local variation_pass = HasSuitVariationEquipped(grenade_data.player_style.variation)
        if (grenade_pass or parts_pass or melee_pass or HasViperGrenadesOnLauncherEquipped()) and player_style_pass and variation_pass then
            AddAchievementTracker2("pxp1_1_stats")
        end
    end
    pxp_1_checked = true
end

---@param achievement_id string
---@param f fun(am: AchievmentManager, stat: string, value: number?)
local function HookAwardAchievement(achievement_id, f)
    EHI:HookWithID(AchievmentManager, "award_progress", "EHI_" .. achievement_id .. "_AwardProgress", f)
end

---@param achievement_id string
---@param keys table
local function OnSetSavedJobValue(achievement_id, keys)
    EHI:PreHookWithID(MissionManager, "on_set_saved_job_value", "EHI_" .. achievement_id .. "_Achievement", function(mm, key, value)
        if keys[key] and value == 1 then
            local progress = 0
            local to_secure = tweak_data.achievement.collection_achievements[achievement_id].collection
            for _, item in ipairs(to_secure) do
                if Global.mission_manager.saved_job_values[item] then
                    progress = progress + 1
                end
            end
            if progress == 4 then
                return
            end
            ShowPopup(achievement_id, progress, 4)
        end
    end)
end

local _f_at_exit = IngameWaitingForPlayersState.at_exit
function IngameWaitingForPlayersState:at_exit(...)
    _f_at_exit(self, ...)
    EHI:CallCallback(EHI.CallbackMessage.HUDVisibilityChanged, not Global.hud_disabled)
    --[[if level == "flat" and EHI:IsAchievementLocked("flat_5") then
        managers.ehi_tracker:AddTracker({
            id = "flat_5",
            icons = { "C_Classics_H_PanicRoom_DontYouDare" },
            flash_bg = false,
            class = "EHIChanceTracker"
        })
    else]]
    EHI:CallCallbackOnce(EHI.CallbackMessage.Spawned)
    if EHI._cache.UnlockablesAreDisabled or GunGameGame or TIM then -- Twitch Integration Mod
        challenges = nil
        sh_dailies = nil
        return
    end
    primary = managers.blackmarket:equipped_primary()
    secondary = managers.blackmarket:equipped_secondary()
    melee = managers.blackmarket:equipped_melee_weapon()
    grenade = managers.blackmarket:equipped_grenade()
    is_stealth = managers.groupai:state():whisper_mode()
    local level = Global.game_settings.level_id
    local mask_id = managers.blackmarket:equipped_mask().mask_id
    local from_beginning = managers.statistics:started_session_from_beginning()
    if EHI:GetUnlockableAndOption("show_achievements") then
        if EHI:GetUnlockableOption("show_achievements_weapon") then -- Kill with weapons (primary or secondary)
            if EHI:IsAchievementLocked2("halloween_6") and mask_id == tweak_data.achievement.pump_action.mask and HasWeaponTypeEquipped("shotgun") then -- "Pump-Action" achievement
                AddAchievementTracker2("halloween_6_stats")
            end
            if EHI:IsAchievementLocked2("halloween_8") and HasWeaponEquipped("usp") then -- "The Pumpkin King Made Me Do It!" achievement
                AddAchievementTracker2("halloween_8_stats")
            end
            if EHI:IsAchievementLocked2("armored_5") and HasWeaponEquipped("ppk") then -- "License to Kill" achievement
                AddAchievementTracker2("armored_5_stat")
            end
            if EHI:IsAchievementLocked2("armored_7") and HasWeaponEquipped("s552") and mask_id == tweak_data.achievement.enemy_kill_achievements.im_not_a_crook.mask then -- "I'm Not a Crook!" achievement
                local function f()
                    AddAchievementTracker2("armored_7_stat")
                end
                ShowTrackerInLoud(f)
                stats.armored_7_stat = "armored_7"
            end
            if EHI:IsAchievementLocked2("armored_9") and HasWeaponEquipped("m45") and mask_id == tweak_data.achievement.enemy_kill_achievements.fool_me_once.mask then -- "Fool Me Once, Shame on -Shame on You. Fool Me - You Can't Get Fooled Again" achievement
                local function f()
                    AddAchievementTracker2("armored_9_stat")
                end
                ShowTrackerInLoud(f)
                stats.armored_9_stat = "armored_9"
            end
            if EHI:IsAchievementLocked2("gage_1") and HasWeaponEquipped("ak5") and mask_id == tweak_data.achievement.enemy_kill_achievements.wanted.mask then -- "Wanted" achievement
                AddAchievementTracker2("gage_1_stats")
            end
            if EHI:IsAchievementLocked2("gage_2") and HasWeaponEquipped("p90") and mask_id == tweak_data.achievement.enemy_kill_achievements.three_thousand_miles.mask then -- "3000 Miles to the Safe House" achievement
                AddAchievementTracker2("gage_2_stats")
            end
            if EHI:IsAchievementLocked2("gage_3") and HasWeaponEquipped("aug") and mask_id == tweak_data.achievement.enemy_kill_achievements.commando.mask then -- "Commando" achievement
                AddAchievementTracker2("gage_3_stats")
            end
            if EHI:IsAchievementLocked2("gage_4") and HasWeaponEquipped("colt_1911") and mask_id == tweak_data.achievement.enemy_kill_achievements.public_enemies.mask then -- "Public Enemies" achievement
                AddAchievementTracker2("gage_4_stats")
            end
            if EHI:IsAchievementLocked2("gage_5") and HasWeaponEquipped("scar") then -- "Inception" achievement
                AddAchievementTracker2("gage_5_stats")
            end
            if EHI:IsAchievementLocked2("gage_6") and HasWeaponEquipped("mp7") then -- "Hard Corps" achievement
                AddAchievementTracker2("gage_6_stats")
            end
            if EHI:IsAchievementLocked2("gage_7") and HasWeaponEquipped("p226") then -- "Above the Law" achievement
                AddAchievementTracker2("gage_7_stats")
            end
            if EHI:IsAchievementLocked2("gage2_5") and HasWeaponTypeEquipped("lmg") then -- "The Eighth and Final Rule" achievement
                AddAchievementTracker("gage2_5", 0, 220)
                EHI:HookWithID(StatisticsManager, "killed", "EHI_gage2_5_killed", function(self, data)
                    if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base().is_category and data.weapon_unit:base():is_category("lmg") and not CopDamage.is_civilian(data.name) then
                        managers.ehi_tracker:IncreaseTrackerProgress("gage2_5")
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gage3_6") and HasWeaponTypeEquipped("snp") then
                if EHI:IsAchievementLocked2("gage3_3") then -- "Lord of the Flies" achievement
                    AddAchievementTracker2("gage3_3_stats")
                end
                if EHI:IsAchievementLocked2("gage3_4") then -- "Arachne's Curse" achievement
                    AddAchievementTracker2("gage3_4_stats")
                end
                if EHI:IsAchievementLocked2("gage3_5") then -- "Pest Control" achievement
                    AddAchievementTracker2("gage3_5_stats")
                end
                AddAchievementTracker2("gage3_6_stats") -- "Seer of Death" achievement
            end
            if EHI:IsAchievementLocked2("gage3_7") and HasWeaponEquipped("m95") then -- "Far, Far Away" achievement
                AddAchievementTracker2("gage3_7_stats")
            end
            if EHI:IsAchievementLocked2("gage3_10") and HasWeaponEquipped("r93") then -- "Maximum Penetration" achievement
                AddAchievementTracker2("gage3_10_stats")
            end
            if EHI:IsAchievementLocked2("gage3_11") and HasWeaponEquipped("m95") then -- "Dodge This" achievement
                local function f()
                    AddAchievementTracker2("gage3_11_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage3_11_stats = "gage3_11"
            end
            if EHI:IsAchievementLocked2("gage3_12") and HasWeaponEquipped("m95") then -- "Surprise Motherfucker" achievement
                local function f()
                    AddAchievementTracker2("gage3_12_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage3_12_stats = "gage3_12"
            end
            if EHI:IsAchievementLocked2("gage3_13") and HasWeaponTypeEquipped("snp") then -- "Didn't See That Coming Did You?" achievement
                for _, unit in ipairs(ZipLine.ziplines) do
                    if unit:zipline():is_usage_type_person() then
                        local progress = EHI:GetAchievementProgress("gage3_13_stats")
                        if gage3_13_levels[level] then
                            EHI:HookWithID(AchievmentManager, "award_progress", "EHI_gage3_13_AwardProgress", function(am, stat, value)
                                if stat == "gage3_13_stats" then
                                    progress = progress + (value or 1)
                                    if progress >= 10 then
                                        EHI:Unhook("gage3_13_AwardProgress")
                                        return
                                    end
                                    ShowPopup("gage3_13", progress, 10)
                                end
                            end)
                        else
                            AddAchievementTracker("gage3_13", progress, 10)
                            stats.gage3_13_stats = "gage3_13"
                        end
                        break
                    end
                end
            end
            if EHI:IsAchievementLocked2("gage3_14") and HasWeaponEquipped("msr") then -- "Return to Sender" achievement
                local function f()
                    AddAchievementTracker2("gage3_14_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage3_14_stats = "gage3_14"
            end
            if EHI:IsAchievementLocked2("gage3_15") and HasWeaponEquipped("r93") then -- "You Can't Hide" achievement
                AddAchievementTracker2("gage3_15_stats")
            end
            if EHI:IsAchievementLocked2("gage3_16") and HasWeaponEquipped("msr") then -- "Double Kill" achievement
                AddAchievementTracker2("gage3_16_stats")
            end
            if EHI:IsAchievementLocked2("gage3_17") and HasWeaponEquipped("msr") then -- "Public Enemy No. 1" achievement
                AddAchievementTracker2("gage3_17_stats")
            end
            if EHI:IsAchievementLocked2("gage4_6") and HasWeaponTypeEquipped("shotgun") and WeaponsContainBlueprint("wpn_fps_upg_a_slug") then -- "Knock, Knock" achievement
                local function f()
                    AddAchievementTracker2("gage4_6_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage4_6_stats = "gage4_6"
            end
            if EHI:IsAchievementLocked2("gage4_8") and HasWeaponTypeEquipped("shotgun") and WeaponsContainBlueprint("wpn_fps_upg_a_piercing") then -- "Clay Pigeon Shooting" achievement
                local function f()
                    AddAchievementTracker2("gage4_8_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage4_8_stats = "gage4_8"
            end
            if EHI:IsAchievementLocked2("gage4_10") and HasWeaponTypeEquipped("shotgun") then -- "Bang for the Buck" achievement
                if WeaponsContainBlueprint("wpn_fps_upg_a_custom") or WeaponsContainBlueprint("wpn_fps_upg_a_custom_free") then
                    local function f()
                        AddAchievementTracker2("gage4_10_stats")
                    end
                    ShowTrackerInLoud(f)
                    stats.gage4_10_stats = "gage4_10"
                end
            end
            if EHI:IsAchievementLocked2("gage5_1") and HasWeaponEquipped("g3") then -- "Precision Aiming" achievement
                local function f()
                    AddAchievementTracker2("gage5_1_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage5_1_stats = "gage5_1"
            end
            if EHI:IsAchievementLocked2("gage5_5") and HasWeaponEquipped("gre_m79") then -- "Artillery Barrage" achievement
                AddAchievementTracker2("gage5_5_stats")
            end
            if EHI:IsAchievementLocked2("gage5_9") and HasWeaponEquipped("galil") then -- "Rabbit Hunting" achievement
                local function f()
                    AddAchievementTracker2("gage5_9_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage5_9_stats = "gage5_9"
            end
            if EHI:IsAchievementLocked2("gage5_10") and HasWeaponEquipped("famas") then -- "Tour de Clarion" achievement
                AddAchievementTracker2("gage5_10_stats")
            end
            if EHI:IsAchievementLocked2("eagle_1") and HasWeaponEquipped("mosin") then -- "Death From Below" achievement
                local function f()
                    AddAchievementTracker2("eagle_1_stats")
                end
                ShowTrackerInLoud(f)
                stats.eagle_1_stats = "eagle_1"
            end
            if EHI:IsAchievementLocked2("ameno_8") then -- "The Collector" achievement
                local needed_weapons = tweak_data.achievement.enemy_kill_achievements.akm4_shootout.weapons
                local primary_pass = table.index_of(needed_weapons, primary.weapon_id) ~= -1
                local secondary_pass = table.index_of(needed_weapons, secondary.weapon_id) ~= -1
                if primary_pass or secondary_pass then
                    AddAchievementTracker2("ameno_08_stats")
                end
            end
            if EHI:IsAchievementLocked2("turtles_1") and HasWeaponEquipped("wa2000") then -- "Names Are for Friends, so I Don't Need One" achievement
                AddAchievementTracker("turtles_1", 0, 11)
                HookKillFunctionNoCivilian("turtles_1", "wa2000")
                EHI:Hook(RaycastWeaponBase, "on_reload", function(self, amount)
                    if self:get_name_id() == "wa2000" then
                        managers.ehi_tracker:SetTrackerProgress("turtles_1", 0)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("turtles_2") and HasWeaponEquipped("polymer") then -- "Swiss Cheese" achievement
                AddAchievementTracker("turtles_2", 0, 100)
                HookKillFunction("turtles_2", "polymer")
            end
            if EHI:IsAchievementLocked2("tango_achieve_2") and HasWeaponEquipped("arbiter") and ArbiterHasStandardAmmo() then -- "Let Them Fly" achievement
                local function f()
                    AddAchievementTracker2("tango_2_stats")
                end
                ShowTrackerInLoud(f)
                stats.tango_2_stats = "tango_achieve_2"
            end
            if EHI:IsAchievementLocked2("grv_2") and HasWeaponEquipped("coal") then -- "Spray Control" achievement
                AddAchievementTracker("grv_2", 0, 32)
                HookKillFunctionNoCivilian("grv_2", "coal")
                EHI:Hook(RaycastWeaponBase, "on_reload", function(self, amount)
                    if self:get_name_id() == "coal" then
                        managers.ehi_tracker:SetTrackerProgress("grv_2", 0)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("grv_3") then -- "Have Nice Day!" achievement
                local weapons_required = tweak_data.achievement.enemy_kill_achievements.grv_3.weapons
                local pass = table.index_of(weapons_required, primary.weapon_id) ~= -1
                local pass2 = table.index_of(weapons_required, secondary.weapon_id) ~= -1
                if pass or pass2 then
                    AddAchievementTracker2("grv_3_stats")
                end
            end
            if EHI:IsAchievementLocked2("cac_2") then -- "Human Sentry Gun" achievement
                local pass, _, _ = CheckWeaponsBlueprint("wpn_fps_upg_bp_lmg_lionbipod")
                if pass then
                    local function f()
                        local enemy_killed_key = "EHI_cac_2_enemy_killed"
                        AddAchievementTracker("cac_2", 0, 20)
                        local function on_enemy_killed(...)
                            managers.ehi_tracker:IncreaseTrackerProgress("cac_2")
                        end
                        local function on_player_state_changed(state_name)
                            managers.ehi_tracker:SetTrackerProgress("cac_2", 0)
                            if state_name == "bipod" then
                                managers.player:register_message(Message.OnEnemyKilled, enemy_killed_key, on_enemy_killed)
                            else
                                managers.player:unregister_message(Message.OnEnemyKilled, enemy_killed_key)
                            end
                        end
                        managers.player:register_message("player_state_changed", "EHI_cac_2_state_changed_key", on_player_state_changed)
                    end
                    ShowTrackerInLoud(f)
                end
            end
            if EHI:IsAchievementLocked2("pxp2_1") and HasWeaponEquipped("hailstorm") and WeaponsContainFiremode("volley") then -- "Field Test" achievement
                AddAchievementTracker2("pxp2_1_stats")
            end
            if EHI:IsAchievementLocked2("pxp2_2") and (HasWeaponEquipped("sko12") or HasWeaponEquipped("x_sko12")) then -- "Heister With A Shotgun" achievement
                AddAchievementTracker2("pxp2_2_stats")
            end
            if VeryHardOrAbove then
                if EHI:IsAchievementLocked2("tango_achieve_3") and managers.ehi_manager:GetStartedFromBeginning() then -- "The Reckoning" achievement
                    local pass, primary_index, secondary_index = CheckWeaponsBlueprint(tweak_data.achievement.complete_heist_achievements.tango_3.killed_by_blueprint.blueprint)
                    if pass then
                        if primary_index and secondary_index then
                            ---@class EHItango_achieve_3Tracker : EHIAchievementProgressTracker
                            ---@field super EHIAchievementProgressTracker
                            EHItango_achieve_3Tracker = class(EHIAchievementProgressTracker)
                            EHItango_achieve_3Tracker._forced_icons = EHI:GetAchievementIcon("tango_achieve_3")
                            function EHItango_achieve_3Tracker:init(panel, params, parent_class)
                                self._kills =
                                {
                                    primary = 0,
                                    secondary = 0
                                }
                                self._weapon_id = 0
                                EHItango_achieve_3Tracker.super.init(self, panel, params, parent_class)
                            end
                            function EHItango_achieve_3Tracker:WeaponSwitched(id)
                                if self._weapon_id == id or self._finished then
                                    return
                                end
                                local previous_weapon_id = self._weapon_id
                                self._weapon_id = id
                                local current_selection = id == 0 and "secondary" or "primary"
                                local previous_selection = previous_weapon_id == 0 and "secondary" or "primary"
                                self._kills[previous_selection] = self._progress
                                self._progress = self._kills[current_selection]
                                self:SetAndFitTheText()
                                self:AnimateBG(1)
                            end
                            function EHItango_achieve_3Tracker:SetCompleted(force)
                                EHItango_achieve_3Tracker.super.SetCompleted(self, force)
                                if self._status == "completed" then
                                    self._finished = true
                                end
                            end
                            managers.ehi_tracker:AddTracker({
                                id = "tango_achieve_3",
                                progress = 0,
                                max = 200,
                                flash_times = 1,
                                show_finish_after_reaching_target = true,
                                class = "EHItango_achieve_3Tracker"
                            })
                            HookKillFunctionNoCivilian("tango_achieve_3", primary.weapon_id)
                            HookKillFunctionNoCivilian("tango_achieve_3", secondary.weapon_id)
                            local function switch()
                                local player = managers.player:local_player()
                                if not player then
                                    return
                                end
                                local weapon = player:inventory():equipped_unit():base():selection_index()
                                if weapon and (weapon == 1 or weapon == 2) then
                                    managers.ehi_tracker:CallFunction("tango_achieve_3", "WeaponSwitched", weapon - 1)
                                end
                            end
                            managers.player:register_message(Message.OnSwitchWeapon, "EHI_tango_achieve_3", switch)
                        else
                            AddAchievementTracker("tango_achieve_3", 0, 200)
                            local weapon_required = primary_index and primary.weapon_id or secondary.weapon_id
                            HookKillFunctionNoCivilian("tango_achieve_3", weapon_required)
                        end
                    end
                end
            end
            if OVKOrAbove then
                if EHI:IsAchievementLocked2("pim_1") and HasWeaponTypeEquipped("snp") then -- "Nothing Personal" achievement
                    local function f()
                        AddAchievementTracker2("pim_1_stats")
                    end
                    ShowTrackerInLoud(f)
                    stats.pim_1_stats = "pim_1"
                end
                pxp_1()
                if level == "man" and EHI:IsAchievementLocked2("man_5") and HasWeaponTypeEquipped("grenade_launcher") and from_beginning then
                    managers.ehi_tracker:AddTracker({
                        id = "man_5",
                        icons = EHI:GetAchievementIcon("man_5"),
                        class = EHI.Trackers.Achievement.Status
                    })
                    local function fail()
                        managers.ehi_achievement:SetAchievementFailed("man_5")
                        EHI:Unhook("man_5_killed")
                        EHI:Unhook("man_5_shot_fired")
                    end
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_man_5_killed", function(sm, data)
                        local is_not_explosion = data.variant ~= "explosion"
                        local name_id, is_throwable = sm:_get_name_id_and_throwable_id(data.weapon_unit)
                        if is_not_explosion or (name_id and not table.contains(sm:_get_boom_guns(), name_id)) or is_throwable then
                            fail()
                        end
                    end)
                    EHI:HookWithID(StatisticsManager, "shot_fired", "EHI_man_5_shot_fired", function(sm, data)
                        local name_id = data.name_id or data.weapon_unit:base():get_name_id()
                        if tweak_data:get_raw_value("weapon", name_id, "categories", 1) ~= "grenade_launcher" then
                            fail()
                        end
                    end)
                end
                if level == "mad" and EHI:IsAchievementLocked2("pim_3") and HasWeaponTypeEquipped("smg") then -- "UMP for Me, UMP for You" achievement
                    AddAchievementTracker2("pim_3_stats")
                end
                if level == "sand" and EHI:IsAchievementLocked2("sand_11") and HasWeaponTypeEquipped("snp") then -- "This Calls for a Round of Sputniks!" achievement
                    managers.ehi_tracker:AddTracker({
                        id = "sand_11",
                        flash_times = 1,
                        class = "EHIsand11Tracker"
                    })
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_sand_11_killed", function(_, data)
                        if data.variant ~= "melee" and data.weapon_unit and data.weapon_unit:base().is_category and data.weapon_unit:base():is_category("snp") then
                            managers.ehi_tracker:IncreaseTrackerProgress("sand_11")
                        end
                    end)
                    EHI:HookWithID(StatisticsManager, "shot_fired", "EHI_sand_11_accuracy", function(sm, _)
                        managers.ehi_tracker:SetChance("sand_11", sm:session_hit_accuracy())
                    end)
                end
            end
            if EHI:IsDifficultyOrAbove(EHI.Difficulties.DeathWish) and EHI:IsAchievementLocked2("gage3_2") and HasWeaponEquipped("akm_gold") then -- "The Man With the Golden Gun" achievement
                local function f()
                    AddAchievementTracker2("gage3_2_stats")
                end
                ShowTrackerInLoud(f)
                stats.gage3_2_stats = "gage3_2"
            end
        end
        if EHI:GetUnlockableOption("show_achievements_melee") then -- Kill with melee
            if EHI:IsAchievementLocked2("halloween_7") and mask_id == tweak_data.achievement.cant_hear_you_scream.mask then -- "No One Can Hear You Scream" achievement
                if is_stealth then
                    AddAchievementTracker2("halloween_7_stats")
                    EHI:AddOnAlarmCallback(function()
                        managers.ehi_tracker:RemoveTracker("halloween_7")
                        stats.halloween_7_stats = nil
                    end)
                end
            end
            if EHI:IsAchievementLocked2("gage5_8") and HasMeleeEquipped("dingdong") then -- "Hammertime" achievement
                AddAchievementTracker2("gage5_8_stats")
            end
            if EHI:IsAchievementLocked2("eagle_2") and HasMeleeEquipped("fairbair") then -- "Special Operations Execution" achievement
                if is_stealth then
                    AddAchievementTracker2("eagle_2_stats")
                    EHI:AddOnAlarmCallback(function()
                        managers.ehi_tracker:RemoveTracker("eagle_2")
                        stats.eagle_2_stats = nil
                    end)
                end
            end
            if EHI:IsAchievementLocked2("steel_2") then -- "Their Armor Is Thick and Their Shields Broad" achievement
                local melee_required = tweak_data.achievement.enemy_melee_hit_achievements.steel_2.melee_weapons
                local pass = table.index_of(melee_required, melee) ~= -1
                if pass then
                    AddAchievementTracker("steel_2", 0, 10)
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_steel_2_killed", function(_, data)
                        if data.variant == "melee" and data.name == "shield" then
                            managers.ehi_tracker:IncreaseTrackerProgress("steel_2")
                        end
                    end)
                end
            end
            if EHI:IsAchievementLocked2("gsu_01") and HasMeleeEquipped("spoon") then -- "For all you legends" achievement
                AddAchievementTracker2("gsu_stat")
            end
            if level == "nightclub" then
                if EHI:IsAchievementLocked2("gage2_3") and HasMeleeEquipped("fists") then -- "The Eighth and Final Rule" achievement
                    local function f()
                        AddAchievementTracker2("gage2_3_stats")
                    end
                    ShowTrackerInLoud(f)
                    stats.gage2_3_stats = "gage2_3"
                end
                if EHI:IsAchievementLocked2("gage4_7") and HasMeleeEquipped("shovel") then -- "Every day I'm Shovelin'" achievement
                    local function f()
                        AddAchievementTracker2("gage4_7_stats")
                    end
                    ShowTrackerInLoud(f)
                    stats.gage4_7_stats = "gage4_7"
                end
            end
            if (level == "mia_1" or level == "mia_2") and EHI:IsAchievementLocked2("pig_3") and HasMeleeEquipped("baseballbat") then -- "Do You Like Hurting Other People?" achievement
                AddAchievementTracker2("pig_3_stats")
            end
            if OVKOrAbove then
                if EHI:IsAchievementLocked2("gage2_9") and HasMeleeTypeEquipped("knife") then -- "I Ain't Got Time to Bleed" achievement
                    local function f()
                        AddAchievementTracker2("gage2_9_stats")
                    end
                    ShowTrackerInLoud(f)
                    stats.gage2_9_stats = "gage2_9"
                end
                if EHI:IsAchievementLocked2("sawp_1") then -- "Buzzbomb" achievement
                    local achievement_data = tweak_data.achievement.enemy_melee_hit_achievements.sawp_1
                    local melee_pass = table.index_of(achievement_data.melee_weapons, melee) ~= -1
                    local player_style_pass = HasPlayerStyleEquipped(achievement_data.player_style.style)
                    local variation_pass = HasSuitVariationEquipped(achievement_data.player_style.variation)
                    if melee_pass and player_style_pass and variation_pass then
                        AddAchievementTracker2("sawp_stat")
                    end
                end
                pxp_1()
                if (level == "rvd1" or level == "rvd2") and EHI:IsAchievementLocked2("rvd_12") and HasMeleeEquipped("clean") then -- "Close Shave" achievement
                    AddAchievementTracker2("rvd_12_stats")
                end
                if level == "bph" and EHI:IsAchievementLocked2("bph_9") and HasMeleeEquipped("toothbrush") then -- "Prison Rules, Bitch!" achievement
                    AddAchievementTracker2("bph_9_stat")
                end
            end
        end
        if EHI:GetUnlockableOption("show_achievements_grenade") then -- Kill with grenades
            if EHI:IsAchievementLocked2("gage_9") then -- "Fire in the Hole!" achievement
                local eligible_grenades = tweak_data.achievement.fire_in_the_hole.grenade
                for _, eligible_grenade in ipairs(eligible_grenades) do
                    if grenade == eligible_grenade then
                        local progress = EHI:GetAchievementProgress("gage_9_stats")
                        HookAwardAchievement("gage_9", function(am, stat, value)
                            if stat == "gage_9_stats" then
                                progress = progress + (value or 1)
                                if progress >= 100 then
                                    EHI:Unhook("gage_9_achievement")
                                    return
                                end
                                ShowPopup("gage_9", progress, 100)
                            end
                        end)
                        ShowPopup("gage_9", progress, 100)
                        break
                    end
                end
            end
            if EHI:IsAchievementLocked2("dec21_02") and HasNonExplosiveGrenadeEquipped() then -- "Gift Giver" achievement
                AddAchievementTracker2("dec21_02_stat")
            end
            if level == "dark" and EHI:IsAchievementLocked2("pim_2") then -- Crouched and Hidden, Flying Dagger
                local progress = EHI:GetAchievementProgress("pim_2_stats")
                AddAchievementTracker("pim_2", progress, 8, false, true, true)
                EHI:Hook(AchievmentManager, "add_heist_success_award_progress", function(am, id)
                    if id == "pim_2_stats" then
                        progress = progress + 1
                        managers.ehi_tracker:SetTrackerProgress("pim_2", progress)
                    end
                end)
                EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                    if success and progress < 8 then
                        managers.hud:custom_ingame_popup_text("SAVED", "Progress Saved: " .. tostring(progress) .. "/8", "C_Jimmy_H_MurkyStation_CrouchedandHidden")
                    elseif not success then
                        managers.hud:custom_ingame_popup_text("LOST", "Progress Lost: " .. tostring(progress) .. "/8", "C_Jimmy_H_MurkyStation_CrouchedandHidden")
                    end
                end)
            end
            if OVKOrAbove then
                pxp_1()
                if EHI:IsAchievementLocked2("pxp2_3") and HasGrenadeEquipped("poison_gas_grenade") then -- "Snake Charmer" achievement
                    AddAchievementTracker2("pxp2_3_stats")
                end
            end
        end
        if EHI:GetUnlockableOption("show_achievements_other") then
            if EHI:IsAchievementLocked2("halloween_4") and mask_id == tweak_data.achievement.witch_doctor.mask then -- "Witch Doctor" achievement
                AddAchievementTracker2("halloween_4_stats")
            end
            if EHI:IsAchievementLocked2("halloween_5") and mask_id == tweak_data.achievement.its_alive_its_alive.mask then -- "It's Alive! IT'S ALIVE!" achievement
                local function f()
                    AddAchievementTracker2("halloween_5_stats")
                end
                ShowTrackerInLoud(f)
                stats.halloween_5_stats = "halloween_5"
            end
            if EHI:IsAchievementLocked2("armored_8") and mask_id == tweak_data.achievement.relation_with_bulldozer.mask then -- "I Did Not Have Sexual Relations With That Bulldozer" achievement
                local function f()
                    AddAchievementTracker2("armored_8_stat")
                end
                ShowTrackerInLoud(f)
                stats.armored_8_stat = "armored_8"
            end
            if EHI:IsAchievementLocked2("armored_10") and mask_id == tweak_data.achievement.no_we_cant.mask then -- "Affordable Healthcare" achievement
                local progress = EHI:GetAchievementProgress("armored_10_stat")
                ShowTrackerInLoud(function()
                    ShowPopup("armored_10", progress, 61)
                end)
                HookAwardAchievement("armored_10", function(am, stat, value)
                    if stat == "armored_10_stat" and progress < 61 then
                        progress = progress + (value or 1)
                        ShowPopup("armored_10", progress, 61)
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_1") then -- "Praying Mantis" achievement
                local progress = EHI:GetAchievementProgress("gmod_1_stats")
                HookAwardAchievement("gmod_1", function(am, stat, value)
                    if stat == "gmod_1_stats" then
                        progress = progress + value
                        if progress < 5 then
                            ShowPopup("gmod_1", progress, 5)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_2") then -- "Bullseye" achievement
                local progress = EHI:GetAchievementProgress("gmod_2_stats")
                HookAwardAchievement("gmod_2", function(am, stat, value)
                    if stat == "gmod_2_stats" then
                        progress = progress + value
                        if progress < 10 then
                            ShowPopup("gmod_2", progress, 10)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_3") then -- "My Spider Sense is Tingling" achievement
                local progress = EHI:GetAchievementProgress("gmod_3_stats")
                HookAwardAchievement("gmod_3", function(am, stat, value)
                    if stat == "gmod_3_stats" then
                        progress = progress + value
                        if progress < 15 then
                            ShowPopup("gmod_3", progress, 15)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_4") then -- "Eagle Eyes" achievement
                local progress = EHI:GetAchievementProgress("gmod_4_stats")
                HookAwardAchievement("gmod_4", function(am, stat, value)
                    if stat == "gmod_4_stats" then
                        progress = progress + value
                        if progress < 20 then
                            ShowPopup("gmod_4", progress, 20)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_5") then -- "Like A Boy Killing Snakes" achievement
                local progress = EHI:GetAchievementProgress("gmod_5_stats")
                HookAwardAchievement("gmod_5", function(am, stat, value)
                    if stat == "gmod_5_stats" then
                        progress = progress + value
                        if progress < 25 then
                            ShowPopup("gmod_5", progress, 25)
                        end
                    end
                end)
            end
            if EHI:IsAchievementLocked2("gmod_6") then -- "There and Back Again" achievement
                EHI:HookWithID(GageAssignmentManager, "_give_rewards", "EHI_gmod_6_achievement", function(gam, assignment, ...)
                    local progress = 0
                    for i, dvalue in pairs(gam._global.completed_assignments) do
                        if Application:digest_value(dvalue, false) >= tweak_data.achievement.gonna_find_them_all then
                            progress = progress + 1
                        end
                    end
                    if progress < 5 then
                        ShowPopup("gmod_6", progress, 5)
                    end
                end)
            end
            if EHI:IsAchievementLocked("ovk_3") and HasWeaponEquipped("m134") and (level == "chill" or level == "safehouse") then -- "Oh, That's How You Do It" achievement
                -- Only tracked in Safehouse to prevent tracker spam in heists
                ---@class EHIovk3Tracker : EHIAchievementUnlockTracker
                ---@field super EHIAchievementUnlockTracker
                EHIovk3Tracker = class(EHIAchievementUnlockTracker)
                EHIovk3Tracker._forced_icons = EHI:GetAchievementIcon("ovk_3")
                function EHIovk3Tracker:Reset()
                    self:SetTime(25)
                    self._fade_time = 5
                    self:StopAndSetTextColor(Color.white)
                    self.update = EHIovk3Tracker.super.update
                end
                EHI:HookWithID(RaycastWeaponBase, "start_shooting", "EHI_ovk_3_start_shooting", function(self, ...)
                    if self._shooting and self:get_name_id() == "m134" then
                        if managers.ehi_tracker:CallFunction2("ovk_3", "Reset") then
                            managers.ehi_tracker:AddTracker({
                                id = "ovk_3",
                                time = 25,
                                status_is_overridable = false,
                                class = "EHIovk3Tracker"
                            })
                        end
                    end
                end)
                EHI:HookWithID(RaycastWeaponBase, "stop_shooting", "EHI_ovk_3_stop_shooting", function(...)
                    managers.ehi_achievement:SetAchievementFailed("ovk_3")
                end)
                EHI:HookWithID(AchievmentManager, "award", "EHI_ovk_3_award", function(self, id)
                    if id == "ovk_3" then
                        EHI:Unhook("ovk_3_start_shooting")
                        EHI:Unhook("ovk_3_stop_shooting")
                        EHI:Unhook("ovk_3_award")
                    end
                end)
            end
            if EHI:IsAchievementLocked2("cac_3") then -- "Denied" achievement
                local listener_key = "EHI_cac_3_listener"
                local progress = EHI:GetAchievementProgress("cac_3_stats")
                local function on_flash_grenade_destroyed(attacker_unit)
                    local local_player = managers.player:player_unit()
                    if local_player and attacker_unit == local_player then
                        progress = progress + 1
                        if progress < 30 then
                            ShowPopup("cac_3", progress, 30)
                        else
                            managers.player:unregister_message("flash_grenade_destroyed", listener_key)
                        end
                    end
                end
                managers.player:register_message("flash_grenade_destroyed", listener_key, on_flash_grenade_destroyed)
                ShowTrackerInLoud(function() -- Show progress when alarm went off
                    ShowPopup("cac_3", progress, 30)
                end)
            end
            if EHI:IsAchievementLocked2("cac_34") then -- "Lieutenant Colonel" achievement
                local listener_key = "EHI_cac_34_listener_key"
                local progress = EHI:GetAchievementProgress("cac_34_stats")
                local function on_cop_converted(converted_unit, converting_unit)
                    if not alive(converting_unit) then
                        return
                    end
                    progress = progress + 1
                    if progress >= 300 then
                        managers.player:unregister_message("cop_converted", listener_key)
                        return
                    end
                    ShowPopup("cac_34", progress, 300)
                end
                managers.player:register_message("cop_converted", listener_key, on_cop_converted)
                ShowPopup("cac_34", progress, 300)
            end
            if eng_1_levels[level] then
                if EHI:IsAchievementLocked2("eng_1") then -- "The only one that is true" achievement
                    local progress = EHI:GetAchievementProgress("eng_1_stats") + 1
                    HookAwardAchievement("eng_1",  function(am, stat, value)
                        if stat == "eng_1_stats" and progress < 5 then
                            ShowPopup("eng_1", progress, 5)
                        end
                    end)
                end
            end
            if level == "kosugi" or level == "red2" then
                if EHI:IsAchievementLocked2("eng_2") then -- "The one that had many names" achievement
                    local progress = EHI:GetAchievementProgress("eng_2_stats") + 1
                    HookAwardAchievement("eng_2",  function(am, stat, value)
                        if stat == "eng_2_stats" and progress < 5 then
                            ShowPopup("eng_2", progress, 5)
                        end
                    end)
                end
            end
            if level == "roberts" or level == "four_stores" then
                if EHI:IsAchievementLocked2("eng_3") then -- "The one that survived" achievement
                    local progress = EHI:GetAchievementProgress("eng_3_stats") + 1
                    HookAwardAchievement("eng_3", function(am, stat, value)
                        if stat == "eng_3_stats" and progress < 5 then
                            ShowPopup("eng_3", progress, 5)
                        end
                    end)
                end
            end
            if level == "family" or level == "hox_1" then
                if EHI:IsAchievementLocked2("eng_4") then -- "The one who declared himself the hero" achievement
                    local progress = EHI:GetAchievementProgress("eng_4_stats") + 1
                    HookAwardAchievement("eng_4", function(am, stat, value)
                        if stat == "eng_4_stats" and progress < 5 then
                            ShowPopup("eng_4", progress, 5)
                        end
                    end)
                end
            end
            if EHI:IsAchievementLocked2("xm20_1") and xm20_1_levels[level] then
                OnSetSavedJobValue("xm20_1", { present_mex = true, present_bex = true, present_pex = true, present_fex = true })
            end
            if EHI:IsAchievementLocked2("pent_11") and pent_11_levels[level] then
                OnSetSavedJobValue("pent_11", { tea_chas = true, tea_sand = true, tea_chca = true, tea_pent = true })
            end
            if VeryHardOrAbove then
                if level == "help" and EHI:IsAchievementLocked2("tawp_1") and mask_id == tweak_data.achievement.complete_heist_achievements.tawp_1.mask then -- "Cloaker Charmer" achievement
                    AddAchievementTracker("tawp_1", 0, 1, false, true)
                    EHI:HookWithID(StatisticsManager, "killed", "EHI_tawp_1_killed", function (self, data)
                        if data.name == "spooc" then
                            managers.ehi_tracker:IncreaseTrackerProgress("tawp_1")
                        end
                    end)
                end
            end
            if OVKOrAbove then
                if armored_4_levels[level] and EHI:IsAchievementLocked2("armored_4") and mask_id == tweak_data.achievement.complete_heist_achievements.i_take_scores.mask and from_beginning then -- I Do What I Do Best, I Take Scores
                    local progress = EHI:GetAchievementProgress("armored_4_stat")
                    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                        if success and progress < 15 and managers.job:on_last_stage() then
                            ShowPopup("armored_4", progress + 1, 15)
                        end
                    end)
                end
                if EHI:IsAchievementLocked2("halloween_10") and managers.job:current_contact_id() == "vlad" and mask_id == tweak_data.achievement.complete_heist_achievements.in_soviet_russia.mask and from_beginning then -- From Russia With Love
                    local progress = EHI:GetAchievementProgress("halloween_10_stats")
                    EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                        if success and progress < 25 and managers.job:on_last_stage() then
                            ShowPopup("halloween_10", progress + 1, 25)
                        end
                    end)
                end
            end
        end
        --[[if EHI:IsAchievementLocked2("gage4_3") then -- "Swing Dancing" achievement
            AddAchievementTracker("gage4_3", 0, 50)
            EHI:HookWithID(StatisticsManager, "killed", "EHI_gage4_3_killed", function (self, data)
                if data.variant == "melee" then
                    if not CopDamage.is_civilian(data.name) then
                        managers.ehi_tracker:IncreaseTrackerProgress("gage4_3")
                    end
                else
                    managers.ehi_achievement:SetAchievementFailed("gage4_3")
                    EHI:Unhook("gage4_3_killed")
                end
            end)
        end]]
    end
    if EHI:GetUnlockableAndOption("show_dailies") then
        local active_sh_daily = EHI:GetActiveSHDaily() ---@cast active_sh_daily -?
        local sh_daily = active_sh_daily and sh_dailies and sh_dailies[active_sh_daily]
        if sh_daily then
            local all_pass = true
            if sh_daily.check then
                if sh_daily.check.melee and not HasMeleeEquipped(sh_daily.check.melee) then
                    all_pass = false
                elseif sh_daily.check.grenades and not table.contains(sh_daily.check.grenades, grenade) then
                    all_pass = false
                end
            end
            if all_pass then
                local icon = sh_daily.achievement_icon and EHI:GetAchievementIconString(sh_daily.achievement_icon) or sh_daily.icon
                if sh_daily.track then
                    AddDailySHChallengeTracker(active_sh_daily, nil, icon)
                    EHI:HookWithID(CustomSafehouseManager, "award", string.format("EHI_%s_AwardProgress", active_sh_daily), function(csm, id)
                        if id == active_sh_daily then
                            managers.ehi_tracker:IncreaseTrackerProgress(active_sh_daily)
                        end
                    end)
                elseif sh_daily.hook_secured then
                    local data
                    if sh_daily.first_entry then
                        data = tweak_data.achievement.loot_cash_achievements[active_sh_daily].secured[1]
                    else
                        data = tweak_data.achievement.loot_cash_achievements[active_sh_daily].secured
                    end
                    HookSecuredChallenge(active_sh_daily, data, icon)
                elseif sh_daily.hook_end then
                    HookMissionEndSHDailyProgress(active_sh_daily, icon)
                end
            end
        end
        if managers.challenge:can_progress_challenges() and challenges then
            local tracked_challenges = {}
            local active_challenges = managers.challenge:get_all_active_challenges()
            for _, challenge in pairs(active_challenges) do
                local c = challenges[challenge.id or ""]
                if c and not challenge.completed then
                    local all_pass = true
                    if c.check then
                        if c.check.weapon_type and not HasWeaponTypeEquipped(c.check.weapon_type) then
                            all_pass = false
                        elseif c.check.enemy_check and not tweak_data.group_ai:IsSpecialEnemyAllowedToSpawn(c.check.enemy_check) then
                            all_pass = false
                        end
                    end
                    if all_pass then
                        if c.icon then
                            local icon = tweak_data.hud_icons[c.icon] or tweak_data.ehi.icons[c.icon]
                            tweak_data.ehi.icons[challenge.id] = icon
                            tweak_data.hud_icons[challenge.id] = icon
                        end
                        if c.check_on_completion then
                            if not c.contact or managers.job:current_contact_id() == c.contact then
                                ---@param success boolean
                                EHI:AddCallback(EHI.CallbackMessage.MissionEnd, function(success)
                                    if success and managers.job:on_last_stage() and managers.statistics:started_session_from_beginning() then
                                        local progress, max = EHI:GetDailyChallengeProgressAndMax(challenge.id, c.progress_id)
                                        if progress + 1 < max then
                                            managers.hud:custom_ingame_popup_text(managers.localization:to_upper_text("menu_challenge_" .. challenge.id), tostring(progress) .. "/" .. tostring(max), c.icon)
                                        end
                                    end
                                end)
                            end
                        elseif c.loud_only then
                            ShowTrackerInLoud(function()
                                AddDailyChallengeTracker(challenge.id, c.progress_id, c.icon)
                            end)
                        else
                            AddDailyChallengeTracker(challenge.id, c.progress_id, c.icon)
                        end
                        if not c.do_not_track then
                            tracked_challenges[c.progress_id] = challenge.id
                        end
                    end
                end
            end
            if next(tracked_challenges) then
                EHI:HookWithID(ChallengeManager, "award_progress", "EHI_DailyChallenge_AwardProgress", function(c, progress_id, amount)
                    local challenge = tracked_challenges[progress_id]
                    if challenge then
                        managers.ehi_tracker:IncreaseTrackerProgress(challenge, amount)
                    end
                end)
            end
        end
    end
    challenges = nil
    sh_dailies = nil
    if next(stats) then
        HookAwardAchievement("IngameWaitingForPlayers", function(am, stat, value)
            local achievement = stats[stat]
            if achievement then
                managers.ehi_tracker:IncreaseTrackerProgress(achievement, value)
            end
        end)
    end
end