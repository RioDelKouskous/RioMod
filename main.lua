--- STEAMODDED HEADER
--- MOD_NAME: BalaRio
--- MOD_ID: BalaRio
--- MOD_AUTHOR: [RioSkai]
--- MOD_DESCRIPTION: Cool mod yeah yeah.
--- PREFIX: xmpl
----------------------------------------------
------------ ATLAS DEFINITIONS ---------------

SMODS.Atlas{
    key = 'rio_assets',
    path = 'rio_assets.png',
    px = 71, py = 95
}

----------------------------------------------
------------ LOAD ITEM FILES -----------------

local f, err = SMODS.load_file("items/jokers.lua")
if err then
    error(err)
else
    f()
end

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