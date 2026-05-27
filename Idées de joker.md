## 4-2 de théo

*Assets : aucun*

*Effets : aucun*

**Reference :**

## May

**Assets :**

- assets\2x\may.png
- assets\sounds\sm64lethallava.ogg

**Effets :**

- Forcer la vitesse du jeu a x4, en ignorant les paramètres de saturn *(ou autre mod)*
- Mettre un shader tah la chaleur *(une couleur chaude ou autre pour simuler la chaleur sur tout l'écran)*
- Mettre le background en couleur orange chaude
- Mettre la musique lethal lava de mario en arrière plan, en replaçant celle du jeu
- Enlever les effets du joker "coldcarrefour". Penser ne pas activer les effets quand la daronne a vexpi est active pour éviter les bugs

- Faire des paramètres pour désactiver les effets visuels individuellement comme le mod bunco *(bouton gris a coté du bouton vendre du joker, ça amène aux paramètres du joker)*

- Si obtenue d'un autre moyen que le joker coldcarrefour : elle commence a X2 Chips, X2 Mult
- A chaque seconde de la musique, elle perd x0.003 sur son Xmult
- A chaque seconde de la musique, elle gagne x0.02 sur ses Xchips
- Au bout de 2min30, la carte change en coldcarrefour.
- Penser a conserver le statut de la carte *(l'état du multiplicateur, son edition, stickers, seal, enhance, les markings **(du mod lucky rabbit, penser a le rajouter en dependecies)**)*

**Reference :**

> Les températures en mai ça va on se sent bien
> La référence vient d'une fois ou on est sortie du lycée (gabin marvin nathan) et on s'est retrouvé a la traversée du desert en plein main
> Du coup pour illustrer cette situation on a mis cette musique en pleine rue

**Description**
```lua
'{C:inactive}Weather in may for absolute no reason{}',
'Make your game feels like this damn month',
'{X:mult,C:white}X#5#{} Mult and {X:chips,C:white}X#6#{} Chips'
```

## Cold Carrefour

**Assets :**
- assets\2x\coldcarrefour.png
- assets\sounds\sm64coolcool.ogg

**Effets :**
- Enlève les effets du joker "may". Penser ne pas activer les effets quand la daronne a vexpi est active pour éviter les bugs

- Faire des paramètres pour désactiver les effets visuels individuellement comme le mod bunco (bouton gris a coté du bouton vendre du joker, ça amène aux paramètres du joker)
- Met le background en blue ciel froid
- Met la musique ms64coolcool en fond
- Mettre un shader tah le froid *(une couleur froide et un overlay avec de la glace autour pour simuler la froid sur tout l'écran)*
- Force la vitesse du jeu a 16 en ignorant les paramètres de saturn *(ou autre mod)*

- Si obtenue d'un autre moyen que le joker may : elle commence a X2 Chips, X2 Mult
- A chaque seconde de la musique, elle perd x0.003 sur son Xchips
- A chaque seconde de la musique, elle gagne x0.02 sur son Xmult
- Au bout de 2min30, la carte change en may.
- Penser a conserver le statut de la carte *(l'état du multiplicateur, son edition, stickers, seal, enhance, les markings **(du mod lucky rabbit, penser a le rajouter en dependecies)**)*

**Reference :**

> Les températures en mai ça va on se sent bien
> la même référence que may sauf que la c'est l'oasis

**Description**
```lua
'{C:blue,E:2}Fr{}{C:white,E:2}en{}{C:red,E:2}ch{} {C:inactive}oasis replacement in a hot may{}',
'Make your game feels nice and cold',
'{X:mult,C:white}X#5#{} Mult and {X:chips,C:white}X#6#{} Chips'
```


## Big data

## Big data container en papier

# Global

## Catégories :

- **Faster**
- **Jeux**
- **Random**
- **Balls**

> Les catégories peuvent êtres désactivées & activées dans les paramètres du mod

