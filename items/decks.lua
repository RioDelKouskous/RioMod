------------ ATLAS DEFINITIONS ---------------

SMODS.Atlas{
    key = 'heaviest_deck_atlas',
    path = 'deckdaronnevexpi.png',
    px = 71,
    py = 95
}

SMODS.Atlas{
    key = 'temperature_deck_atlas',
    path = 'temperaturedeck.png',
    px = 71,
    py = 95
}

----------------------------------------------
------------ DECK DEFINITIONS ----------------

local DARONNE_VEXPI_KEY = 'j_xmpl_daronne_vexpi'
local MAY_KEY = 'j_xmpl_may'
local PERFECT_MIDDLE_KEY = 'j_xmpl_perfect_middle'

SMODS.Back{
    key = 'heaviest_deck',
    atlas = 'heaviest_deck_atlas',
    pos = {x = 0, y = 0},
    unlocked = false,
    discovered = false,
    config = {
        dollars = 20,
        jokers = {DARONNE_VEXPI_KEY},
    },
    check_for_unlock = function(self, args)
        local joker = G.P_CENTERS[DARONNE_VEXPI_KEY]
        return joker and joker.discovered
    end,
}

SMODS.Back{
    key = 'temperature_deck',
    atlas = 'temperature_deck_atlas',
    pos = {x = 0, y = 0},
    unlocked = false,
    discovered = false,
    config = {
        jokers = {MAY_KEY},
    },
    check_for_unlock = function(self, args)
        local joker = G.P_CENTERS[PERFECT_MIDDLE_KEY]
        return joker and joker.discovered
    end,
}
