--- STEAMODDED HEADER
--- MOD_NAME: BalaRio
--- MOD_ID: BalaRio
--- MOD_AUTHOR: [RioSkai, Suiveurtag]
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