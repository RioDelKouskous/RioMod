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

SMODS.Sound{
    key = 'music_may_lava',
    path = 'sm64lethallava.ogg',
    sync = false,
    pitch = 1,
    volume = 0.8,
    select_music_track = function()
        if G and G.GAME and G.GAME.xmpl_weather_music == 'may' and not G.GAME.xmpl_daronne_music_active then
            return 900000
        end
    end
}

SMODS.Sound{
    key = 'music_cold_carrefour',
    path = 'sm64coolcool.ogg',
    sync = false,
    pitch = 1,
    volume = 0.8,
    select_music_track = function()
        if G and G.GAME and G.GAME.xmpl_weather_music == 'cold_carrefour' and not G.GAME.xmpl_daronne_music_active then
            return 900000
        end
    end
}

SMODS.Sound{
    key = 'music_perfect_middle',
    path = 'sm64swimswim.ogg',
    sync = false,
    pitch = 1,
    volume = 0.8,
    select_music_track = function()
        if G and G.GAME and G.GAME.xmpl_weather_music == 'perfect_middle' and not G.GAME.xmpl_daronne_music_active then
            return 900000
        end
    end
}

SMODS.ScreenShader{
    key = 'weather_heat',
    path = 'weather_heat.fs',
    send_vars = function()
        return {
            time = G and G.TIMERS and G.TIMERS.REAL or 0,
            strength = 1
        }
    end,
    should_apply = function()
        return G and G.GAME and G.GAME.xmpl_weather_shader == 'may'
            and not G.GAME.xmpl_daronne_bg_lock
    end
}

SMODS.ScreenShader{
    key = 'weather_middle',
    path = 'weather_middle.fs',
    send_vars = function()
        return {
            time = G and G.TIMERS and G.TIMERS.REAL or 0,
            strength = 1
        }
    end,
    should_apply = function()
        return G and G.GAME and G.GAME.xmpl_weather_shader == 'perfect_middle'
            and not G.GAME.xmpl_daronne_bg_lock
    end
}

SMODS.ScreenShader{
    key = 'weather_cold',
    path = 'weather_cold.fs',
    send_vars = function()
        return {
            time = G and G.TIMERS and G.TIMERS.REAL or 0,
            strength = 1
        }
    end,
    should_apply = function()
        return G and G.GAME and G.GAME.xmpl_weather_shader == 'cold_carrefour'
            and not G.GAME.xmpl_daronne_bg_lock
    end
}

SMODS.ScreenShader{
    key = 'temperature_tornado',
    path = 'temperature_tornado.fs',
    send_vars = function()
        local timer = G and G.GAME and G.GAME.xmpl_temperature_tornado_timer or 0
        local duration = 2.4
        return {
            time = G and G.TIMERS and G.TIMERS.REAL or 0,
            strength = math.max(0, math.min(1, timer / duration))
        }
    end,
    should_apply = function()
        return G and G.GAME and G.GAME.xmpl_temperature_tornado_active
    end
}

SMODS.Shader{
    key = 'relief_3d',
    path = 'relief_3d.fs',
    send_vars = function(sprite, card)
        local uv_off_y = 0.5
        if sprite and sprite.texture then
            local th = sprite.texture:getHeight()
            local _, _, _, _, qh = sprite.quad:getViewport()
            if th > 0 and qh > 0 then
                uv_off_y = qh / th
            end
        end
        
        return {
            tilt = (card and card.tilt_var) and {card.tilt_var.x * 0.4, card.tilt_var.y * 0.4} or {0, 0},
            uv_offset = {0, uv_off_y}
        }
    end
}

local function rio_weather_card_shader_vars(sprite, card)
    return {
        time = G and G.TIMERS and G.TIMERS.REAL or 0,
        strength = (card and (card.greyed or card.debuff or card.REMOVED or card.destroyed)) and 0.35 or 1
    }
end

SMODS.Shader{
    key = 'weather_card_heat',
    path = 'weather_card_heat.fs',
    send_vars = rio_weather_card_shader_vars
}

SMODS.Shader{
    key = 'weather_card_cold',
    path = 'weather_card_cold.fs',
    send_vars = rio_weather_card_shader_vars
}

SMODS.Shader{
    key = 'weather_card_middle',
    path = 'weather_card_middle.fs',
    send_vars = rio_weather_card_shader_vars
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

local WEATHER_BACKGROUNDS = {
    may = {
        L = HEX('ff7a1a'),
        C = HEX('ffb347'),
        D = HEX('7a2100'),
        contrast = 2.2
    },
    cold_carrefour = {
        L = HEX('87ceeb'),
        C = HEX('d6f4ff'),
        D = HEX('18537a'),
        contrast = 2.1
    },
    perfect_middle = {
        L = HEX('ffd37a'),
        C = HEX('b9f8ff'),
        D = HEX('4a8fbd'),
        contrast = 2.35
    }
}

function XMP_WEATHER_APPLY_BACKGROUND()
    if not (G and G.GAME and G.C and G.C.BACKGROUND) then return end
    if G.GAME.xmpl_daronne_bg_lock then return end
    local cfg = WEATHER_BACKGROUNDS[G.GAME.xmpl_weather_background]
    if not cfg then return end

    for key, colour in pairs({L = cfg.L, C = cfg.C, D = cfg.D}) do
        local target = G.C.BACKGROUND[key]
        if target then
            target[1], target[2], target[3], target[4] = colour[1], colour[2], colour[3], colour[4] or 1
        end
    end
    G.C.BACKGROUND.contrast = cfg.contrast
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
        if G and G.GAME and G.GAME.xmpl_weather_background then
            XMP_WEATHER_APPLY_BACKGROUND()
            return
        end
        return ease_background_colour_blind_ref(state, blind_override)
    end
end

if Game and Game.update then
    local game_update_ref = Game.update
    function Game:update(dt)
        local saved_gamespeed
        if G and G.GAME and G.SETTINGS and G.GAME.xmpl_weather_speed
            and not G.GAME.xmpl_daronne_bg_lock and not G.GAME.xmpl_daronne_music_active then
            saved_gamespeed = G.SETTINGS.GAMESPEED
            G.SETTINGS.GAMESPEED = G.GAME.xmpl_weather_speed
        end
        local ret = game_update_ref(self, dt)
        if saved_gamespeed then
            G.SETTINGS.GAMESPEED = saved_gamespeed
        end
        if G and G.GAME and G.GAME.xmpl_daronne_bg_lock then
            XMP_DARONNE_APPLY_FEAST_BACKGROUND()
        elseif G and G.GAME and G.GAME.xmpl_weather_background then
            XMP_WEATHER_APPLY_BACKGROUND()
        end
        if XMP_WEATHER_REFRESH then
            XMP_WEATHER_REFRESH(dt)
        end
        if XMP_TEMPERATURE_TORNADO_REFRESH then
            XMP_TEMPERATURE_TORNADO_REFRESH(dt)
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
