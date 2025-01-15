--- STEAMODDED HEADER
--- MOD_NAME: JokerDisplay
--- MOD_ID: JokerDisplay
--- PREFIX: JokerDisplay
--- MOD_AUTHOR: [nh6574]
--- MOD_DESCRIPTION: Display useful information under Jokers. Right-click on a Joker/Display to hide/show. Left-click on a Display to collapse/expand.
--- PRIORITY: -100000
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0812d]
--- VERSION: 1.7.4

----------------------------------------------
------------MOD CODE -------------------------

---MOD INITIALIZATION

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

----------------------------------------------
------------MOD CODE END----------------------
