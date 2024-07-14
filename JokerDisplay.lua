--- STEAMODDED HEADER
--- MOD_NAME: JokerDisplay
--- MOD_ID: JokerDisplay
--- MOD_AUTHOR: [nh6574]
--- MOD_DESCRIPTION: Display information underneath Jokers
--- PRIORITY: -100000
--- VERSION: 1.4.1

----------------------------------------------
------------MOD CODE -------------------------

---UTILITY FUNCTIONS

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

---DISPLAY BOX CLASS

JokerDisplayBox = UIBox:extend()

function JokerDisplayBox:init(parent, func, args)
    args = args or {}

    args.definition = args.definition or {
        n = G.UIT.ROOT,
        config = {
            minh = 0.6,
            minw = 2,
            maxw = 2,
            r = 0.001,
            padding = 0.1,
            align = 'cm',
            colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.8),
            shadow = true,
            func = func,
            ref_table = parent
        },
        nodes = {
            {
                n = G.UIT.R,
                config = { ref_table = parent, align = "cm", func = "joker_display_style_override" },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { id = "modifiers", ref_table = parent, align = "cm" },
                    },
                    {
                        n = G.UIT.R,
                        config = { id = "extra", ref_table = parent, align = "cm" },
                    },
                    {
                        n = G.UIT.R,
                        config = { id = "text", ref_table = parent, align = "cm" },
                    },
                    {
                        n = G.UIT.R,
                        config = { id = "reminder_text", ref_table = parent, align = "cm" },
                    }
                }
            },
        }
    }

    args.config = args.config or {}
    args.config.align = args.config.align or "bm"
    args.config.parent = parent
    args.config.offset = { x = 0, y = -0.1 }

    UIBox.init(self, args)

    self.states.collide.can = true
    self.name = "JokerDisplay"
    self.can_collapse = true

    self.text = self.UIRoot.children[1].children[3]
    self.has_text = false
    self.reminder_text = self.UIRoot.children[1].children[4]
    self.has_reminder_text = false
    self.extra = self.UIRoot.children[1].children[2]
    self.has_extra = false
    self.modifier_row = self.UIRoot.children[1].children[1]
    self.has_modifiers = false

    self.modifiers = {
        chips = nil,
        x_chips = nil,
        x_chips_text = nil,
        mult = nil,
        x_mult = nil,
        x_mult_text = nil,
        dollars = nil,
    }
end

function JokerDisplayBox:recalculate()
    if not (self.has_text or self.has_extra or self.has_modifiers) and self.has_reminder_text then
        self.text.config.minh = 0.4
    else
        self.text.config.minh = nil
    end

    if self.has_text then
        self.text.config.padding = 0.03
    else
        self.text.config.padding = nil
    end

    UIBox.recalculate(self)
    self:align_to_text()
end

function JokerDisplayBox:add_text(nodes)
    self.has_text = true
    for i = 1, #nodes do
        self:add_child(JokerDisplay.create_display_object(self.parent, nodes[i]), self.text)
    end
end

function JokerDisplayBox:remove_text()
    self.has_text = false
    self:remove_children(self.text)
end

function JokerDisplayBox:add_reminder_text(nodes)
    self.has_reminder_text = true
    for i = 1, #nodes do
        self:add_child(JokerDisplay.create_display_object(self.parent, nodes[i]), self.reminder_text)
    end
end

function JokerDisplayBox:remove_reminder_text()
    self.has_reminder_text = false
    self:remove_children(self.reminder_text)
end

function JokerDisplayBox:add_extra(node_rows)
    self.has_extra = true
    for i = #node_rows, 1, -1 do
        local row_nodes = {}
        for j = 1, #node_rows[i] do
            table.insert(row_nodes, JokerDisplay.create_display_object(self.parent, node_rows[i][j]))
        end
        local extra_row = {
            n = G.UIT.R,
            config = { ref_table = parent, align = "cm", padding = 0.03 },
            nodes = row_nodes
        }
        self:add_child(extra_row, self.extra)
    end
end

function JokerDisplayBox:remove_extra()
    self.has_extra = false
    self:remove_children(self.extra)
end

function JokerDisplayBox:change_modifiers(modifiers, reset)
    local new_modifiers = {
        chips = modifiers.chips or not reset and self.modifiers.chips or nil,
        x_chips = modifiers.x_chips or not reset and self.modifiers.x_chips or nil,
        mult = modifiers.mult or not reset and self.modifiers.mult or nil,
        x_mult = modifiers.x_mult or not reset and self.modifiers.x_mult or nil,
        dollars = modifiers.dollars or not reset and self.modifiers.dollars or nil,
    }

    local mod_keys = { "chips", "x_chips", "mult", "x_mult", "dollars" }
    local modifiers_changed = false

    for i = 1, #mod_keys do
        if (not not self.modifiers[mod_keys[i]]) ~= (not not new_modifiers[mod_keys[i]]) then
            modifiers_changed = true
        end
        self.modifiers[mod_keys[i]] = new_modifiers[mod_keys[i]]
    end

    self.modifiers.x_chips_text = self.modifiers.x_chips and tonumber(string.format("%.2f", self.modifiers.x_chips)) or
    nil
    self.modifiers.x_mult_text = self.modifiers.x_mult and tonumber(string.format("%.2f", self.modifiers.x_mult)) or nil

    if modifiers_changed then
        self:remove_modifiers()
        self:add_modifiers()
    end
end

function JokerDisplayBox:add_modifiers()
    self.has_modifiers = true

    local mod_nodes = {}

    if self.modifiers.chips then
        local chip_node = {}
        table.insert(chip_node, JokerDisplay.create_display_object(self, { text = "+", colour = G.C.CHIPS }))
        table.insert(chip_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "chips", colour = G.C.CHIPS }))
        table.insert(mod_nodes, chip_node)
    end

    if self.modifiers.x_chips then
        local xchip_node = {}
        table.insert(xchip_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = { { text = "X" },
                        { ref_table = "card.modifiers", ref_value = "x_chips_text" } },
                    border_colour = G.C.CHIPS
                }))
        table.insert(mod_nodes, xchip_node)
    end

    if self.modifiers.mult then
        local mult_node = {}
        table.insert(mult_node, JokerDisplay.create_display_object(self, { text = "+", colour = G.C.MULT }))
        table.insert(mult_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "mult", colour = G.C.MULT }))
        table.insert(mod_nodes, mult_node)
    end

    if self.modifiers.x_mult then
        local xmult_node = {}
        table.insert(xmult_node,
            JokerDisplay.create_display_object(self,
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.modifiers", ref_value = "x_mult_text" }
                    }
                }
            ))
        table.insert(mod_nodes, xmult_node)
    end

    if self.modifiers.dollars then
        local dollars_node = {}
        table.insert(dollars_node,
            JokerDisplay.create_display_object(self, { text = "+" .. localize('$'), colour = G.C.GOLD }))
        table.insert(dollars_node,
            JokerDisplay.create_display_object(self,
                { ref_table = "card.modifiers", ref_value = "dollars", colour = G.C.GOLD }))
        table.insert(mod_nodes, dollars_node)
    end

    local row_index = 1
    local mod_rows = {}
    for i = 1, #mod_nodes do
        if mod_rows[row_index] and #mod_rows[row_index] >= 2 then
            row_index = row_index + 1
        end
        if not mod_rows[row_index] then
            mod_rows[row_index] = {}
        end
        local mod_column = {
            n = G.UIT.C,
            config = { ref_table = parent, align = "cm", padding = 0.03 },
            nodes = mod_nodes[i]
        }
        table.insert(mod_rows[row_index], mod_column)
    end

    for i = 1, #mod_rows do
        local extra_row = {
            n = G.UIT.R,
            config = { ref_table = parent, align = "cm", padding = 0.03 },
            nodes = mod_rows[i]
        }
        self:add_child(extra_row, self.modifier_row)
    end
end

function JokerDisplayBox:remove_modifiers()
    self.has_modifiers = false
    self:remove_children(self.modifier_row)
end

function JokerDisplayBox:remove_children(node)
    if not node.children then
        return
    end
    remove_all(node.children)
    node.children = {}
    self:recalculate()
end

function JokerDisplayBox:align_to_text()
    local y_value = self.T and self.T.y - (self.has_text and self.text.T.y or
        self.has_extra and self.extra.children[#self.extra.children] and self.extra.children[#self.extra.children].T and self.extra.children[#self.extra.children].T.y or
        self.has_modifiers and self.modifier_row.children[#self.modifier_row.children] and self.modifier_row.children[#self.modifier_row.children].T and self.modifier_row.children[#self.modifier_row.children].T.y or
        self.UIRoot.T and self.UIRoot.T.y)
    self.alignment.offset.y = y_value - 0.1
end

---DISPLAY CONFIGURATION

---Updates the JokerDisplay and initializes it if necessary.
---@param from string? Optional string with information of where the call is from. For debug purposes.
function Card:update_joker_display(from)
    if self.ability and self.ability.set == 'Joker' and not self.no_ui and not G.debug_tooltip_toggle then
        --sendDebugMessage(self.ability.name .. ((" " .. from) or ""))

        if not self.children.joker_display then
            self.joker_display_values = {}
            self.joker_display_values.small = false

            --Regular Display
            self.children.joker_display = JokerDisplayBox(self, "joker_display_disable")
            self.children.joker_display_small = JokerDisplayBox(self, "joker_display_small_enable")
            self.children.joker_display_debuff = JokerDisplayBox(self, "joker_display_debuff")
            self.children.joker_display_debuff:add_text({ { text = "" .. localize("k_debuffed"), colour = G.C.UI.TEXT_INACTIVE } })
            self:initialize_joker_display()

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
                self.children.joker_display_perishable.states.collide.can = true
                self.children.joker_display_perishable.name = "JokerDisplay"
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
                self.children.joker_display_rental.states.collide.can = true
                self.children.joker_display_rental.name = "JokerDisplay"
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

---STYLE MOD FUNCTIONS
G.FUNCS.joker_display_disable = function(e)
    local card = e.config.ref_table
    if card.facing == 'back' or card.debuff or card.joker_display_values.small then
        e.states.visible = false
        e.parent.states.collide.can = false
    else
        e.states.visible = JokerDisplay.visible
        e.parent.states.collide.can = JokerDisplay.visible
    end
end

G.FUNCS.joker_display_small_enable = function(e)
    local card = e.config.ref_table
    if card.facing == 'back' or card.debuff or not (card.joker_display_values.small) then
        e.states.visible = false
        e.parent.states.collide.can = false
    else
        e.states.visible = JokerDisplay.visible
        e.parent.states.collide.can = JokerDisplay.visible
    end
end


G.FUNCS.joker_display_debuff = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.debuff then
        e.states.visible = JokerDisplay.visible
        e.parent.states.collide.can = JokerDisplay.visible
    else
        e.states.visible = false
        e.parent.states.collide.can = false
    end
end

G.FUNCS.joker_display_perishable = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.ability.perishable then
        e.states.visible = JokerDisplay.visible
        e.parent.states.collide.can = JokerDisplay.visible
    else
        e.states.visible = false
        e.parent.states.collide.can = false
    end
end

G.FUNCS.joker_display_rental = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.ability.rental then
        e.states.visible = JokerDisplay.visible
        e.parent.states.collide.can = JokerDisplay.visible
    else
        e.states.visible = false
        e.parent.states.collide.can = false
    end
end

---Modifies JokerDisplay's nodes style values dynamically
---@param e table
G.FUNCS.joker_display_style_override = function(e)
    local card = e.config.ref_table
    local text = e.children and e.children[3] or nil
    local reminder_text = e.children and e.children[4] or nil
    local extra = e.children and e.children[2] or nil

    local joker_display_definition = JokerDisplay.Definitions[card.config.center.key]
    local style_function = joker_display_definition and joker_display_definition.style_function

    if style_function then
        local recalculate = style_function(card, text, reminder_text, extra)
        if recalculate then
            JokerDisplay.recalculate(e.UIBox)
        end
    end
end

--HELPER FUNCTIONS

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
---@return table|nil name Copied Joker
JokerDisplay.calculate_blueprint_copy = function(card, _cycle_count)
    if _cycle_count and _cycle_count > #G.jokers.cards + 1 then
        return nil
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
            return other_joker
        end
    end
    return nil
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
            local retrigger_function = (not v.debuff and joker_display_definition and joker_display_definition.retrigger_function) or
                (not v.debuff and v.joker_display_values and v.joker_display_values.blueprint_ability_key and
                    not v.joker_display_values.blueprint_debuff and
                    JokerDisplay.Definitions[v.joker_display_values.blueprint_ability_key] and
                    JokerDisplay.Definitions[v.joker_display_values.blueprint_ability_key].retrigger_function)

            if retrigger_function then
                triggers = triggers + retrigger_function(card, scoring_hand, held_in_hand)
            end
        end
    end

    triggers = triggers + (card:get_seal() == 'Red' and 1 or 0)

    return triggers
end

JokerDisplay.calculate_joker_modifiers = function(card)
    local modifiers = {
        chips = nil,
        x_chips = nil,
        mult = nil,
        x_mult = nil,
        dollars = nil
    }
    local joker_edition = card:get_edition()

    if joker_edition and not card.debuff then
        modifiers.chips = joker_edition.chip_mod
        modifiers.mult = joker_edition.mult_mod
        modifiers.x_mult = joker_edition.x_mult_mod
    end

    if G.jokers then
        for k, v in pairs(G.jokers.cards) do
            local joker_display_definition = JokerDisplay.Definitions[v.config.center.key]
            local mod_function = (not v.debuff and joker_display_definition and joker_display_definition.mod_function) or
                (not v.debuff and v.joker_display_values and v.joker_display_values.blueprint_ability_key and
                    not v.joker_display_values.blueprint_debuff and
                    JokerDisplay.Definitions[v.joker_display_values.blueprint_ability_key] and
                    JokerDisplay.Definitions[v.joker_display_values.blueprint_ability_key].mod_function)

            if mod_function then
                local extra_mods = mod_function(card)
                modifiers = {
                    chips = modifiers.chips and extra_mods.chips and modifiers.chips + extra_mods.chips or
                        extra_mods.chips or modifiers.chips,
                    x_chips = modifiers.x_chips and extra_mods.x_chips and modifiers.x_chips * extra_mods.x_chips or
                        extra_mods.x_chips or modifiers.x_chips,
                    mult = modifiers.mult and extra_mods.mult and modifiers.mult + extra_mods.mult or
                        extra_mods.mult or modifiers.mult,
                    x_mult = modifiers.x_mult and extra_mods.x_mult and modifiers.x_mult * extra_mods.x_mult or
                        extra_mods.x_mult or modifiers.x_mult,
                    dollars = modifiers.dollars and extra_mods.dollars and modifiers.dollars + extra_mods.dollars or
                        extra_mods.dollars or modifiers.dollars,
                }
            end
        end
    end

    return modifiers
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

---DISPLAY DEFINITION

---Initializes nodes for JokerDisplay.
function Card:initialize_joker_display()
    self:calculate_joker_display()

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local definiton_text = joker_display_definition and
    (joker_display_definition.text or joker_display_definition.line_1)
    local definiton_reminder_text = joker_display_definition and (joker_display_definition.reminder_text or
        joker_display_definition.line_2)
    local definiton_extra = joker_display_definition and joker_display_definition.extra

    if definiton_text then
        self.children.joker_display:add_text(definiton_text)
        self.children.joker_display_small:add_text(definiton_text)
    end
    if definiton_reminder_text then
        self.children.joker_display:add_reminder_text(definiton_reminder_text)
    end
    if definiton_extra then
        self.children.joker_display:add_extra(definiton_extra)
    end

    self.children.joker_display:recalculate()
end

---DISPLAY CALCULATION

---Calculates values for JokerDisplay. Saves them to Card.joker_display_values.
function Card:calculate_joker_display()
    self.joker_display_values.perishable = (G.GAME.perishable_rounds or 5) .. "/" .. (G.GAME.perishable_rounds or 5)
    self.joker_display_values.rental = "-$" .. (G.GAME.rental_rate or 3)

    if self.ability.perishable then
        self.joker_display_values.perishable = (self.ability.perish_tally or 5) .. "/" .. (G.GAME.perishable_rounds or 5)
    end

    if self.ability.rental then
        self.joker_display_values.rental = "-$" .. (G.GAME.rental_rate or 3)
    end

    self.children.joker_display:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
    self.children.joker_display_debuff:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)

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
        if press_node and G.jokers and ((press_node.area and press_node.area == G.jokers)
                or (press_node.name and press_node.name == "JokerDisplay")) then
            JokerDisplay.visible = not JokerDisplay.visible
        end
    end
end

local controller_queue_L_cursor_press_ref = Controller.queue_L_cursor_press
function Controller:queue_L_cursor_press(x, y)
    controller_queue_L_cursor_press_ref(self, x, y)
    if not G.SETTINGS.paused then
        local press_node = self.hovering.target or self.focused.target
        if press_node and press_node.name and press_node.name == "JokerDisplay" and press_node.can_collapse and press_node.parent then
            press_node.parent.joker_display_values.small = not press_node.parent.joker_display_values.small
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
