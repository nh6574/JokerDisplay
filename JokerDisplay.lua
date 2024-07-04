--- STEAMODDED HEADER
--- MOD_NAME: JokerDisplay
--- MOD_ID: JokerDisplay
--- MOD_AUTHOR: [nh6574]
--- MOD_DESCRIPTION: Display information underneath Jokers
--- PRIORITY: -100000
--- VERSION: 1.4.0

----------------------------------------------
------------MOD CODE -------------------------

---MOD INITIALIZATION

JokerDisplay = {}
JokerDisplay.visible = true

if SMODS["INIT"] then -- 0.9.x
    local init = SMODS["INIT"]
    function init.JokerDisplay()
        JokerDisplay.Path = (SMODS.findModByID and SMODS.findModByID('JokerDisplay').path)
        JokerDisplay.Definitions = NFS.load(JokerDisplay.Path .. "display_definitions.lua")() or {}
    end
else -- 1.x
    JokerDisplay.Path = SMODS.current_mod.path
    JokerDisplay.Definitions = NFS.load(JokerDisplay.Path .. "display_definitions.lua")() or {}
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
                    maxh = 1.5,
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
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm"
                                },
                                nodes = {
                                    JokerDisplay.create_display_text_object({
                                        text = "" .. localize("k_debuffed"),
                                        colour =
                                            G.C.UI.TEXT_INACTIVE
                                    })
                                }
                            }
                        }
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

            --Debuff Display (with Baseball XMULT)
            self.config.joker_display_debuff_baseball = {
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
                    func = 'joker_display_debuff_baseball',
                    ref_table = self
                },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = {
                                    align = "cm"
                                },
                                nodes = {
                                    JokerDisplay.create_display_text_object({
                                        text = "" .. localize("k_debuffed") .. " (",
                                        colour =
                                            G.C.UI.TEXT_INACTIVE
                                    }),
                                    JokerDisplay.create_display_border_text_object(
                                        { JokerDisplay.create_display_text_object({
                                            ref_table = self
                                                .joker_display_values,
                                            ref_value = "x_mult_mod"
                                        }) },
                                        G.C.XMULT),
                                    JokerDisplay.create_display_text_object({
                                        text = ")",
                                        colour =
                                            G.C.UI.TEXT_INACTIVE
                                    }),
                                }
                            }
                        }
                    }
                }
            }

            self.config.joker_display_debuff_baseball_config = {
                align = "bm",
                bond = 'Strong',
                parent = self,
            }
            if self.config.joker_display_debuff_baseball then
                self.children.joker_display_debuff_baseball = UIBox {
                    definition = self.config.joker_display_debuff_baseball,
                    config = self.config.joker_display_debuff_baseball_config,
                }
                self.children.joker_display_debuff_baseball.states.collide.can = false
                self.children.joker_display_debuff_baseball.states.drag.can = true
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
                        nodes = { { n = G.UIT.R, config = { align = "cm" }, nodes = { JokerDisplay.create_display_text_object({ ref_table = self.joker_display_values, ref_value = "perishable", colour = lighten(G.C.PERISHABLE, 0.35), scale = 0.35 }) } } }
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
                        nodes = { { n = G.UIT.R, config = { align = "cm" }, nodes = { JokerDisplay.create_display_text_object({ ref_table = self.joker_display_values, ref_value = "rental", colour = G.C.GOLD, scale = 0.35 }) } } }
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

--- Splits text by a separator.
---@param str string String to split
---@param sep string? Separator. Defauls to whitespace.
---@return table split_text
local function strsplit(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for substr in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, substr)
    end
    return t
end

--- Deep copies a table
---@param orig table? Table to copy
---@return table? copy
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---Returns scoring information about a set of cards. Similar to _G.FUNCS.evaluate_play_.
---@param cards table Cards to calculate.
---@param count_facedowns boolean? If true, counts cards facing back.
---@return string text Scoring poker hand's non-localized text. "Unknown" if there's a card facedown.
---@return table poker_hands Poker hands contained in the scoring hand.
---@return table scoring_hand Scoring cards in hand.
JokerDisplay.evaluate_hand = function(cards, count_facedowns)
    local valid_cards = cards
    local has_facedown = false

    if not type(cards) == "table" then
        return "Unknown", {}, {}
    end
    for i = 1, #cards do
        if not type(cards[i]) == "table" then
            return "Unknown", {}, {}
        end
    end

    if not count_facedowns then
        valid_cards = {}
        for i = 1, #cards do
            if cards[i].facing and not (cards[i].facing == 'back') then
                table.insert(valid_cards, cards[i])
            else
                has_facedown = true
            end
        end
    end

    local text, _, poker_hands, scoring_hand, _ = G.FUNCS.get_poker_hand_info(valid_cards)

    local pures = {}
    for i = 1, #valid_cards do
        if next(find_joker('Splash')) then
            scoring_hand[i] = valid_cards[i]
        else
            if valid_cards[i].ability.effect == 'Stone Card' then
                local inside = false
                for j = 1, #scoring_hand do
                    if scoring_hand[j] == valid_cards[i] then
                        inside = true
                    end
                end
                if not inside then table.insert(pures, valid_cards[i]) end
            end
        end
    end
    for i = 1, #pures do
        table.insert(scoring_hand, pures[i])
    end

    return (has_facedown and "Unknown" or text), poker_hands, scoring_hand
end

---Returns what Joker the current card (i.e. Blueprint or Brainstorm) is copying.
---@param card table Blueprint or Brainstorm card to calculate copy.
---@param _cycle_count integer? Counts how many times the function has recurred to prevent loops.
---@return string|nil name Copied Joker's non-localized name if any.
---@return string|nil key Copied Joker's key if any.
JokerDisplay.calculate_blueprint_copy = function(card, _cycle_count)
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
            return JokerDisplay.calculate_blueprint_copy(other_joker, _cycle_count and _cycle_count + 1 or 1)
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
JokerDisplay.find_joker_or_copy = function(name, non_debuff)
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
JokerDisplay.calculate_leftmost_card = function(cards)
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
---@param scoring_hand table? Scoring hand. nil if poker hand is unknown (i.e. there are facedowns) (This might change in the future).
---@param held_in_hand boolean? If the card is held in hand and not a scoring card.
---@return integer # Times the card would trigger. (0 if debuffed)
JokerDisplay.calculate_card_triggers = function(card, scoring_hand, held_in_hand)
    if card.debuff then
        return 0
    end

    local triggers = 1

    if G.jokers then
        for k, v in pairs(G.jokers.cards) do
            local joker_display_definition = JokerDisplay.Definitions[v.config.center.key]
            local retrigger_function = (joker_display_definition and joker_display_definition.retrigger_function) or
                (v.joker_display_values and v.joker_display_values.blueprint_ability_key and
                    JokerDisplay.Definitions[v.joker_display_values.blueprint_ability_key].retrigger_function)

            if retrigger_function then
                triggers = triggers + retrigger_function(card, scoring_hand, held_in_hand)
            end
        end
    end

    triggers = triggers + (card:get_seal() == 'Red' and 1 or 0)

    return triggers
end

---Creates an object with JokerDisplay configurations.
---@param card table Reference card
---@param config {text: string?, ref_table: string?, ref_value: string?, scale: number?, colour: table?, border_nodes: table?, border_colour: table?, dynatext: table?} Node configuration
---@return table
JokerDisplay.create_display_object = function(card, config)
    local node = {}
    if config.dynatext then
        return {
            n = G.UIT.O,
            config = {
                object = DynaText(
                    deepcopy(config.dynatext)
                )
            }
        }
    end
    if config.border_nodes then
        local inside_nodes = {}
        for i = 1, #config.border_nodes do
            table.insert(inside_nodes, JokerDisplay.create_display_object(card, config.border_nodes[i]))
        end
        return JokerDisplay.create_display_border_text_object(inside_nodes, config.border_colour or G.C.XMULT)
    end
    if config.ref_value and config.ref_table then
        local table_path = strsplit(config.ref_table, ".")
        local ref_table = table_path[1] == "card" and card or _G[table_path[1]]
        for i = 2, #table_path do
            if ref_table[table_path[i]] then
                ref_table = ref_table[table_path[i]]
            end
        end
        return JokerDisplay.create_display_text_object({
            ref_table = ref_table,
            ref_value = config.ref_value,
            colour = config.colour or G.C.UI.TEXT_LIGHT,
            scale = config.scale or 0.4
        })
    end
    if config.text then
        return JokerDisplay.create_display_text_object({
            text = config.text,
            colour = config.colour or G.C.UI.TEXT_LIGHT,
            scale = config.scale or 0.4
        })
    end
    return node
end

---Creates a G.UIT.T object with JokerDisplay configurations for text display.
---@param config {text: string?, ref_table: table?, ref_value: string?, scale: number?, colour: table?}
---@return table
JokerDisplay.create_display_text_object = function(config)
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
JokerDisplay.create_display_border_text_object = function(nodes, border_color)
    return {
        n = G.UIT.C,
        config = { colour = border_color, r = 0.05, padding = 0.03, res = 0.15 },
        nodes = nodes
    }
end

---Creates a G.UIT.R object with JokerDisplay configurations for displaying a row.
---@param node_rows table Nodes contained in the row.
---@return table
JokerDisplay.create_display_row_objects = function(node_rows)
    local row_nodes = {}

    row_nodes[1] = { n = G.UIT.R, config = {align = "cm", minh = 0.4, maxw=2}, nodes = node_rows[1] }
    row_nodes[2] = { n = G.UIT.R, config = {align = "cm", maxh = 0.3, maxw=1.8}, nodes = node_rows[2] }

    return row_nodes
end

---STYLE MOD FUNCTIONS
G.FUNCS.joker_display_disable = function(e)
    local card = e.config.ref_table
    if card.facing == 'back' or card.debuff then
        e.states.visible = false
    else
        e.states.visible = JokerDisplay.visible
    end
end

G.FUNCS.joker_display_debuff = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and (card.config.center.rarity ~= 2 or #JokerDisplay.find_joker_or_copy('Baseball Card') == 0) and card.debuff then
        e.states.visible = JokerDisplay.visible
    else
        e.states.visible = false
    end
end

G.FUNCS.joker_display_debuff_baseball = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.config.center.rarity == 2 and #JokerDisplay.find_joker_or_copy('Baseball Card') > 0 and card.debuff then
        e.states.visible = JokerDisplay.visible
    else
        e.states.visible = false
    end
end

G.FUNCS.joker_display_perishable = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.ability.perishable then
        e.states.visible = JokerDisplay.visible
    else
        e.states.visible = false
    end
end

G.FUNCS.joker_display_rental = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.ability.rental then
        e.states.visible = JokerDisplay.visible
    else
        e.states.visible = false
    end
end

---Modifies JokerDisplay's nodes style values dynamically
---@param e table
G.FUNCS.joker_display_style_override = function(e)
    local card = e.config.ref_table
    local line_1 = e.children and e.children[1] or nil
    local line_2 = e.children and e.children[2] or nil

    local joker_display_definition = JokerDisplay.Definitions[card.config.center.key]
    local style_function = joker_display_definition and joker_display_definition.style_function

    if style_function then
        local recalculate = style_function(card, line_1, line_2)
        if recalculate then
            e.UIBox:recalculate(true)
        end
    end
end

---DISPLAY DEFINITION

---Initializes nodes for JokerDisplay.
---@return table # JokerDisplay nodes for the card.
function Card:initialize_joker_display()
    self.joker_display_values.is_empty = true
    self:calculate_joker_display()

    local text_rows, first_line_empty = self:define_joker_display()
    if not first_line_empty then
        self.joker_display_values.is_empty = false
        self.joker_display_values.mod_begin = (self.joker_display_values.has_mod and " " or "") ..
            self.joker_display_values.mod_begin
    end

    table.insert(text_rows[1],
        JokerDisplay.create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "mod_begin",
            colour = G.C.UI
                .TEXT_INACTIVE
        }))
    table.insert(text_rows[1],
        JokerDisplay.create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "chips_mod",
            colour =
                G.C.CHIPS
        }))
    table.insert(text_rows[1],
        JokerDisplay.create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "mult_mod",
            colour =
                G.C.MULT
        }))
    local xmult_border = JokerDisplay.create_display_border_text_object(
        { JokerDisplay.create_display_text_object({ ref_table = self.joker_display_values, ref_value = "x_mult_mod" }) },
        G.C.XMULT)
    xmult_border.config.padding = 0
    xmult_border.config.id = "xmult_mod"
    table.insert(text_rows[1], xmult_border)
    table.insert(text_rows[1],
        JokerDisplay.create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "mod_end",
            colour = G.C.UI
                .TEXT_INACTIVE
        }))

    return JokerDisplay.create_display_row_objects(text_rows)
end

---Defines nodes for the joker for JokerDisplay.
---@return table text_rows # JokerDisplay text nodes for the card.
---@return boolean first_line_empty # If the first line is empty
function Card:define_joker_display()
    local text_rows = {}

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local line_1 = joker_display_definition and joker_display_definition.line_1
    local line_2 = joker_display_definition and joker_display_definition.line_2
    local first_line_empty = not line_1

    if line_1 then
        text_rows[1] = {}
        for i = 1, #line_1 do
            table.insert(text_rows[1], JokerDisplay.create_display_object(self, line_1[i]))
        end
    else
        text_rows[1] = { JokerDisplay.create_display_text_object({
            ref_table = self.joker_display_values,
            ref_value = "empty",
            colour =
                G.C.UI.TEXT_INACTIVE
        }) }
    end
    if line_2 then
        text_rows[2] = {}
        for i = 1, #line_2 do
            table.insert(text_rows[2], JokerDisplay.create_display_object(self, line_2[i]))
        end
    end

    return text_rows, first_line_empty
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
    self.joker_display_values.perishable = (G.GAME.perishable_rounds or 5) .. "/" .. (G.GAME.perishable_rounds or 5)
    self.joker_display_values.rental = "-$" .. (G.GAME.rental_rate or 3)
    self.joker_display_values.has_mod = false

    local joker_edition = self:get_edition()
    local baseball_enhancements = (self.config.center.rarity == 2 and #JokerDisplay.find_joker_or_copy('Baseball Card') or 0)

    if joker_edition and not self.debuff then
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
        self.joker_display_values.perishable = (self.ability.perish_tally or 5) .. "/" .. (G.GAME.perishable_rounds or 5)
    end

    if self.ability.rental then
        self.joker_display_values.rental = "-$" .. (G.GAME.rental_rate or 3)
    end

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local calc_function = joker_display_definition and joker_display_definition.calc_function

    if calc_function then
        calc_function(self)
    end
end

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

--- CONTROLLER INPUT

local controller_queue_R_cursor_press_ref = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    controller_queue_R_cursor_press_ref(self, x, y)
    if not G.SETTINGS.paused then
        local press_node = self.hovering.target or self.focused.target
        if press_node and G.jokers and press_node.area and press_node.area == G.jokers then
            JokerDisplay.visible = not JokerDisplay.visible
        end
    end
end

local controller_button_press_update_ref = Controller.button_press_update
function Controller:button_press_update(button, dt)
    controller_button_press_update_ref(self, button, dt)

    if button == 'b' and G.jokers and self.focused.target and self.focused.target.area == G.jokers then
        JokerDisplay.visible = not JokerDisplay.visible
    end
end

----------------------------------------------
------------MOD CODE END----------------------
