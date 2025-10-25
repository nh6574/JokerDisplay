---DISPLAY DEFINITION

---Initializes nodes for JokerDisplay.
---@param custom_parent table? Another card the display should be under
---@param stop_calc boolean? Don't call calculate_joker_display
function Card:initialize_joker_display(custom_parent, stop_calc)
    if not JokerDisplay.Definitions[self.config.center.key] and
        self.config.center.joker_display_def and type(self.config.center.joker_display_def) == "function" then
        JokerDisplay.Definitions[self.config.center.key] = self.config.center.joker_display_def(JokerDisplay)
    end

    local replace_text, replace_text_config = nil, nil
    local replace_reminder, replace_reminder_config = nil, nil
    local replace_extra, replace_extra_config = nil, nil
    local replace_modifiers, replace_modifiers_config = nil, nil
    local replace_debuff_text, replace_debuff_text_config = nil, nil
    local replace_debuff_reminder, replace_debuff_reminder_config = nil, nil
    local replace_debuff_extra, replace_debuff_extra_config = nil, nil
    local replace_stop_calc = false
    if JokerDisplay.Global_Definitions.Replace then
        local current_replace_priority
        for _, replace_definition in pairs(JokerDisplay.Global_Definitions.Replace) do
            local replace_priority = replace_definition.priority or 0
            local is_replace_priority_greater = not current_replace_priority or
                (replace_priority > current_replace_priority)
            if is_replace_priority_greater and replace_definition.is_replaced_func and replace_definition.is_replaced_func(self, custom_parent) then
                current_replace_priority = replace_priority
                replace_text, replace_text_config = JokerDisplay.get_replace_definition(replace_definition.replace_text,
                    "text")
                replace_reminder, replace_reminder_config = JokerDisplay.get_replace_definition(
                    replace_definition.replace_reminder, "reminder")
                replace_extra, replace_extra_config = JokerDisplay.get_replace_definition(
                    replace_definition.replace_extra, "extra")
                replace_modifiers, replace_modifiers_config = JokerDisplay.get_replace_definition(
                    replace_definition.replace_modifiers, "modifiers")
                replace_debuff_text, replace_debuff_text_config = JokerDisplay.get_replace_definition(
                    replace_definition.replace_debuff_text, "text")
                replace_debuff_reminder, replace_debuff_reminder_config = JokerDisplay.get_replace_definition(
                    replace_definition.replace_debuff_text, "reminder")
                replace_debuff_extra, replace_debuff_extra_config = JokerDisplay.get_replace_definition(
                    replace_definition.replace_debuff_text, "extra")
                replace_stop_calc = replace_definition.stop_calc
            end
        end
    end

    if not custom_parent then
        self.children.joker_display:remove_text()
        self.children.joker_display_small:remove_text()
        self.children.joker_display:remove_reminder_text()
        self.children.joker_display_small:remove_reminder_text()
        self.children.joker_display:remove_extra()
        self.children.joker_display_small:remove_extra()
        self.children.joker_display:remove_modifiers()
        self.children.joker_display_small:remove_modifiers()
        self.children.joker_display_debuff:remove_modifiers()
        self.children.joker_display_debuff:remove_text()

        self.children.joker_display_debuff:add_text(
            replace_debuff_text or { { text = "" .. localize("k_debuffed"), colour = G.C.UI.TEXT_INACTIVE } },
            replace_debuff_text_config)
    end
    if replace_modifiers then
        self.children.joker_display.stop_modifiers = true
        self.children.joker_display_small.stop_modifiers = true
        self.children.joker_display_debuff.stop_modifiers = true
    else
        self.children.joker_display.stop_modifiers = false
        self.children.joker_display_small.stop_modifiers = false
        self.children.joker_display_debuff.stop_modifiers = false
    end
    self.children.joker_display_debuff:remove_reminder_text()
    if replace_debuff_reminder then
        self.children.joker_display_debuff:add_reminder_text(replace_debuff_reminder, replace_debuff_reminder_config)
    end
    self.children.joker_display_debuff:remove_extra()
    if replace_debuff_extra then
        self.children.joker_display_debuff:add_extra(replace_debuff_extra, replace_debuff_extra_config)
    end

    self.joker_display_stop_calc = replace_stop_calc

    if not stop_calc then
        self:calculate_joker_display(custom_parent)
    end

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local definition_text = replace_text or joker_display_definition and
        (joker_display_definition.text or joker_display_definition.line_1)
    local text_config = replace_text_config or joker_display_definition and joker_display_definition.text_config
    local definition_reminder_text = replace_reminder or
        joker_display_definition and (joker_display_definition.reminder_text or
            joker_display_definition.line_2)
    local reminder_text_config = replace_reminder_config or
        joker_display_definition and joker_display_definition.reminder_text_config
    local definition_extra = replace_extra or joker_display_definition and joker_display_definition.extra
    local extra_config = replace_extra_config or joker_display_definition and joker_display_definition.extra_config

    if definition_text then
        if custom_parent then
            custom_parent.children.joker_display:add_text(definition_text, text_config, self)
            custom_parent.children.joker_display_small:add_text(definition_text, text_config, self)
        else
            self.children.joker_display:add_text(definition_text, text_config)
            self.children.joker_display_small:add_text(definition_text, text_config)
        end
    end
    if definition_reminder_text then
        if not reminder_text_config then
            reminder_text_config = {}
        end
        reminder_text_config.colour = reminder_text_config.colour or G.C.UI.TEXT_INACTIVE
        reminder_text_config.scale = reminder_text_config.scale or 0.3
        if JokerDisplay.config.default_rows.reminder then
            if custom_parent then
                custom_parent.children.joker_display:add_reminder_text(definition_reminder_text, reminder_text_config,
                    self)
            else
                self.children.joker_display:add_reminder_text(definition_reminder_text, reminder_text_config)
            end
        end
        if JokerDisplay.config.small_rows.reminder then
            if custom_parent then
                custom_parent.children.joker_display_small:add_reminder_text(definition_reminder_text,
                    reminder_text_config, self)
            else
                self.children.joker_display_small:add_reminder_text(definition_reminder_text, reminder_text_config)
            end
        end
    end
    if definition_extra then
        if JokerDisplay.config.default_rows.extra then
            if custom_parent then
                custom_parent.children.joker_display:add_extra(definition_extra, extra_config, self)
            else
                self.children.joker_display:add_extra(definition_extra, extra_config)
            end
        end
        if JokerDisplay.config.small_rows.extra then
            if custom_parent then
                custom_parent.children.joker_display_small:add_extra(definition_extra, extra_config, self)
            else
                self.children.joker_display_small:add_extra(definition_extra, extra_config)
            end
        end
    end

    if custom_parent then
        custom_parent.children.joker_display:recalculate(true, true)
        custom_parent.children.joker_display_small:recalculate(true, true)
        custom_parent.children.joker_display_debuff:recalculate(true, true)
    else
        self.children.joker_display:recalculate(true, true)
        self.children.joker_display_small:recalculate(true, true)
        self.children.joker_display_debuff:recalculate(true, true)
    end
end

function JokerDisplay.get_replace_definition(definition, def_type)
    if type(definition) == "function" then
        definition = definition()
    end
    if type(definition) == "table" then
        return definition, nil
    end
    if type(definition) == "string" then
        local joker_display_definition = JokerDisplay.Definitions[definition]
        if joker_display_definition then
            if def_type == "text" then
                return joker_display_definition.text or joker_display_definition.line_1,
                    joker_display_definition.text_config
            end
            if def_type == "reminder" then
                return joker_display_definition.reminder_text or
                    joker_display_definition.line_2
            end
            if def_type == "extra" then
                return joker_display_definition.extra, joker_display_definition.extra_config
            end
            if def_type == "modifiers" then
                return {}, {} -- TBD
            end
        end
    end
    return nil, nil
end

---Calculates values for JokerDisplay. Saves them to Card.joker_display_values.
function Card:calculate_joker_display(custom_parent)
    self.joker_display_values.trigger_count = JokerDisplay.calculate_joker_triggers(custom_parent or self)

    if not custom_parent then
        self.joker_display_values.perishable = (G.GAME.perishable_rounds or 5) .. "/" .. (G.GAME.perishable_rounds or 5)
        self.joker_display_values.rental = "-$" .. (G.GAME.rental_rate or 3)

        if self.ability.perish_tally then
            self.joker_display_values.perishable = (self.ability.perish_tally or 5) ..
                "/" .. (G.GAME.perishable_rounds or 5)
        end

        if self.ability.rental then
            self.joker_display_values.rental = "-$" .. (G.GAME.rental_rate or 3)
        end

        if JokerDisplay.config.default_rows.modifiers and not self.joker_display_stop_calc then
            if not self.children.joker_display.stop_modifiers then
                self.children.joker_display:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
            end
            if not self.children.joker_display_debuff.stop_modifiers then
                self.children.joker_display_debuff:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
            end
        end

        if JokerDisplay.config.small_rows.modifiers and not self.children.joker_display_small.stop_modifiers and not self.joker_display_stop_calc then
            self.children.joker_display_small:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
        end
    end

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local calc_function = joker_display_definition and joker_display_definition.calc_function

    if calc_function and not self.joker_display_stop_calc then
        calc_function(self)
    end
end

---Updates the JokerDisplay and initializes it if necessary.
---@param force_update boolean? Force update even if disabled.
---@param force_reload boolean? Force re-initialization
---@param _from string? Debug string
function Card:update_joker_display(force_update, force_reload, _from)
    if self.ability then
        --print(tostring(self.ability.name) .. " : " .. tostring(_from))
        if not self.children.joker_display then
            self.joker_display_values = {}
            self.joker_display_values.disabled = JokerDisplay.config.hide_by_default or false
            self.joker_display_values.small = false

            --Regular Display
            self.children.joker_display = JokerDisplayBox(self, "joker_display_disable", { type = "NORMAL" })
            self.children.joker_display_small = JokerDisplayBox(self, "joker_display_small_enable", { type = "SMALL" })
            self.children.joker_display_debuff = JokerDisplayBox(self, "joker_display_debuff", { type = "DEBUFF" })
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
            if force_update or (JokerDisplay.config.enabled and (not self.joker_display_values.disabled or self.joker_display_values.blueprint_force_update)) then
                if force_reload then
                    self:initialize_joker_display()
                else
                    self:calculate_joker_display()
                end
            end
        end
    end
end

---Updates the JokerDisplay for all jokers and initializes it if necessary.
---@param force_update boolean? Force update even if disabled.
---@param force_reload boolean? Force re-initialization
---@param _from string? Debug string
function JokerDisplay.update_all_joker_display(force_update, force_reload, _from)
    if G.jokers then
        for _, area in ipairs(JokerDisplay.get_display_areas()) do
            for _, card in pairs(area.cards) do
                card:update_joker_display(force_update, force_reload, _from)
            end
        end
    end
end

---Hides/unhides display
function Card:joker_display_toggle()
    if not self.joker_display_values then return end
    if self.joker_display_values.disabled then
        self:update_joker_display(true)
    end
    self.joker_display_values.disabled = not self.joker_display_values.disabled
end

---Removes display entirely
function Card:joker_display_remove()
    if self.children.joker_display then
        self.children.joker_display:remove()
        self.children.joker_display = nil
    end
    if self.children.joker_display_small then
        self.children.joker_display_small:remove()
        self.children.joker_display_small = nil
    end
    if self.children.joker_display_debuff then
        self.children.joker_display_debuff:remove()
        self.children.joker_display_debuff = nil
    end
    if self.children.joker_display_perishable then
        self.children.joker_display_perishable:remove()
        self.children.joker_display_perishable = nil
    end
    if self.children.joker_display_rental then
        self.children.joker_display_rental:remove()
        self.children.joker_display_rental = nil
    end
end

---STYLE MOD FUNCTIONS
G.FUNCS.joker_display_disable = function(e)
    local card = e.config.ref_table
    if card.facing == 'back' or card.debuff or card.joker_display_values.small or
        (not card:joker_display_has_info() and JokerDisplay.config.hide_empty) then
        e.states.visible = false
        e.parent.states.collide.can = false
    else
        e.states.visible = JokerDisplay.config.enabled and not card.joker_display_values.disabled
        e.parent.states.collide.can = JokerDisplay.config.enabled and not card.joker_display_values.disabled
    end
end

G.FUNCS.joker_display_small_enable = function(e)
    local card = e.config.ref_table
    if card.facing == 'back' or card.debuff or not (card.joker_display_values.small) or
        (not card:joker_display_has_info() and JokerDisplay.config.hide_empty) then
        e.states.visible = false
        e.parent.states.collide.can = false
    else
        e.states.visible = JokerDisplay.config.enabled and not card.joker_display_values.disabled
        e.parent.states.collide.can = JokerDisplay.config.enabled and not card.joker_display_values.disabled
    end
end


G.FUNCS.joker_display_debuff = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.debuff then
        e.states.visible = JokerDisplay.config.enabled and not card.joker_display_values.disabled
        e.parent.states.collide.can = JokerDisplay.config.enabled and not card.joker_display_values.disabled
    else
        e.states.visible = false
        e.parent.states.collide.can = false
    end
end

G.FUNCS.joker_display_perishable = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.ability.perishable then
        e.states.visible = JokerDisplay.config.enabled and not card.joker_display_values.disabled and
            not JokerDisplay.config.disable_perishable
        e.parent.states.collide.can = JokerDisplay.config.enabled and not card.joker_display_values.disabled and
            not JokerDisplay.config.disable_perishable
    else
        e.states.visible = false
        e.parent.states.collide.can = false
    end
end

G.FUNCS.joker_display_rental = function(e)
    local card = e.config.ref_table
    if not (card.facing == 'back') and card.ability.rental then
        e.states.visible = JokerDisplay.config.enabled and not card.joker_display_values.disabled and
            not JokerDisplay.config.disable_rental
        e.parent.states.collide.can = JokerDisplay.config.enabled and not card.joker_display_values.disabled and
            not JokerDisplay.config.disable_rental
    else
        e.states.visible = false
        e.parent.states.collide.can = false
    end
end

---Modifies JokerDisplay's nodes style values dynamically
---@param e table
G.FUNCS.joker_display_style_override = function(e)
    local card = e.config.ref_table
    if JokerDisplay.config.enabled and (card.joker_display_values and not card.joker_display_values.disabled) then
        local text = e.children and e.children[3] or nil
        local reminder_text = e.children and e.children[4] or nil
        local extra = e.children and e.children[2] or nil

        local is_blueprint_copying = card.joker_display_values and not card.joker_display_values.blueprint_stop_func and
            card.joker_display_values.blueprint_ability_key
        local joker_display_definition = JokerDisplay.Definitions[is_blueprint_copying or card.config.center.key]
        local style_function = joker_display_definition and joker_display_definition.style_function

        if style_function then
            local recalculate = style_function(
                is_blueprint_copying and card.joker_display_values.blueprint_ability_joker or card, text, reminder_text,
                extra)
            if recalculate then
                JokerDisplayBox.recalculate(e.UIBox, true)
            end
        end
    end
end

--- UPDATE

local card_update_ref = Card.update
function Card:update(dt)
    card_update_ref(self, dt)
    if JokerDisplay.config.enabled and G.jokers then
        local is_display_area = false
        if self.area then
            for _, area in ipairs(JokerDisplay.get_display_areas()) do
                if self.area == area then
                    is_display_area = true
                    break
                end
            end
        end
        if is_display_area then
            if G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.SELECTING_HAND and G.STATE ~= G.STATES.DRAW_TO_HAND then
                JokerDisplay.current_hand = {}
                JokerDisplay.current_hand_info = {
                    text = "Unknown",
                    poker_hands = {},
                    scoring_hand = {}
                }
            end
            if not self.joker_display_last_update_time then
                self.joker_display_last_update_time = 0
                self.joker_display_update_time_variance = math.random()
                local joker_number_delta_variance = math.max(0.01, #G.jokers.cards / 20)
                self.joker_display_next_update_time = joker_number_delta_variance / 2 +
                    joker_number_delta_variance / 2 * self.joker_display_update_time_variance
            elseif self.joker_display_values and G.real_dt > 0.05 and #G.jokers.cards > 20 then
                self.joker_display_values.disabled = true
            else
                self.joker_display_last_update_time = self.joker_display_last_update_time + G.real_dt
                if self.joker_display_last_update_time > self.joker_display_next_update_time then
                    self.joker_display_last_update_time = 0
                    local joker_number_delta_variance = math.max(0.1, #G.jokers.cards / 20)
                    self.joker_display_next_update_time = joker_number_delta_variance / 2 +
                        joker_number_delta_variance / 2 * self.joker_display_update_time_variance
                    self:update_joker_display(false, false, "Card:update")

                    if self.children.joker_display then self.children.joker_display:recalculate(true) end
                    if self.children.joker_display_small then self.children.joker_display_small:recalculate(true) end
                    if self.children.joker_display_debuff then self.children.joker_display_debuff:recalculate(true) end
                end
            end
        end
    end
end

local card_set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    card_set_ability_ref(self, center, initial, delay_sprites)
    if JokerDisplay.config.enabled and G.jokers and self.joker_display_values then
        local is_display_area = false
        if self.area then
            for _, area in ipairs(JokerDisplay.get_display_areas()) do
                if self.area == area then
                    is_display_area = true
                    break
                end
            end
        end
        if is_display_area then
            self:update_joker_display(true, true, "Card:set_ability")
        end
    end
end

---Gets information about the current highlighted/played hand. If you want to evaluate the current hand:
---@see JokerDisplay.evaluate_hand
JokerDisplay.get_scoring_hand = function()
    if G.in_delete_run then return end

    local count_facedowns = false
    if G.STATE ~= G.STATES.HAND_PLAYED then
        JokerDisplay.current_hand = {}
        if G.STATE == G.STATES.SELECTING_HAND and G.hand and G.hand.highlighted then
            JokerDisplay.current_hand = JokerDisplay.sort_cards(G.hand.highlighted)
        end
    else
        count_facedowns = true
    end

    local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand(JokerDisplay.current_hand or {}, count_facedowns)
    JokerDisplay.current_hand_info = {
        text = text,
        poker_hands = poker_hands,
        scoring_hand = scoring_hand
    }
end

local cardarea_parse_highlighted_ref = CardArea.parse_highlighted
function CardArea:parse_highlighted()
    cardarea_parse_highlighted_ref(self)
    if G.hand then
        JokerDisplay.get_scoring_hand()
    end
end

local draw_card_ref = draw_card
function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
    draw_card_ref(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
    if from and (from == G.play or from == G.discard or from == G.deck or (from == G.hand and to ~= G.play)) then
        JokerDisplay.get_scoring_hand()
    end
end

local card_remove_ref = Card.remove
function Card:remove()
    card_remove_ref(self)
    if G.hand then
        JokerDisplay.get_scoring_hand()
    end
end

local card_release_ref = Node.stop_drag
function Node:stop_drag()
    card_release_ref(self)
    if self.area and self.area == G.hand then
        JokerDisplay.get_scoring_hand()
    end
end
