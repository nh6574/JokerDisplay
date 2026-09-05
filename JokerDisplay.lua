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

error(
    "\n\n --------------------------------------\nHi! Sorry for making the game crash but it appears that you have downloaded/cloned JokerDisplay from the main branch.\n\nIf you are not a developer or someone that knows what they're doing, I would recommend getting the mod from the latest GitHub release or from Thunderstore using the website, r2modman, Gale or frostice's in-game mod manager (this last one is my recommendation)\nIf you intended to clone from main I would encourage you to use the new stable branch instead.\n\nThe reason for the crash is because I'm tired of the Balatro Mod Manager providing the mod against my wishes despite my continued insistence. BMM is a vibecoded, poorly made manager that has caused more headaches for me and my fellow devs than it is worth. If you have installed the mod through BMM I would encourage you to switch to one of the above methods instead.\n\nSorry again\n\n --------------------------------------")
