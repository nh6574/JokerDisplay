---@meta

---@class JDModifiers
---@field chips? number
---@field x_chips? number
---@field xchips? number
---@field mult? number
---@field x_mult? number
---@field xmult? number
---@field dollars? number
---@field e_mult? number
---@field emult? number

---@class JokerDisplay
---@field evaluate_hand? fun(cards:Card[]|table[]?, count_facedowns:boolean?):string,table<string, Card[]|table[]>,Card[]|table[] Returns scoring information about a set of cards. You can get the full hand using `JokerDisplay.current_hand`.
---@field current_hand? table<string, Card[]|table[]> Full hand selected or played
---@field calculate_blueprint_copy? fun(card:Card|table, _cycle_count:integer?, _cycle_debuff:boolean?):Card|table?,boolean Returns what Joker the current Blueprint-like card is copying.
---@field copy_display? fun(card:Card|table,copied_joker:Card|table?,is_debuffed:boolean?,bypass_debuff:boolean?,stop_func_copy:boolean?) Copies an in-play Joker's display
---@field find_joker_or_copy? fun(key:string,count_debuffed:boolean?):Card[]|table[] Returns all held instances of certain Joker, including Blueprint copies.
---@field sort_cards? fun(cards:Card[]|table[]):Card[]|table[] Sorts a table of cards based on their screen position from left to right
---@field calculate_leftmost_card? fun(cards:Card[]|table[]):Card|table? Returns leftmost card base on their screen position
---@field calculate_rightmost_card? fun(cards:Card[]|table[]):Card|table? Returns rightmost card base on their screen position
---@field calculate_card_triggers? fun(card:Card|table, scoring_hand:Card[]|table[]?, held_in_hand:boolean?):integer Returns how many times the scoring card would be triggered for scoring if played. 0 if debuffed.
---@field calculate_joker_modifiers? fun(card:Card|table):table|JDModifiers Returns what modifiers the other Jokers in play add to the this Joker card.
---@field triggers_blind? fun(blind:Blind|table, text:string, poker_hands:table<string, Card[]|table[]>, scoring_hand:Card[]|table[], full_hand:Card[]|table[]):boolean? Returns if hand triggers (boss) blind. `true` if it triggers the blind, `false` otherwise. `nil` if unknown (blind is not defined).
---@field calculate_joker_triggers? fun(card:Card|table):integer Returns how many times the Joker would be triggered if activated. 0 if debuffed.

---@class JDTextObject
---@field text? string Text to display
---@field colour? table HEX color of the text.
---@field scale? number Scale of the text
---@field ref_table? string Reference table to get text from, written in string form. `card` always refers to the current card
---@field ref_value? string Field in ref_table to get text from
---@field retrigger_type? 'add'|'+'|'mult'|'multiply'|'*'|'exp'|'exponentiate'|'^'|fun(base_number:integer,triggers:integer):integer If your Joker's numerical ref_value can retrigger multiple times, you can add retrigger_type to specify how that value interacts with retriggering. "add" or "+": Add the extra triggers to the base number. "mult", "multiply" or "*": Multiplies the base number by the number of total triggers. Use this for mult, chips, dollars or counters. "exp", "exponentiate" or "^": Exponentiates the base number by the number of total triggers. Use this for Xmult or Xchips. Or specify your own function (for emult, for example)
---@field dynatext? table Specify dynatext object
---@field border_nodes? JDTextObject[] Xmult-style border
---@field border_colour? table HEX color of the border_nodes.

---@class JDTextObjectConfig
---@field colour? table HEX color of the text.
---@field scale? number Scale of the text

---@class JDJokerDefinition
---@field text? JDTextObject[] The main text of the Joker.
---@field text_config? JDTextObjectConfig Default configuration for text.
---@field reminder_text? JDTextObject[] Reminder text below the main text.
---@field reminder_text_config? JDTextObjectConfig Default configuration for reminder_text.
---@field extra? JDTextObject[][] Extra text on top of the main text.
---@field extra_config? JDTextObjectConfig Default configuration for all extra rows.
---@field calc_function? fun(card:table|Card) Called every time the display updates.
---@field style_function? fun(card:table|Card, text:table, reminder_text:table, extra:table):boolean? Used to change attributes for the different text lines.
---@field retrigger_function? fun(card:Card|table, scoring_hand:Card[]|table[]?, held_in_hand:boolean?, joker_card:Card|table?):integer Used to calculate playing card retriggers caused by the Joker.
---@field retrigger_joker_function? fun(card:Card|table, retrigger_joker:Card|table?):integer Used to calculate other Joker retriggers caused by the Joker.
---@field mod_function? fun(card:Card|table, mod_joker:Card|table?):JDModifiers Used to add extra modifiers to other Jokers.
---@field get_blueprint_joker? fun(card:Card|table):Card|table? Used to calculate the Joker to copy for Blueprint-like Jokers.

---@class SMODS.Joker
---@field joker_display_def? fun(JokerDisplay:JokerDisplay):JDJokerDefinition Define JokerDisplay
