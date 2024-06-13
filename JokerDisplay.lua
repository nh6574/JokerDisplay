--- STEAMODDED HEADER
--- MOD_NAME: JokerDisplay
--- MOD_ID: JokerDisplay
--- MOD_AUTHOR: [nh6574]
--- MOD_DESCRIPTION: Display information underneath Jokers

----------------------------------------------
------------MOD CODE -------------------------

--- UPDATE CONDITIONS

local node_stop_drag_ref = Node.stop_drag
function Node:stop_drag()
    node_stop_drag_ref(self)
    update_all_joker_display("Node.stop_drag")
end

local cardarea_emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    cardarea_emplace_ref(self, card, location, stay_flipped)
    update_all_joker_display("CardArea.emplace")
end

local cardarea_load_ref = CardArea.load
function CardArea:load(cardAreaTable)
    cardarea_load_ref(self, cardAreaTable)
    if self == G.jokers then
        update_all_joker_display("CardArea.load")
    end
end

local cardarea_parse_highlighted_ref = CardArea.parse_highlighted
function CardArea:parse_highlighted()
    cardarea_parse_highlighted_ref(self)
    update_all_joker_display("CardArea.parse_highlighted")
end

local cardarea_remove_card_ref = CardArea.remove_card
function CardArea:remove_card(card, discarded_only)
    local t = cardarea_remove_card_ref(self, card, discarded_only)
    update_all_joker_display("CardArea.remove_card")
    return t
end

local card_calculate_joker_ref = Card.calculate_joker
function Card:calculate_joker(context)
    local t = card_calculate_joker_ref(self, context)

    if G.jokers and self.area == G.jokers then
        self:update_joker_display("Card.calculate_joker")
    end
    return t
end

---DISPLAY CONFIGURATION

---Updates the JokerDisplay and initializes it if necessary.
---@param from string? Optional string with information of where the call is from. For debug purposes.
function Card:update_joker_display(from)
    if self.ability and self.ability.set == 'Joker' and not self.no_ui and not G.debug_tooltip_toggle then
        --sendDebugMessage(self.ability.name .. ((" " .. from) or ""))

        if not self.children.joker_display then
            self.joker_display_values = {}

            --Regular Display
            self.joker_display_nodes = self:initialize_joker_display()
            self.config.joker_display = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.6,
                    maxh = 1.2,
                    minw = 2,
                    maxw = 2,
                    r = 0.001,
                    padding = 0.1,
                    align = 'cm',
                    colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.8),
                    shadow = true,
                    func = 'joker_display_disable',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { ref_table = self, align = "cm", func = "joker_display_style_override" },
                        nodes = self.joker_display_nodes
                    }

                }
            }

            self.config.joker_display_config = {
                align = "bm",
                bond = 'Strong',
                parent = self,
            }
            if self.config.joker_display then
                self.children.joker_display = UIBox {
                    definition = self.config.joker_display,
                    config = self.config.joker_display_config,
                }
                self.children.joker_display.states.collide.can = false
                self.children.joker_display.states.drag.can = true
            end

            --Debuff Display
            self.config.joker_display_debuff = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.6,
                    maxh = 1.2,
                    minw = 2,
                    maxw = 2,
                    r = 0.001,
                    padding = 0.1,
                    align = 'cm',
                    colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.8),
                    shadow = true,
                    func = 'joker_display_debuff',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = { { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = localize("k_debuffed"), scale = 0.4, colour = G.C.UI.TEXT_INACTIVE } } } } }
                    }

                }
            }

            self.config.joker_display_debuff_config = {
                align = "bm",
                bond = 'Strong',
                parent = self,
            }
            if self.config.joker_display_debuff then
                self.children.joker_display_debuff = UIBox {
                    definition = self.config.joker_display_debuff,
                    config = self.config.joker_display_debuff_config,
                }
                self.children.joker_display_debuff.states.collide.can = false
                self.children.joker_display_debuff.states.drag.can = true
            end

            --Perishable Display
            self.config.joker_display_perishable = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.5,
                    maxh = 0.5,
                    minw = 0.75,
                    maxw = 0.75,
                    r = 0.001,
                    padding = 0.1,
                    align = 'cm',
                    colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.8),
                    shadow = false,
                    func = 'joker_display_perishable',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = { { n = G.UIT.R, config = { align = "cm" }, nodes = { create_display_text_object({ ref_table = self.joker_display_values, ref_value = "perishable", colour = lighten(G.C.PERISHABLE, 0.35), scale = 0.35 }) } } }
                    }

                }
            }

            self.config.joker_display_perishable_config = {
                align = "tl",
                bond = 'Strong',
                parent = self,
                offset = { x = 0.8, y = 0 },
            }
            if self.config.joker_display_perishable then
                self.children.joker_display_perishable = UIBox {
                    definition = self.config.joker_display_perishable,
                    config = self.config.joker_display_perishable_config,
                }
                self.children.joker_display_perishable.states.collide.can = false
                self.children.joker_display_perishable.states.drag.can = true
            end

            --Rental Display
            self.config.joker_display_rental = {
                n = G.UIT.ROOT,
                config = {
                    minh = 0.5,
                    maxh = 0.5,
                    minw = 0.75,
                    maxw = 0.75,
                    r = 0.001,
                    padding = 0.1,
                    align = 'cm',
                    colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.8),
                    shadow = false,
                    func = 'joker_display_rental',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = { { n = G.UIT.R, config = { align = "cm" }, nodes = { create_display_text_object({ ref_table = self.joker_display_values, ref_value = "rental", colour = G.C.GOLD, scale = 0.35 }) } } }
                    }

                }
            }

            self.config.joker_display_rental_config = {
                align = "tr",
                bond = 'Strong',
                parent = self,
                offset = { x = -0.8, y = 0 },
            }
            if self.config.joker_display_rental then
                self.children.joker_display_rental = UIBox {
                    definition = self.config.joker_display_rental,
                    config = self.config.joker_display_rental_config,
                }
                self.children.joker_display_rental.states.collide.can = false
                self.children.joker_display_rental.states.drag.can = true
            end
        else
            self:calculate_joker_display()
        end
    end
end

---Updates the JokerDisplay for all jokers and initializes it if necessary.
---@param from string? Optional string with information of where the call is from. For debug purposes.
function update_all_joker_display(from)
    if G.jokers then
        for k, v in pairs(G.jokers.cards) do
            v:update_joker_display(from)
        end
    end
end

--HELPER FUNCTIONS

---Returns scoring information about a set of cards. Similar to _G.FUNCS.evaluate_play_.
---@param cards table Cards to calculate.
---@return string text Scoring poker hand's non-localized text.
---@return table poker_hands Poker hands contained in the scoring hand.
---@return table scoring_hand Scoring cards in hand.
function joker_display_evaluate_hand(cards)
    local text, _, poker_hands, scoring_hand, _ = G.FUNCS.get_poker_hand_info(cards)

    local pures = {}
    for i = 1, #cards do
        if next(find_joker('Splash')) then
            scoring_hand[i] = cards[i]
        else
            if cards[i].ability.effect == 'Stone Card' then
                local inside = false
                for j = 1, #scoring_hand do
                    if scoring_hand[j] == cards[i] then
                        inside = true
                    end
                end
                if not inside then table.insert(pures, cards[i]) end
            end
        end
    end
    for i = 1, #pures do
        table.insert(scoring_hand, pures[i])
    end
    return text, poker_hands, scoring_hand
end

---Returns what Joker the current card (i.e. Blueprint or Brainstorm) is copying.
---@param card table Blueprint or Brainstorm card to calculate copy.
---@param _cycle_count integer? Counts how many times the function has recurred to prevent loops.
---@return string|nil name Copied Joker's non-localized name if any.
---@return string|nil key Copied Joker's key if any.
function calculate_blueprint_copy(card, _cycle_count)
    if _cycle_count and _cycle_count > #G.jokers.cards + 1 then
        return nil, nil
    end
    local other_joker = nil
    if card.ability.name == "Blueprint" then
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                other_joker = G.jokers.cards[i + 1]
            end
        end
    elseif card.ability.name == "Brainstorm" then
        other_joker = G.jokers.cards[1]
    end
    if other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat then
        if other_joker.ability.name == "Blueprint" or other_joker.ability.name == "Brainstorm" then
            return calculate_blueprint_copy(other_joker, _cycle_count and _cycle_count + 1 or 1)
        else
            return other_joker.ability.name, other_joker.config.center.key
        end
    end
    return nil, nil
end

---Returns all held instances of certain Joker, including Blueprint copies. Similar to _find_joker_.
---@param name string Name of the Joker to find.
---@param non_debuff boolean? If true also returns debuffed cards.
---@return table #All Jokers found, including Jokers with copy abilities.
function find_joker_or_copy(name, non_debuff)
    local jokers = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for k, v in pairs(G.jokers.cards) do
        if v and type(v) == 'table' and
            (v.ability.name == name or
                v.joker_display_values and v.joker_display_values.blueprint_ability_name and
                v.joker_display_values.blueprint_ability_name == name) and
            (non_debuff or not v.debuff) then
            table.insert(jokers, v)
        end
    end
    for k, v in pairs(G.consumeables.cards) do
        if v and type(v) == 'table' and
            (v.ability.name == name or
                v.joker_display_values and v.joker_display_values.blueprint_ability_name and
                v.joker_display_values.blueprint_ability_name == name) and
            (non_debuff or not v.debuff) then
            table.insert(jokers, v)
        end
    end

    local blueprint_count = 0
    for k, v in pairs(jokers) do
        if v.ability.name == "Blueprint" or v.ability.name == "Brainstorm" then
            blueprint_count = blueprint_count + 1
        end
    end
    if blueprint_count >= #jokers then
        return {}
    end

    return jokers
end

---Returns the leftmost card in a set of cards.
---@param cards table Cards to calculate.
---@return table|nil # Leftmost card in hand if any.
function calculate_leftmost_card(cards)
    if not cards or type(cards) ~= "table" then
        return nil
    end
    local leftmost = cards[1]
    for i = 1, #cards do
        if cards[i].T.x < leftmost.T.x then
            leftmost = cards[i]
        end
    end
    return leftmost
end

---Returns how many times the scoring card would be triggered for scoring if played.
---@param card table Card to calculate.
---@param first_card table? First card in hand.
---@param held_in_hand boolean? If the card is held in hand and not a scoring card.
---@return integer # Times the card would retrigger. (0 if debuffed)
function calculate_card_triggers(card, first_card, held_in_hand)
    if card.debuff then
        return 0
    end

    local triggers = 1

    triggers = triggers + (held_in_hand and #find_joker_or_copy('Mime') or 0)
    if not held_in_hand then
        triggers = triggers + (#find_joker_or_copy('Seltzer') or 0)
        triggers = triggers + (card:is_face() and #find_joker_or_copy('Sock and Buskin') or 0)
        triggers = triggers +
            ((card:get_id() == 2 or card:get_id() == 3 or card:get_id() == 4 or card:get_id() == 5) and #find_joker_or_copy('Hack') or 0)
        triggers = triggers + (G.GAME.current_round.hands_left == 0 and #find_joker_or_copy('Dusk') or 0)
        triggers = triggers + (first_card and card == first_card and #find_joker_or_copy('Hanging Chad') * 2 or 0)
    end
    triggers = triggers + (card:get_seal() == 'Red' and 1 or 0)

    return triggers
end

---Creates a G.UIT.T object with JokerDisplay configurations for text display.
---@param config {text: string?, ref_table: table?, ref_value: string?, scale: number?, colour: table?}
---@return table
function create_display_text_object(config)
    local text_node = {}
    if config.ref_table then
        text_node = { n = G.UIT.T, config = { ref_table = config.ref_table, ref_value = config.ref_value, scale = config.scale or 0.4, colour = config.colour or G.C.UI.TEXT_LIGHT } }
    else
        text_node = { n = G.UIT.T, config = { text = config.text or "ERROR", scale = config.scale or 0.4, colour = config.colour or G.C.UI.TEXT_LIGHT } }
    end
    return text_node
end

---Creates a G.UIT.C object with JokerDisplay configurations for text borders (e.g. for XMULT).
---@param nodes table Nodes contained inside the border.
---@param border_color table Color of the border.
---@return table
function create_display_border_text_object(nodes, border_color)
    return {
        n = G.UIT.C,
        config = { colour = border_color, r = 0.05, padding = 0.03, res = 0.15 },
        nodes = nodes
    }
end

---Creates a G.UIT.R object with JokerDisplay configurations for displaying a row.
---@param node_rows table Nodes contained in the row.
---@return table
function create_display_row_objects(node_rows)
    local row_nodes = {}

    for _, row in pairs(node_rows) do
        row_nodes[#row_nodes + 1] = { n = G.UIT.R, config = { align = "cm" }, nodes = row }
    end

    return row_nodes
end

---STYLE MOD FUNCTIONS
G.FUNCS.joker_display_disable = function(e)
    local card = e.config.ref_table
    if card.facing == 'back' or card.debuff then
        e.states.visible = false
    else
        e.states.visible = true
    end
end

G.FUNCS.joker_display_debuff = function(e)
    local card = e.config.ref_table
    if card.facing ~= 'back' and card.debuff then
        e.states.visible = true
    else
        e.states.visible = false
    end
end

G.FUNCS.joker_display_perishable = function(e)
    local card = e.config.ref_table
    if card.facing ~= 'back' and card.ability.perishable then
        e.states.visible = true
    else
        e.states.visible = false
    end
end

G.FUNCS.joker_display_rental = function(e)
    local card = e.config.ref_table
    if card.facing ~= 'back' and card.ability.rental then
        e.states.visible = true
    else
        e.states.visible = false
    end
end

---Modifies JokerDisplay's nodes style values dinamically
---@param e table
G.FUNCS.joker_display_style_override = function(e)
    local card = e.config.ref_table

    if card.ability.name == 'Sixth Sense' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and
                G.C.UI.TEXT_LIGHT or
                G.C.UI.TEXT_INACTIVE
        end
    elseif card.ability.name == 'Vagabond' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and
                G.C.SECONDARY_SET.Tarot or
                G.C.UI.TEXT_INACTIVE
        end
    elseif card.ability.name == 'Luchador' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and G.C.GREEN or
                G.C.RED
            e.children[1].children[1].config.scale = card.joker_display_values.active and 0.4 or 0.3
            e.UIBox:recalculate(true)
        end
    elseif card.ability.name == 'Trading Card' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and G.C.GOLD or
                G.C.UI.TEXT_INACTIVE
        end
    elseif card.ability.name == 'Ancient Joker' then
        if e.children and e.children[2] and card.joker_display_values then
            e.children[2].children[2].config.colour = G.C.SUITS[G.GAME.current_round.ancient_card.suit]
        end
    elseif card.ability.name == 'Castle' then
        if e.children and e.children[2] and card.joker_display_values then
            e.children[2].children[2].config.colour = G.C.SUITS[G.GAME.current_round.castle_card.suit]
        end
    elseif card.ability.name == 'The Idol' then
        if e.children and e.children[2] and card.joker_display_values then
            e.children[2].children[4].config.colour = G.C.SUITS[G.GAME.current_round.idol_card.suit]
        end
    elseif card.ability.name == 'Matador' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and G.C.GOLD or
                G.C.RED
            e.children[1].children[1].config.scale = card.joker_display_values.active and 0.4 or 0.3
            e.UIBox:recalculate(true)
        end
    elseif card.ability.name == "Driver's License" then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and G.C.XMULT or
                adjust_alpha(G.C.UI.TEXT_INACTIVE, 0)
            e.children[1].children[1].children[1].config.colour = card.joker_display_values.active and
                G.C.UI.TEXT_LIGHT or G.C.UI.TEXT_INACTIVE
        end
    elseif card.ability.name == 'Chicot' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values.active and G.C.GREEN or
                G.C.RED
            e.children[1].children[1].config.scale = card.joker_display_values.active and 0.4 or 0.3
            e.UIBox:recalculate(true)
        end
    elseif card.ability.name == 'Blueprint' or card.ability.name == 'Brainstorm' then
        if e.children and e.children[1] and card.joker_display_values then
            e.children[1].children[1].config.colour = card.joker_display_values
                .blueprint_ability_name and G.C.GREEN or
                G.C.RED
        end
    end
end

---DISPLAY DEFINITION

---Initializes nodes for JokerDisplay.
---@return table # JokerDisplay nodes for the card.
function Card:initialize_joker_display()
    self.joker_display_values.is_empty = true
    self:calculate_joker_display()

    local text_rows = self:define_joker_display()
    if not text_rows or not next(text_rows) then
        text_rows[1] = { create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "empty",
            colour =
                G.C.UI.TEXT_INACTIVE
        }) }
    else
        self.joker_display_values.is_empty = false
        self.joker_display_values.mod_begin = (self.joker_display_values.has_mod and " " or "") ..
            self.joker_display_values.mod_begin
    end

    table.insert(text_rows[1],
        create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "mod_begin",
            colour = G.C.UI
                .TEXT_INACTIVE
        }))
    table.insert(text_rows[1],
        create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips_mod", colour = G.C.CHIPS }))
    table.insert(text_rows[1],
        create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult_mod", colour = G.C.MULT }))
    local xmult_border = create_display_border_text_object(
        { create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult_mod" }) }, G.C.XMULT)
    xmult_border.config.padding = 0
    xmult_border.config.id = "xmult_mod"
    table.insert(text_rows[1], xmult_border)
    table.insert(text_rows[1],
        create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "mod_end",
            colour = G.C.UI
                .TEXT_INACTIVE
        }))

    return create_display_row_objects(text_rows)
end

---Defines nodes for the joker for JokerDisplay.
---@return table # JokerDisplay text nodes for the card.
function Card:define_joker_display()
    local text_rows = {}

    if self.ability.name == 'Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Greedy Joker' or self.ability.name == 'Lusty Joker' or
        self.ability.name == 'Wrathful Joker' or self.ability.name == 'Gluttonous Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                text = localize(self.ability.extra.suit, 'suits_plural'),
                colour = loc_colour(
                    self.ability.extra.suit:lower()),
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Jolly Joker' or self.ability.name == 'Zany Joker' or
        self.ability.name == 'Mad Joker' or self.ability.name == 'Crazy Joker' or
        self.ability.name == 'Droll Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize(self.ability.type, 'poker_hands'), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Sly Joker' or self.ability.name == 'Wily Joker' or
        self.ability.name == 'Clever Joker' or self.ability.name == 'Devious Joker' or
        self.ability.name == 'Crafty Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
        text_rows[2] = {
            create_display_text_object({ text = " (", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize(self.ability.type, 'poker_hands'), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Half Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Joker Stencil' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Four Fingers' then
    elseif self.ability.name == 'Mime' then
    elseif self.ability.name == 'Credit Card' then
    elseif self.ability.name == 'Ceremonial Dagger' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Banner' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'Mystic Summit' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Marble Joker' then
    elseif self.ability.name == 'Loyalty Card' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "loyalty_text",
                colour = G.C
                    .UI.TEXT_INACTIVE,
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == '8 Ball' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "count" }),
            create_display_text_object({ text = "x", scale = 0.35 }),
            create_display_text_object({ text = localize("k_tarot"), colour = G.C.SECONDARY_SET.Tarot }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "odds", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ text = " in " .. self.ability.extra .. ")", colour = G.C.GREEN, scale = 0.3 }),
        }
    elseif self.ability.name == 'Misprint' then
        local r_mults = {}
        for i = self.ability.extra.min, self.ability.extra.max do
            r_mults[#r_mults + 1] = tostring(i)
        end
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            { n = G.UIT.O, config = { object = DynaText({ string = r_mults, colours = { G.C.RED }, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.4, min_cycle_time = 0 }) } }
        }
    elseif self.ability.name == 'Dusk' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "active",
                colour = G.C.UI
                    .TEXT_INACTIVE
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Raised Fist' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Chaos the Clown' then
    elseif self.ability.name == 'Fibonacci' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({
                text = "(" .. localize("Ace", "ranks") .. ",2,3,5,8)",
                colour = G.C.UI
                    .TEXT_INACTIVE,
                scale = 0.3
            }),
        }
    elseif self.ability.name == 'Steel Joker' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Scary Face' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("k_face_cards"), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Abstract Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Delayed Gratification' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
            create_display_text_object({ text = " (" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 })
        }
    elseif self.ability.name == 'Hack' then
        text_rows[1] = {
            create_display_text_object({ text = "(2,3,4,5)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 }),
        }
    elseif self.ability.name == 'Pareidolia' then
    elseif self.ability.name == 'Gros Michel' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Even Steven' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(10,8,6,4,2)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Odd Todd' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
        text_rows[2] = {
            create_display_text_object({
                text = "(" .. localize("Ace", "ranks") .. ",9,7,5,3)",
                colour = G.C.UI
                    .TEXT_INACTIVE,
                scale = 0.3
            }),
        }
    elseif self.ability.name == 'Scholar' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS }),
            create_display_text_object({ text = " +", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(" .. localize("k_aces") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Business Card' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "count" }),
            create_display_text_object({ text = "x", scale = 0.35 }),
            create_display_text_object({ text = localize('$') .. "2", colour = G.C.GOLD }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "odds", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ text = " in " .. self.ability.extra .. ")", colour = G.C.GREEN, scale = 0.3 }),
        }
    elseif self.ability.name == 'Supernova' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Ride the Bus' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Burglar' then
    elseif self.ability.name == 'Space Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "odds", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ text = " in " .. self.ability.extra .. ")", colour = G.C.GREEN, scale = 0.3 }),
        }
    elseif self.ability.name == 'Egg' then
        text_rows[1] = {
            create_display_text_object({ text = localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self, ref_value = "sell_cost", colour = G.C.GOLD })
        }
    elseif self.ability.name == 'Blackboard' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Runner' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'Ice Cream' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'DNA' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "active",
                colour = G.C.UI
                    .TEXT_INACTIVE
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Splash' then
    elseif self.ability.name == 'Blue Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'Sixth Sense' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "active_text" }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "count" }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "active_text_spectral",
                colour =
                    G.C.SECONDARY_SET.Spectral
            })
        }
    elseif self.ability.name == 'Constellation' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Hiker' then
    elseif self.ability.name == 'Faceless Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
        }
    elseif self.ability.name == 'Green Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Superposition' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.SECONDARY_SET.Tarot }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "count",
                colour = G.C
                    .SECONDARY_SET.Tarot
            }),
            create_display_text_object({ text = " " .. localize("k_tarot"), colour = G.C.SECONDARY_SET.Tarot }),
        }
        text_rows[2] = {
            create_display_text_object({
                text = "(" ..
                    localize("Ace", "ranks") .. "+" .. localize('Straight', "poker_hands") .. ")",
                colour = G.C.UI.TEXT_INACTIVE,
                scale = 0.3
            }),
        }
    elseif self.ability.name == 'To Do List' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "to_do_poker_hand",
                colour =
                    G.C.ORANGE,
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Cavendish' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability.extra, ref_value = "Xmult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Card Sharp' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Red Card' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Madness' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Square Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'Seance' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.SECONDARY_SET.Spectral }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "count",
                colour = G.C.SECONDARY_SET
                    .Spectral
            }),
            create_display_text_object({ text = " " .. localize("k_spectral"), colour = G.C.SECONDARY_SET.Spectral })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                text = localize(self.ability.extra.poker_hand, 'poker_hands'),
                colour = G.C
                    .ORANGE,
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Riff-raff' then
    elseif self.ability.name == 'Vampire' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Shortcut' then
    elseif self.ability.name == 'Hologram' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Vagabond' then
        text_rows[1] = { create_display_text_object({ ref_table = self.joker_display_values, ref_value = "active_text" }) }
    elseif self.ability.name == 'Baron' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Cloud 9' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
            create_display_text_object({ text = " (" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 })
        }
    elseif self.ability.name == 'Rocket' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "dollars", colour = G.C.GOLD }),
            create_display_text_object({ text = " (" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 })
        }
    elseif self.ability.name == 'Obelisk' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Midas Mask' then
    elseif self.ability.name == 'Luchador' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "active_text" }),
        }
    elseif self.ability.name == 'Photograph' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("k_face_cards"), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Gift Card' then
    elseif self.ability.name == 'Turtle Bean' then
        text_rows[1] = {
            create_display_text_object({ text = "(+", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({
                ref_table = self.ability.extra,
                ref_value = "h_size",
                colour = G.C.UI
                    .TEXT_INACTIVE
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Erosion' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Reserved Parking' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "count" }),
            create_display_text_object({ text = "x", scale = 0.35 }),
            create_display_text_object({ text = localize('$') .. self.ability.extra.dollars, colour = G.C.GOLD }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "odds", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ text = " in " .. self.ability.extra.odds .. ")", colour = G.C.GREEN, scale = 0.3 }),
        }
    elseif self.ability.name == 'Mail-In Rebate' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "mail_card_rank",
                colour = G
                    .C.ORANGE,
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'To the Moon' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
            create_display_text_object({ text = " (" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 })
        }
    elseif self.ability.name == 'Hallucination' then
    elseif self.ability.name == 'Fortune Teller' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Juggler' or self.ability.name == 'Drunkard' then
    elseif self.ability.name == 'Stone Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'Golden Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.ability, ref_value = "extra", colour = G.C.GOLD }),
            create_display_text_object({ text = " (" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 })
        }
    elseif self.ability.name == 'Lucky Cat' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Baseball Card' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "count", colour = G.C.ORANGE }),
            create_display_text_object({ text = "x", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 }),
            create_display_text_object({ text = localize("k_uncommon"), colour = G.C.GREEN }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Bull' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS })
        }
    elseif self.ability.name == 'Diet Cola' then
    elseif self.ability.name == 'Trading Card' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
        }
    elseif self.ability.name == 'Flash Card' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Popcorn' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Spare Trousers' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Ancient Joker' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "ancient_card_suit",
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Ramen' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Walkie Talkie' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS }),
            create_display_text_object({ text = " +", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(10,4)", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Seltzer' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({ ref_table = self.ability, ref_value = "extra", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE })
        }
    elseif self.ability.name == 'Castle' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "chips", colour = G.C.CHIPS }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "castle_card_suit",
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Smiley Face' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT })
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("k_face_cards"), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Campfire' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Golden Ticket' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("k_gold"), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Mr. Bones' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "active",
                colour = G.C.UI
                    .TEXT_INACTIVE
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Acrobat' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Sock and Buskin' then
    elseif self.ability.name == 'Swashbuckler' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.ability, ref_value = "mult", colour = G.C.MULT })
        }
    elseif self.ability.name == 'Troubadour' then
    elseif self.ability.name == 'Certificate' then
    elseif self.ability.name == 'Smeared Joker' then
    elseif self.ability.name == 'Throwback' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Hanging Chad' then
    elseif self.ability.name == 'Rough Gem' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("Diamonds", 'suits_plural'), colour = G.C.SUITS["Diamonds"], scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Bloodstone' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "count" }),
            create_display_text_object({ text = "x", scale = 0.35 }),
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability.extra, ref_value = "Xmult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "odds", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ text = " in " .. self.ability.extra.odds .. ")", colour = G.C.GREEN, scale = 0.3 }),
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("Hearts", 'suits_plural'), colour = G.C.SUITS["Hearts"], scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Arrowhead' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "chips", colour = G.C.CHIPS }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("Spades", 'suits_plural'), colour = G.C.SUITS["Spades"], scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Onyx Agate' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("Clubs", 'suits_plural'), colour = G.C.SUITS["Clubs"], scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Glass Joker' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Showman' then
    elseif self.ability.name == 'Flower Pot' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = "All Suits", colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Blueprint' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "blueprint_compat" }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "blueprint_ability_name_ui",
                colour =
                    G.C.ORANGE,
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Wee Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "chips", colour = G.C.CHIPS }),
        }
    elseif self.ability.name == 'Merry Andy' then
    elseif self.ability.name == 'Oops! All 6s' then
    elseif self.ability.name == 'The Idol' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "idol_card_rank",
                colour = G
                    .C.ORANGE,
                scale = 0.35
            }),
            create_display_text_object({ text = " of ", scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "idol_card_suit",
                scale = 0.35
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Seeing Double' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("Clubs", 'suits_singular'), colour = G.C.SUITS["Clubs"], scale = 0.3 }),
            create_display_text_object({ text = "+", scale = 0.3 }),
            create_display_text_object({ text = localize('k_other'), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Matador' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "active_text" }),
        }
    elseif self.ability.name == 'Hit the Road' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'The Duo' or self.ability.name == 'The Trio'
        or self.ability.name == 'The Family' or self.ability.name == 'The Order' or self.ability.name == 'The Tribe' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize(self.ability.type, 'poker_hands'), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Stuntman' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.CHIPS }),
            create_display_text_object({ ref_table = self.ability.extra, ref_value = "chip_mod", colour = G.C.CHIPS }),
        }
    elseif self.ability.name == 'Invisible Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "active",
                colour = G.C.UI
                    .TEXT_INACTIVE
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Brainstorm' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "blueprint_compat" }),
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "blueprint_ability_name_ui",
                colour =
                    G.C.ORANGE,
                scale = 0.3
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 })
        }
    elseif self.ability.name == 'Satellite' then
        text_rows[1] = {
            create_display_text_object({ text = "+" .. localize('$'), colour = G.C.GOLD }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "dollars", colour = G.C.GOLD }),
            create_display_text_object({ text = " (" .. localize("k_round") .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.35 })
        }
    elseif self.ability.name == 'Shoot the Moon' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT }),
        }
    elseif self.ability.name == "Driver's License" then
        text_rows[1] = {
            create_display_border_text_object(
                { create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) },
                G.C.XMULT)
        }
    elseif self.ability.name == 'Cartomancer' then
    elseif self.ability.name == 'Astronomer' then
    elseif self.ability.name == 'Burnt Joker' then
        text_rows[1] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "active",
                colour = G.C.UI
                    .TEXT_INACTIVE
            }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE }),
        }
    elseif self.ability.name == 'Bootstraps' then
        text_rows[1] = {
            create_display_text_object({ text = "+", colour = G.C.MULT }),
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "mult", colour = G.C.MULT }),
        }
    elseif self.ability.name == 'Caino' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "caino_xmult" }) }, G.C.XMULT)
        }
    elseif self.ability.name == 'Triboulet' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("King", "ranks"), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ",", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({ text = localize("Queen", "ranks"), colour = G.C.ORANGE, scale = 0.3 }),
            create_display_text_object({ text = ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Yorick' then
        text_rows[1] = {
            create_display_border_text_object({ create_display_text_object({ text = "X" }),
                create_display_text_object({ ref_table = self.ability, ref_value = "x_mult" }) }, G.C.XMULT)
        }
        text_rows[2] = {
            create_display_text_object({ text = "(", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
            create_display_text_object({
                ref_table = self.joker_display_values,
                ref_value = "yorick_discards",
                colour = G
                    .C.UI.TEXT_INACTIVE,
                scale = 0.3
            }),
            create_display_text_object({ text = "/" .. self.ability.extra.discards .. ")", colour = G.C.UI.TEXT_INACTIVE, scale = 0.3 }),
        }
    elseif self.ability.name == 'Chicot' then
        text_rows[1] = {
            create_display_text_object({ ref_table = self.joker_display_values, ref_value = "active_text" }),
        }
    elseif self.ability.name == 'Perkeo' then
    end

    return text_rows
end

---DISPLAY CALCULATION

---Calculates values for JokerDisplay. Saves them to Card.joker_display_values.
function Card:calculate_joker_display()
    self.joker_display_values.empty = "-"
    self.joker_display_values.mod_begin = ""
    self.joker_display_values.chips_mod = ""
    self.joker_display_values.mult_mod = ""
    self.joker_display_values.x_mult_mod = ""
    self.joker_display_values.mod_end = ""
    self.joker_display_values.perishable = G.GAME.perishable_rounds .. "/" .. G.GAME.perishable_rounds
    self.joker_display_values.rental = "-$" .. G.GAME.rental_rate
    self.joker_display_values.has_mod = false

    local joker_edition = self:get_edition()
    local baseball_enhancements = (self.config.center.rarity == 2 and #find_joker_or_copy('Baseball Card') or 0)

    if joker_edition then
        if joker_edition.chip_mod then
            self.joker_display_values.chips_mod = "+" ..
                joker_edition.chip_mod .. (((joker_edition.mult_mod or joker_edition.x_mult_mod) and " ") or "")
        end
        if joker_edition.mult_mod then
            self.joker_display_values.mult_mod = "+" ..
                joker_edition.mult_mod .. ((joker_edition.x_mult_mod and " ") or "")
        end
        if baseball_enhancements > 0 then
            local baseball_xmult = find_joker('Baseball Card')[1].ability.extra ^ baseball_enhancements
            baseball_xmult = tonumber(string.format("%.2f", baseball_xmult * (joker_edition.x_mult_mod or 1)))
            self.joker_display_values.x_mult_mod = "X" .. baseball_xmult
        elseif joker_edition.x_mult_mod then
            self.joker_display_values.x_mult_mod = "X" .. joker_edition.x_mult_mod
        end
        if baseball_enhancements > 0 or joker_edition.chip_mod or joker_edition.mult_mod or joker_edition.x_mult_mod then
            self.joker_display_values.mod_begin = (self.joker_display_values.is_empty and "" or " ") .. "("
            self.joker_display_values.mod_end = ")"
            self.joker_display_values.empty = ""
            self.joker_display_values.has_mod = true
        end
    elseif baseball_enhancements > 0 then
        local baseball_xmult = find_joker('Baseball Card')[1].ability.extra ^ baseball_enhancements
        baseball_xmult = tonumber(string.format("%.2f", baseball_xmult))
        self.joker_display_values.x_mult_mod = "X" .. baseball_xmult
        self.joker_display_values.mod_begin = (self.joker_display_values.is_empty and "" or " ") .. "("
        self.joker_display_values.mod_end = ")"
        self.joker_display_values.empty = ""
        self.joker_display_values.has_mod = true
    end

    if self.ability.perishable then
        self.joker_display_values.perishable = self.ability.perish_tally .. "/" .. G.GAME.perishable_rounds
    end

    if self.ability.rental then
        self.joker_display_values.rental = "-$" .. G.GAME.rental_rate
    end

    if self.ability.name == 'Joker' then
    elseif self.ability.name == 'Greedy Joker' or self.ability.name == 'Lusty Joker' or
        self.ability.name == 'Wrathful Joker' or self.ability.name == 'Gluttonous Joker' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit(self.ability.extra.suit) then
                mult = mult + self.ability.extra.s_mult * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Jolly Joker' or self.ability.name == 'Zany Joker' or
        self.ability.name == 'Mad Joker' or self.ability.name == 'Crazy Joker' or
        self.ability.name == 'Droll Joker' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, poker_hands, _ = joker_display_evaluate_hand(hand)
        if next(poker_hands[self.ability.type]) then
            mult = self.ability.t_mult
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Sly Joker' or self.ability.name == 'Wily Joker' or
        self.ability.name == 'Clever Joker' or self.ability.name == 'Devious Joker' or
        self.ability.name == 'Crafty Joker' then
        local chips = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, poker_hands, _ = joker_display_evaluate_hand(hand)
        if next(poker_hands[self.ability.type]) then
            chips = self.ability.t_chips
        end
        self.joker_display_values.chips = chips
    elseif self.ability.name == 'Half Joker' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        if #hand > 0 and #hand <= self.ability.extra.size then
            mult = self.ability.extra.mult
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Joker Stencil' then
    elseif self.ability.name == 'Four Fingers' then
    elseif self.ability.name == 'Mime' then
    elseif self.ability.name == 'Credit Card' then
    elseif self.ability.name == 'Ceremonial Dagger' then
    elseif self.ability.name == 'Banner' then
        self.joker_display_values.chips = self.ability.extra *
            (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left or 0)
    elseif self.ability.name == 'Mystic Summit' then
        self.joker_display_values.mult = self.ability.extra.mult *
            (G.GAME and G.GAME.current_round and G.GAME.current_round.discards_left <= self.ability.extra.d_remaining and 1 or 0)
    elseif self.ability.name == 'Marble Joker' then
    elseif self.ability.name == 'Loyalty Card' then
        self.joker_display_values.loyalty_text = localize { type = 'variable', key = (self.ability.loyalty_remaining == 0 and 'loyalty_active' or 'loyalty_inactive'), vars = { self.ability.loyalty_remaining } }
        self.joker_display_values.x_mult = (self.ability.loyalty_remaining == 0 and self.ability.extra.Xmult or 1)
    elseif self.ability.name == '8 Ball' then
        local count = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and v:get_id() == 8 then
                count = count + 1 * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.count = count
        self.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
    elseif self.ability.name == 'Misprint' then
    elseif self.ability.name == 'Dusk' then
        self.joker_display_values.active = G.GAME and G.GAME.current_round.hands_left <= 1 and localize("k_active_ex") or
            "Inactive"
    elseif self.ability.name == 'Raised Fist' then
        local temp_Mult, temp_ID = 15, 15
        local temp_card = nil
        for i = 1, #G.hand.cards do
            if not G.hand.cards[i].highlighted and temp_ID >= G.hand.cards[i].base.id and G.hand.cards[i].ability.effect ~= 'Stone Card' then
                temp_Mult = G.hand.cards[i].base.nominal * calculate_card_triggers(G.hand.cards[i], nil, true)
                temp_ID = G.hand.cards[i].base.id
                temp_card = G.hand.cards[i]
            end
        end
        if temp_card and temp_card.debuff then
            temp_Mult = 0
        end
        self.joker_display_values.mult = (temp_Mult < 15 and temp_Mult * 2 or 0)
    elseif self.ability.name == 'Chaos the Clown' then
    elseif self.ability.name == 'Fibonacci' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and v:get_id() == 2 or v:get_id() == 3 or v:get_id() == 5
                or v:get_id() == 8 or v:get_id() == 14 then
                mult = mult + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Steel Joker' then
        self.joker_display_values.x_mult = 1 + self.ability.extra * (self.ability.steel_tally or 0)
    elseif self.ability.name == 'Scary Face' then
        local chips = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_face() then
                chips = chips + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.chips = chips
    elseif self.ability.name == 'Abstract Joker' then
        self.joker_display_values.mult = (G.jokers and G.jokers.cards and #G.jokers.cards or 0) * self.ability.extra
    elseif self.ability.name == 'Delayed Gratification' then
        self.joker_display_values.dollars = (G.GAME and G.GAME.current_round.discards_used == 0 and G.GAME.current_round.discards_left > 0 and G.GAME.current_round.discards_left * self.ability.extra or 0)
    elseif self.ability.name == 'Hack' then
    elseif self.ability.name == 'Pareidolia' then
    elseif self.ability.name == 'Gros Michel' then
    elseif self.ability.name == 'Even Steven' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and v:get_id() <= 10 and v:get_id() >= 0 and v:get_id() % 2 == 0 then
                mult = mult + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Odd Todd' then
        local chips = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and ((v:get_id() <= 10 and v:get_id() >= 0 and
                    v:get_id() % 2 == 1) or (v:get_id() == 14)) then
                chips = chips + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.chips = chips
    elseif self.ability.name == 'Scholar' then
        local chips, mult = 0, 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and v:get_id() == 14 then
                local retriggers = calculate_card_triggers(v, first_card)
                chips = chips + self.ability.extra.chips * retriggers
                mult = mult + self.ability.extra.mult * retriggers
            end
        end
        self.joker_display_values.mult = mult
        self.joker_display_values.chips = chips
    elseif self.ability.name == 'Business Card' then
        local count = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_face() then
                count = count + 1 * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.count = count
        self.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
    elseif self.ability.name == 'Supernova' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local text, _, _ = joker_display_evaluate_hand(hand)
        self.joker_display_values.mult = (G.GAME and G.GAME.hands[text] and G.GAME.hands[text].played) or 0
    elseif self.ability.name == 'Ride the Bus' then
    elseif self.ability.name == 'Egg' then
    elseif self.ability.name == 'Burglar' then
    elseif self.ability.name == 'Space Joker' then
        self.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
    elseif self.ability.name == 'Blackboard' then
        local playing_hand = next(G.play.cards)
        local black_suits, all_cards = 0, 0
        local is_all_black_suits = false
        for k, v in ipairs(G.hand.cards) do
            if playing_hand or not v.highlighted then
                all_cards = all_cards + 1
                if v:is_suit('Clubs', nil, true) or v:is_suit('Spades', nil, true) then
                    black_suits = black_suits + 1
                end
            end
            is_all_black_suits = black_suits == all_cards
        end
        self.joker_display_values.x_mult = is_all_black_suits and self.ability.extra or 1
    elseif self.ability.name == 'Runner' then
    elseif self.ability.name == 'Ice Cream' then
    elseif self.ability.name == 'DNA' then
        self.joker_display_values.active = (G.GAME and G.GAME.current_round.hands_played == 0 and localize("k_active_ex") or "Inactive")
    elseif self.ability.name == 'Splash' then
    elseif self.ability.name == 'Blue Joker' then
        self.joker_display_values.chips = self.ability.extra * ((G.deck and G.deck.cards) and #G.deck.cards or 52)
    elseif self.ability.name == 'Sixth Sense' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local sixth_sense_eval = #scoring_hand == 1 and scoring_hand[1]:get_id() == 6
        self.joker_display_values.active = G.GAME and G.GAME.current_round.hands_played == 0
        self.joker_display_values.count = self.joker_display_values.active and tostring(sixth_sense_eval and 1 or 0) or
            ""
        self.joker_display_values.active_text = self.joker_display_values.active and "+" or "(Inactive)"
        self.joker_display_values.active_text_spectral = self.joker_display_values.active and
            " " .. localize("k_spectral") or ""
    elseif self.ability.name == 'Constellation' then
    elseif self.ability.name == 'Hiker' then
    elseif self.ability.name == 'Faceless Joker' then
        local count = 0
        local hand = G.hand.highlighted
        for k, v in pairs(hand) do
            if v:is_face() then
                count = count + 1
            end
        end
        self.joker_display_values.dollars = count >= self.ability.extra.faces and self.ability.extra.dollars or 0
    elseif self.ability.name == 'Green Joker' then
    elseif self.ability.name == 'Superposition' then
        local has_ace, has_straight = false, false
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, poker_hands, scoring_hand = joker_display_evaluate_hand(hand)
        for k, v in pairs(scoring_hand) do
            if v:get_id() == 14 then
                has_ace = true
            end
        end
        if next(poker_hands["Straight"]) then
            has_straight = true
        end
        self.joker_display_values.count = has_ace and has_straight and 1 or 0
    elseif self.ability.name == 'To Do List' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local text, _, _ = joker_display_evaluate_hand(hand)
        local is_to_do_poker_hand = text == self.ability.to_do_poker_hand
        self.joker_display_values.dollars = is_to_do_poker_hand and self.ability.extra.dollars or 0
        self.joker_display_values.to_do_poker_hand = localize(self.ability.to_do_poker_hand, 'poker_hands')
    elseif self.ability.name == 'Cavendish' then
    elseif self.ability.name == 'Card Sharp' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local text, _, _ = joker_display_evaluate_hand(hand)
        local is_card_sharp_hand = G.GAME.hands and G.GAME.hands[text] and
            G.GAME.hands[text].played_this_round > (next(G.play.cards) and 1 or 0)
        self.joker_display_values.x_mult = is_card_sharp_hand and self.ability.extra.Xmult or 1
    elseif self.ability.name == 'Red Card' then
    elseif self.ability.name == 'Madness' then
    elseif self.ability.name == 'Square Joker' then
    elseif self.ability.name == 'Seance' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local text, _, _ = joker_display_evaluate_hand(hand)
        local is_seance_hand = text == self.ability.extra.poker_hand
        self.joker_display_values.count = is_seance_hand and 1 or 0
    elseif self.ability.name == 'Riff-raff' then
    elseif self.ability.name == 'Vampire' then
    elseif self.ability.name == 'Shortcut' then
    elseif self.ability.name == 'Hologram' then
    elseif self.ability.name == 'Vagabond' then
        self.joker_display_values.active = G.GAME and G.GAME.dollars < 5
        self.joker_display_values.active_text = self.joker_display_values.active and localize("k_plus_tarot") or
            "(Inactive)"
    elseif self.ability.name == 'Baron' then
        local playing_hand = next(G.play.cards)
        local count = 0
        for k, v in ipairs(G.hand.cards) do
            if playing_hand or not v.highlighted then
                if not v.debuff and v:get_id() == 13 then
                    count = count + 1 * calculate_card_triggers(v, nil, true)
                end
            end
        end
        self.joker_display_values.x_mult = tonumber(string.format("%.2f", (self.ability.extra ^ count)))
    elseif self.ability.name == 'Cloud 9' then
        self.joker_display_values.dollars = self.ability.extra * (self.ability.nine_tally or 0)
    elseif self.ability.name == 'Rocket' then
    elseif self.ability.name == 'Obelisk' then
        local hand = G.hand.highlighted
        local text, _, _ = joker_display_evaluate_hand(hand)
        local play_more_than = 0
        for k, v in pairs(G.GAME.hands) do
            if v.played >= play_more_than and v.visible then
                play_more_than = v.played
            end
        end
        local hand_exits = G.GAME and G.GAME.hands and G.GAME.hands[text]
        self.joker_display_values.x_mult = (hand_exits and (G.GAME.hands[text].played >= play_more_than and 1 or self.ability.x_mult + self.ability.extra) or self.ability.x_mult)
    elseif self.ability.name == 'Midas Mask' then
    elseif self.ability.name == 'Luchador' then
        local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and
            ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
        self.joker_display_values.active = disableable
        self.joker_display_values.active_text = localize(disableable and 'k_active' or 'ph_no_boss_active')
    elseif self.ability.name == 'Photograph' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local face_cards = {}
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_face() then
                table.insert(face_cards, v)
            end
        end
        local first_face = calculate_leftmost_card(face_cards)
        self.joker_display_values.x_mult = first_face and
            (self.ability.extra ^ calculate_card_triggers(first_face, first_card)) or 1
    elseif self.ability.name == 'Gift Card' then
    elseif self.ability.name == 'Turtle Bean' then
    elseif self.ability.name == 'Erosion' then
        self.joker_display_values.mult = math.max(0,
            self.ability.extra * (G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0))
    elseif self.ability.name == 'Reserved Parking' then
        local playing_hand = next(G.play.cards)
        local count = 0
        for k, v in ipairs(G.hand.cards) do
            if playing_hand or not v.highlighted then
                if v:is_face() then
                    count = count + 1 * calculate_card_triggers(v, nil, true)
                end
            end
        end
        self.joker_display_values.count = count
        self.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
    elseif self.ability.name == 'Mail-In Rebate' then
        local dollars = 0
        local hand = G.hand.highlighted
        for k, v in pairs(hand) do
            if not v.debuff and v:get_id() == G.GAME.current_round.mail_card.id then
                dollars = dollars + self.ability.extra
            end
        end
        self.joker_display_values.dollars = dollars
        self.joker_display_values.mail_card_rank = localize(G.GAME.current_round.mail_card.rank, 'ranks')
    elseif self.ability.name == 'To the Moon' then
        self.joker_display_values.dollars = G.GAME and G.GAME.dollars and
            math.max(math.min(math.floor(G.GAME.dollars / 5), G.GAME.interest_cap / 5), 0) * self.ability.extra
    elseif self.ability.name == 'Hallucination' then
    elseif self.ability.name == 'Fortune Teller' then
        self.joker_display_values.mult = G.GAME and G.GAME.consumeable_usage_total and
            G.GAME.consumeable_usage_total.tarot or 0
    elseif self.ability.name == 'Juggler' or self.ability.name == 'Drunkard' then
    elseif self.ability.name == 'Stone Joker' then
        self.joker_display_values.chips = self.ability.extra * (self.ability.stone_tally or 0)
    elseif self.ability.name == 'Golden Joker' then
    elseif self.ability.name == 'Lucky Cat' then
    elseif self.ability.name == 'Baseball Card' then
        local count = 0
        if G.jokers then
            for k, v in ipairs(G.jokers.cards) do
                if v.config.center.rarity == 2 then
                    count = count + 1
                end
            end
        end
        self.joker_display_values.count = count
    elseif self.ability.name == 'Bull' then
        self.joker_display_values.chips = self.ability.extra * (math.max(0, G.GAME.dollars) or 0)
    elseif self.ability.name == 'Diet Cola' then
    elseif self.ability.name == 'Trading Card' then
        local is_trading_card_discard = #G.hand.highlighted == 1
        self.joker_display_values.active = G.GAME and G.GAME.current_round.discards_used == 0
        self.joker_display_values.dollars = self.joker_display_values.active and
            ("+" .. localize('$') .. (is_trading_card_discard and self.ability.extra or 0)) or "(Inactive)"
    elseif self.ability.name == 'Flash Card' then
    elseif self.ability.name == 'Popcorn' then
    elseif self.ability.name == 'Spare Trousers' then
    elseif self.ability.name == 'Ancient Joker' then
        local count = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit(G.GAME.current_round.ancient_card.suit) then
                count = count + 1 * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.x_mult = tonumber(string.format("%.2f", (self.ability.extra ^ count)))
        self.joker_display_values.ancient_card_suit = localize(G.GAME.current_round.ancient_card.suit, 'suits_singular')
    elseif self.ability.name == 'Ramen' then
    elseif self.ability.name == 'Walkie Talkie' then
        local chips, mult = 0, 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and (v:get_id() == 10 or v:get_id() == 4) then
                local retriggers = calculate_card_triggers(v, first_card)
                chips = chips + self.ability.extra.chips * retriggers
                mult = mult + self.ability.extra.mult * retriggers
            end
        end
        self.joker_display_values.chips = chips
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Seltzer' then
    elseif self.ability.name == 'Castle' then
        self.joker_display_values.castle_card_suit = localize(G.GAME.current_round.castle_card.suit, 'suits_singular')
    elseif self.ability.name == 'Smiley Face' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_face() then
                mult = mult + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Campfire' then
    elseif self.ability.name == 'Golden Ticket' then
        local dollars = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and v.ability.name == 'Gold Card' then
                dollars = dollars + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.dollars = dollars
    elseif self.ability.name == 'Mr. Bones' then
        self.joker_display_values.active = G.GAME and G.GAME.chips and G.GAME.blind.chips and
            G.GAME.chips / G.GAME.blind.chips >= 0.25 and localize("k_active_ex") or "Inactive"
    elseif self.ability.name == 'Acrobat' then
        self.joker_display_values.x_mult = G.GAME and G.GAME.current_round.hands_left == 1 and self.ability.extra or 1
    elseif self.ability.name == 'Sock and Buskin' then
    elseif self.ability.name == 'Swashbuckler' then
    elseif self.ability.name == 'Troubadour' then
    elseif self.ability.name == 'Certificate' then
    elseif self.ability.name == 'Smeared Joker' then
    elseif self.ability.name == 'Throwback' then
    elseif self.ability.name == 'Hanging Chad' then
    elseif self.ability.name == 'Rough Gem' then
        local dollars = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit("Diamonds") then
                dollars = dollars + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.dollars = dollars
    elseif self.ability.name == 'Bloodstone' then
        local count = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit("Hearts") then
                count = count + 1 * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.count = count
        self.joker_display_values.odds = G.GAME and G.GAME.probabilities.normal or 1
    elseif self.ability.name == 'Arrowhead' then
        local chips = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit("Spades") then
                chips = chips + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.chips = chips
    elseif self.ability.name == 'Onyx Agate' then
        local mult = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit("Clubs") then
                mult = mult + self.ability.extra * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == 'Glass Joker' then
    elseif self.ability.name == 'Showman' then
    elseif self.ability.name == 'Flower Pot' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
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
        self.joker_display_values.x_mult = is_flower_pot_hand and self.ability.extra or 1
    elseif self.ability.name == 'Blueprint' then
        local ability_name, ability_key = calculate_blueprint_copy(self)
        self.joker_display_values.blueprint_ability_name = ability_name
        self.joker_display_values.blueprint_ability_name_ui = ability_key and
            localize { type = 'name_text', key = ability_key, set = 'Joker' } or "-"
        self.joker_display_values.blueprint_compat = localize('k_' ..
            (self.joker_display_values.blueprint_ability_name and "compatible" or "incompatible"))
    elseif self.ability.name == 'Wee Joker' then
    elseif self.ability.name == 'Merry Andy' then
    elseif self.ability.name == 'Oops! All 6s' then
    elseif self.ability.name == 'The Idol' then
        local count = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if v:is_suit(G.GAME.current_round.idol_card.suit) and v:get_id() == G.GAME.current_round.idol_card.id then
                count = count + 1 * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.x_mult = self.ability.extra ^ count
        self.joker_display_values.idol_card_rank = localize(G.GAME.current_round.idol_card.rank, 'ranks')
        self.joker_display_values.idol_card_suit = localize(G.GAME.current_round.idol_card.suit, 'suits_plural')
    elseif self.ability.name == 'Seeing Double' then
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
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
        self.joker_display_values.x_mult = is_seeing_double_hand and self.ability.extra or 1
    elseif self.ability.name == 'Matador' then
        local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and
            ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
        self.joker_display_values.active = disableable
        self.joker_display_values.active_text = self.joker_display_values.active and
            ("+" .. localize('$') .. self.ability.extra .. "?") or localize('ph_no_boss_active')
    elseif self.ability.name == 'Hit the Road' then
    elseif self.ability.name == 'The Duo' or self.ability.name == 'The Trio'
        or self.ability.name == 'The Family' or self.ability.name == 'The Order' or self.ability.name == 'The Tribe' then
        local x_mult = 1
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, poker_hands, _ = joker_display_evaluate_hand(hand)
        if next(poker_hands[self.ability.type]) then
            x_mult = self.ability.x_mult
        end
        self.joker_display_values.x_mult = x_mult
    elseif self.ability.name == 'Stuntman' then
    elseif self.ability.name == 'Invisible Joker' then
        self.joker_display_values.active = self.ability.invis_rounds >= self.ability.extra and localize("k_active_ex") or
            (self.ability.invis_rounds .. "/" .. self.ability.extra)
    elseif self.ability.name == 'Brainstorm' then
        local ability_name, ability_key = calculate_blueprint_copy(self)
        self.joker_display_values.blueprint_ability_name = ability_name
        self.joker_display_values.blueprint_ability_name_ui = ability_key and
            localize { type = 'name_text', key = ability_key, set = 'Joker' } or "-"
        self.joker_display_values.blueprint_compat = localize('k_' ..
            (self.joker_display_values.blueprint_ability_name and "compatible" or "incompatible"))
    elseif self.ability.name == 'Satellite' then
        local planets_used = 0
        for k, v in pairs(G.GAME.consumeable_usage) do
            if v.set == 'Planet' then
                planets_used = planets_used + 1
            end
        end
        self.joker_display_values.dollars = planets_used * self.ability.extra
    elseif self.ability.name == 'Shoot the Moon' then
        local playing_hand = next(G.play.cards)
        local mult = 0
        for k, v in ipairs(G.hand.cards) do
            if playing_hand or not v.highlighted then
                if not v.debuff and v:get_id() == 12 then
                    mult = mult + self.ability.extra * calculate_card_triggers(v, nil, true)
                end
            end
        end
        self.joker_display_values.mult = mult
    elseif self.ability.name == "Driver's License" then
        self.joker_display_values.active = self.ability.driver_tally and self.ability.driver_tally >= 16
        self.joker_display_values.x_mult = self.joker_display_values.active and ("X" .. self.ability.extra) or
            ("(" .. (self.ability.driver_tally or '0') .. "/16)")
    elseif self.ability.name == 'Cartomancer' then
    elseif self.ability.name == 'Astronomer' then
    elseif self.ability.name == 'Burnt Joker' then
        self.joker_display_values.active = (G.GAME and G.GAME.current_round.discards_used <= 0 and localize("k_active_ex") or "Inactive")
    elseif self.ability.name == 'Bootstraps' then
        self.joker_display_values.mult = G.GAME and
            self.ability.extra.mult *
            (math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / self.ability.extra.dollars)) or 0
    elseif self.ability.name == 'Caino' then
    elseif self.ability.name == 'Triboulet' then
        local count = 0
        local hand = next(G.play.cards) and G.play.cards or G.hand.highlighted
        local _, _, scoring_hand = joker_display_evaluate_hand(hand)
        local first_card = calculate_leftmost_card(scoring_hand)
        for k, v in pairs(scoring_hand) do
            if not v.debuff and (v:get_id() == 13 or v:get_id() == 12) then
                count = count + 1 * calculate_card_triggers(v, first_card)
            end
        end
        self.joker_display_values.x_mult = self.ability.extra ^ count
    elseif self.ability.name == 'Yorick' then
        self.joker_display_values.yorick_discards = self.ability.yorick_discards or self.ability.extra.discards
    elseif self.ability.name == 'Chicot' then
        local disableable = G.GAME and G.GAME.blind and G.GAME.blind.get_type and (G.GAME.blind:get_type() == 'Boss')
        self.joker_display_values.active = disableable
        self.joker_display_values.active_text = localize(disableable and 'k_active' or 'ph_no_boss_active')
    elseif self.ability.name == 'Perkeo' then
    end
end

----------------------------------------------
------------MOD CODE END----------------------
