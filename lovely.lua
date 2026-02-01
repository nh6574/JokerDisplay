if not SMODS then
    JokerDisplay = {}

    -- pls copy lovely loading from someone more competent than me
    -- Copied from SMODS
    local fs = require "JokerDisplay.nativefs"
    local lovely = require "lovely"

    local lovely_mod_dir = lovely.mod_dir:gsub("/$", "")
    fs.setWorkingDirectory(lovely_mod_dir)
    lovely_mod_dir = fs.getWorkingDirectory()
    fs.setWorkingDirectory(love.filesystem.getSaveDirectory())

    local mod_path = false -- patched in

    JokerDisplay.path = assert(mod_path, "JokerDisplay could not find itself"):gsub("\\", "/")
    if JokerDisplay.path:lower():match("%.zip$") then
        local mount_name = "JokerDisplay.mnt"
        local res = fs.mount(JokerDisplay.path, mount_name)
        assert(res, "JokerDisplay could not load as a zip")
        local items = love.filesystem.getDirectoryItems(mount_name)
        if #items == 1 then
            local item = items[1]
            local info = love.filesystem.getInfo(mount_name .. "/" .. item)
            if info.type == "directory" then
                mount_name = mount_name .. "/" .. item
            end
        end
        JokerDisplay.path = mount_name
        fs = love.filesystem -- nfs doesnt load the mounts and i dont care to figure out why
    end
    JokerDisplay.path = JokerDisplay.path .. "/"

    JokerDisplay.load_file = function(path, target)
        local full_path = JokerDisplay.path .. path
        local file = fs.read(full_path)

        assert(file, "JokerDisplay: Failed to read " .. full_path)
        return load(file,
            ('=[SMODS JokerDisplay "%s"]'):format(target or string.match(path, '[^/]+/[^/]+$')))
    end

    local function load_mod_config()
        local s1, config = pcall(function()
            return load(fs.read('config/JokerDisplay.jkr'), '=[SMODS JokerDisplay "config"]')()
        end)
        local s2, default_config = pcall(function()
            return JokerDisplay.load_file('config.lua', "default_config")()
        end)
        if not s1 or type(config) ~= 'table' then config = {} end
        if not s2 or type(default_config) ~= 'table' then default_config = {} end
        JokerDisplay.config = default_config

        local function insert_saved_config(savedCfg, defaultCfg)
            for savedKey, savedVal in pairs(savedCfg) do
                local savedValType = type(savedVal)
                local defaultValType = type(defaultCfg[savedKey])
                if not defaultCfg[savedKey] then
                    defaultCfg[savedKey] = savedVal
                elseif savedValType ~= defaultValType then
                elseif savedValType == "table" and defaultValType == "table" then
                    insert_saved_config(savedVal, defaultCfg[savedKey])
                elseif savedVal ~= defaultCfg[savedKey] then
                    defaultCfg[savedKey] = savedVal
                end
            end
        end

        insert_saved_config(config, JokerDisplay.config)

        return JokerDisplay.config
    end

    load_mod_config()
    local function serialize(t, indent)
        local function serialize_string(s)
            return string.format("%q", s)
        end
        indent = indent or ''
        local str = '{\n'
        for k, v in ipairs(t) do
            str = str .. indent .. '\t'
            if type(v) == 'number' then
                str = str .. v
            elseif type(v) == 'boolean' then
                str = str .. (v and 'true' or 'false')
            elseif type(v) == 'string' then
                str = str .. serialize_string(v)
            elseif type(v) == 'table' then
                str = str .. serialize(v, indent .. '\t')
            else
                -- not serializable
                str = str .. 'nil'
            end
            str = str .. ',\n'
        end
        for k, v in pairs(t) do
            if type(k) == 'string' then
                str = str .. indent .. '\t' .. '[' .. serialize_string(k) .. '] = '

                if type(v) == 'number' then
                    str = str .. v
                elseif type(v) == 'boolean' then
                    str = str .. (v and 'true' or 'false')
                elseif type(v) == 'string' then
                    str = str .. serialize_string(v)
                elseif type(v) == 'table' then
                    str = str .. serialize(v, indent .. '\t')
                else
                    -- not serializable
                    str = str .. 'nil'
                end
                str = str .. ',\n'
            end
        end
        str = str .. indent .. '}'
        return str
    end

    function JokerDisplay.save_config()
        local success = pcall(function()
            fs.createDirectory('config')
            local serialized = 'return ' .. serialize(JokerDisplay.config)
            fs.write(('config/JokerDisplay.jkr'), serialized)
        end)
        return success
    end

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

        JokerDisplay.init_loc = true

        return jokerdisplay_init_localization_ref(...)
    end
end
