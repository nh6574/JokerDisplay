--- Joker Display Definitions

--- Format (All values are optional):
--- line_1 [table] | First line of the display.
--- line_2 [table] | Second line of the display.
--- --- Lines are composed of tables that specify how each block of text is displayed, with the following paramenters (All values are optional):
--- --- text [string] | Text to be displayed. (Ignored if ref_value exists)
--- --- colour [table] | Text colour. (Default = G.C.UI.TEXT_LIGHT)
--- --- scale [number] | Text size. (Default = 0.4) (For consistency: 0.4 normal, 0.35 smaller, 0.3 smallest)
--- --- ref_value [string] | Value to reference for the text.
--- --- ref_table [string] | Location of the reference table for ref_value. Use "card" to reference the card's table, otherwise it will check in the global scope. (Ignored if ref_value doesn't exist) (ex. "card.joker_display_values" or "card.ability")
--- --- border_nodes [table] | Ignore all previous parameters and creates a border object with the specified text blocks. (Used for X Mult. The text blocks use the parameters above)
--- --- border_colour [table] | Colour of the border around border_nodes. (Used for X Mult. Default = G.C.XMULT)
--- --- dynatext [table] | Ignore all previous parameters and use a dynatext with this configuration instead. (See Misprint for example)
--- calc_function [function] | Calculation function that will be called every time the display updates.
--- --- Arguments:
--- --- card [table] | Joker card.
--- --- Notes:
--- --- Use to keep track of values for the display. You can use the card.joker_display_values table to store them.
--- --- You should check if the value is being store somewhere else (for example "card.ability") to avoid unnecessary calculations.
--- --- Check the main JokerDisplay file for helper functions.
--- style_function [function] | Style modifying function for the display.
--- --- Arguments:
--- --- card [table] | Joker card.
--- --- line_1 [table] | First line object (the "children" table contains each text block).
--- --- line_2 [table] | Second line object (the "children" table contains each text block).
--- --- Returns:
--- --- recalculate [boolean] | Whether to recalculate the UI or not. (Generally return true if there's a change in scale, false otherwise)
--- --- Notes:
--- --- Use to change any style paramentes (like colour or scale) of the display.
--- --- If border_nodes is used, the text object is a child of that child.
--- --- (ex. line_1.children[1].colour changes the border color and line_1.children[1].children[1].colour changes the text colour)
--- retrigger_function [function] | Used for retrigger calculations in the helper functions.
--- --- Arguments:
--- --- card [table] | Card to calculate triggers for.
--- --- scoring_hand [table] | Scoring hand. nil if poker hand is unknown (i.e. there are facedowns) (This might change in the future).
--- --- held_in_hand [table] | If the card is held in hand and not a scoring card.
--- --- Returns:
--- --- triggers [integer] | Extra triggers (0 if none)

return {
    j_joker = { -- Joker
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_greedy_joker = { -- Greedy Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = { --
            { text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            {
                text = localize(G.P_CENTERS["j_greedy_joker"].config.extra.suit, 'suits_plural'),
                colour =
                    lighten(loc_colour(G.P_CENTERS["j_greedy_joker"].config.extra.suit:lower()), 0.35),
                scale = 0.3
            },
            { text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit(card.ability.extra.suit) then
                    mult = mult +
                        card.ability.extra.s_mult *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_lusty_joker = { -- Lusty Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                                      colour = G.C.UI.TEXT_INACTIVE,                                                              scale = 0.3 },
            { text = localize(G.P_CENTERS["j_lusty_joker"].config.extra.suit, 'suits_plural'), colour = lighten(loc_colour(G.P_CENTERS["j_lusty_joker"].config.extra.suit:lower()), 0.35), scale = 0.3 },
            { text = ")",                                                                      colour = G.C.UI.TEXT_INACTIVE,                                                              scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit(card.ability.extra.suit) then
                    mult = mult +
                        card.ability.extra.s_mult *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_wrathful_joker = { -- Wrathful Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                                         colour = G.C.UI.TEXT_INACTIVE,                                                                 scale = 0.3 },
            { text = localize(G.P_CENTERS["j_wrathful_joker"].config.extra.suit, 'suits_plural'), colour = lighten(loc_colour(G.P_CENTERS["j_wrathful_joker"].config.extra.suit:lower()), 0.35), scale = 0.3 },
            { text = ")",                                                                         colour = G.C.UI.TEXT_INACTIVE,                                                                 scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit(card.ability.extra.suit) then
                    mult = mult +
                        card.ability.extra.s_mult *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_gluttenous_joker = { -- Gluttonous Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                                           colour = G.C.UI.TEXT_INACTIVE,                                                                   scale = 0.3 },
            { text = localize(G.P_CENTERS["j_gluttenous_joker"].config.extra.suit, 'suits_plural'), colour = lighten(loc_colour(G.P_CENTERS["j_gluttenous_joker"].config.extra.suit:lower()), 0.35), scale = 0.3 },
            { text = ")",                                                                           colour = G.C.UI.TEXT_INACTIVE,                                                                   scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit(card.ability.extra.suit) then
                    mult = mult +
                        card.ability.extra.s_mult *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_jolly = { -- Jolly Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_jolly"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                mult = card.ability.t_mult
            end
            card.joker_display_values.mult = mult
        end
    },
    j_zany = { -- Zany Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_zany"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                mult = card.ability.t_mult
            end
            card.joker_display_values.mult = mult
        end
    },
    j_mad = { -- Mad Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_mad"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                mult = card.ability.t_mult
            end
            card.joker_display_values.mult = mult
        end
    },
    j_crazy = { -- Crazy Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_crazy"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                mult = card.ability.t_mult
            end
            card.joker_display_values.mult = mult
        end
    },
    j_droll = { -- Droll Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_droll"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                mult = card.ability.t_mult
            end
            card.joker_display_values.mult = mult
        end
    },
    j_sly = { -- Sly Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = " (",                                                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_sly"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                chips = card.ability.t_chips
            end
            card.joker_display_values.chips = chips
        end
    },
    j_wily = { -- Wily Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = " (",                                                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_wily"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                chips = card.ability.t_chips
            end
            card.joker_display_values.chips = chips
        end
    },
    j_clever = { -- Clever Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = " (",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_clever"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                chips = card.ability.t_chips
            end
            card.joker_display_values.chips = chips
        end
    },
    j_devious = { -- Devious Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = " (",                                                          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_devious"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                           colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                chips = card.ability.t_chips
            end
            card.joker_display_values.chips = chips
        end
    },
    j_crafty = { -- Crafty Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = " (",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_crafty"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                chips = card.ability.t_chips
            end
            card.joker_display_values.chips = chips
        end
    },
    j_half = { -- Half Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            if type(hand) == "table" and #hand > 0 and #hand <= card.ability.extra.size then
                mult = card.ability.extra.mult
            end
            card.joker_display_values.mult = mult
        end
    },
    j_stencil = { -- Joker Stencil
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_four_fingers = { -- Four Fingers
    },
    j_mime = {         -- Mime
        retrigger_function = function(card, scoring_hand, held_in_hand)
            return held_in_hand and 1 or 0
        end
    },
    j_credit_card = { -- Credit Card
    },
    j_ceremonial = {  -- Ceremonial Dagger
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_banner = { -- Banner
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        calc_function = function(card)
            card.joker_display_values.chips = card.ability.extra *
                (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left or 0)
        end
    },
    j_mystic_summit = { -- Mystic Summit
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            card.joker_display_values.mult = card.ability.extra.mult *
                (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left <= card.ability.extra.d_remaining and 1 or 0)
        end
    },
    j_marble = {       -- Marble Joker
    },
    j_loyalty_card = { -- Loyalty Card
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "loyalty_text",    colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local loyalty_remaining = card.ability.loyalty_remaining + (next(G.play.cards) and 1 or 0)
            card.joker_display_values.loyalty_text = localize { type = 'variable', key = (loyalty_remaining % 6 == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { loyalty_remaining } }
            card.joker_display_values.x_mult = (loyalty_remaining % 6 == 0 and card.ability.extra.Xmult or 1)
        end
    },
    j_8_ball = { -- 8 Ball
        text = {
            { text = "+",                              colour = G.C.SECONDARY_SET.Tarot },
            { ref_table = "card.joker_display_values", ref_value = "count",             colour = G.C.SECONDARY_SET.Tarot },
        },
        reminder_text = {
            { text = "(",                                                   colour = G.C.GREEN, scale = 0.3 },
            { ref_table = "card.joker_display_values",                      ref_value = "odds", colour = G.C.GREEN, scale = 0.3 },
            { text = " in " .. G.P_CENTERS["j_8_ball"].config.extra .. ")", colour = G.C.GREEN, scale = 0.3 },
        },
        calc_function = function(card)
            local count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and v:get_id() == 8 then
                    count = count +
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.count = count
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
    },
    j_misprint = { -- Misprint
        text = {
            { text = "+", colour = G.C.MULT },
            {
                dynatext = {
                    string = (
                        function()
                            local r_mult = {}
                            for i = G.P_CENTERS["j_misprint"].config.extra.min, G.P_CENTERS["j_misprint"].config.extra.max do
                                r_mult[#r_mult + 1] = tostring(i)
                            end
                            return r_mult
                        end
                    )(),
                    colours = { G.C.RED },
                    pop_in_rate = 9999999,
                    silent = true,
                    random_element = true,
                    pop_delay = 0.5,
                    scale = 0.4,
                    min_cycle_time = 0
                }
            }
        }
    },
    j_dusk = { -- Dusk
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "active",          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = G.GAME and G.GAME.current_round.hands_left <= 1 and
                localize("k_active_ex") or "Inactive"
        end,
        retrigger_function = function(card, scoring_hand, held_in_hand)
            return G.GAME and G.GAME.current_round.hands_left <= 1 and 1 or 0
        end
    },
    j_raised_fist = { -- Raised Fist
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            local temp_Mult, temp_ID = 15, 15
            local temp_card = nil
            for i = 1, #G.hand.cards do
                if not G.hand.cards[i].highlighted and temp_ID >= G.hand.cards[i].base.id
                    and G.hand.cards[i].ability.effect ~= 'Stone Card' then
                    temp_Mult = G.hand.cards[i].base.nominal *
                        JokerDisplay.calculate_card_triggers(G.hand.cards[i], nil, true)
                    temp_ID = G.hand.cards[i].base.id
                    temp_card = G.hand.cards[i]
                end
            end
            if not temp_card or temp_card.debuff or temp_card.facing == 'back' then
                temp_Mult = 0
            end
            card.joker_display_values.mult = (temp_Mult < 15 and temp_Mult * 2 or 0)
        end
    },
    j_chaos = {     -- Chaos the Clown
    },
    j_fibonacci = { -- Fibonacci
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(" .. localize("Ace", "ranks") .. ",2,3,5,8)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and v:get_id() == 2 or v:get_id() == 3 or v:get_id() == 5
                    or v:get_id() == 8 or v:get_id() == 14 then
                    mult = mult +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_steel_joker = { -- Steel Joker
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        calc_function = function(card)
            card.joker_display_values.x_mult = 1 + card.ability.extra * (card.ability.steel_tally or 0)
        end
    },
    j_scary_face = { -- Scary Face
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = "(",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("k_face_cards"), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_face() then
                    chips = chips +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.chips = chips
        end
    },
    j_abstract = { -- Abstract Joker
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            card.joker_display_values.mult = (G.jokers and G.jokers.cards and #G.jokers.cards or 0) * card.ability.extra
        end
    },
    j_delayed_grat = { -- Delayed Gratification
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            card.joker_display_values.dollars = (G.GAME and G.GAME.current_round.discards_used == 0 and G.GAME.current_round.discards_left > 0 and G.GAME.current_round.discards_left * card.ability.extra or 0)
        end
    },
    j_hack = { -- Hack
        reminder_text = {
            { text = "(2,3,4,5)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        retrigger_function = function(card, scoring_hand, held_in_hand)
            return (card:get_id() == 2 or card:get_id() == 3 or card:get_id() == 4 or card:get_id() == 5) and 1 or 0
        end
    },
    j_pareidolia = {  -- Pareidolia
    },
    j_gros_michel = { -- Gros Michel
        text = {
            { text = "+",                       colour = G.C.MULT },
            { ref_table = "card.ability.extra", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_even_steven = { -- Even Steven
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(10,8,6,4,2)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and v:get_id() <= 10 and v:get_id() >= 0 and v:get_id() % 2 == 0 then
                    mult = mult +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_odd_todd = { -- Odd Todd
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        reminder_text = {
            { text = "(" .. localize("Ace", "ranks") .. ",9,7,5,3)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and ((v:get_id() <= 10 and v:get_id() >= 0 and
                        v:get_id() % 2 == 1) or (v:get_id() == 14)) then
                    chips = chips +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.chips = chips
        end
    },
    j_scholar = { -- Scholar
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
            { text = " +",                             colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult",  colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(" .. localize("k_aces") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local chips, mult = 0, 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and v:get_id() == 14 then
                    local retriggers = JokerDisplay.calculate_card_triggers(v,
                        not (text == 'Unknown') and scoring_hand or nil)
                    chips = chips + card.ability.extra.chips * retriggers
                    mult = mult + card.ability.extra.mult * retriggers
                end
            end
            card.joker_display_values.mult = mult
            card.joker_display_values.chips = chips
        end
    },
    j_business = { -- Business Card
        text = {
            { ref_table = "card.joker_display_values", ref_value = "count" },
            { text = "x",                              scale = 0.35 },
            { text = localize('$') .. "2",             colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(",                                                     colour = G.C.GREEN, scale = 0.3 },
            { ref_table = "card.joker_display_values",                        ref_value = "odds", colour = G.C.GREEN, scale = 0.3 },
            { text = " in " .. G.P_CENTERS["j_business"].config.extra .. ")", colour = G.C.GREEN, scale = 0.3 },
        },
        calc_function = function(card)
            local count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_face() then
                    count = count +
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.count = count
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
    },
    j_supernova = { -- Supernova
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, _ = JokerDisplay.evaluate_hand(hand)
            card.joker_display_values.mult = (text ~= 'Unknown' and G.GAME and G.GAME.hands[text] and G.GAME.hands[text].played) or
                0
        end
    },
    j_ride_the_bus = { -- Ride the Bus
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_burglar = { -- Burglar
    },
    j_space = {   -- Space Joker
        reminder_text = {
            { text = "(",                                                  colour = G.C.GREEN, scale = 0.3 },
            { ref_table = "card.joker_display_values",                     ref_value = "odds", colour = G.C.GREEN, scale = 0.3 },
            { text = " in " .. G.P_CENTERS["j_space"].config.extra .. ")", colour = G.C.GREEN, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
    },
    j_egg = { -- Egg
        reminder_text = {
            { text = "(",           colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { text = localize('$'), colour = G.C.GOLD,             scale = 0.35 },
            { ref_table = "card",   ref_value = "sell_cost",       colour = G.C.GOLD, scale = 0.35 },
            { text = ")",           colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
        }
    },
    j_blackboard = { -- Blackboard
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        calc_function = function(card)
            local playing_hand = next(G.play.cards)
            local black_suits, all_cards = 0, 0
            local is_all_black_suits = false
            for k, v in ipairs(G.hand.cards) do
                if playing_hand or not v.highlighted then
                    all_cards = all_cards + 1
                    if v.facing and not (v.facing == 'back') and (v:is_suit('Clubs', nil, true) or v:is_suit('Spades', nil, true)) then
                        black_suits = black_suits + 1
                    end
                end
                is_all_black_suits = black_suits == all_cards
            end
            card.joker_display_values.x_mult = is_all_black_suits and card.ability.extra or 1
        end
    },
    j_runner = { -- Runner
        text = {
            { text = "+",                       colour = G.C.CHIPS },
            { ref_table = "card.ability.extra", ref_value = "chips", colour = G.C.CHIPS }
        }
    },
    j_ice_cream = { -- Ice Cream
        text = {
            { text = "+",                       colour = G.C.CHIPS },
            { ref_table = "card.ability.extra", ref_value = "chips", colour = G.C.CHIPS }
        }
    },
    j_dna = { -- DNA
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "active",          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = (G.GAME and G.GAME.current_round.hands_played == 0 and localize("k_active_ex") or "Inactive")
        end
    },
    j_splash = {     -- Splash
    },
    j_blue_joker = { -- Blue Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        calc_function = function(card)
            card.joker_display_values.chips = card.ability.extra * ((G.deck and G.deck.cards) and #G.deck.cards or 52)
        end
    },
    j_sixth_sense = { -- Sixth Sense
        text = {
            { ref_table = "card.joker_display_values", ref_value = "active_text" }
        },
        reminder_text = {
            { text = "(6)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            local sixth_sense_eval = #scoring_hand == 1 and scoring_hand[1]:get_id() == 6
            card.joker_display_values.active = G.GAME and G.GAME.current_round.hands_played == 0
            card.joker_display_values.active_text = card.joker_display_values.active and
                "+" .. tostring(sixth_sense_eval and 1 or 0) or "-"
        end,
        style_function = function(card, text, reminder_text, extra)
            if text and text.children[1] then
                text.children[1].config.colour = card.joker_display_values.active and G.C.SECONDARY_SET.Spectral or
                    G.C.UI.TEXT_INACTIVE
            end
            return false
        end
    },
    j_constellation = { -- Constellation
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_hiker = {    -- Hiker
    },
    j_faceless = { -- Faceless Joker
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        calc_function = function(card)
            local count = 0
            local hand = G.hand.highlighted
            for k, v in pairs(hand) do
                if v.facing and not (v.facing == 'back') and v:is_face() then
                    count = count + 1
                end
            end
            card.joker_display_values.dollars = G.GAME.current_round.discards_left > 0 and
                count >= card.ability.extra.faces and card.ability.extra.dollars or 0
        end
    },
    j_green_joker = { -- Green Joker
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_superposition = { -- Superposition
        text = {
            { text = "+",                              colour = G.C.SECONDARY_SET.Tarot },
            { ref_table = "card.joker_display_values", ref_value = "count",             colour = G.C.SECONDARY_SET.Tarot },
        },
        reminder_text = {
            { text = "(",                                 colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("Ace", "ranks"),            colour = G.C.ORANGE,           scale = 0.3 },
            { text = "+",                                 colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize('Straight', "poker_hands"), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                 colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local has_ace, has_straight = false, false
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:get_id() and v:get_id() == 14 then
                    has_ace = true
                end
            end
            if next(poker_hands["Straight"]) then
                has_straight = true
            end
            card.joker_display_values.count = has_ace and has_straight and 1 or 0
        end
    },
    j_todo_list = { -- To Do List
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE,  scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "to_do_poker_hand", colour = G.C.ORANGE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE,  scale = 0.3 },
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, _ = JokerDisplay.evaluate_hand(hand)
            local is_to_do_poker_hand = text == card.ability.to_do_poker_hand
            card.joker_display_values.dollars = is_to_do_poker_hand and card.ability.extra.dollars or 0
            card.joker_display_values.to_do_poker_hand = localize(card.ability.to_do_poker_hand, 'poker_hands')
        end
    },
    j_cavendish = { -- Cavendish
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability.extra", ref_value = "Xmult" }
                }
            }
        }
    },
    j_card_sharp = { -- Card Sharp
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, _ = JokerDisplay.evaluate_hand(hand)
            local is_card_sharp_hand = text ~= 'Unknown' and G.GAME.hands and G.GAME.hands[text] and
                G.GAME.hands[text].played_this_round > (next(G.play.cards) and 1 or 0)
            card.joker_display_values.x_mult = is_card_sharp_hand and card.ability.extra.Xmult or 1
        end
    },
    j_red_card = { -- Red Card
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_madness = { -- Madness
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_square = { -- Square Joker
        text = {
            { text = "+",                       colour = G.C.CHIPS },
            { ref_table = "card.ability.extra", ref_value = "chips", colour = G.C.CHIPS }
        }
    },
    j_seance = { -- Séance
        text = {
            { text = "+",                              colour = G.C.SECONDARY_SET.Spectral },
            { ref_table = "card.joker_display_values", ref_value = "count",                colour = G.C.SECONDARY_SET.Spectral },
        },
        reminder_text = {
            { text = "(",                                                                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_seance"].config.extra.poker_hand, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, _ = JokerDisplay.evaluate_hand(hand)
            local is_seance_hand = text == card.ability.extra.poker_hand
            card.joker_display_values.count = is_seance_hand and 1 or 0
        end
    },
    j_riff_raff = { -- Riff-Raff
    },
    j_vampire = {   -- Vampire
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_shortcut = { -- Shortcut
    },
    j_hologram = { -- Hologram
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_vagabond = { -- Vagabond
        text = {
            { ref_table = "card.joker_display_values", ref_value = "active_text", colour = G.C.SECONDARY_SET.Tarot }
        },
        calc_function = function(card)
            card.joker_display_values.active = G.GAME and G.GAME.dollars < 5
            card.joker_display_values.active_text = card.joker_display_values.active and "+1" or "+0"
        end
    },
    j_baron = { -- Baron
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        calc_function = function(card)
            local playing_hand = next(G.play.cards)
            local count = 0
            for k, v in ipairs(G.hand.cards) do
                if playing_hand or not v.highlighted then
                    if not (v.facing == 'back') and not v.debuff and v:get_id() and v:get_id() == 13 then
                        count = count + JokerDisplay.calculate_card_triggers(v, nil, true)
                    end
                end
            end
            card.joker_display_values.x_mult = tonumber(string.format("%.2f", (card.ability.extra ^ count)))
        end
    },
    j_cloud_9 = { -- Cloud 9
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            card.joker_display_values.dollars = card.ability.extra * (card.ability.nine_tally or 0)
        end
    },
    j_rocket = { -- Rocket
        text = {
            { text = "+" .. localize('$'),      colour = G.C.GOLD },
            { ref_table = "card.ability.extra", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
    },
    j_obelisk = { -- Obelisk
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        calc_function = function(card)
            local hand = G.hand.highlighted
            local text, _, _ = JokerDisplay.evaluate_hand(hand)
            local play_more_than = 0
            for k, v in pairs(G.GAME.hands) do
                if v.played and v.played >= play_more_than and v.visible then
                    play_more_than = v.played
                end
            end
            local hand_exists = text ~= 'Unknown' and G.GAME and G.GAME.hands and G.GAME.hands[text]
            card.joker_display_values.x_mult = (hand_exists and (G.GAME.hands[text].played >= play_more_than and 1 or card.ability.x_mult + card.ability.extra) or card.ability.x_mult)
        end
    },
    j_midas_mask = { -- Midas Mask
    },
    j_luchador = {   -- Luchador
        reminder_text = {
            { ref_table = "card.joker_display_values", ref_value = "active_text", scale = 0.3 },
        },
        calc_function = function(card)
            local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and
                ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
            card.joker_display_values.active = disableable
            card.joker_display_values.active_text = localize(disableable and 'k_active' or 'ph_no_boss_active')
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[1] then
                reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.RED
                reminder_text.children[1].config.scale = card.joker_display_values.active and 0.35 or 0.3
                return true
            end
            return false
        end
    },
    j_photograph = { -- Photograph
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("k_face_cards"), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            local face_cards = {}
            for k, v in pairs(scoring_hand) do
                if v:is_face() then
                    table.insert(face_cards, v)
                end
            end
            local first_face = JokerDisplay.calculate_leftmost_card(face_cards)
            card.joker_display_values.x_mult = first_face and
                (card.ability.extra ^ JokerDisplay.calculate_card_triggers(first_face, not (text == 'Unknown') and scoring_hand or nil)) or
                1
        end
    },
    j_gift = {        -- Gift Card
    },
    j_turtle_bean = { -- Turtle Bean
        reminder_text = {
            { text = "(+",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { ref_table = "card.ability.extra", ref_value = "h_size",          colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { text = ")",                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
        }
    },
    j_erosion = { -- Erosion
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            card.joker_display_values.mult = math.max(0,
                card.ability.extra * (G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0))
        end
    },
    j_reserved_parking = { -- Reserved Parking
        text = {
            { ref_table = "card.joker_display_values",                                        ref_value = "count" },
            { text = "x",                                                                     scale = 0.35 },
            { text = localize('$') .. G.P_CENTERS["j_reserved_parking"].config.extra.dollars, colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(",                                                                  colour = G.C.GREEN, scale = 0.3 },
            { ref_table = "card.joker_display_values",                                     ref_value = "odds", colour = G.C.GREEN, scale = 0.3 },
            { text = " in " .. G.P_CENTERS["j_reserved_parking"].config.extra.odds .. ")", colour = G.C.GREEN, scale = 0.3 },
        },
        calc_function = function(card)
            local playing_hand = next(G.play.cards)
            local count = 0
            for k, v in ipairs(G.hand.cards) do
                if playing_hand or not v.highlighted then
                    if v.facing and not (v.facing == 'back') and v:is_face() then
                        count = count + JokerDisplay.calculate_card_triggers(v, nil, true)
                    end
                end
            end
            card.joker_display_values.count = count
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
    },
    j_mail = { -- Mail-In Rebate
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { ref_table = "card.joker_display_values", ref_value = "mail_card_rank",  colour = G.C.ORANGE, scale = 0.35 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 }
        },
        calc_function = function(card)
            local dollars = 0
            local hand = G.hand.highlighted
            for k, v in pairs(hand) do
                if v.facing and not (v.facing == 'back') and not v.debuff and v:get_id() and v:get_id() == G.GAME.current_round.mail_card.id then
                    dollars = dollars + card.ability.extra
                end
            end
            card.joker_display_values.dollars = G.GAME.current_round.discards_left > 0 and dollars or 0
            card.joker_display_values.mail_card_rank = localize(G.GAME.current_round.mail_card.rank, 'ranks')
        end
    },
    j_to_the_moon = { -- To the Moon
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            card.joker_display_values.dollars = G.GAME and G.GAME.dollars and
                math.max(math.min(math.floor(G.GAME.dollars / 5), G.GAME.interest_cap / 5), 0) * card.ability.extra
        end
    },
    j_hallucination = {  -- Hallucination
    },
    j_fortune_teller = { -- Fortune Teller
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        calc_function = function(card)
            card.joker_display_values.mult = G.GAME and G.GAME.consumeable_usage_total and
                G.GAME.consumeable_usage_total.tarot or 0
        end
    },
    j_juggler = {  -- Juggler
    },
    j_drunkard = { -- Drunkard
    },
    j_stone = {    -- Stone Joker
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        calc_function = function(card)
            card.joker_display_values.chips = card.ability.extra * (card.ability.stone_tally or 0)
        end
    },
    j_golden = { -- Golden Joker
        text = {
            { text = "+" .. localize('$'), colour = G.C.GOLD },
            { ref_table = "card.ability",  ref_value = "extra", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
    },
    j_lucky_cat = { -- Lucky Cat
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_baseball = { -- Baseball Card
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "count",           colour = G.C.ORANGE, scale = 0.3 },
            { text = "x",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("k_uncommon"),           colour = G.C.GREEN,            scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local count = 0
            if G.jokers then
                for k, v in ipairs(G.jokers.cards) do
                    if v.config.center.rarity and v.config.center.rarity == 2 then
                        count = count + 1
                    end
                end
            end
            card.joker_display_values.count = count
        end,
        mod_function = function(card)
            return { x_mult = card.config.center.rarity == 2 and G.P_CENTERS["j_baseball"].config.extra or nil }
        end
    },
    j_bull = { -- Bull
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS }
        },
        calc_function = function(card)
            card.joker_display_values.chips = card.ability.extra * (math.max(0, G.GAME.dollars) or 0)
        end
    },
    j_diet_cola = { -- Diet Cola
    },
    j_trading = {   -- Trading Card
        text = {
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        calc_function = function(card)
            local is_trading_card_discard = #G.hand.highlighted == 1
            card.joker_display_values.active = G.GAME and G.GAME.current_round.discards_used == 0 and
                G.GAME.current_round.discards_left > 0
            card.joker_display_values.dollars = card.joker_display_values.active and
                ("+" .. localize('$') .. (is_trading_card_discard and card.ability.extra or 0)) or "-"
        end,
        style_function = function(card, text, reminder_text, extra)
            if text and text.children[1] then
                text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or
                    G.C.UI.TEXT_INACTIVE
            end
            return false
        end
    },
    j_flash = { -- Flash Card
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_popcorn = { -- Popcorn
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_trousers = { -- Spare Trousers
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_ancient = { -- Ancient Joker
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE,   scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "ancient_card_suit", scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE,   scale = 0.3 }
        },
        calc_function = function(card)
            local count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit(G.GAME.current_round.ancient_card.suit) then
                    count = count +
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.x_mult = tonumber(string.format("%.2f", (card.ability.extra ^ count)))
            card.joker_display_values.ancient_card_suit = localize(G.GAME.current_round.ancient_card.suit,
                'suits_singular')
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[2] then
                reminder_text.children[2].config.colour = lighten(G.C.SUITS[G.GAME.current_round.ancient_card.suit], 0.35)
            end
            return false
        end
    },
    j_ramen = { -- Ramen
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_walkie_talkie = { -- Walkie Talkie
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
            { text = " +",                             colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult",  colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(10,4)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local chips, mult = 0, 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and (v:get_id() == 10 or v:get_id() == 4) then
                    local retriggers = JokerDisplay.calculate_card_triggers(v,
                        not (text == 'Unknown') and scoring_hand or nil)
                    chips = chips + card.ability.extra.chips * retriggers
                    mult = mult + card.ability.extra.mult * retriggers
                end
            end
            card.joker_display_values.chips = chips
            card.joker_display_values.mult = mult
        end
    },
    j_selzer = { -- Seltzer
        reminder_text = {
            { text = "(",                 colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.ability", ref_value = "extra",           colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = "/10)",              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        retrigger_function = function(card, scoring_hand, held_in_hand)
            return 1
        end
    },
    j_castle = { -- Castle
        text = {
            { text = "+",                       colour = G.C.CHIPS },
            { ref_table = "card.ability.extra", ref_value = "chips", colour = G.C.CHIPS },
        },
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE,  scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "castle_card_suit", scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE,  scale = 0.3 }
        },
        calc_function = function(card)
            card.joker_display_values.castle_card_suit = localize(G.GAME.current_round.castle_card.suit, 'suits_singular')
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[2] then
                reminder_text.children[2].config.colour = lighten(G.C.SUITS[G.GAME.current_round.castle_card.suit], 0.35)
            end
            return false
        end
    },
    j_smiley = { -- Smiley Face
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT }
        },
        reminder_text = {
            { text = "(",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("k_face_cards"), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                      colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_face() then
                    mult = mult +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_campfire = { -- Campfire
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_ticket = { -- Golden Ticket
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(",                colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("k_gold"), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local dollars = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v.ability.name and v.ability.name == 'Gold Card' then
                    dollars = dollars +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.dollars = dollars
        end
    },
    j_mr_bones = { -- Mr. Bones
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "active",          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = G.GAME and G.GAME.chips and G.GAME.blind.chips and
                G.GAME.chips / G.GAME.blind.chips >= 0.25 and localize("k_active_ex") or "Inactive"
        end
    },
    j_acrobat = { -- Acrobat
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        calc_function = function(card)
            card.joker_display_values.x_mult = G.GAME and G.GAME.current_round.hands_left == 1 and card.ability.extra or
                1
        end
    },
    j_sock_and_buskin = { -- Sock and Buskin
        retrigger_function = function(card, scoring_hand, held_in_hand)
            return card:is_face() and 1 or 0
        end
    },
    j_swashbuckler = { -- Swashbuckler
        text = {
            { text = "+",                 colour = G.C.MULT },
            { ref_table = "card.ability", ref_value = "mult", colour = G.C.MULT }
        }
    },
    j_troubadour = {  -- Troubadour
    },
    j_certificate = { -- Certificate
    },
    j_smeared = {     -- Smeared Joker
    },
    j_throwback = {   -- Throwback
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_hanging_chad = { -- Hanging Chad
        retrigger_function = function(card, scoring_hand, held_in_hand)
            local first_card = scoring_hand and JokerDisplay.calculate_leftmost_card(scoring_hand)
            return first_card and card == first_card and 2 or 0
        end
    },
    j_rough_gem = { -- Rough Gem
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(",                                  colour = G.C.UI.TEXT_INACTIVE,  scale = 0.3 },
            { text = localize("Diamonds", 'suits_plural'), colour = G.C.SUITS["Diamonds"], scale = 0.3 },
            { text = ")",                                  colour = G.C.UI.TEXT_INACTIVE,  scale = 0.3 }
        },
        calc_function = function(card)
            local dollars = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit("Diamonds") then
                    dollars = dollars +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.dollars = dollars
        end
    },
    j_bloodstone = { -- Bloodstone
        text = {
            { ref_table = "card.joker_display_values", ref_value = "count" },
            { text = "x",                              scale = 0.35 },
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability.extra", ref_value = "Xmult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                            colour = G.C.GREEN,            scale = 0.3 },
            { ref_table = "card.joker_display_values",                               ref_value = "odds",            colour = G.C.GREEN, scale = 0.3 },
            { text = " in " .. G.P_CENTERS["j_bloodstone"].config.extra.odds .. ")", colour = G.C.GREEN,            scale = 0.3 },
            { text = "(",                                                            colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("Hearts", 'suits_plural'),                             colour = G.C.SUITS["Hearts"],  scale = 0.3 },
            { text = ")",                                                            colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit("Hearts") then
                    count = count +
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.count = count
            card.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
        end
    },
    j_arrowhead = { -- Arrowhead
        text = {
            { text = "+",                              colour = G.C.CHIPS },
            { ref_table = "card.joker_display_values", ref_value = "chips", colour = G.C.CHIPS },
        },
        reminder_text = {
            { text = "(",                                colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("Spades", 'suits_plural'), colour = G.C.SUITS["Spades"],  scale = 0.3 },
            { text = ")",                                colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local chips = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit("Spades") then
                    chips = chips +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.chips = chips
        end
    },
    j_onyx_agate = { -- Onyx Agate
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT },
        },
        reminder_text = {
            { text = "(",                               colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("Clubs", 'suits_plural'), colour = G.C.SUITS["Clubs"],   scale = 0.3 },
            { text = ")",                               colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local mult = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit("Clubs") then
                    mult = mult +
                        card.ability.extra *
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_glass = { -- Glass Joker
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_ring_master = { -- Showman
    },
    j_flower_pot = {  -- Flower Pot
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = "All Suits", colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #scoring_hand do
                if scoring_hand[i].ability.name ~= 'Wild Card' then
                    if scoring_hand[i]:is_suit('Hearts', true) and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif scoring_hand[i]:is_suit('Diamonds', true) and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif scoring_hand[i]:is_suit('Spades', true) and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif scoring_hand[i]:is_suit('Clubs', true) and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            for i = 1, #scoring_hand do
                if scoring_hand[i].ability.name == 'Wild Card' then
                    if scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            local is_flower_pot_hand = suits["Hearts"] > 0 and suits["Diamonds"] > 0 and suits["Spades"] > 0 and
                suits["Clubs"] > 0
            card.joker_display_values.x_mult = is_flower_pot_hand and card.ability.extra or 1
        end
    },
    j_blueprint = { -- Blueprint
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE,           scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "blueprint_ability_name_ui", colour = G.C.ORANGE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE,           scale = 0.3 }
        },
        calc_function = function(card)
            local ability_name, ability_key = JokerDisplay.calculate_blueprint_copy(card)
            card.joker_display_values.blueprint_ability_name = ability_name
            card.joker_display_values.blueprint_ability_key = ability_key
            card.joker_display_values.blueprint_ability_name_ui = ability_key and
                localize { type = 'name_text', key = ability_key, set = 'Joker' } or "-"
            card.joker_display_values.blueprint_compat = localize('k_' ..
                (card.joker_display_values.blueprint_ability_name and "compatible" or "incompatible"))
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[2] then
                reminder_text.children[2].config.colour = card.joker_display_values
                    .blueprint_ability_name and G.C.GREEN or
                    G.C.RED
            end
            return false
        end
    },
    j_wee = { -- Wee Joker
        text = {
            { text = "+",                       colour = G.C.CHIPS },
            { ref_table = "card.ability.extra", ref_value = "chips", colour = G.C.CHIPS },
        }
    },
    j_merry_andy = { -- Merry Andy
    },
    j_oops = {       -- Oops! All 6s
    },
    j_idol = {       -- The Idol
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "idol_card_rank",  colour = G.C.ORANGE, scale = 0.35 },
            { text = " of ",                           scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "idol_card_suit",  scale = 0.35 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if v:is_suit(G.GAME.current_round.idol_card.suit) and v:get_id() and v:get_id() == G.GAME.current_round.idol_card.id then
                    count = count +
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.x_mult = card.ability.extra ^ count
            card.joker_display_values.idol_card_rank = localize(G.GAME.current_round.idol_card.rank, 'ranks')
            card.joker_display_values.idol_card_suit = localize(G.GAME.current_round.idol_card.suit, 'suits_plural')
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[4] then
                reminder_text.children[4].config.colour = lighten(G.C.SUITS[G.GAME.current_round.idol_card.suit], 0.35)
            end
            return false
        end
    },
    j_seeing_double = { -- Seeing Double
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                 colour = G.C.UI.TEXT_INACTIVE,              scale = 0.3 },
            { text = localize("Clubs", 'suits_singular'), colour = lighten(G.C.SUITS["Clubs"], 0.35), scale = 0.3 },
            { text = "+",                                 scale = 0.3 },
            { text = localize('k_other'),                 colour = G.C.ORANGE,                        scale = 0.3 },
            { text = ")",                                 colour = G.C.UI.TEXT_INACTIVE,              scale = 0.3 },
        },
        calc_function = function(card)
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            local suits = {
                ['Hearts'] = 0,
                ['Diamonds'] = 0,
                ['Spades'] = 0,
                ['Clubs'] = 0
            }
            for i = 1, #scoring_hand do
                if scoring_hand[i].ability.name ~= 'Wild Card' then
                    if scoring_hand[i]:is_suit('Hearts') then
                        suits["Hearts"] = suits["Hearts"] + 1
                    elseif scoring_hand[i]:is_suit('Diamonds') then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif scoring_hand[i]:is_suit('Spades') then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif scoring_hand[i]:is_suit('Clubs') then
                        suits["Clubs"] = suits["Clubs"] + 1
                    end
                end
            end
            for i = 1, #scoring_hand do
                if scoring_hand[i].ability.name == 'Wild Card' then
                    if scoring_hand[i]:is_suit('Clubs') and suits["Clubs"] == 0 then
                        suits["Clubs"] = suits["Clubs"] + 1
                    elseif scoring_hand[i]:is_suit('Diamonds') and suits["Diamonds"] == 0 then
                        suits["Diamonds"] = suits["Diamonds"] + 1
                    elseif scoring_hand[i]:is_suit('Spades') and suits["Spades"] == 0 then
                        suits["Spades"] = suits["Spades"] + 1
                    elseif scoring_hand[i]:is_suit('Hearts') and suits["Hearts"] == 0 then
                        suits["Hearts"] = suits["Hearts"] + 1
                    end
                end
            end
            local is_seeing_double_hand = (suits["Hearts"] > 0 or suits["Diamonds"] > 0 or suits["Spades"] > 0) and
                (suits["Clubs"] > 0)
            card.joker_display_values.x_mult = is_seeing_double_hand and card.ability.extra or 1
        end
    },
    j_matador = { -- Matador
        reminder_text = {
            { ref_table = "card.joker_display_values", ref_value = "active_text", scale = 0.3 },
        },
        calc_function = function(card)
            local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and
                ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
            card.joker_display_values.active = disableable
            card.joker_display_values.active_text = card.joker_display_values.active and
                ("+" .. localize('$') .. card.ability.extra .. "?") or localize('ph_no_boss_active')
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[1] and card.joker_display_values then
                reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or
                    G.C.RED
                reminder_text.children[1].config.scale = card.joker_display_values.active and 0.35 or 0.3
                return true
            end
            return false
        end
    },
    j_hit_the_road = { -- Hit the Road
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        }
    },
    j_duo = { -- The Duo
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_duo"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                       colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local x_mult = 1
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                x_mult = card.ability.x_mult
            end
            card.joker_display_values.x_mult = x_mult
        end
    },
    j_trio = { -- The Trio
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_trio"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local x_mult = 1
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                x_mult = card.ability.x_mult
            end
            card.joker_display_values.x_mult = x_mult
        end
    },
    j_family = { -- The Family
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_family"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local x_mult = 1
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                x_mult = card.ability.x_mult
            end
            card.joker_display_values.x_mult = x_mult
        end
    },
    j_order = { -- The Order
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_order"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local x_mult = 1
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                x_mult = card.ability.x_mult
            end
            card.joker_display_values.x_mult = x_mult
        end
    },
    j_tribe = { -- The Tribe
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize(G.P_CENTERS["j_tribe"].config.type, 'poker_hands'), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local x_mult = 1
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local _, poker_hands, _ = JokerDisplay.evaluate_hand(hand)
            if next(poker_hands[card.ability.type]) then
                x_mult = card.ability.x_mult
            end
            card.joker_display_values.x_mult = x_mult
        end
    },
    j_stuntman = { -- Stuntman
        text = {
            { text = "+",                       colour = G.C.CHIPS },
            { ref_table = "card.ability.extra", ref_value = "chip_mod", colour = G.C.CHIPS },
        }
    },
    j_invisible = { -- Invisible Joker
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { ref_table = "card.joker_display_values", ref_value = "active",          colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 },
        },
        calc_function = function(card)
            card.joker_display_values.active = card.ability.invis_rounds >= card.ability.extra and
                localize("k_active_ex") or
                (card.ability.invis_rounds .. "/" .. card.ability.extra)
        end
    },
    j_brainstorm = { -- Brainstorm
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE,           scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "blueprint_ability_name_ui", colour = G.C.ORANGE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE,           scale = 0.3 }
        },
        calc_function = function(card)
            local ability_name, ability_key = JokerDisplay.calculate_blueprint_copy(card)
            card.joker_display_values.blueprint_ability_name = ability_name
            card.joker_display_values.blueprint_ability_key = ability_key
            card.joker_display_values.blueprint_ability_name_ui = ability_key and
                localize { type = 'name_text', key = ability_key, set = 'Joker' } or "-"
            card.joker_display_values.blueprint_compat = localize('k_' ..
                (card.joker_display_values.blueprint_ability_name and "compatible" or "incompatible"))
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[2] then
                reminder_text.children[2].config.colour = card.joker_display_values.blueprint_ability_name and G.C.GREEN or
                    G.C.RED
            end
            return false
        end
    },
    j_satellite = { -- Satellite
        text = {
            { text = "+" .. localize('$'),             colour = G.C.GOLD },
            { ref_table = "card.joker_display_values", ref_value = "dollars", colour = G.C.GOLD },
        },
        reminder_text = {
            { text = "(" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }
        },
        calc_function = function(card)
            local planets_used = 0
            for k, v in pairs(G.GAME.consumeable_usage) do
                if v.set and v.set == 'Planet' then
                    planets_used = planets_used + 1
                end
            end
            card.joker_display_values.dollars = planets_used * card.ability.extra
        end
    },
    j_shoot_the_moon = { -- Shoot the Moon
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT },
        },
        calc_function = function(card)
            local playing_hand = next(G.play.cards)
            local mult = 0
            for k, v in ipairs(G.hand.cards) do
                if playing_hand or not v.highlighted then
                    if v.facing and not (v.facing == 'back') and not v.debuff and v:get_id() == 12 then
                        mult = mult + card.ability.extra * JokerDisplay.calculate_card_triggers(v, nil, true)
                    end
                end
            end
            card.joker_display_values.mult = mult
        end
    },
    j_drivers_license = { -- Driver's License
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                 colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.ability", ref_value = "driver_tally",    colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = "/16)",              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = card.ability.driver_tally and card.ability.driver_tally >= 16
            card.joker_display_values.x_mult = card.joker_display_values.active and card.ability.extra or 1
        end
    },
    j_cartomancer = { -- Cartomancer
    },
    j_astronomer = {  -- Astronomer
    },
    j_burnt = {       -- Burnt Joker
        reminder_text = {
            { text = "(",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values", ref_value = "active",          colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = ")",                              colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.active = (G.GAME and G.GAME.current_round.discards_used <= 0 and G.GAME.current_round.discards_left > 0 and localize("k_active_ex") or "Inactive")
        end
    },
    j_bootstraps = { -- Bootstraps
        text = {
            { text = "+",                              colour = G.C.MULT },
            { ref_table = "card.joker_display_values", ref_value = "mult", colour = G.C.MULT },
        },
        calc_function = function(card)
            card.joker_display_values.mult = G.GAME and
                card.ability.extra.mult *
                (math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)) or 0
        end
    },
    j_caino = { -- Canio
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "caino_xmult" }
                }
            }
        }
    },
    j_triboulet = { -- Triboulet
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.joker_display_values", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("King", "ranks"),  colour = G.C.ORANGE,           scale = 0.3 },
            { text = ",",                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = localize("Queen", "ranks"), colour = G.C.ORANGE,           scale = 0.3 },
            { text = ")",                        colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            local count = 0
            local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
            local text, _, scoring_hand = JokerDisplay.evaluate_hand(hand)
            for k, v in pairs(scoring_hand) do
                if not v.debuff and v:get_id() and (v:get_id() == 13 or v:get_id() == 12) then
                    count = count +
                        JokerDisplay.calculate_card_triggers(v, not (text == 'Unknown') and scoring_hand or nil)
                end
            end
            card.joker_display_values.x_mult = card.ability.extra ^ count
        end
    },
    j_yorick = { -- Yorick
        text = {
            {
                border_nodes = {
                    { text = "X" },
                    { ref_table = "card.ability", ref_value = "x_mult" }
                }
            }
        },
        reminder_text = {
            { text = "(",                                                         colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { ref_table = "card.joker_display_values",                            ref_value = "yorick_discards", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
            { text = "/" .. G.P_CENTERS["j_yorick"].config.extra.discards .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 },
        },
        calc_function = function(card)
            card.joker_display_values.yorick_discards = card.ability.yorick_discards or card.ability.extra.discards
        end
    },
    j_chicot = { -- Chicot
        reminder_text = {
            { ref_table = "card.joker_display_values", ref_value = "active_text", scale = 0.3 },
        },
        calc_function = function(card)
            local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and (G.GAME.blind:get_type() == 'Boss')
            card.joker_display_values.active = disableable
            card.joker_display_values.active_text = localize(disableable and 'k_active' or 'ph_no_boss_active')
        end,
        style_function = function(card, text, reminder_text, extra)
            if reminder_text and reminder_text.children[1] then
                reminder_text.children[1].config.colour = card.joker_display_values.active and G.C.GREEN or
                    G.C.RED
                reminder_text.children[1].config.scale = card.joker_display_values.active and 0.35 or 0.3
                return true
            end
            return false
        end
    },
    j_perkeo = { -- Perkeo
    }
}
