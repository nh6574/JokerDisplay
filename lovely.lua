if not SMODS then
    JokerDisplay = {}

    -- Copied from cg-223/Joker-Loadouts <3
    local fs = love.filesystem
    local function JokerDisplay_find_self()
        local start_dir = "Mods"
        local files = fs.getDirectoryItems(start_dir)
        for _, file in ipairs(files) do
            if fs.getInfo(start_dir .. "/" .. file .. "/" .. "JokerDisplay.json") then
                return start_dir .. "/" .. file .. "/"
            end
        end
    end

    JokerDisplay.path = JokerDisplay_find_self()

    JokerDisplay.load_file = function(path)
        return load(fs.read(JokerDisplay.path .. path))
    end
    JokerDisplay.config = JokerDisplay.load_file("config.lua")()
    JokerDisplay.load_file("src/utils.lua")()
    JokerDisplay.load_file("src/ui.lua")()
    JokerDisplay.load_file("src/display_functions.lua")()
    JokerDisplay.load_file("src/api_helper_functions.lua")()
    JokerDisplay.load_file("src/controller.lua")()
    JokerDisplay.load_file("src/config_tab.lua")()

    local jokerdisplay_game_main_menu_ref = Game.main_menu
    function Game:main_menu(change_context)
        if not JokerDisplay.Global_Definitions then
            JokerDisplay.Global_Definitions = JokerDisplay.load_file("definitions/global_definitions.lua")() or {}
            JokerDisplay.Definitions = JokerDisplay.load_file("definitions/display_definitions.lua")() or {}
            JokerDisplay.Blind_Definitions = JokerDisplay.load_file("definitions/blind_definitions.lua")() or {}
            JokerDisplay.Edition_Definitions = JokerDisplay.load_file("definitions/edition_definitions.lua")() or {}
        end

        return jokerdisplay_game_main_menu_ref(self, change_context)
    end

    -- Copied from SleepyG11/HandyBalatro <3
    local jokerdisplay_init_localization_ref = init_localization
    function init_localization(...)
        local en_loc = JokerDisplay.load_file("localization/en-us.lua")()

        local function table_merge(target, source, ...)
            local tables_to_merge = { source, ... }
            if #tables_to_merge == 0 then
                return target
            end

            for i = 1, #tables_to_merge do
                local from = tables_to_merge[i]
                for k, v in pairs(from) do
                    if type(v) == "table" then
                        target[k] = target[k] or {}
                        target[k] = table_merge(target[k], v)
                    else
                        target[k] = v
                    end
                end
            end

            return target
        end
        table_merge(G.localization, en_loc)

        if G.SETTINGS.language ~= "en-us" then
            local success, current_loc = pcall(function()
                return JokerDisplay.load_file("localization/" .. G.SETTINGS.language .. ".lua")()
            end)
            if success and current_loc then
                table_merge(G.localization, current_loc)
            end
        end

        return jokerdisplay_init_localization_ref(...)
    end
end
