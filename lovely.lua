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
end
