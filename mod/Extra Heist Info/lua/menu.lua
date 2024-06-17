local EHI = EHI
if EHI:CheckHook("MenuManager") then
    return
end

local Languages =
{
    [2] = "english",
    [3] = "czech",
    [4] = "french",
    [5] = "italian",
    [6] = "russian",
    [7] = "thai",
    [8] = "schinese",
    [9] = "portuguese", -- Brazil
    [10] = "spanish",
    [11] = "japanese"
}
local LocLoaded = false

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_EHI", function(loc)
    if LocLoaded then
        return
    end
    local language_filename = nil
    local lang = EHI:GetOption("mod_language")
    if lang == 1 then -- Autodetect
        local LanguageKey =
        {
            ["PAYDAY 2 THAI LANGUAGE Mod"] = "thai",
            --["Ultimate Localization Manager & 正體中文化"] = "tchinese",
            --["Payday 2 Korean patch"] = "korean"
        }
        for _, mod in ipairs(BLT and BLT.Mods and BLT.Mods:Mods() or {}) do
            language_filename = mod:IsEnabled() and LanguageKey[mod:GetName()]
            if language_filename then
                break
            end
        end
        if not language_filename then
            for _, filename in ipairs(file.GetFiles(EHI.LocPath)) do
                local str = filename:match('^(.*).json$')
                if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
                    language_filename = str
                    break
                end
            end
        end
        if language_filename then
            loc:load_localization_file(EHI.ModPath .. "loc/" .. language_filename .. ".json")
        end
    else
        loc:load_localization_file(EHI.ModPath .. "loc/" .. Languages[lang] .. ".json")
    end
    if lang ~= 2 or not language_filename then
        loc:load_localization_file(EHI.ModPath .. "loc/english.json", false)
    end
    loc:load_localization_file(EHI.ModPath .. "loc/languages.json")
    EHI:CallCallbackOnce(EHI.CallbackMessage.LocLoaded, loc, Languages[lang] or language_filename or "english")
    LocLoaded = true
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_EHI", function(menu_manager, nodes)
    MenuCallbackHandler.OpenEHIModOptions = function(self, item)
        EHI.Menu = EHI.Menu or EHIMenu:new()
        EHI.Menu:Open()

        -- Add Hook when menu is created
        if not EHI.MenuHooks then
            Hooks:PostHook(MenuManager, "update", "update_menu_EHI", function(self, t, dt)
                if EHI.Menu and EHI.Menu.update and EHI.Menu._enabled then
                    EHI.Menu:update(t, dt)
                end
            end)
            Hooks:PostHook(MenuManager, "destroy", "destroy_menu_EHI", function(...)
                if EHI.Menu then
                    EHI.Menu:destroy()
                    EHI.Menu = nil
                end
            end)
            EHI.MenuHooks = true
        end
    end

    local node = nodes["blt_options"]

    local item_params = {
        name = "EHI_OpenMenu",
        text_id = "ehi_mod_title",
        help_id = "ehi_mod_desc",
        callback = "OpenEHIModOptions",
        localize = true,
    }
    local item = node:create_item({type = "CoreMenuItem.Item"}, item_params)
    node:add_item(item)
end)

local function CacheRank(self, ...)
    self.__ehi_rank = managers.experience:current_rank()
end
local function IncreaseRank(self, ...)
    local xp = managers.experience
    local current_rank = xp:current_rank()
    if self.__ehi_rank ~= current_rank then
        managers.ehi_experience:ExperienceReload(xp)
    end
    self.__ehi_rank = nil
end
EHI:PreHookAndHookWithID(MenuCallbackHandler, "_increase_infamous", "EHI_MenuCallbackHandler_increase_infamous", CacheRank, IncreaseRank)
EHI:PreHookAndHookWithID(MenuCallbackHandler, "_increase_infamous_with_prestige", "EHI_MenuCallbackHandler_increase_infamous_with_prestige", CacheRank, IncreaseRank)