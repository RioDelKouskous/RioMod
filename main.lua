--- STEAMODDED HEADER
--- MOD_NAME: BalaRio
--- MOD_ID: BalaRio
--- MOD_AUTHOR: [RioSkai, Suiveurtag]
--- MOD_DESCRIPTION: Cool mod yeah yeah.
--- PREFIX: xmpl
--- DEPENDENCIES: [Cryptid]
----------------------------------------------
------------ ATLAS DEFINITIONS ---------------

SMODS.Atlas{
    key = 'rio_assets',
    path = 'rio_assets.png',
    px = 71, py = 95
}

------------ GRAND FEAST EFFECTS ---------------

SMODS.Sound{
    key = 'music_daronne_feast',
    path = 'ultrakillost-altarsofapostasy.ogg',
    sync = false,
    pitch = 1,
    volume = 0.75,
    select_music_track = function()
        if G and G.GAME and G.GAME.xmpl_daronne_music_active then
            return 1000000
        end
    end
}


local DARONNE_FEAST_BACKGROUND = {
    HEX('ff2a6d'),
    HEX('05d9e8'),
    HEX('f9f871'),
    HEX('9d4edd'),
    HEX('00ff87'),
}

local function rio_daronne_background_colour(index, still)
    if still then
        local colour = DARONNE_FEAST_BACKGROUND[((index - 1) % #DARONNE_FEAST_BACKGROUND) + 1]
        return {colour[1], colour[2], colour[3], colour[4] or 1}
    end

    local timer = G and G.TIMERS and (G.TIMERS.REAL or G.TIMERS.TOTAL) or 0
    local phase = (timer * 0.45 + index * 0.9) % #DARONNE_FEAST_BACKGROUND
    local start_index = math.floor(phase) + 1
    local end_index = start_index == #DARONNE_FEAST_BACKGROUND and 1 or start_index + 1
    local blend = phase % 1
    blend = 0.5 - 0.5 * math.cos(blend * math.pi)

    local a = DARONNE_FEAST_BACKGROUND[start_index]
    local b = DARONNE_FEAST_BACKGROUND[end_index]
    return {
        a[1] * (1 - blend) + b[1] * blend,
        a[2] * (1 - blend) + b[2] * blend,
        a[3] * (1 - blend) + b[3] * blend,
        1
    }
end

function XMP_DARONNE_APPLY_FEAST_BACKGROUND()
    if not (G and G.C and G.C.BACKGROUND) then return end

    local still = G.SETTINGS and G.SETTINGS.reduced_motion
    local colours = {
        L = rio_daronne_background_colour(1, still),
        C = rio_daronne_background_colour(3, still),
        D = rio_daronne_background_colour(5, still),
    }

    for key, colour in pairs(colours) do
        local target = G.C.BACKGROUND[key]
        if target then
            target[1], target[2], target[3], target[4] = colour[1], colour[2], colour[3], colour[4]
        end
    end
    G.C.BACKGROUND.contrast = 2.6
end

if ease_background_colour_blind then
    local ease_background_colour_blind_ref = ease_background_colour_blind
    function ease_background_colour_blind(state, blind_override)
        if G and G.GAME and G.GAME.xmpl_daronne_bg_lock then
            XMP_DARONNE_APPLY_FEAST_BACKGROUND()
            return
        end
        return ease_background_colour_blind_ref(state, blind_override)
    end
end

if Game and Game.update then
    local game_update_ref = Game.update
    function Game:update(dt)
        local ret = game_update_ref(self, dt)
        if G and G.GAME and G.GAME.xmpl_daronne_bg_lock then
            XMP_DARONNE_APPLY_FEAST_BACKGROUND()
        end
        return ret
    end
end

----------------------------------------------
------------ LOAD ITEM FILES -----------------

local f, err = SMODS.load_file("items/jokers.lua")
if err then
    error(err)
else
    f()
end

f, err = SMODS.load_file("items/decks.lua")
if err then
    error(err)
else
    f()
end
