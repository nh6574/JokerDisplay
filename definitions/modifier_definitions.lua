return {
    chips = {
        text = {
            { ref_table = "card.modifiers", ref_value = "chips", colour = G.C.CHIPS, signed = true }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier + new_modifier) or
                old_modifier or new_modifier
        end,
    },
    x_chips = {
        text = {
            {
                border_nodes = { { ref_table = "card.modifiers", ref_value = "x_chips", signed = "X" } },
                border_colour = G.C.CHIPS
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    mult = {
        text = {
            { ref_table = "card.modifiers", ref_value = "mult", colour = G.C.MULT, signed = true }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier + new_modifier) or
                old_modifier or new_modifier
        end,
    },
    x_mult = {
        text = {
            {
                border_nodes = { { ref_table = "card.modifiers", ref_value = "x_mult" } },
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    dollars = {
        text = {
            { ref_table = "card.modifiers", ref_value = "dollars", colour = G.C.GOLD, signed = "$" }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier + new_modifier) or
                old_modifier or new_modifier
        end,
    },
    xdollars = {
        text = {
            {
                border_nodes = { { ref_table = "card.modifiers", ref_value = "xdollars", signed = { plus = "X$", minus = "X-$" } } },
                border_colour = G.C.GOLD
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    edollars = {
        text = {
            {
                border_nodes = { { ref_table = "card.modifiers", ref_value = "edollars", signed = { plus = "^$", minus = "^-$" } } },
                border_colour = G.C.GOLD
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    e_mult = {
        text = {
            {
                border_nodes = { { text = "^" },
                    { ref_table = "card.modifiers", ref_value = "e_mult" } },
                border_colour = function() return Spectrallib and Spectrallib.emult or G.C.emult or G.C.DARK_EDITION end
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    e_chips = {
        text = {
            {
                border_nodes = { { text = "^" },
                    { ref_table = "card.modifiers", ref_value = "e_chips" } },
                border_colour = function() return Spectrallib and Spectrallib.echips or G.C.echips or G.C.DARK_EDITION end
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    score = {
        text = {
            { ref_table = "card.modifiers", ref_value = "score", colour = G.C.PURPLE, signed = true }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier + new_modifier) or
                old_modifier or new_modifier
        end,
    },
    xscore = {
        text = {
            {
                border_nodes = { { ref_table = "card.modifiers", ref_value = "xscore", signed = "X" } },
                border_colour = G.C.PURPLE
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
    blindsize = {
        text = {
            { ref_table = "card.modifiers", ref_value = "blindsize", colour = G.C.DYN_UI.MAIN, signed = true }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier + new_modifier) or
                old_modifier or new_modifier
        end,
    },
    xblindsize = {
        text = {
            {
                border_nodes = { { ref_table = "card.modifiers", ref_value = "xblindsize", signed = "X" } },
                border_colour = G.C.DYN_UI.MAIN
            }
        },
        calc_function = function(card, old_modifier, new_modifier)
            return (old_modifier and new_modifier and old_modifier * new_modifier) or
                old_modifier or new_modifier
        end,
    },
}
