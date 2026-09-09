JokerDisplay = {}
JokerDisplay.path = SMODS.current_mod.path
JokerDisplay.config = SMODS.current_mod.config

SMODS.load_file("src/utils.lua")()
SMODS.load_file("src/ui.lua")()
SMODS.load_file("src/display_functions.lua")()
SMODS.load_file("src/api_helper_functions.lua")()
SMODS.load_file("src/controller.lua")()
SMODS.load_file("src/config_tab.lua")()

JokerDisplay.Global_Definitions = SMODS.load_file("definitions/global_definitions.lua")() or {}
JokerDisplay.Definitions = SMODS.load_file("definitions/display_definitions.lua")() or {}
JokerDisplay.Blind_Definitions = SMODS.load_file("definitions/blind_definitions.lua")() or {}
JokerDisplay.Edition_Definitions = SMODS.load_file("definitions/edition_definitions.lua")() or {}
JokerDisplay.mod_keys = { "chips", "x_chips", "mult", "x_mult",
    "e_mult", "e_chips", "score", "xscore", "blindsize", "xblindsize", "dollars", "xdollars", "edollars" }
JokerDisplay.Modifier_Definitions = SMODS.load_file("definitions/modifier_definitions.lua")() or {}

SMODS.current_mod.custom_ui = function(modNodes)
    return JokerDisplay.custom_menu_ui(modNodes)
end
