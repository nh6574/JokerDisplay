--- Edition Definitions
return {
    e_foil = {
        condition_function = function(card)
            return not card.debuff and card.edition and card.edition.foil
        end,
        mod_function = function(card)
            return { chips = card:get_edition().chip_mod }
        end
    },
    e_holo = {
        condition_function = function(card)
            return not card.debuff and card.edition and card.edition.holo
        end,
        mod_function = function(card)
            return { mult = card:get_edition().mult_mod }
        end
    },
    e_polychrome = {
        condition_function = function(card)
            return not card.debuff and card.edition and card.edition.polychrome
        end,
        mod_function = function(card)
            return { x_mult = card:get_edition().x_mult_mod }
        end
    },
}
