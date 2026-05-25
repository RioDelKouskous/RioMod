return {
    descriptions = {
        Other = {
            xmpl_daronne_grand_feast = {
                name = 'Grand Feast',
                text = {
                    'Raises all current and future',
                    'buffs by {X:dark_edition,C:white} ^1.5 {}',
                    'Eats every consumable, sets',
                    'eaten Jokers to {C:attention}0{}',
                    'sets money per hand to {C:money}+$20{},',
                    'removes all money, gains {C:attention}+3{} Ante,',
                    'and becomes {C:dark_edition}Polychrome{}',
                    "{C:green}> Vexpi's Mother becomes inevitable{}",
                    "{C:green}> The universe bows before her{}",
                    "{C:green}> Most epic moment in a card game{}",
                }
            }
        },
        Joker = {
            j_xmpl_derek = {
                name = 'Derek',
                text = {
                    'When Blind is selected,',
                    'create a {C:attention}Joker{}',
                    '{X:mult,C:white}X#1#{} Mult',
                    'Gain {C:money}4${} at end of round'
                }
            },
            j_xmpl_horse_of_peace_and_kindness = {
                name = 'Horse of Peace and Kindness',
                text = {
                    '{C:green}> Horse is at peace with himself{}',
                    '{C:green}> Horse offers you his kindness{}',
                    '{C:chips}+#1#{} Chips and {X:mult,C:white}X#2#{} Mult'
                }
            },
            j_xmpl_dolby = {
                name = 'Dolby',
                text = {
                    'Adds {C:mult}+#1#{} Mult.',
                    '{C:red,E:2}Self-destructs{} in {C:attention}#2#{} hands.'
                }
            },
            j_xmpl_daronne_vexpi = {
                name = "Vexpi's Mother",
                text = {
                    'Reduces {C:attention}Joker{} slots to {C:attention}1{}',
                    'On each shop {C:attention}reroll{}, creates',
                    '{C:attention}#1#{} random {C:dark_edition}Negative{} consumables',
                    'Eats {C:attention}#2#{} consumables after each hand',
                    'Eats {C:attention}1{} more consumable each Ante',
                    '{C:planet}Planet{}: {C:chips}+#3#{} Chips, {C:tarot}Tarot{}: {C:mult}+#4#{} Mult',
                    '{C:spectral}Spectral{}: {X:mult,C:white}X#5#{} Mult',
                    'Other consumable: {X:chips,C:white}X#6#{} Chips',
                    'Eats adjacent {C:dark_edition}Negative{} Jokers',
                    '{C:attention}X2{} per eaten Joker {C:inactive}(X#7#, #12# eaten){}',
                    'If {C:attention}10+{} consumables are present,',
                    'all {C:attention}Jokers{} in the shop are {C:dark_edition}Negative{}',
                    'Each eaten {C:dark_edition}Negative{} Joker gives {C:money}+#13#${}',
                    'to each remaining hand {C:inactive}(Current: +#14#$){}',
                    '{C:inactive}Current: +#8# Chips, +#9# Mult, X#10# Mult, X#11# Chips{}',
                    'If reroll is {C:money}$30{} or more, {C:attention}100+{} consumables, {C:money}$100+{}:',
                    'Buying a {C:attention}Voucher{} triggers {C:dark_edition,E:2}Grand Feast{}',
                    'Eating a {C:blue}Legendary{} Joker triggers {C:dark_edition,E:2}Grand Feast{}',
                    '{C:green}> She is going to crash your game eventually{}',
                    '{C:green}> The question is when ?{}'
                }
            }
        },
        Tarot = {
            c_xmpl_rio_guy = {
                name = 'The guy',
                text = {
                    'Create {C:attention}2{} random',
                    '{C:tarot}Tarot{} cards'
                }
            }
        },
        Back = {
            b_xmpl_heaviest_deck = {
                name = 'Heaviest Deck',
                text = {
                    'Start with {C:attention}Vexpi\'s Mother{}',
                    'Gain {C:money}$20{} at start of run',
                },
                unlock = {
                    'Have {C:attention}Vexpi\'s Mother{}',
                    'in a run',
                }
            }
        },
        Booster = {
            p_xmpl_rio_pack = {
                name = 'Rio Pack',
                text = {
                    'Choose {C:attention}#1#{} of',
                    '{C:attention}#2#{} Tarot cards'
                }
            }
        }
    },
    misc = {
        dictionary = {
            k_xmpl_live = 'Live!',
            k_xmpl_derek_yay = 'Derek yay',
            k_xmpl_peace_kindness = 'Peace & Kindness!',
            k_xmpl_self_destruct = 'Self-Destruct!',
            k_xmpl_daronne_reroll = 'Dinner time!',
            k_xmpl_daronne_ate = 'Meal done!',
            k_xmpl_daronne_feast = 'GRAND FEAST!',
            k_xmpl_daronne_feast_line_1 = 'Finally, I can unleash my real power',
            k_xmpl_daronne_feast_line_2 = "I'M HUNGRY MORE THAN EVER",
            k_xmpl_daronne_feast_line_3 = "I'M GONNA EAT THE WHOLE DAMN UNIVERSE",
            k_xmpl_daronne_feast_line_4 = 'BEHOLD! THE POWER OF AN ANGEL'
        }
    }
}
