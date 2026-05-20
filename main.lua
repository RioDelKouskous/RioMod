--- STEAMODDED HEADER
--- MOD_NAME: BalaRio
--- MOD_ID: BalaRio
--- MOD_AUTHOR: [RioSkai]
--- MOD_DESCRIPTION: Cool mod yeah yeah.
--- PREFIX: xmpl
----------------------------------------------
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
    key = 'rio_assets',
    path = 'rio_assets.png',
    px = 71, py = 95
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
    rarity = 3, -- 1 = common, 2 = uncommon, 3 = rare and 4 = legendary
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
            '> Horse is at peace with himself',
            '> Horse offers you his kindness',
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

----------------------------------------------
------------ TAROT DEFINITIONS ---------------

SMODS.Tarot{
    key = 'rio_guy',
    loc_txt = {
        name = 'The guy',
        text = { 'Create {C:attention}2{} random', '{C:tarot}Tarot{} cards' }
    },
    atlas = 'rio_assets',
    pos = {x = 0, y = 0},
    cost = 3,
    unlocked = true,
    discovered = true,
    calculate = function(self, card, context)
        if context.using_consumable then
            for i = 1, 2 do
                local new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'rio')
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
            end
            return {
                message = 'Live!',
                colour = G.C.PURPLE
            }
        end
    end
}

----------------------------------------------
----------- BOOSTER DEFINITIONS --------------

SMODS.Booster{
    key = 'rio_pack',
    kind = 'Tarot',
    atlas = 'rio_assets',
    pos = {x = 1, y = 0},
    config = {extra = 3, choose = 1}, -- Look at 3, choose 1
    cost = 4,
    weight = 2, -- How often it appears
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Rio Pack',
        text = { 'Choose {C:attention}#1#{} of', '{C:attention}#2#{} Tarot cards' }
    },
    loc_vars = function(self, info_queue, center)
        return {vars = {center.config.choose, center.config.extra}}
    end,
    create_card = function(self, card, i)
        return create_card('Tarot', G.pack_cards, nil, nil, nil, nil, nil, 'rio_p')
    end,
    group_key = 'k_tarot_pack'
}