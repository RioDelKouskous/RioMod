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

local DARONNE_VEXPI_SOUND_KEYS = {
    'breakfart',
    'cartooneating',
    'maneatingchips',
    'nomnomnom',
    'rawmeat',
    'robloxchezburger',
}

for _, key in ipairs(DARONNE_VEXPI_SOUND_KEYS) do
    SMODS.Sound{
        key = key,
        path = key .. '.ogg'
    }
end

local DARONNE_VEXPI_SOUNDS = {}
for _, key in ipairs(DARONNE_VEXPI_SOUND_KEYS) do
    DARONNE_VEXPI_SOUNDS[#DARONNE_VEXPI_SOUNDS + 1] = 'xmpl_' .. key
end

local DARONNE_VEXPI_KEY = 'j_xmpl_daronne_vexpi'
local HEAVIEST_DECK_KEY = 'b_xmpl_heaviest_deck'
local CRYPTID_ABSOLUTE_STICKER = 'cry_absolute'
local DARONNE_VEXPI_WORDS = {
    'Yummy!',
    'Delicious!',
    'Tasty!',
    'Scrumptious!',
    'Nom nom!',
    'Chef kiss!',
    'Snack time!',
    'Miam!',
    'CHEESEBURGER!',
    'THE UNIVERSE IS MINE!',
    'Om nom nom!',
    'MORE MORE MORE MORE MORE MORE MORE !',
    'CHICKEN!'
}

local DARONNE_VEXPI_FEAST_LINES = {
    'k_xmpl_daronne_feast_line_1',
    'k_xmpl_daronne_feast_line_2',
    'k_xmpl_daronne_feast_line_3',
    'k_xmpl_daronne_feast_line_4',
}

local DARONNE_VEXPI_STAT_CAP = 1e300

local rio_daronne_apply_shop_negative
local rio_daronne_queue_grand_feast
local rio_daronne_cleanup_grand_feast

local function rio_daronne_set_absolute(card, value)
    if not card then return end
    card.ability = card.ability or {}
    if SMODS and SMODS.Stickers and SMODS.Stickers[CRYPTID_ABSOLUTE_STICKER] then
        local sticker = SMODS.Stickers[CRYPTID_ABSOLUTE_STICKER]
        if sticker.set_sticker then
            sticker:set_sticker(card, value and true or false)
            return
        elseif sticker.apply then
            sticker:apply(card, value and true or false)
            return
        end
    end
    card.ability[CRYPTID_ABSOLUTE_STICKER] = value and true or nil
end

local function rio_daronne_clear_feast_world()
    if not G.GAME then return end
    G.GAME.xmpl_daronne_music_active = nil
    G.GAME.xmpl_daronne_bg_lock = nil
    SMODS.previous_track = nil
    if ease_background_colour_blind then
        pcall(ease_background_colour_blind, G.GAME.blind)
    end
end

-- #region agent log
local RIO_DEBUG_LOG_PATH = 'C:/Users/Suiveurtag/AppData/Roaming/Balatro/Mods/RioMod/debug-dfab94.log'
local function rio_debug_log(hypothesisId, location, message, data)
    pcall(function()
        local f = io.open(RIO_DEBUG_LOG_PATH, 'a')
        if not f then return end
        local ts = os.time() or 0
        local parts = {
            '"sessionId":"dfab94"',
            '"hypothesisId":"' .. tostring(hypothesisId) .. '"',
            '"location":"' .. tostring(location):gsub('"', '\\"') .. '"',
            '"message":"' .. tostring(message):gsub('"', '\\"') .. '"',
            '"timestamp":' .. tostring(ts * 1000),
        }
        if data then
            local dp = {}
            for k, v in pairs(data) do
                local val
                if type(v) == 'string' then
                    val = '"' .. v:gsub('"', '\\"') .. '"'
                elseif type(v) == 'boolean' then
                    val = v and 'true' or 'false'
                else
                    val = tostring(v)
                end
                dp[#dp + 1] = '"' .. tostring(k) .. '":' .. val
            end
            parts[#parts + 1] = '"data":{' .. table.concat(dp, ',') .. '}'
        end
        f:write('{' .. table.concat(parts, ',') .. '}\n')
        f:close()
    end)
end
-- #endregion

local function rio_format_num(value)
    if type(value) == 'table' then
        if number_format then return number_format(value) end
        return tostring(value)
    end
    if type(value) ~= 'number' then return value end
    if value ~= value then return '0' end
    if value == math.huge or value >= DARONNE_VEXPI_STAT_CAP then value = DARONNE_VEXPI_STAT_CAP end
    if math.abs(value) >= 1000000 then return string.format('%.2e', value) end
    local formatted = string.format('%.2f', value)
    formatted = formatted:gsub('0+$', ''):gsub('%.$', '')
    return formatted
end

local function rio_daronne_talisman_active()
    return type(to_big) == 'function'
end

local function rio_daronne_stat_cap()
    return rio_daronne_talisman_active() and to_big(DARONNE_VEXPI_STAT_CAP) or DARONNE_VEXPI_STAT_CAP
end

local function rio_daronne_cap_stat(value)
    if type(value) == 'table' and rio_daronne_talisman_active() then
        local cap = rio_daronne_stat_cap()
        local negative_cap = to_big(-DARONNE_VEXPI_STAT_CAP)
        if value > cap then return cap end
        if value < negative_cap then return negative_cap end
        return value
    end
    if type(value) ~= 'number' then return value end
    if value ~= value then return 0 end
    if rio_daronne_talisman_active() then
        return rio_daronne_cap_stat(to_big(value))
    end
    local cap = rio_daronne_stat_cap()
    if value == math.huge or value > cap then return cap end
    if value == -math.huge or value < -cap then return -cap end
    return value
end

local function rio_daronne_cap_buffs(extra)
    extra.chips = rio_daronne_cap_stat(extra.chips)
    extra.mult = rio_daronne_cap_stat(extra.mult)
    extra.Xmult = rio_daronne_cap_stat(extra.Xmult)
    extra.Xchips = rio_daronne_cap_stat(extra.Xchips)
    extra.planet_chips = rio_daronne_cap_stat(extra.planet_chips)
    extra.tarot_mult = rio_daronne_cap_stat(extra.tarot_mult)
    extra.xmult_gain = rio_daronne_cap_stat(extra.xmult_gain)
    extra.xchips_gain = rio_daronne_cap_stat(extra.xchips_gain)
    extra.buff_scale = rio_daronne_cap_stat(extra.buff_scale)
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

    local old_delta = extra.slot_delta or 0
    local base_limit = extra.base_card_limit
    if not base_limit then
        base_limit = G.jokers.config.card_limit + old_delta
        extra.base_card_limit = base_limit
    end

    local neg_bonus = 0
    for _, j in ipairs(G.jokers.cards) do
        if j ~= card and j.edition and j.edition.negative
            and j.added_to_deck and not j.getting_sliced and not j.destroyed then
            neg_bonus = neg_bonus + 1
        end
    end

    local target = 1 + neg_bonus
    local new_delta = math.max(base_limit - target, 0)
    extra.slot_delta = new_delta
    G.GAME.xmpl_daronne_vexpi_slot_delta = new_delta
    G.jokers.config.card_limit = base_limit - new_delta
end

local function rio_daronne_restore_slots(card)
    if not G.jokers or not G.jokers.config then return end
    local extra = card.ability.extra
    local others = rio_daronne_active_others(card)

    if #others > 0 then
        if extra.slot_delta then
            others[1].ability.extra.slot_delta = extra.slot_delta
            others[1].ability.extra.base_card_limit = extra.base_card_limit
            extra.slot_delta = nil
            extra.base_card_limit = nil
        end
        return
    end

    local slot_delta = extra.slot_delta or G.GAME.xmpl_daronne_vexpi_slot_delta
    if slot_delta then
        G.jokers.config.card_limit = G.jokers.config.card_limit + slot_delta
        extra.slot_delta = nil
        extra.base_card_limit = nil
        G.GAME.xmpl_daronne_vexpi_slot_delta = nil
    end
end

local function rio_daronne_chomp(card, colour)
    local extra = card.ability.extra
    local count = (extra.eaten_cards or 0) + (extra.eaten_jokers or 0)
    local message = pseudorandom_element(DARONNE_VEXPI_WORDS, pseudoseed('daronne_vexpi_chomp' .. count))
    card_eval_status_text(card, 'extra', nil, nil, nil, {message = message, colour = colour or G.C.FILTER})
    local sound = pseudorandom_element(DARONNE_VEXPI_SOUNDS, pseudoseed('daronne_vexpi_sound' .. count))
    play_sound(sound, 0.95 + math.random() * 0.1, 0.8)
end

local function rio_daronne_apply_consumable(card, consumed)
    local extra = card.ability.extra
    local consumed_set = consumed.ability and consumed.ability.set or consumed.config.center.set

    if consumed_set == 'Planet' then
        extra.chips = rio_daronne_cap_stat(extra.chips + extra.planet_chips * extra.buff_scale)
    elseif consumed_set == 'Tarot' then
        extra.mult = rio_daronne_cap_stat(extra.mult + extra.tarot_mult * extra.buff_scale)
    elseif consumed_set == 'Spectral' then
        extra.Xmult = rio_daronne_cap_stat(extra.Xmult + extra.xmult_gain * extra.buff_scale)
    else
        extra.Xchips = rio_daronne_cap_stat(extra.Xchips + extra.xchips_gain * extra.buff_scale)
    end

    extra.eaten_cards = (extra.eaten_cards or 0) + 1
end

local function rio_daronne_card_alive(card)
    return card and not card.REMOVED and not card.destroyed and not card.getting_sliced
        and card.ability and card.ability.extra
end

local function rio_daronne_is_consumable(card)
    return card and card.ability and card.ability.consumeable
        and not card.getting_sliced and not card.destroyed and not card.REMOVED
end

local function rio_daronne_joker_money_gain(joker)
    local rarity = joker and joker.config and joker.config.center and joker.config.center.rarity
    if rarity == 1 or rarity == 'Common' or rarity == 'common' then return 4 end
    if rarity == 2 or rarity == 'Uncommon' or rarity == 'uncommon' then return 6 end
    if rarity == 3 or rarity == 'Rare' or rarity == 'rare' then return 8 end
    return 10
end

local function rio_daronne_double_buffs(card, eaten_joker)
    local extra = card.ability.extra
    extra.buff_scale = rio_daronne_cap_stat(extra.buff_scale * 2)
    extra.chips = rio_daronne_cap_stat(extra.chips * 2)
    extra.mult = rio_daronne_cap_stat(extra.mult * 2)
    extra.Xmult = rio_daronne_cap_stat(1 + (extra.Xmult - 1) * 2)
    extra.Xchips = rio_daronne_cap_stat(1 + (extra.Xchips - 1) * 2)
    extra.eaten_jokers = (extra.eaten_jokers or 0) + 1
    extra.dollar_bonus = (extra.dollar_bonus or 0) + rio_daronne_joker_money_gain(eaten_joker)
end

local function rio_daronne_dollar_bonus(extra)
    return extra.dollar_bonus or 0
end

local function rio_daronne_has_eternal_sticker(joker)
    return joker and joker.ability and joker.ability.eternal
end

local function rio_daronne_is_negative_joker(joker)
    return joker and joker.config and joker.config.center and joker.config.center.set == 'Joker'
        and joker.edition and joker.edition.negative and not joker.getting_sliced and not joker.destroyed
end

local function rio_daronne_is_legendary_joker(joker)
    if not (joker and joker.config and joker.config.center and joker.config.center.set == 'Joker') then return false end
    local rarity = joker.config.center.rarity
    return rarity == 4 or rarity == 'Legendary' or rarity == 'legendary'
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

    local ate_legendary = false
    for _, joker in ipairs(to_eat) do
        if rio_daronne_is_legendary_joker(joker) then ate_legendary = true end
        if rio_daronne_has_eternal_sticker(joker) then
            ease_dollars(30)
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_xmpl_daronne_eternal'), colour = G.C.MONEY})
        end
        rio_daronne_double_buffs(card, joker)
        SMODS.destroy_cards(joker, true)
    end

    if #to_eat > 0 then
        rio_daronne_chomp(card, G.C.RED)
    end

    if ate_legendary and rio_daronne_card_alive(card) and G.GAME and not G.GAME.xmpl_daronne_feast_lock then
        rio_daronne_queue_grand_feast(card)
    end

    return #to_eat
end

local function rio_daronne_queue_eat_adjacent_jokers(card)
    if not rio_daronne_card_alive(card) then return end
    if not G.E_MANAGER then
        rio_daronne_eat_adjacent_jokers(card)
        return
    end

    local extra = card.ability.extra
    if extra.adjacent_eat_queued then return end
    extra.adjacent_eat_queued = true

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.05,
        func = function()
            extra.adjacent_eat_queued = nil
            if rio_daronne_card_alive(card) then
                rio_daronne_eat_adjacent_jokers(card)
            end
            return true
        end
    }))
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

local function count_consumables()
    if not G.consumeables or not G.consumeables.cards then return 0 end
    local count = 0
    for _, c in ipairs(G.consumeables.cards) do
        if rio_daronne_is_consumable(c) then
            count = count + 1
        end
    end
    return count
end

local function rio_daronne_safe_pow(v, p)
    if not v or v <= 0 then return v end
    return rio_daronne_cap_stat(v ^ p)
end

local function rio_daronne_self_destruct(card)
    if not rio_daronne_card_alive(card) then return end
    rio_daronne_set_absolute(card, false)
    rio_daronne_cleanup_grand_feast(true)
    card.getting_sliced = true
    card:juice_up(0.8, 0.8)
    local function destroy()
        SMODS.destroy_cards(card, true)
        return true
    end
    if G.E_MANAGER then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.25,
            func = destroy
        }))
    else
        destroy()
    end
end

local function rio_daronne_check_hunger(card, eaten)
    if not rio_daronne_card_alive(card) then return end
    local extra = card.ability.extra
    if eaten >= (extra.eat_per_hand or 0) then
        extra.hungry_rounds = 0
        return
    end

    extra.hungry_rounds = (extra.hungry_rounds or 0) + 1
    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_xmpl_daronne_more'), colour = G.C.RED})
    if extra.hungry_rounds >= 3 then
        rio_daronne_self_destruct(card)
    end
end

local function rio_daronne_reset_slots_to_one(card)
    if not G.GAME or not G.jokers or not G.jokers.config or not rio_daronne_card_alive(card) then return end
    if #rio_daronne_active_others(card) > 0 then return end

    local extra = card.ability.extra
    local old_delta = extra.slot_delta or G.GAME.xmpl_daronne_vexpi_slot_delta or 0
    local base_limit = extra.base_card_limit or (G.jokers.config.card_limit + old_delta)
    local new_delta = math.max(base_limit - 1, 0)

    extra.base_card_limit = base_limit
    extra.slot_delta = new_delta
    G.GAME.xmpl_daronne_vexpi_slot_delta = new_delta
    G.jokers.config.card_limit = 1
end

local function rio_daronne_to_number(value)
    if type(value) == 'number' then return value end

    if type(to_number) == 'function' then
        local ok, converted = pcall(to_number, value)
        if ok and type(converted) == 'number' then return converted end
    end

    if type(value) == 'table' and type(value.to_number) == 'function' then
        local ok, converted = pcall(value.to_number, value)
        if ok and type(converted) == 'number' then return converted end
    end

    local text = tostring(value or '')
    if text == '' then return nil end
    text = text:gsub(',', ''):gsub('%$', ''):gsub('%s+', '')
    return tonumber(text)
end

local function rio_daronne_purchase_cost(bought)
    if not bought then return 0 end
    local cost = bought.cost
    if type(cost) == 'function' then
        local ok, resolved_cost = pcall(cost, bought)
        cost = ok and resolved_cost or nil
    end
    if type(cost) ~= 'number' and bought.base_cost then
        cost = bought.base_cost
    end
    if type(cost) ~= 'number' and bought.config and bought.config.center then
        cost = bought.config.center.cost
    end
    return rio_daronne_to_number(cost) or 0
end

local function rio_daronne_back_key(back)
    if not back then return nil end
    if back.effect and back.effect.center and back.effect.center.key then return back.effect.center.key end
    if back.center and back.center.key then return back.center.key end
    if back.key then return back.key end
    if back.name then return back.name end
end

local function rio_daronne_is_heaviest_deck_run()
    if not G.GAME then return false end

    local selected_key = rio_daronne_back_key(G.GAME.selected_back)
    local viewed_key = rio_daronne_back_key(G.GAME.viewed_back)
    return selected_key == HEAVIEST_DECK_KEY or viewed_key == HEAVIEST_DECK_KEY
        or selected_key == 'heaviest_deck' or viewed_key == 'heaviest_deck'
        or selected_key == 'Heaviest Deck' or viewed_key == 'Heaviest Deck'
        or selected_key == 'Paquet le plus lourd' or viewed_key == 'Paquet le plus lourd'
end

local function rio_daronne_feast_conditions(bought)
    -- #region agent log
    rio_debug_log('C', 'jokers.lua:feast_conditions', 'feast_conditions_enter', {
        cost_type = bought and type(bought.cost) or 'nil',
        runId = 'post-fix-3',
    })
    -- #endregion
    local current_round = G.GAME and G.GAME.current_round
    local has_round = type(current_round) == 'table'
    local reroll_cost = has_round and (current_round.reroll_cost or 0) or -1
    local consumables = count_consumables()
    local raw_cash = G.GAME and G.GAME.dollars
    local cash = rio_daronne_to_number(raw_cash) or 0
    local purchase_cost = rio_daronne_purchase_cost(bought)
    local dollars = cash + purchase_cost
    local heaviest_deck = rio_daronne_is_heaviest_deck_run()
    local ok = has_round and heaviest_deck and reroll_cost >= 30 and consumables >= 100 and dollars >= 100
    -- #region agent log
    rio_debug_log('C', 'jokers.lua:feast_conditions', 'feast_conditions_eval', {
        has_round = has_round and true or false,
        heaviest_deck = heaviest_deck,
        reroll_cost = reroll_cost,
        consumables = consumables,
        dollars = dollars,
        cash = cash,
        cash_type = type(raw_cash),
        cash_raw = tostring(raw_cash),
        purchase_cost = purchase_cost,
        ok = ok,
        runId = 'post-fix-3',
    })
    -- #endregion
    if not has_round then return false end
    if not heaviest_deck then return false end
    if reroll_cost < 30 then return false end
    if consumables < 100 then return false end
    if dollars < 100 then return false end
    return true
end

local function rio_daronne_consumable_candidates()
    local candidates = {}
    if not G.consumeables or not G.consumeables.cards then return candidates end

    for _, consumable in ipairs(G.consumeables.cards) do
        if rio_daronne_is_consumable(consumable) then
            candidates[#candidates + 1] = consumable
        end
    end
    return candidates
end

local function rio_daronne_eat_one_consumable(card, consumed, index)
    if not rio_daronne_card_alive(card) or not rio_daronne_is_consumable(consumed) then return false end

    rio_daronne_apply_consumable(card, consumed)
    consumed:juice_up(0.6, 0.7)
    SMODS.destroy_cards(consumed, true)

    if index == 1 or index % 12 == 0 then
        rio_daronne_chomp(card, G.C.GOLD)
    elseif index % 4 == 0 then
        local sound = pseudorandom_element(DARONNE_VEXPI_SOUNDS, pseudoseed('daronne_vexpi_feast_sound' .. index))
        play_sound(sound, 0.9 + math.random() * 0.2, 0.55)
    end

    return true
end

local function rio_daronne_pow_buffs(card, power)
    local extra = card.ability.extra
    extra.chips = rio_daronne_safe_pow(extra.chips, power)
    extra.mult = rio_daronne_safe_pow(extra.mult, power)
    extra.Xmult = rio_daronne_safe_pow(extra.Xmult, power)
    extra.Xchips = rio_daronne_safe_pow(extra.Xchips, power)
    extra.planet_chips = rio_daronne_safe_pow(extra.planet_chips, power)
    extra.tarot_mult = rio_daronne_safe_pow(extra.tarot_mult, power)
    extra.xmult_gain = rio_daronne_safe_pow(extra.xmult_gain, power)
    extra.xchips_gain = rio_daronne_safe_pow(extra.xchips_gain, power)
    extra.buff_scale = rio_daronne_safe_pow(extra.buff_scale, power)
end

local function rio_daronne_begin_grand_feast(card)
    if not rio_daronne_card_alive(card) then return end

    card.ability.extra.feast_world_active = true
    rio_daronne_set_absolute(card, true)
    rio_daronne_pow_buffs(card, 2)
    card:juice_up(1.2, 1.2)
    if G.ROOM then G.ROOM.jiggle = (G.ROOM.jiggle or 0) + 6 end
    play_sound('timpani', 0.85, 0.8)
end

local function rio_daronne_finish_grand_feast(card)
    if not rio_daronne_card_alive(card) then return end

    local extra = card.ability.extra
    extra.eaten_jokers = 0
    extra.dollar_bonus = 20
    extra.create_on_reroll = (extra.create_on_reroll or 0) + 3

    local cash = rio_daronne_to_number(G.GAME and G.GAME.dollars) or 0
    if cash > 0 then
        ease_dollars(-cash, true)
    end

    ease_ante(3)

    card:set_edition({polychrome = true}, true, true)
    rio_daronne_set_absolute(card, true)
    card:juice_up(1, 1)
    play_sound('xmpl_nomnomnom', 1.0, 2.4)
    card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_xmpl_daronne_feast'), colour = G.C.GOLD})
end

local function rio_daronne_close_shop_for_intro()
    if not G then return end

    local function lower(obj, delta)
        if obj and obj.alignment and obj.alignment.offset then
            if obj.alignment.offset.xmpl_daronne_original_y == nil then
                obj.alignment.offset.xmpl_daronne_original_y = obj.alignment.offset.y or 0
            end
            obj.alignment.offset.y = obj.alignment.offset.xmpl_daronne_original_y + delta
        end
    end

    lower(G.shop, 8)
    lower(G.SHOP_SIGN, 4)
end

local function rio_daronne_reopen_shop_after_intro()
    local function restore(obj)
        if obj and obj.alignment and obj.alignment.offset
            and obj.alignment.offset.xmpl_daronne_original_y ~= nil then
            obj.alignment.offset.y = obj.alignment.offset.xmpl_daronne_original_y
            obj.alignment.offset.xmpl_daronne_original_y = nil
        end
    end

    restore(G.shop)
    restore(G.SHOP_SIGN)
end

local function rio_daronne_lock_controls()
    if not (G.GAME and G.CONTROLLER and G.CONTROLLER.locks) then return end

    G.GAME.xmpl_daronne_saved_locks = {
        use = G.CONTROLLER.locks.use,
        shop_reroll = G.CONTROLLER.locks.shop_reroll,
        locked = G.CONTROLLER.locked,
    }
    G.CONTROLLER.locked = true
    G.CONTROLLER.locks.use = true
    G.CONTROLLER.locks.shop_reroll = true
end

local function rio_daronne_unlock_controls()
    if not (G.CONTROLLER and G.CONTROLLER.locks) then return end

    local saved = G.GAME and G.GAME.xmpl_daronne_saved_locks or {}
    G.CONTROLLER.locked = false
    G.CONTROLLER.locks.use = saved.use or false
    G.CONTROLLER.locks.shop_reroll = saved.shop_reroll or false
    for key, value in pairs(G.CONTROLLER.locks) do
        if type(value) == 'boolean' then
            G.CONTROLLER.locks[key] = false
        end
    end
    G.CONTROLLER.interrupt = G.CONTROLLER.interrupt or {}
    G.CONTROLLER.interrupt.focus = false
    if G.GAME then G.GAME.xmpl_daronne_saved_locks = nil end
end

rio_daronne_cleanup_grand_feast = function(clear_world)
    rio_debug_log('F', 'jokers.lua:queue_grand_feast', 'feast_cleanup', {
        runId = 'post-fix-3',
    })
    rio_daronne_reopen_shop_after_intro()
    rio_daronne_unlock_controls()
    if clear_world then
        rio_daronne_clear_feast_world()
    end
    if G.GAME then G.GAME.xmpl_daronne_feast_lock = nil end
    if G.E_MANAGER then
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            timer = 'REAL',
            func = function()
                rio_daronne_unlock_controls()
                return true
            end
        }))
    end
end

local function rio_daronne_start_feast_world()
    if not G.GAME then return end

    G.GAME.xmpl_daronne_music_active = true
    G.GAME.xmpl_daronne_bg_lock = true

    if XMP_DARONNE_APPLY_FEAST_BACKGROUND then
        XMP_DARONNE_APPLY_FEAST_BACKGROUND()
    end
    if G.SOUND_MANAGER and G.SOUND_MANAGER.channel then
        G.SOUND_MANAGER.channel:push({type = 'stop'})
    end
    SMODS.previous_track = nil
end

local function rio_daronne_show_feast_line(card, line_key, index)
    local colours = {G.C.GOLD, G.C.RED, G.C.PURPLE, G.C.WHITE}
    local colour = colours[index] or G.C.GOLD

    play_sound(index == 4 and 'gong' or 'tarot1', 0.8 + index * 0.12, index == 4 and 0.6 or 0.4)
    if G.ROOM then G.ROOM.jiggle = (G.ROOM.jiggle or 0) + (index == 4 and 8 or 3) end
    if card and card.juice_up then card:juice_up(0.8, 0.8) end
    attention_text({
        scale = index == 1 and 0.9 or 0.82,
        text = localize(line_key),
        hold = index == 4 and 3.0 or 2.4,
        align = 'cm',
        offset = {x = 0, y = -1.3},
        major = G.ROOM_ATTACH,
        colour = colour,
        backdrop_colour = colour,
        backdrop_scale = index == 4 and 1.8 or 1.25,
        noisy = true,
    })
end

local function rio_daronne_queue_paced_eating(card, candidates, on_complete)
    candidates = candidates or rio_daronne_consumable_candidates()
    local index = 1
    local batch_size = 4
    local completed = false

    local function finish_eating()
        if completed then return true end
        completed = true
        if on_complete then on_complete() end
        return true
    end

    local function eat_next_batch()
        if index > #candidates or not rio_daronne_card_alive(card) then
            return finish_eating()
        end

        local eaten = 0
        while index <= #candidates and eaten < batch_size do
            local consumed = candidates[index]
            if consumed and rio_daronne_is_consumable(consumed) then
                rio_daronne_eat_one_consumable(card, consumed, index)
            end
            index = index + 1
            eaten = eaten + 1
        end
        if index <= #candidates and rio_daronne_card_alive(card) then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.04,
                func = function()
                    eat_next_batch()
                    return true
                end
            }))
        else
            finish_eating()
        end
        return true
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.08,
        func = eat_next_batch
    }))
end

rio_daronne_queue_grand_feast = function(card)
    -- #region agent log
    rio_debug_log('F', 'jokers.lua:queue_grand_feast', 'queue_grand_feast_called', {
        has_game = G.GAME and true or false,
        feast_lock = G.GAME and G.GAME.xmpl_daronne_feast_lock and true or false,
    })
    -- #endregion
    if not G.GAME or G.GAME.xmpl_daronne_feast_lock then return end

    G.GAME.xmpl_daronne_feast_lock = true
    local play_intro = true
    local candidates = rio_daronne_consumable_candidates()
    local dialogue_delays = {0.8, 2.3, 3.8, 5.3}
    local intro_delay = 7.2

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.05,
        timer = 'REAL',
        func = function()
            rio_debug_log('F', 'jokers.lua:queue_grand_feast', 'intro_start', {
                runId = 'post-fix-3',
                candidates = #candidates,
            })
            rio_daronne_start_feast_world()
            rio_daronne_lock_controls()
            rio_daronne_close_shop_for_intro()
            rio_daronne_begin_grand_feast(card)
            return true
        end
    }))

    if play_intro then
        for i, line_key in ipairs(DARONNE_VEXPI_FEAST_LINES) do
            local line_index = i
            local event_line_key = line_key
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = dialogue_delays[i] or (0.8 + (i - 1) * 1.5),
                timer = 'REAL',
                func = function()
                    rio_debug_log('F', 'jokers.lua:queue_grand_feast', 'dialogue_line', {
                        runId = 'post-fix-3',
                        line = line_index,
                    })
                    rio_daronne_show_feast_line(card, event_line_key, line_index)
                    return true
                end
            }))
        end
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = intro_delay,
        timer = 'REAL',
        func = function()
            rio_debug_log('F', 'jokers.lua:queue_grand_feast', 'intro_done', {
                runId = 'post-fix-3',
            })
            rio_daronne_reopen_shop_after_intro()
            if rio_daronne_card_alive(card) then
                card:juice_up(1.2, 1.2)
                if G.ROOM then G.ROOM.jiggle = (G.ROOM.jiggle or 0) + 6 end
                play_sound('timpani', 0.85, 0.8)
            end
            return true
        end
    }))

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = intro_delay + 0.25,
        timer = 'REAL',
        func = function()
            rio_debug_log('F', 'jokers.lua:queue_grand_feast', 'eating_start', {
                runId = 'post-fix-3',
                candidates = #candidates,
            })
            rio_daronne_queue_paced_eating(card, candidates, function()
                rio_daronne_finish_grand_feast(card)
                rio_daronne_cleanup_grand_feast()
            end)
            return true
        end
    }))
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
    discovered = false,
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
            money_per_hand_gain = 3,
            dollar_bonus = nil
        }
    },
    in_pool = function(self, args)
        if rio_daronne_is_heaviest_deck_run() then return true end
        return not self.discovered
    end,
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = {key = 'xmpl_daronne_grand_feast', set = 'Other'}
        local extra = rio_daronne_get_extra(card, self)
        rio_daronne_cap_buffs(extra)
        local scale = extra.buff_scale or 1
        local money_gain = extra.money_per_hand_gain or 5
        return {vars = {
            extra.create_on_reroll,
            extra.eat_per_hand,
            rio_format_num(rio_daronne_cap_stat(extra.planet_chips * scale)),
            rio_format_num(rio_daronne_cap_stat(extra.tarot_mult * scale)),
            rio_format_num(rio_daronne_cap_stat(1 + extra.xmult_gain * scale)),
            rio_format_num(rio_daronne_cap_stat(1 + extra.xchips_gain * scale)),
            rio_format_num(scale),
            rio_format_num(extra.chips),
            rio_format_num(extra.mult),
            rio_format_num(extra.Xmult),
            rio_format_num(extra.Xchips),
            extra.eaten_jokers or 0,
            money_gain,
            rio_daronne_dollar_bonus(extra)
        }}
    end,
    calc_dollar_bonus = function(self, card)
        local bonus = rio_daronne_dollar_bonus(card.ability.extra)
        if bonus > 0 then return bonus end
    end,
    add_to_deck = function(self, card, from_debuff)
        rio_daronne_reduce_slots(card)
        if rio_daronne_is_heaviest_deck_run() then
            rio_daronne_set_absolute(card, true)
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if card and card.ability and card.ability.extra and card.ability.extra.feast_world_active then
            rio_daronne_clear_feast_world()
            card.ability.extra.feast_world_active = nil
        end
        rio_daronne_restore_slots(card)
    end,
    calculate = function(self, card, context)
        rio_daronne_cap_buffs(card.ability.extra)
        if not context.buying_card then
            rio_daronne_reduce_slots(card)
            rio_daronne_update_ante(card)
            if rio_daronne_apply_shop_negative then rio_daronne_apply_shop_negative() end
        end

        if context.buying_card then
            -- #region agent log
            rio_debug_log('E', 'jokers.lua:calculate', 'buying_card_pre_blueprint', {
                blueprint = context.blueprint and true or false,
                buying_self = context.buying_self and true or false,
            })
            -- #endregion
        end

        if not context.blueprint then
            if context.card_added or context.setting_blind then
                rio_daronne_queue_eat_adjacent_jokers(card)
            elseif context.after then
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
                rio_daronne_check_hunger(card, eaten)
                if eaten > 0 then
                    return {
                        message = localize('k_xmpl_daronne_ate'),
                        colour = G.C.FILTER
                    }
                end
            end

            if context.end_of_round and not context.repetition then
                rio_daronne_reset_slots_to_one(card)
            end

            if context.buying_card then
                local bought = context.card
                local bought_set = bought and bought.config and bought.config.center and bought.config.center.set or 'nil'
                -- #region agent log
                rio_debug_log('A', 'jokers.lua:calculate', 'buying_card_context', {
                    buying_self = context.buying_self and true or false,
                    blueprint = context.blueprint and true or false,
                    bought_set = bought_set,
                    feast_lock = G.GAME and G.GAME.xmpl_daronne_feast_lock and true or false,
                })
                -- #endregion
            end

            if context.buying_card and not context.buying_self then
                local bought = context.card
                local bought_set = bought and bought.config and bought.config.center and bought.config.center.set or 'nil'
                local is_voucher = bought_set == 'Voucher'
                local feast_ok = is_voucher and rio_daronne_feast_conditions(bought)
                -- #region agent log
                rio_debug_log('B', 'jokers.lua:calculate', 'voucher_buy_branch', {
                    is_voucher = is_voucher,
                    feast_ok = feast_ok,
                    bought_set = bought_set,
                })
                -- #endregion
                if bought and bought.config and bought.config.center
                    and bought.config.center.set == 'Voucher'
                    and feast_ok then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.05,
                        func = function()
                            -- #region agent log
                            rio_debug_log('F', 'jokers.lua:calculate', 'deferred_grand_feast', {
                                feast_lock = G.GAME and G.GAME.xmpl_daronne_feast_lock and true or false,
                                runId = 'post-fix-3',
                            })
                            -- #endregion
                            if rio_daronne_card_alive(card) and G.GAME and not G.GAME.xmpl_daronne_feast_lock then
                                rio_daronne_queue_grand_feast(card)
                            end
                            return true
                        end
                    }))
                    return {
                        message = localize('k_xmpl_daronne_feast'),
                        colour = G.C.GOLD
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

local function has_daronne_vexpi()
    if not G.jokers or not G.jokers.cards then return false end
    for _, j in ipairs(G.jokers.cards) do
        if j.config and j.config.center and j.config.center.key == DARONNE_VEXPI_KEY and not j.getting_sliced and not j.destroyed then
            return true
        end
    end
    return false
end

local function rio_daronne_real_joker_limit()
    if not G.jokers or not G.jokers.config or not G.jokers.cards then return nil end
    local saved_delta = G.GAME and G.GAME.xmpl_daronne_vexpi_slot_delta or 0
    for _, j in ipairs(G.jokers.cards) do
        if j.config and j.config.center and j.config.center.key == DARONNE_VEXPI_KEY and not j.getting_sliced and not j.destroyed then
            local extra = j.ability and j.ability.extra or {}
            return extra.base_card_limit or (G.jokers.config.card_limit + (extra.slot_delta or saved_delta or 0))
        end
    end
    return nil
end

if G and G.P_CENTERS and G.P_CENTERS.c_soul and not G.P_CENTERS.c_soul.xmpl_daronne_can_use_patched then
    local original_soul_can_use = G.P_CENTERS.c_soul.can_use
    local original_soul_use = G.P_CENTERS.c_soul.use
    G.P_CENTERS.c_soul.can_use = function(self, card)
        if original_soul_can_use and original_soul_can_use(self, card) then return true end
        local real_limit = rio_daronne_real_joker_limit()
        return real_limit and G.jokers and G.jokers.cards and #G.jokers.cards < real_limit or false
    end
    if original_soul_use then
        G.P_CENTERS.c_soul.use = function(self, card, ...)
            local real_limit = rio_daronne_real_joker_limit()
            if not (real_limit and G.jokers and G.jokers.config and G.jokers.cards and #G.jokers.cards < real_limit) then
                return original_soul_use(self, card, ...)
            end

            local old_limit = G.jokers.config.card_limit
            G.jokers.config.card_limit = real_limit
            G.GAME.xmpl_daronne_force_soul_legendary = true
            local ret = {original_soul_use(self, card, ...)}
            G.GAME.xmpl_daronne_force_soul_legendary = nil
            G.jokers.config.card_limit = old_limit
            return unpack(ret)
        end
    end
    G.P_CENTERS.c_soul.xmpl_daronne_can_use_patched = true
end

local function rio_daronne_make_negative(card)
    if card and not (card.edition and card.edition.negative) and not card.getting_sliced and not card.destroyed then
        card:set_edition({negative = true}, true, true)
    end
end

rio_daronne_apply_shop_negative = function()
    if not (count_consumables() >= 10 and has_daronne_vexpi()) then return end
    if G.shop_jokers then
        for _, c in ipairs(G.shop_jokers.cards or {}) do
            rio_daronne_make_negative(c)
        end
    end
    if G.shop_booster then
        for _, c in ipairs(G.shop_booster.cards or {}) do
            rio_daronne_make_negative(c)
        end
    end
    if G.pack_cards then
        for _, c in ipairs(G.pack_cards.cards or {}) do
            if c.config and c.config.center and c.config.center.set == 'Joker' then
                rio_daronne_make_negative(c)
            end
        end
    end
end

local original_create_card = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if G and G.GAME and G.GAME.xmpl_daronne_force_soul_legendary and _type == 'Joker' and area == G.jokers then
        legendary = true
    end
    local card = original_create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if card and G and area == G.pack_cards and count_consumables() >= 10 and has_daronne_vexpi()
        and card.config and card.config.center and card.config.center.set == 'Joker' then
        rio_daronne_make_negative(card)
    end
    return card
end

local original_create_card_for_shop = create_card_for_shop
function create_card_for_shop(area)
    local card = original_create_card_for_shop(area)
    if card and count_consumables() >= 10 and has_daronne_vexpi() then
        if card.config and card.config.center then
            local s = card.config.center.set
            if s == 'Joker' or s == 'Booster' then
                rio_daronne_make_negative(card)
            end
        end
    end
    return card
end

if CardArea and CardArea.emplace then
    local original_cardarea_emplace = CardArea.emplace
    function CardArea:emplace(card, ...)
        local ret = original_cardarea_emplace(self, card, ...)
        if G and self == G.jokers and card and card.config and card.config.center
            and card.config.center.key == DARONNE_VEXPI_KEY and rio_daronne_is_heaviest_deck_run() then
            rio_daronne_set_absolute(card, true)
        end
        if G and (self == G.consumeables or self == G.shop_jokers or self == G.shop_booster or self == G.pack_cards) then
            rio_daronne_apply_shop_negative()
        end
        return ret
    end
end
