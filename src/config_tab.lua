--- MOD CONFIG

local ui_config = {
    bg_colour = HEX("44D72344"),
    back_colour = HEX("D63939"),
    tab_button_colour = HEX("D63939"),
    collection_option_cycle_colour = HEX("D63939"),
    author_colour = HEX("D63939")
}

JokerDisplay.save_config = JokerDisplay.save_config or function() end

JokerDisplay.config_tab = function()
    if not JokerDisplay.init_loc then init_localization() end
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

    local modNodes = {}

    local authors = localize('jdis_author') .. ': ' .. "nh6574"

    -- Authors names
    table.insert(modNodes, {
        n = G.UIT.R,
        config = {
            align = "cm",
            r = 0.1,
            emboss = 0.1,
            outline = 1,
            padding = 0.07,
            outline_colour = ui_config.author_outline_colour,
            colour = ui_config.author_bg_colour,
        },
        nodes = {
            {
                n = G.UIT.T,
                config = {
                    text = authors,
                    shadow = true,
                    scale = 0.75 * 0.65,
                    colour = ui_config.author_colour or G.C.BLUE,
                }
            }
        }
    })

    modNodes[#modNodes + 1] = {}
    local loc_vars = { background_colour = G.C.CLEAR, text_colour = G.C.UI.TEXT_LIGHT, scale = 1.2 }
    localize { type = 'descriptions', key = loc_vars.key or "JokerDisplay", set = 'Mod', nodes = modNodes[#modNodes], vars = loc_vars.vars, scale = loc_vars.scale, text_colour = loc_vars.text_colour, shadow = loc_vars.shadow }
    modNodes[#modNodes] = desc_from_rows(modNodes[#modNodes])
    modNodes[#modNodes].config.colour = loc_vars.background_colour or modNodes[#modNodes].config.colour

    local config = {
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
                                    ref_value = 'enabled',
                                    callback = JokerDisplay.save_config
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
                                    'hide_by_default',
                                    callback = JokerDisplay.save_config
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
                                    'hide_empty',
                                    callback = JokerDisplay.save_config
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
                                    'disable_collapse',
                                    callback = JokerDisplay.save_config
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
                                    'disable_perishable',
                                    callback = JokerDisplay.save_config
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
                                    'disable_rental',
                                    callback = JokerDisplay.save_config
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
                    'shift_to_hide',
                    callback = JokerDisplay.save_config
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
                    'joker_count',
                    callback = JokerDisplay.save_config
                })
            }
        },
        { n = G.UIT.R, config = { minh = 0.1 } }
    }

    return SMODS and {
        n = G.UIT.ROOT,
        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
        nodes = config
    } or {
        n = G.UIT.ROOT,
        config = { align = "tm", colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.R,
                config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.CLEAR },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { r = 0.1, minw = 8, align = "tm", padding = 0.2, colour = G.C.BLACK },
                        nodes = config
                    },
                    {
                        n = G.UIT.C,
                        config = {
                            minh = 6,
                            r = 0.1,
                            minw = 6,
                            align = "tm",
                            padding = 0.2,
                            colour = G.C.BLACK
                        },
                        nodes = modNodes
                    }
                }
            }
        }
    }
end

if SMODS then
    SMODS.current_mod.ui_config = ui_config

    SMODS.current_mod.description_loc_vars = function()
        return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
    end

    SMODS.current_mod.config_tab = function()
        return JokerDisplay.config_tab()
    end
end

-- Callback function for config toggles, updates the example joker and any current jokers if a game is being played
function update_display()
    JokerDisplay.save_config()

    G.config_card_area.cards[1]:update_joker_display(false, true, "config_update")
    if G.jokers then
        for _, area in ipairs(JokerDisplay.get_display_areas()) do
            for _, joker in pairs(area.cards) do
                joker:update_joker_display(false, true, "config_update")
            end
        end
    end
end
