--- STEAMODDED HEADER
--- MOD_NAME: RIOMOD
--- MOD_ID: RIOMOD
--- MOD_AUTHOR: [elial1]
--- MOD_DESCRIPTION: Cool mod yeah yeah.
--- PREFIX: xmpl
----------------------------------------------
------------MOD CODE -------------------------


SMODS.Atlas{
    key = 'Jokers',
    path = 'Jokers.png',
    px = 71,
    py = 95
}
SMODS.Joker{
    key = 'derek',
    loc_txt = {
        name = 'Derek',
        text = {
          'When Blind is selected,',
          'create a {C:attention}Joker{}',
          '{X:mult,C:white}X#1#{} Mult',
          'Gain {C:money}123${} at end of round'
        },
    },
    atlas = 'Jokers',
    rarity = 4, --rarity: 1 = Common, 2 = Uncommon, 3 = Rare, 4 = Legendary
    --soul_pos = { x = 0, y = 0 },
    cost = 123,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,
    pos = {x = 0, y = 0},
    config = { 
      extra = {
        Xmult = 100
      }
    },
    loc_vars = function(self,info_queue,center)
        info_queue[#info_queue+1] = G.P_CENTERS.j_joker --adds "Joker"'s description next to this card's description
        return {vars = {center.ability.extra.Xmult}} --#1# is replaced with card.ability.extra.Xmult
    end,
    check_for_unlock = function(self, args)
        if args.type == 'derek_loves_you' then
            unlock_card(self)
        end
        unlock_card(self)
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return {
                card = card,
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                colour = G.C.MULT
            }
        end

        if context.setting_blind then
            local new_card = create_card('Joker', G.jokers, nil,nil,nil,nil,'j_joker')
            new_card:add_to_deck()
            G.jokers:emplace(new_card)
        end
    end,
    in_pool = function(self,wawa,wawa2)
        return true
    end,
    calc_dollar_bonus = function(self,card)
        return 123
    end,
}