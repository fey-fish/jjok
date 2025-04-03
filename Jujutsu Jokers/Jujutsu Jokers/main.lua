--- STEAMODDED HEADER
--- MOD_NAME: Jujutsu Jokers
--- MOD_ID: JJOKERS
--- MOD_AUTHOR: [fey]
--- MOD_DESCRIPTION: Add jokers based on the popular shonen JJK
--- BADGE_COLOR: 660000
--- PREFIX: jjok
----------------------------------------------
------------MOD CODE -------------------------

SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
        post_trigger = true
    }
end

SMODS.Rarity {
    key = 'jjok_special',
    loc_txt = {
        name = 'Special Grade'
    },
    badge_colour = HEX('A64D79')
}

SMODS.Consumable {
    key = 'awake',
    set = 'Spectral',
    atlas = 'atlastwo',
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y =0},
    loc_txt = {
        'Awaken any {C:legendary}Grade 1{} sorceror',
        'into a {C:G.C.Rarity.jjok_special}'
    },
    pools = {
        ["Spectral"] = true,
        ["hidden"] = true
    },
    soul_set = 'Spectral',
    soul_rate = 0.15,
}

SMODS.Joker {
    key = 'ygojo',
    atlas = 'atlasone',
    soul_pos = {x = 0, y = 2},
    pos = {x = 1, y = 2},
    loc_vars = function(self,info_queue,card)
        return  {vars = {card.ability.extra.mult}}
    end,
    loc_txt = {
        name = 'Young Gojo',
        text = {
            'Gains {C:mult}+1{} mult everytime',
            'a joker triggers',
            '{s:0.8, C:inactive}(Currently: {C:mult,s:0.8}+#1#{s:0.8, C:inactive} mult){}',
            '{s:0.8}"I alone am the honoured one"{}'
        }
    },
    rarity = 4,
    config = {extra = { mult = 0, mult_gain = 1}},
    calculate = function(self,card,context)
        if context.joker_main then
            return {
            mult_mod = card.ability.extra.mult,
            message = localize{type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
            }
        end
        if context.post_trigger and context.other_card ~= card and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = 'Concept Grasped',
                colour = G.C.MULT
            }
        end
    end
}


SMODS.Atlas {
    key = 'atlasone',
    path = 'one.png',
    px = 1030,
    py = 1378
}

SMODS.Atlas {
    key = 'atlastwo',
    path = 'two.png',
    px = 126,
    py = 185
}

SMODS.Joker {
    key = 'yuta',
    loc_txt = {
        name = 'Yuta Okkotsu',
        text = {
            'Rika {C:attention}copies{} the abilities of the jokers',
            'to the {X:chips,C:white}left{} and {X:mult,C:white}right{} of Yuta if both',
            'abilities can be copied',
            '{s:0.8}"The cursed child..."{}'
        }
    }, 
    rarity = "jjok_special",
    atlas = 'atlasone',
    pos = {x = 1, y = 1},
    soul_pos = {x = 0, y = 1},
    blueprint_compat = false,
    config = { extra = { retriggers = 1 } },
    update = function(self, card, context)
        local index = -1
        Right_joker = nil
        Left_joker = nil
        RightCompat = nil
        LeftCompat = nil
        if G.STAGE == G.STAGES.RUN then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    index = i
                end
            end
            if index > 1 and index < #G.jokers.cards then
                Left_joker = G.jokers.cards[index - 1]
                Right_joker = G.jokers.cards[index + 1]

                if Right_joker and Right_joker ~= self and Right_joker.config.center.blueprint_compat then
                    RightCompat = true
                else
                    RightCompat = false
                end
                if Left_joker and Left_joker ~= self and Left_joker.config.center.blueprint_compat then
                    LeftCompat = true
                else
                    LeftCompat = false
                end
                if LeftCompat == true and RightCompat == true then
                    card.ability.blueprint_compat = 'compatible'
                else
                    card.ability.blueprint_compat = 'incompatible'
                end
            end
        end
    end,
    calculate = function(self, card, context)
        if RightCompat == true and LeftCompat == true then
            if context.retrigger_joker_check and not context.retrigger_joker and (context.other_card == Right_joker or context.other_card == Left_joker) then
                return {
                    message = 'Copied!',
                    repetitions = card.ability.extra.retriggers,
                    card = card
                }
            end
        end
    end
}   

SMODS.Joker {
    key = 'maki',
    loc_txt = {
        name = 'Maki Zenin',
        text = {
            'Gives {X:mult,C:white}X#1#{} mult',
            '{s:0.8}"A demonic fighter... was not yet realized"'
        }
    },
    atlas = 'atlasone',
    blueprint_compat = true,
    cost = 3,
    soul_pos = { x = 0, y = 0 },
    pos = { x = 1, y = 0 },
    order = 0,
    config = { extra = {
        Xmult = 1.5
    }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                card = card,
                Xmult = card.ability.extra.Xmult,
            }
        else
            if context.blueprint then
                return {
                    card = card,
                    Xmult = card.ability.extra.Xmult,
                }
            end
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
