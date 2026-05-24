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

SMODS.Atlas{
    key = 'daronne_vexpi_atlas',
    path = 'daronnevexpi.png',
    px = 150, py = 95
}

SMODS.Sound{
    key = 'robloxchezburger',
    path = 'robloxchezburger.ogg'
}

local DARONNE_VEXPI_KEY = 'j_xmpl_daronne_vexpi'
local DARONNE_VEXPI_SOUND = 'xmpl_robloxchezburger'
local DARONNE_VEXPI_WORDS = {
    'Yummy!',
    'Delicious!',
    'Tasty!',
    'Scrumptious!',
    'Nom nom!',
    'Chef kiss!',
    'Snack time!',
    'Miam!'
}

local function rio_format_num(value)
    if type(value) ~= 'number' then return value end
    local formatted = string.format('%.2f', value)
    formatted = formatted:gsub('0+$', ''):gsub('%.$', '')
    return formatted
end

local function rio_daronne_get_extra(card, joker)
    return card and card.ability and card.ability.extra or joker.config.extra
end

local function rio_daronne_active_others(card)
    local others = {}
    if not G.jokers or not G.jokers.cards then return others end
    for _, joker in ipairs(G.jokers.cards) do
        if joker ~= card and joker.config and joker.config.center and joker.config.center.key == DARONNE_VEXPI_KEY
            and joker.added_to_deck and not joker.getting_sliced then
            others[#others + 1] = joker
        end
    end
    return others
end

local function rio_daronne_reduce_slots(card)
    if not G.jokers or not G.jokers.config then return end
    if card.getting_sliced or card.destroyed then return end
    local extra = card.ability.extra
    if #rio_daronne_active_others(card) > 0 then return end

    local current_limit = G.jokers.config.card_limit or 1
    local slot_delta = math.max(current_limit - 1, 0)
    extra.slot_delta = (extra.slot_delta or 0) + slot_delta
    G.GAME.xmpl_daronne_vexpi_slot_delta = extra.slot_delta
    G.jokers.config.card_limit = current_limit - slot_delta
end

local function rio_daronne_restore_slots(card)
    if not G.jokers or not G.jokers.config then return end
    local extra = card.ability.extra
    local others = rio_daronne_active_others(card)

    if #others > 0 then
        if extra.slot_delta then
            others[1].ability.extra.slot_delta = extra.slot_delta
            extra.slot_delta = nil
        end
        return
    end

    local slot_delta = extra.slot_delta or G.GAME.xmpl_daronne_vexpi_slot_delta
    if slot_delta then
        G.jokers.config.card_limit = G.jokers.config.card_limit + slot_delta
        extra.slot_delta = nil
        G.GAME.xmpl_daronne_vexpi_slot_delta = nil
    end
end

local function rio_daronne_chomp(card, colour)
    local extra = card.ability.extra
    local count = (extra.eaten_cards or 0) + (extra.eaten_jokers or 0)
    local message = pseudorandom_element(DARONNE_VEXPI_WORDS, pseudoseed('daronne_vexpi_chomp' .. count))
    card_eval_status_text(card, 'extra', nil, nil, nil, {message = message, colour = colour or G.C.FILTER})
    play_sound(DARONNE_VEXPI_SOUND, 0.95 + math.random() * 0.1, 0.8)
end

local function rio_daronne_apply_consumable(card, consumed)
    local extra = card.ability.extra
    local consumed_set = consumed.ability and consumed.ability.set or consumed.config.center.set

    if consumed_set == 'Planet' then
        extra.chips = extra.chips + extra.planet_chips * extra.buff_scale
    elseif consumed_set == 'Tarot' then
        extra.mult = extra.mult + extra.tarot_mult * extra.buff_scale
    elseif consumed_set == 'Spectral' then
        extra.Xmult = extra.Xmult + extra.xmult_gain * extra.buff_scale
    else
        extra.Xchips = extra.Xchips + extra.xchips_gain * extra.buff_scale
    end

    extra.eaten_cards = (extra.eaten_cards or 0) + 1
end

local function rio_daronne_double_buffs(card)
    local extra = card.ability.extra
    extra.buff_scale = extra.buff_scale * 2
    extra.chips = extra.chips * 2
    extra.mult = extra.mult * 2
    extra.Xmult = 1 + (extra.Xmult - 1) * 2
    extra.Xchips = 1 + (extra.Xchips - 1) * 2
    extra.eaten_jokers = (extra.eaten_jokers or 0) + 1
    if G.GAME and G.GAME.modifiers then
        G.GAME.modifiers.money_per_hand = (G.GAME.modifiers.money_per_hand or 1) + (extra.money_per_hand_gain or 5)
    end
end

local function rio_daronne_is_negative_joker(joker)
    return joker and joker.config and joker.config.center and joker.config.center.set == 'Joker'
        and joker.edition and joker.edition.negative and not joker.getting_sliced and not joker.destroyed
end

local function rio_daronne_eat_adjacent_jokers(card)
    if not G.jokers or not G.jokers.cards then return 0 end

    local index
    for i, joker in ipairs(G.jokers.cards) do
        if joker == card then
            index = i
            break
        end
    end
    if not index then return 0 end

    local to_eat = {}
    for i = index - 1, 1, -1 do
        if rio_daronne_is_negative_joker(G.jokers.cards[i]) then
            to_eat[#to_eat + 1] = G.jokers.cards[i]
        else
            break
        end
    end
    for i = index + 1, #G.jokers.cards do
        if rio_daronne_is_negative_joker(G.jokers.cards[i]) then
            to_eat[#to_eat + 1] = G.jokers.cards[i]
        else
            break
        end
    end

    for _, joker in ipairs(to_eat) do
        rio_daronne_double_buffs(card)
        SMODS.destroy_cards(joker, true)
    end

    if #to_eat > 0 then
        rio_daronne_chomp(card, G.C.RED)
    end

    return #to_eat
end

local function rio_daronne_eat_consumables(card)
    if not G.consumeables or not G.consumeables.cards then return 0 end

    local candidates = {}
    for _, consumable in ipairs(G.consumeables.cards) do
        if consumable.ability and consumable.ability.consumeable and not consumable.getting_sliced and not consumable.destroyed then
            candidates[#candidates + 1] = consumable
        end
    end

    local eaten = 0
    local extra = card.ability.extra
    for i = 1, math.min(extra.eat_per_hand, #candidates) do
        local consumed = pseudorandom_element(candidates, pseudoseed('daronne_vexpi_eat' .. (extra.eaten_cards or 0) .. '_' .. i))
        for j, candidate in ipairs(candidates) do
            if candidate == consumed then
                table.remove(candidates, j)
                break
            end
        end

        rio_daronne_apply_consumable(card, consumed)
        SMODS.destroy_cards(consumed, true)
        eaten = eaten + 1
    end

    if eaten > 0 then
        rio_daronne_chomp(card, G.C.FILTER)
    end

    return eaten
end

local function rio_daronne_update_ante(card)
    local extra = card.ability.extra
    local ante = G.GAME and G.GAME.round_resets and G.GAME.round_resets.ante
    if not ante then return end

    if not extra.last_ante then
        extra.last_ante = ante
        return
    end

    if ante > extra.last_ante then
        extra.eat_per_hand = extra.eat_per_hand + (ante - extra.last_ante)
        extra.last_ante = ante
    end
end

----------------------------------------------
------------ JOKER DEFINITIONS ---------------

SMODS.Joker{
    key = 'derek',
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
                message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.Xmult}},
                Xmult_mod = card.ability.extra.Xmult
            }
        end
        if context.setting_blind and not context.blueprint and #G.jokers.cards < G.jokers.config.card_limit then
            local new_card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_joker')
            new_card:add_to_deck()
            G.jokers:emplace(new_card)
            return {
                message = localize('k_xmpl_derek_yay'),
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
                message = localize('k_xmpl_peace_kindness'),
                colour = G.C.RED
            }
        end
    end
}

SMODS.Joker{
    key = 'dolby',
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
                message = localize{type = 'variable', key = 'a_mult', vars = {card.ability.extra.mult}},
                mult_mod = card.ability.extra.mult
            }
        end
        if context.after and not context.blueprint then
            if card.ability.extra.hands_left - 1 <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return {
                    message = localize('k_xmpl_self_destruct'),
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

SMODS.Joker{
    key = 'daronne_vexpi',
    atlas = 'daronne_vexpi_atlas',
    rarity = 4,
    cost = 20,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    pos = {x = 0, y = 0},
    display_size = {w = 300, h = 190},
    config = {
        extra = {
            chips = 0,
            mult = 0,
            Xmult = 1,
            Xchips = 1,
            buff_scale = 1,
            planet_chips = 50,
            tarot_mult = 50,
            xmult_gain = 0.5,
            xchips_gain = 0.1,
            create_on_reroll = 3,
            eat_per_hand = 2,
            eaten_cards = 0,
            eaten_jokers = 0,
            last_ante = nil,
            money_per_hand_gain = 5
        }
    },
    loc_vars = function(self, info_queue, card)
        local extra = rio_daronne_get_extra(card, self)
        local scale = extra.buff_scale or 1
        local money_gain = extra.money_per_hand_gain or 5
        return {vars = {
            extra.create_on_reroll,
            extra.eat_per_hand,
            extra.planet_chips * scale,
            extra.tarot_mult * scale,
            rio_format_num(1 + extra.xmult_gain * scale),
            rio_format_num(1 + extra.xchips_gain * scale),
            rio_format_num(scale),
            extra.chips,
            extra.mult,
            rio_format_num(extra.Xmult),
            rio_format_num(extra.Xchips),
            extra.eaten_jokers or 0,
            money_gain,
            (extra.eaten_jokers or 0) * money_gain
        }}
    end,
    add_to_deck = function(self, card, from_debuff)
        rio_daronne_reduce_slots(card)
    end,
    remove_from_deck = function(self, card, from_debuff)
        rio_daronne_restore_slots(card)
    end,
    calculate = function(self, card, context)
        rio_daronne_reduce_slots(card)
        rio_daronne_update_ante(card)

        if not context.blueprint then
            if context.card_added or context.after or context.setting_blind then
                rio_daronne_eat_adjacent_jokers(card)
            end

            if context.reroll_shop then
                local reroll_count = G.GAME.round_scores and G.GAME.round_scores.times_rerolled and G.GAME.round_scores.times_rerolled.amt or 0
                for i = 1, card.ability.extra.create_on_reroll do
                    local new_card = SMODS.add_card({
                        set = 'Consumeables',
                        area = G.consumeables,
                        edition = 'e_negative',
                        key_append = 'daronne_vexpi' .. reroll_count .. '_' .. i,
                        soulable = false
                    })
                    if new_card then new_card:juice_up(0.3, 0.4) end
                end
                return {
                    message = localize('k_xmpl_daronne_reroll'),
                    colour = G.C.PURPLE
                }
            end

            if context.after then
                local eaten = rio_daronne_eat_consumables(card)
                if eaten > 0 then
                    return {
                        message = localize('k_xmpl_daronne_ate'),
                        colour = G.C.FILTER
                    }
                end
            end
        end

        if context.joker_main then
            local extra = card.ability.extra
            local ret = {card = card}
            local has_effect = false

            if extra.chips > 0 then
                ret.chips = extra.chips
                has_effect = true
            end
            if extra.mult > 0 then
                ret.mult = extra.mult
                has_effect = true
            end
            if extra.Xchips > 1 then
                ret.xchips = extra.Xchips
                has_effect = true
            end
            if extra.Xmult > 1 then
                ret.xmult = extra.Xmult
                has_effect = true
            end

            if has_effect then return ret end
        end
    end
}

local function count_consumables()
    if not G.consumeables or not G.consumeables.cards then return 0 end
    local count = 0
    for _, c in ipairs(G.consumeables.cards) do
        if c.ability and c.ability.consumeable and not c.getting_sliced and not c.destroyed then
            count = count + 1
        end
    end
    return count
end

local function has_daronne_vexpi()
    if not G.jokers or not G.jokers.cards then return false end
    for _, j in ipairs(G.jokers.cards) do
        if j.config and j.config.center and j.config.center.key == DARONNE_VEXPI_KEY and not j.getting_sliced and not j.destroyed then
            return true
        end
    end
    return false
end

local original_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    local card = original_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if card and _type == 'Joker' and area == G.shop_jokers then
        if count_consumables() >= 10 and has_daronne_vexpi() then
            card:set_edition({negative = true}, true, true)
        end
    end
    return card
end
