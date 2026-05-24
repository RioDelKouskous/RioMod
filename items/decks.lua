------------ ATLAS DEFINITIONS ---------------

SMODS.Atlas{
    key = 'heaviest_deck_atlas',
    path = 'deckdaronnevexpi.png',
    px = 71,
    py = 95
}

----------------------------------------------
------------ DECK DEFINITIONS ----------------

SMODS.Back{
    key = 'heaviest_deck',
    atlas = 'heaviest_deck_atlas',
    pos = {x = 0, y = 0},
    unlocked = true,
    discovered = true,
    config = {
        dollars = 20,
        jokers = {'j_xmpl_daronne_vexpi'},
    },
}
