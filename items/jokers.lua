------------ ATLAS DEFINITIONS ---------------

SMODS.Atlas{
    key = 'derek_atlas',
    path = 'derek.png',
    px = 71, py = 95
}

SMODS.Atlas{
    key = 'horse of peace and kindness_atlas',
    path = 'horse of peace and kindness.png',
    px = 71, py = 95
}

SMODS.Atlas{
    key = 'dolby_atlas',
    path = 'dolby.png',
    px = 72, py = 96
}

----------------------------------------------
------------ JOKER DEFINITIONS ---------------

SMODS.Joker{
    key = 'derek',
    loc_txt = {
        name = 'Derek',
        text = {
          'When Blind is selected,',
          'create a {C:attention}Joker{}',
          '{X:mult,C:white}X#1#{} Mult',
          'Gain {C:money}4${} at end of round'
        },
    },
    atlas = 'derek_atlas',
    rarity = 3,
    cost = 12,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    pos = {x = 0, y = 0},
    config = { extra = { Xmult = 4 } },
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = 'X' .. card.ability.extra.Xmult,
                Xmult_mod = card.ability.extra.Xmult
            }
        end
        if context.setting_blind and not context.blueprint and #G.jokers.cards < G.jokers.config.card_limit then
            local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_joker')
            new_card:add_to_deck()
            G.jokers:emplace(new_card)
            return {
                message = 'Derek yay',
                colour = G.C.BLUE
            }
        end
    end,
    calc_dollar_bonus = function(self, card)
        return 4
    end
}

SMODS.Joker{
    key = 'horse_of_peace_and_kindness',
    loc_txt = {
        name = 'Horse of Peace and Kindness',
        text = { 
            '{C:green}> Horse is at peace with himself{}',
            '{C:green}> Horse offers you his kindness{}',
            '{C:chips}+#1#{} Chips and {X:mult,C:white}X#2#{} Mult'
        },
    },
    atlas = 'horse of peace and kindness_atlas',
    rarity = 2,
    cost = 7,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    pos = {x = 0, y = 0},
    config = { extra = { chips = 50, Xmult = 1.5 } }, 
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips, center.ability.extra.Xmult}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chip_mod = card.ability.extra.chips,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'Peace & Kindness!',
                colour = G.C.RED
            }
        end
    end
}

SMODS.Joker{
    key = 'dolby',
    loc_txt = {
        name = 'Dolby',
        text = {
            'Adds {C:mult}+#1#{} Mult.',
            '{C:red,E:2}Self-destructs{} in {C:attention}#2#{} hands.'
        },
    },
    atlas = 'dolby_atlas',
    rarity = 1,
    cost = 5,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    pos = {x = 0, y = 0},
    config = { extra = { mult = 500, hands_left = 3 } },
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.mult, center.ability.extra.hands_left}}
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = '+' .. card.ability.extra.mult .. ' Mult',
                mult_mod = card.ability.extra.mult
            }
        end
        if context.after and not context.blueprint then
            if card.ability.extra.hands_left - 1 <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = 'Self-Destruct!',
                    colour = G.C.RED
                }
            else
                card.ability.extra.hands_left = card.ability.extra.hands_left - 1
                return {
                    message = card.ability.extra.hands_left .. '',
                    colour = G.C.RED
                }
            end
        end
    end
}
