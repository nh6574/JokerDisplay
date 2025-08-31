--HELPER FUNCTIONS

---Returns scoring information about a set of cards. You can get the full hand using `JokerDisplay.current_hand`.
---@see G.FUNCS.evaluate_play
---@param cards table? Cards to calculate. Defaults to current precalculated hand.
---@param count_facedowns boolean? If true, counts cards facing back.
---@return string text Scoring poker hand's non-localized text. "Unknown" if there's a card facedown or if selected cards are not valid.
---@return table poker_hands Poker hands contained in the scoring hand.
---@return table scoring_hand Scoring cards in hand.
JokerDisplay.evaluate_hand = function(cards, count_facedowns)
    local valid_cards = cards
    local has_facedown = false

    if not cards then
        local hand_info = JokerDisplay.current_hand_info
        return hand_info.text, hand_info.poker_hands, hand_info.scoring_hand
    elseif type(cards) ~= "table" then
        return "Unknown", {}, {}
    end
    for i = 1, #cards do
        if type(cards[i]) ~= "table" or not cards[i].ability or not (cards[i].ability.set == 'Enhanced' or cards[i].ability.set == 'Default') then
            return "Unknown", {}, {}
        end
    end

    -- To prevent crashing during poker hand eval
    if G.play then
        for i = 1, #G.play.cards do
            if type(G.play.cards[i]) ~= "table" or not G.play.cards[i].ability or not (G.play.cards[i].ability.set == 'Enhanced' or G.play.cards[i].ability.set == 'Default') then
                return "Unknown", {}, {}
            end
        end
    end

    if not count_facedowns then
        valid_cards = {}
        for i = 1, #cards do
            if cards[i].facing and cards[i].facing ~= 'back' then
                table.insert(valid_cards, cards[i])
            else
                has_facedown = true
            end
        end
    else
        valid_cards = cards
    end

    local text, _, poker_hands, scoring_hand, _ = G.FUNCS.get_poker_hand_info(valid_cards)

    local final_scoring_hand = {}
    for i = 1, #valid_cards do
        local splashed = SMODS.always_scores(valid_cards[i]) or next(find_joker('Splash'))
        local unsplashed = SMODS.never_scores(valid_cards[i])
        if not splashed then
            for _, card in pairs(scoring_hand) do
                if card == valid_cards[i] then splashed = true end
            end
        end
        local effects = {}
        SMODS.calculate_context(
            {
                modify_scoring_hand = true,
                other_card = valid_cards[i],
                full_hand = valid_cards,
                scoring_hand =
                    scoring_hand
            }, effects)
        local flags = SMODS.trigger_effects(effects, valid_cards[i])
        flags = flags or {}
        if flags.add_to_hand then splashed = true end
        if flags.remove_from_hand then unsplashed = true end
        if splashed and not unsplashed then table.insert(final_scoring_hand, valid_cards[i]) end
    end

    return (has_facedown and "Unknown" or text), poker_hands, final_scoring_hand
end

---Returns what Joker the current Blueprint-like card is copying.
---@param card table Blueprint-like card to calculate copy for.
---@param _cycle_count integer? Counts how many times the function has recurred to prevent loops.
---@param _cycle_debuff boolean? Saves debuffed state on recursion.
---@return table? copied_joker Copied Joker
---@return boolean debuff If the copied joker (or any in the chain) is debuffed
JokerDisplay.calculate_blueprint_copy = function(card, _cycle_count, _cycle_debuff)
    local joker_display_definition = JokerDisplay.Definitions[card.config.center.key]
    if not joker_display_definition.get_blueprint_joker or (_cycle_count and _cycle_count > #G.jokers.cards + 1) then
        return nil, false
    end
    local other_joker = joker_display_definition.get_blueprint_joker(card)
    if other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat then
        local other_joker_display_definition = JokerDisplay.Definitions[other_joker.config.center.key]
        if other_joker_display_definition and other_joker_display_definition.get_blueprint_joker then
            return JokerDisplay.calculate_blueprint_copy(other_joker,
                _cycle_count and _cycle_count + 1 or 1,
                _cycle_debuff or other_joker.debuff)
        else
            return other_joker, (_cycle_debuff or other_joker.debuff)
        end
    end
    return nil, false
end

---Copies an in-play Joker's display
---@param card table Card that is copying
---@param copied_joker? table Joker being copied. Initializes default display if nil
---@param is_debuffed boolean? If Joker is debuffed by other means.
---@param bypass_debuff boolean? Bypass debuff.
---@param stop_func_copy boolean? Don't copy other functions such as mod_function, retrigger_function, etc.
JokerDisplay.copy_display = function(card, copied_joker, is_debuffed, bypass_debuff, stop_func_copy)
    local changed = copied_joker ~= card.joker_display_values.blueprint_ability_joker or
        card.joker_display_values.blueprint_debuff ~= is_debuffed
    card.joker_display_values.blueprint_ability_joker = copied_joker
    card.joker_display_values.blueprint_ability_name = copied_joker and copied_joker.ability.name
    card.joker_display_values.blueprint_ability_key = copied_joker and copied_joker.config.center.key
    card.joker_display_values.blueprint_debuff = not bypass_debuff and
        (is_debuffed or copied_joker and copied_joker.debuff) or false
    card.joker_display_values.blueprint_stop_func = stop_func_copy
    card.joker_display_values.blueprint_force_update = true

    if card.joker_display_values.blueprint_initialized and (changed or not card.joker_display_values.blueprint_loaded) then
        card.children.joker_display:remove_text()
        card.children.joker_display:remove_reminder_text()
        card.children.joker_display:remove_extra()
        card.children.joker_display_small:remove_text()
        card.children.joker_display_small:remove_reminder_text()
        card.children.joker_display_small:remove_extra()
        if copied_joker then
            if card.joker_display_values.blueprint_debuff then
                card.children.joker_display:add_text({ { text = "" .. localize("k_debuffed"), colour = G.C.UI.TEXT_INACTIVE } })
            elseif copied_joker.joker_display_values then
                copied_joker:initialize_joker_display(card)
                card.joker_display_values.blueprint_loaded = true
            else
                card.joker_display_values.blueprint_loaded = false
            end
        else
            card:initialize_joker_display(nil, true)
            card.joker_display_values.blueprint_loaded = true
        end
    end
    card.joker_display_values.blueprint_initialized = true
end

---Returns all held instances of certain Joker, including Blueprint copies.
---@see SMODS.find_card
---@param key string Key of the Joker to find.
---@param count_debuffed boolean? If true also returns debuffed cards.
---@return table #All Jokers found, including Jokers with copy abilities.
JokerDisplay.find_joker_or_copy = function(key, count_debuffed)
    local jokers = {}
    if not G.jokers or not G.jokers.cards then return {} end
    for _, joker in pairs(G.jokers.cards) do
        if joker and type(joker) == 'table' and
            (joker.config.center.key == key or
                joker.joker_display_values and joker.joker_display_values.blueprint_ability_key and
                not joker.joker_display_values.blueprint_stop_func and
                joker.joker_display_values.blueprint_ability_key == key) and
            (count_debuffed or not joker.debuff) then
            table.insert(jokers, joker)
        end
    end

    local blueprint_count = 0
    for _, joker in pairs(jokers) do
        if joker.joker_display_values.blueprint_ability_key and not joker.joker_display_values.blueprint_stop_func then
            blueprint_count = blueprint_count + 1
        end
    end
    if blueprint_count >= #jokers then
        return {}
    end

    return jokers
end

---Sort cards from left to right.
---@param cards table Cards to sort.
---@return table # Sorted cards.
JokerDisplay.sort_cards = function(cards)
    local copy = {}
    for k, v in pairs(cards) do
        copy[k] = v
    end
    table.sort(copy, function(a, b) return a.T.x < b.T.x end)
    return copy
end

---Returns the leftmost card in a set of cards.
---@param cards table Cards to calculate.
---@return table? # Leftmost card in hand if any.
JokerDisplay.calculate_leftmost_card = function(cards)
    local sorted_cards = JokerDisplay.sort_cards(cards)
    return sorted_cards and sorted_cards[1]
end

---Returns the rightmost card in a set of cards.
---@param cards table Cards to calculate.
---@return table? # Rightmost card in hand if any.
JokerDisplay.calculate_rightmost_card = function(cards)
    local sorted_cards = JokerDisplay.sort_cards(cards)
    return sorted_cards and sorted_cards[#sorted_cards]
end

---Returns how many times the scoring card would be triggered for scoring if played.
---@param card table Card to calculate.
---@param scoring_hand table? Scoring hand.
---@param held_in_hand boolean? true if the card is held in hand and not a scoring card.
---@return integer # Times the card would trigger. (0 if debuffed)
JokerDisplay.calculate_card_triggers = function(card, scoring_hand, held_in_hand)
    if card.debuff then
        return 0
    end

    local triggers = 1

    if G.jokers then
        for _, area in ipairs(JokerDisplay.get_display_areas()) do
            for _, joker in pairs(area.cards) do
                local joker_display_definition = JokerDisplay.Definitions[joker.config.center.key]
                local retrigger_function = not joker.debuff and joker.joker_display_values and
                    ((joker_display_definition and joker_display_definition.retrigger_function) or
                        (joker.joker_display_values.blueprint_ability_key and
                            not joker.joker_display_values.blueprint_debuff and not joker.joker_display_values.blueprint_stop_func and
                            JokerDisplay.Definitions[joker.joker_display_values.blueprint_ability_key] and
                            JokerDisplay.Definitions[joker.joker_display_values.blueprint_ability_key].retrigger_function))

                if retrigger_function then
                    -- The rounding is for Cryptid compat
                    triggers = triggers +
                        math.floor(retrigger_function(card, scoring_hand, held_in_hand or false,
                            joker.joker_display_values and not joker.joker_display_values.blueprint_stop_func and
                            joker.joker_display_values.blueprint_ability_joker or joker) or 0)
                end
            end
        end
    end

    triggers = triggers + (card:get_seal() == 'Red' and 1 or 0) + (card.ability.perma_repetitions or 0)

    return triggers
end

---Returns what modifiers the other Jokers in play add to the this Joker card.
---@param card table Joker to calculate.
---@return table # Modifiers.
JokerDisplay.calculate_joker_modifiers = function(card)
    local modifiers = {
        chips = nil,
        x_chips = nil,
        mult = nil,
        x_mult = nil,
        dollars = nil,
        e_mult = nil
    }

    for _, edition in pairs(JokerDisplay.Edition_Definitions) do
        if edition.condition_function(card) then
            local edition_mods = edition.mod_function(card)
            edition_mods.x_mult = edition_mods.x_mult or edition_mods.xmult
            edition_mods.x_chips = edition_mods.x_chips or edition_mods.xchips
            edition_mods.e_mult = edition_mods.e_mult or edition_mods.emult
            modifiers = {
                chips = (modifiers.chips and edition_mods.chips and modifiers.chips + edition_mods.chips) or
                    edition_mods.chips or modifiers.chips,
                x_chips = (modifiers.x_chips and edition_mods.x_chips and modifiers.x_chips * edition_mods.x_chips) or
                    edition_mods.x_chips or modifiers.x_chips,
                mult = (modifiers.mult and edition_mods.mult and modifiers.mult + edition_mods.mult) or
                    edition_mods.mult or modifiers.mult,
                x_mult = (modifiers.x_mult and edition_mods.x_mult and modifiers.x_mult * edition_mods.x_mult) or
                    edition_mods.x_mult or modifiers.x_mult,
                dollars = (modifiers.dollars and edition_mods.dollars and modifiers.dollars + edition_mods.dollars) or
                    edition_mods.dollars or modifiers.dollars,
                e_mult = (modifiers.e_mult and edition_mods.e_mult and modifiers.e_mult ^ edition_mods.e_mult) or
                    edition_mods.e_mult or modifiers.e_mult,
            }
        end
    end

    if G.jokers then
        for _, area in ipairs(JokerDisplay.get_display_areas()) do
            for _, joker in pairs(area.cards) do
                local joker_display_definition = JokerDisplay.Definitions[joker.config.center.key]
                local mod_function = not joker.debuff and joker.joker_display_values and
                    ((joker_display_definition and joker_display_definition.mod_function) or
                        (joker.joker_display_values.blueprint_ability_key and
                            not joker.joker_display_values.blueprint_debuff and not joker.joker_display_values.blueprint_stop_func and
                            JokerDisplay.Definitions[joker.joker_display_values.blueprint_ability_key] and
                            JokerDisplay.Definitions[joker.joker_display_values.blueprint_ability_key].mod_function))

                if mod_function then
                    local extra_mods = mod_function(card,
                        joker.joker_display_values and not joker.joker_display_values.blueprint_stop_func and
                        joker.joker_display_values.blueprint_ability_joker or joker)
                    extra_mods.x_mult = extra_mods.x_mult or extra_mods.xmult
                    extra_mods.x_chips = extra_mods.x_chips or extra_mods.xchips
                    extra_mods.e_mult = extra_mods.e_mult or extra_mods.emult
                    modifiers = {
                        chips = (modifiers.chips and extra_mods.chips and modifiers.chips + extra_mods.chips) or
                            extra_mods.chips or modifiers.chips,
                        x_chips = (modifiers.x_chips and extra_mods.x_chips and modifiers.x_chips * extra_mods.x_chips) or
                            extra_mods.x_chips or modifiers.x_chips,
                        mult = (modifiers.mult and extra_mods.mult and modifiers.mult + extra_mods.mult) or
                            extra_mods.mult or modifiers.mult,
                        x_mult = (modifiers.x_mult and extra_mods.x_mult and modifiers.x_mult * extra_mods.x_mult) or
                            extra_mods.x_mult or modifiers.x_mult,
                        dollars = (modifiers.dollars and extra_mods.dollars and modifiers.dollars + extra_mods.dollars) or
                            extra_mods.dollars or modifiers.dollars,
                        e_mult = (modifiers.e_mult and extra_mods.e_mult and modifiers.e_mult ^ extra_mods.e_mult) or
                            extra_mods.e_mult or modifiers.e_mult,
                    }
                end
            end
        end
    end

    return modifiers
end

---Returns if hand triggers (boss) blind.
---@param blind table Blind to calculate.
---@param text string Scoring poker hand's non-localized text. "Unknown" if there's a card facedown or if selected cards are not valid.
---@param poker_hands table Poker hands contained in the scoring hand.
---@param scoring_hand table Scoring cards in hand.
---@param full_hand table Full hand.
---@return boolean? # true if it triggers the blind, false otherwise. nil if unknown (blind is not defined).
JokerDisplay.triggers_blind = function(blind, text, poker_hands, scoring_hand, full_hand)
    if blind.disabled then return false end

    local blind_key = blind.config.blind.key
    if not blind_key then return nil end

    local blind_definition = JokerDisplay.Blind_Definitions[blind_key]
    if not blind_definition then return nil end

    if blind_definition.trigger_function then
        return blind_definition.trigger_function(blind, text, poker_hands, scoring_hand, full_hand)
    end

    return false
end

---Returns how many times the Joker would be triggered if activated.
---@param card table Joker to calculate.
---@return integer # Times the card would trigger. (0 if debuffed)
JokerDisplay.calculate_joker_triggers = function(card)
    if card.debuff then
        return 0
    end

    local triggers = 1

    if G.jokers then
        for _, area in ipairs(JokerDisplay.get_display_areas()) do
            for _, joker in pairs(area.cards) do
                local joker_display_definition = JokerDisplay.Definitions[joker.config.center.key]
                local retrigger_joker_function = not joker.debuff and joker.joker_display_values and
                    ((joker_display_definition and joker_display_definition.retrigger_joker_function) or
                        (joker.joker_display_values.blueprint_ability_key and
                            not joker.joker_display_values.blueprint_debuff and not joker.joker_display_values.blueprint_stop_func and
                            JokerDisplay.Definitions[joker.joker_display_values.blueprint_ability_key] and
                            JokerDisplay.Definitions[joker.joker_display_values.blueprint_ability_key].retrigger_joker_function))

                if retrigger_joker_function then
                    -- The rounding is for Cryptid compat
                    triggers = triggers +
                        math.floor(retrigger_joker_function(card,
                            joker.joker_display_values and not joker.joker_display_values.blueprint_stop_func and
                            joker.joker_display_values.blueprint_ability_joker or joker) or 0)
                end
            end
        end
    end

    return triggers
end
