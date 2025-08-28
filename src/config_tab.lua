--- MOD CONFIG

SMODS.current_mod.ui_config = {
    bg_colour = HEX("44D72344"),
    back_colour = HEX("D63939"),
    tab_button_colour = HEX("D63939"),
    collection_option_cycle_colour = HEX("D63939"),
    author_colour = HEX("D63939")
}

SMODS.current_mod.description_loc_vars = function()
    return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end

SMODS.current_mod.config_tab = function()
    -- Create a card area that will display an example joker
    G.config_card_area = CardArea(G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h, 1.03 * G.CARD_W, 1.03 * G.CARD_H,
        { card_limit = 1, type = 'title', highlight_limit = 0, })
    local center = G.P_CENTERS['j_bloodstone']
    local card = Card(G.config_card_area.T.x + G.config_card_area.T.w / 2, G.config_card_area.T.y, G.CARD_W, G.CARD_H,
        nil, center)
    card:set_edition('e_foil', true, true)
    card:set_perishable(true)
    card:set_rental(true)
    G.config_card_area:emplace(card)
    G.config_card_area.cards[1]:update_joker_display()
    G.config_card_area.cards[1].joker_display_values.disabled = false

    return {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = {
            {
                n = G.UIT.R,
                config = { padding = 0.2 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cr", padding = 0.01 },
                                nodes = {
                                    create_toggle({
                                        label = localize('jdis_enabled'),
                                        ref_table = JokerDisplay.config,
                                        ref_value = 'enabled'
                                    })
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { padding = 0.01, align = "cr" },
                                nodes = {
                                    create_toggle({
                                        label = localize('jdis_hide_by_default'),
                                        ref_table = JokerDisplay.config,
                                        ref_value =
                                        'hide_by_default'
                                    })
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { padding = 0.01, align = "cr" },
                                nodes = {
                                    create_toggle({
                                        label = localize('jdis_hide_empty'),
                                        ref_table = JokerDisplay.config,
                                        ref_value =
                                        'hide_empty'
                                    })
                                }
                            },
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { padding = 0.01, align = "cr" },
                                nodes = {
                                    create_toggle({
                                        label = localize('jdis_disable_collapse'),
                                        ref_table = JokerDisplay.config,
                                        ref_value =
                                        'disable_collapse'
                                    })
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { padding = 0.01, align = "cr" },
                                nodes = {
                                    create_toggle({
                                        label = localize('jdis_disable_perishable'),
                                        ref_table = JokerDisplay.config,
                                        ref_value =
                                        'disable_perishable'
                                    })
                                }
                            },
                            {
                                n = G.UIT.R,
                                config = { padding = 0.01, align = "cr" },
                                nodes = {
                                    create_toggle({
                                        label = localize('jdis_disable_rental'),
                                        ref_table = JokerDisplay.config,
                                        ref_value =
                                        'disable_rental'
                                    })
                                }
                            },
                        }
                    },
                }
            },
            {
                n = G.UIT.R,
                config = { padding = 0.2 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm" },
                        nodes = {
                            {
                                n = G.UIT.R,
                                config = { align = "cm" },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cr", padding = 0.2 },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    {
                                                        n = G.UIT.T,
                                                        config = { text = localize('jdis_default_display'), colour = G.C.UI.TEXT_LIGHT, scale = 0.5, align = "cr" }
                                                    },
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cr" },
                                                nodes = {
                                                    create_toggle({
                                                        label = localize('jdis_modifiers'),
                                                        ref_table = JokerDisplay.config.default_rows,
                                                        callback = update_display,
                                                        ref_value = 'modifiers',
                                                        w = 2,
                                                    }),
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cr" },
                                                nodes = {
                                                    create_toggle({
                                                        label = localize('jdis_reminders'),
                                                        ref_table = JokerDisplay.config.default_rows,
                                                        callback = update_display,
                                                        ref_value = 'reminder',
                                                        w = 2
                                                    }),
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cr" },
                                                nodes = {
                                                    create_toggle({
                                                        label = localize('jdis_extras'),
                                                        ref_table = JokerDisplay.config.default_rows,
                                                        callback = update_display,
                                                        ref_value = 'extra',
                                                        w = 2
                                                    })
                                                }
                                            },
                                        }
                                    },
                                    {
                                        n = G.UIT.C,
                                        config = { align = "cr", padding = 0.2 },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = localize('jdis_small_display'), colour = G.C.UI.TEXT_LIGHT, scale = 0.5, align = "cr" } },
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cr" },
                                                nodes = {
                                                    create_toggle({
                                                        label = localize('jdis_modifiers'),
                                                        ref_table = JokerDisplay.config.small_rows,
                                                        callback = update_display,
                                                        ref_value = 'modifiers',
                                                        w = 2
                                                    }),
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cr" },
                                                nodes = {
                                                    create_toggle({
                                                        label = localize('jdis_reminders'),
                                                        ref_table = JokerDisplay.config.small_rows,
                                                        callback = update_display,
                                                        ref_value = 'reminder',
                                                        w = 2
                                                    }),
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cr" },
                                                nodes = {
                                                    create_toggle({
                                                        label = localize('jdis_extras'),
                                                        ref_table = JokerDisplay.config.small_rows,
                                                        callback = update_display,
                                                        ref_value = 'extra',
                                                        w = 2
                                                    })
                                                }
                                            },
                                        }
                                    }
                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "tm", padding = 0.1, no_fill = true },
                        nodes = {
                            { n = G.UIT.O, config = { object = G.config_card_area } }
                        }
                    }
                }
            },
            {
                n = G.UIT.R,
                config = { padding = 0.01, align = "cr" },
                nodes = {
                    create_toggle({
                        label = localize('jdis_shift_to_hide'),
                        ref_table = JokerDisplay.config,
                        ref_value =
                        'shift_to_hide'
                    })
                }
            },
            {
                n = G.UIT.R,
                config = { padding = 0.01, align = "cr" },
                nodes = {
                    create_toggle({
                        label = localize('jdis_joker_count'),
                        ref_table = JokerDisplay.config,
                        ref_value =
                        'joker_count'
                    })
                }
            },
            { n = G.UIT.R, config = { minh = 0.1 } }
        }
    }
end

-- Callback function for config toggles, updates the example joker and any current jokers if a game is being played
function update_display()
    G.config_card_area.cards[1]:update_joker_display(false, true, "config_update")
    if G.jokers then
        for _, area in ipairs(JokerDisplay.get_display_areas()) do
            for _, joker in pairs(area.cards) do
                joker:update_joker_display(false, true, "config_update")
            end
        end
    end
end
