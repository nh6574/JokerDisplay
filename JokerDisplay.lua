SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 32,
    py = 32
})

JokerDisplay = {}
JokerDisplay.path = SMODS.current_mod.path
JokerDisplay.config = SMODS.current_mod.config
JokerDisplay.current_hand = {}
JokerDisplay.current_hand_info = {
    text = "Unknown",
    poker_hands = {},
    scoring_hand = {}
}

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
