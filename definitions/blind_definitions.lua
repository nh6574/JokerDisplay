--- Blind Definitions
return {
    bl_small = { -- Small Blind
    },
    bl_big = {   -- Big Blind
    },
    bl_hook = {  -- The Hook
    },
    bl_ox = {    -- The Ox
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            return G.GAME.current_round.most_played_poker_hand == text
        end
    },
    bl_house = { -- The House
    },
    bl_wall = {  -- The Wall
    },
    bl_wheel = { -- The Wheel
    },
    bl_arm = {   -- The Arm
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            --TODO: Fix untriggering when hand is played for the first time
            local hand_exists = text ~= 'Unknown' and G.GAME and G.GAME.hands and G.GAME.hands[text]
            return hand_exists and G.GAME.hands[text].level > to_big(1) or false
        end
    },
    bl_club = { -- The Club
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit(blind.debuff.suit, true) then
                        return true
                    end
                end
            end
            return false
        end
    },
    bl_fish = {    -- The Fish
    },
    bl_psychic = { -- The Psychic
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            return #full_hand > 0 and #full_hand < blind.debuff.h_size_ge
        end
    },
    bl_goad = { -- The Goad
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit(blind.debuff.suit, true) then
                        return true
                    end
                end
            end
            return false
        end
    },
    bl_water = { -- The Water
    },
    bl_window = { -- The Window
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit(blind.debuff.suit, true) then
                        return true
                    end
                end
            end
            return false
        end
    },
    bl_manacle = { -- The Manacle
    },
    bl_eye = { -- The Eye
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            --TODO: Fix triggering when hand is played for the first time
            return blind.hands[text] or false
        end
    },
    bl_mouth = { -- The Mouth
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            return #full_hand > 0 and text ~= "Unknown" and blind.only_hand and blind.only_hand ~= text or false
        end
    },
    bl_plant = { -- The Plant
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_face(true) then
                        return true
                    end
                end
            end
            return false
        end
    },
    bl_serpent = { -- The Serpent
    },
    bl_pillar = { -- The Pillar
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card.ability.played_this_ante then
                        return true
                    end
                end
            end
            return false
        end
    },
    bl_needle = { -- The Needle
    },
    bl_head = { -- The Head
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            if text ~= 'Unknown' then
                for _, scoring_card in pairs(scoring_hand) do
                    if scoring_card:is_suit(blind.debuff.suit, true) then
                        return true
                    end
                end
            end
            return false
        end
    },
    bl_tooth = { -- The Tooth
    },
    bl_flint = { -- The Flint
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            return true
        end
    },
    bl_mark = { -- The Mark
    },
    bl_final_acorn = { -- Amber Acorn
    },
    bl_final_leaf = { -- Verdant Leaf
        trigger_function = function(blind, text, poker_hands, scoring_hand, full_hand)
            return true
        end
    },
    bl_final_vessel = { -- Violet Vessel
    },
    bl_final_heart = { -- Crimson Heart
    },
    bl_final_bell = { -- Cerulean Bell
    },
}
