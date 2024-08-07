---DISPLAY DEFINITION

---Initializes nodes for JokerDisplay.
function Card:initialize_joker_display(custom_parent)
    if not custom_parent then
        self.children.joker_display:remove_text()
        self.children.joker_display:remove_reminder_text()
        self.children.joker_display:remove_extra()
        self.children.joker_display:remove_modifiers()
        self.children.joker_display_small:remove_text()
        self.children.joker_display_small:remove_reminder_text()
        self.children.joker_display_small:remove_extra()
        self.children.joker_display_small:remove_modifiers()
        self.children.joker_display_debuff:remove_text()
        self.children.joker_display_debuff:remove_modifiers()

        self.children.joker_display_debuff:add_text({ { text = "" .. localize("k_debuffed"), colour = G.C.UI.TEXT_INACTIVE } })
    end

    self:calculate_joker_display()

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local definiton_text = joker_display_definition and
        (joker_display_definition.text or joker_display_definition.line_1)
    local text_config = joker_display_definition and joker_display_definition.text_config
    local definiton_reminder_text = joker_display_definition and (joker_display_definition.reminder_text or
        joker_display_definition.line_2)
    local reminder_text_config = joker_display_definition and joker_display_definition.reminder_text_config
    local definiton_extra = joker_display_definition and joker_display_definition.extra
    local extra_config = joker_display_definition and joker_display_definition.extra_config

    if definiton_text then
        if custom_parent then
            custom_parent.children.joker_display:add_text(definiton_text, text_config, self)
            custom_parent.children.joker_display_small:add_text(definiton_text, text_config, self)
        else
            self.children.joker_display:add_text(definiton_text, text_config)
            self.children.joker_display_small:add_text(definiton_text, text_config)
        end
    end
    if definiton_reminder_text then
        if not reminder_text_config then
            reminder_text_config = {}
        end
        reminder_text_config.colour = reminder_text_config.colour or G.C.UI.TEXT_INACTIVE
        reminder_text_config.scale = reminder_text_config.scale or 0.3
        if JokerDisplay.config.default_rows.reminder then
            if custom_parent then
                custom_parent.children.joker_display:add_reminder_text(definiton_reminder_text, reminder_text_config,
                    self)
            else
                self.children.joker_display:add_reminder_text(definiton_reminder_text, reminder_text_config)
            end
        end
        if JokerDisplay.config.small_rows.reminder then
            if custom_parent then
                custom_parent.children.joker_display_small:add_reminder_text(definiton_reminder_text,
                    reminder_text_config, self)
            else
                self.children.joker_display_small:add_reminder_text(definiton_reminder_text, reminder_text_config)
            end
        end
    end
    if definiton_extra then
        if JokerDisplay.config.default_rows.extra then
            if custom_parent then
                custom_parent.children.joker_display:add_extra(definiton_extra, extra_config, self)
            else
                self.children.joker_display:add_extra(definiton_extra, extra_config)
            end
        end
        if JokerDisplay.config.small_rows.extra then
            if custom_parent then
                custom_parent.children.joker_display_small:add_extra(definiton_extra, extra_config, self)
            else
                self.children.joker_display_small:add_extra(definiton_extra, extra_config)
            end
        end
    end

    if custom_parent then
        custom_parent.children.joker_display:recalculate()
        custom_parent.children.joker_display_small:recalculate()
    else
        self.children.joker_display:recalculate()
        self.children.joker_display_small:recalculate()
    end
end

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

    if JokerDisplay.config.default_rows.modifiers then
        self.children.joker_display:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
        self.children.joker_display_debuff:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
    end

    if JokerDisplay.config.small_rows.modifiers then
        self.children.joker_display_small:change_modifiers(JokerDisplay.calculate_joker_modifiers(self), true)
    end

    local joker_display_definition = JokerDisplay.Definitions[self.config.center.key]
    local calc_function = joker_display_definition and joker_display_definition.calc_function

    if calc_function then
        calc_function(self)
    end
end

---Updates the JokerDisplay and initializes it if necessary.
---@param force_update boolean? Force update even if disabled.
function Card:update_joker_display(force_update, force_reload, _from)
    if self.ability and self.ability.set == 'Joker' then
        --print(tostring(self.ability.name) .. " : " .. tostring(_from))
        if not self.children.joker_display then
            self.joker_display_values = {}
            self.joker_display_values.disabled = JokerDisplay.config.hide_by_default
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
            if force_update or (JokerDisplay.config.enabled and
                    (self:joker_display_has_info() or not JokerDisplay.config.hide_empty)
                    and (not self.joker_display_values.disabled)) then
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
function JokerDisplay.update_all_joker_display(force_update, force_reload, _from)
    if G.jokers and not G.SETTINGS.paused then
        for k, v in pairs(G.jokers.cards) do
            v:update_joker_display(force_update, force_reload, _from)
        end
    end
end

function Card:joker_display_toggle()
    if not self.joker_display_values then return end
    if self.joker_display_values.disabled then
        self:update_joker_display(true)
    end
    self.joker_display_values.disabled = not self.joker_display_values.disabled
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

        local is_blueprint_copying = card.joker_display_values and card.joker_display_values.blueprint_ability_key
        local joker_display_definition = JokerDisplay.Definitions[is_blueprint_copying or card.config.center.key]
        local style_function = joker_display_definition and joker_display_definition.style_function

        if style_function then
            local recalculate = style_function(card, text, reminder_text, extra)
            if recalculate then
                JokerDisplayBox.recalculate(e.UIBox)
            end
        end
    end
end

--- UPDATE

local card_update_ref = Card.update
function Card:update(dt)
    card_update_ref(self, dt)
    if JokerDisplay.config.enabled and G.jokers and self.area == G.jokers then
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
            local joker_number_delta_variance = math.max(0.2, #G.jokers.cards / 20)
            self.joker_display_next_update_time = joker_number_delta_variance / 2 +
                joker_number_delta_variance / 2 * self.joker_display_update_time_variance
        elseif self.joker_display_values and G.real_dt > 0.05 and #G.jokers.cards > 20 then
            self.joker_display_values.disabled = true
        else
            self.joker_display_last_update_time = self.joker_display_last_update_time + dt
            if self.joker_display_last_update_time > self.joker_display_next_update_time then
                self.joker_display_last_update_time = 0
                local joker_number_delta_variance = math.max(0.2, #G.jokers.cards / 20)
                self.joker_display_next_update_time = joker_number_delta_variance / 2 +
                    joker_number_delta_variance / 2 * self.joker_display_update_time_variance
                self:update_joker_display(false, false, "Card:update")
            end
        end
    end
end

JokerDisplay.get_scoring_hand = function()
    local count_facedowns = false
    if G.STATE ~= G.STATES.HAND_PLAYED then
        JokerDisplay.current_hand = {}
        if G.STATE == G.STATES.SELECTING_HAND and G.hand and G.hand.highlighted then
            for i = 1, #G.hand.highlighted do
                JokerDisplay.current_hand[i] = G.hand.highlighted[i]
            end
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
    JokerDisplay.get_scoring_hand()
end

local draw_card_ref = draw_card
function draw_card(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
    draw_card_ref(from, to, percent, dir, sort, card, delay, mute, stay_flipped, vol, discarded_only)
    if from ~= G.hand or to ~= G.play then
        JokerDisplay.get_scoring_hand()
    end
end

local card_remove_ref = Card.remove
function Card:remove()
    card_remove_ref(self)
    JokerDisplay.get_scoring_hand()
end