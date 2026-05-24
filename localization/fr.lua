return {
    descriptions = {
        Joker = {
            j_xmpl_derek = {
                name = 'Derek',
                text = {
                    'Quand la Blinde est choisie,',
                    'crée un {C:attention}Joker{}',
                    '{X:mult,C:white}X#1#{} Multi',
                    'Gagne {C:money}4${} à la fin de la manche'
                }
            },
            j_xmpl_horse_of_peace_and_kindness = {
                name = 'Cheval de paix et de gentillesse',
                text = {
                    '{C:green}> Le Cheval est en paix avec lui-même{}',
                    '{C:green}> Le Cheval vous offre sa gentillesse{}',
                    '{C:chips}+#1#{} Jetons et {X:mult,C:white}X#2#{} Multi'
                }
            },
            j_xmpl_dolby = {
                name = 'Dolby',
                text = {
                    'Ajoute {C:mult}+#1#{} Multi.',
                    "{C:red,E:2}S'autodétruit{} dans {C:attention}#2#{} mains."
                }
            },
            j_xmpl_daronne_vexpi = {
                name = 'La daronne a vexpi',
                text = {
                    'Reduit les emplacements de {C:attention}Jokers{} a {C:attention}1{}',
                    'A chaque {C:attention}reroll{} du shop, cree',
                    '{C:attention}#1#{} consommables {C:dark_edition}negatifs{} aleatoires',
                    'Mange {C:attention}#2#{} consommables apres chaque main',
                    'Mange {C:attention}1{} consommable de plus a chaque Ante',
                    '{C:planet}Planete{}: {C:chips}+#3#{} Jetons, {C:tarot}Tarot{}: {C:mult}+#4#{} Multi',
                    '{C:spectral}Spectral{}: {X:mult,C:white}X#5#{} Multi',
                    'Autre consommable: {X:chips,C:white}X#6#{} Jetons',
                    'Mange les Jokers {C:dark_edition}negatifs{} voisins',
                    '{C:attention}X2{} par Joker mange {C:inactive}(X#7#, #12# manges){}',
                    'Si {C:attention}+10{} consommables sont presents,',
                    'tous les {C:attention}Jokers{} dans le shop sont {C:dark_edition}negatifs{}',
                    'Chaque Joker {C:dark_edition}negatif{} mange donne {C:money}+#13#${}',
                    'a chaque main restante {C:inactive}(Actuel: +#14#$){}',
                    '{C:inactive}Actuel: +#8# Jetons, +#9# Multi, X#10# Multi, X#11# Jetons{}'
                }
            }
        },
        Tarot = {
            c_xmpl_rio_guy = {
                name = 'Le gars',
                text = {
                    'Crée {C:attention}2{} cartes',
                    '{C:tarot}Tarot{} aléatoires'
                }
            }
        },
        Back = {
            b_xmpl_heaviest_deck = {
                name = 'Paquet le plus lourd',
                text = {
                    'Commence avec {C:attention}La daronne a vexpi{}',
                    'Gagne {C:money}20${} au début de la partie',
                },
                unlock = {
                    'Avoir eu {C:attention}La daronne a vexpi{}',
                    'en partie',
                }
            }
        },
        Booster = {
            p_xmpl_rio_pack = {
                name = 'Paquet Rio',
                text = {
                    'Choisissez {C:attention}#1#{} parmi',
                    '{C:attention}#2#{} cartes de Tarot'
                }
            }
        }
    },
    misc = {
        dictionary = {
            k_xmpl_live = 'En vie !',
            k_xmpl_derek_yay = 'Derek, génial',
            k_xmpl_peace_kindness = 'Paix et gentillesse !',
            k_xmpl_self_destruct = 'Autodestruction !',
            k_xmpl_daronne_reroll = 'A table !',
            k_xmpl_daronne_ate = 'Repas fini !'
        }
    }
}
