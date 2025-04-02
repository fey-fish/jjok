--- STEAMODDED HEADER
--- MOD_NAME: Jujutsu Jokers
--- MOD_ID: JJOKERS
--- MOD_AUTHOR: [fey]
--- MOD_DESCRIPTION: Add jokers based on the popular shonen JJK
--- BADGE_COLOR: 660000
--- PREFIX: jjok
----------------------------------------------
------------MOD CODE -------------------------


SMODS.Atlas{
    key = 'makiImg',
    path = 'maki.png',
    px = 1030,
    py = 1378
}

SMODS.Joker{
    key = 'maki',
    loc_txt = {
        name = 'Maki Zenin',
        text = {
            'Gives {X:mult,C:white}X#1#{} mult',
            '{s:0.8}"A demonic fighter... was not yet realized"'
        }
    },
    atlas = 'makiImg',
    soul_pos = {x = 0, y = 0},
    pos = {x = 1, y = 0},
    config = {extra ={
        Xmult = 1.5
    }
    },
    loc_vars = function (self,info_queue,center)
        return{vars = {center.ability.extra.Xmult}}
    end,
    calculate = function(self,card,context)
        if context.joker_main then
            return{
                card = card,
                Xmult = card.ability.extra.Xmult,
            }
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
