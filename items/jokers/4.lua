SMODS.Joker {
    key = 'dagon',
    atlas = 'dagon',
    loc_txt = { name = 'Dagon',
        text = {  'All card areas are filled',
            'with {C:attention}Splash{} plus {C:dark_edition}1 Negative',
            '{C:attention}Splash{} for every {C:attention}Non-Negative',
            'Joker on {C:attention}selecting{} a blind',
            '{C:inactive,s:0.8}(Must have space)' } },
    cost = 20,
    rarity = 4,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        info_queue[#info_queue + 1] = G.P_CENTERS.j_splash
    end,
    config = { extra = { joker_slots = 0 } },
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            card.ability.extra.jokerslots = 0
            for i, v in ipairs(G.jokers.cards) do
                if v.edition == nil or v.edition.key ~= 'e_negative' then
                    card.ability.extra.jokerslots = card.ability.extra.jokerslots + 1
                end
            end
            local emptyJ = G.jokers.config.card_limit - G.jokers.config.card_count
            local emptyC = G.consumeables.config.card_limit - #G.consumeables.cards
            local emptyD = G.domain.config.card_limit - #G.domain.cards
            for i = 1, emptyJ do
                SMODS.add_card({ area = G.jokers, key = 'j_splash' })
            end
            for i = 1, emptyC do
                SMODS.add_card({ area = G.consumeables, key = 'j_splash' })
            end
            for i = 1, emptyD do
                SMODS.add_card({ area = G.domain, key = 'j_splash' })
            end
        end
        if context.setting_blind then
            for i = 1, card.ability.extra.jokerslots do
                SMODS.add_card({ key = 'j_splash', edition = 'e_negative' })
            end
        end
    end
}

SMODS.Atlas {
    key = 'dagon',
    path = 'tac/Cthulu.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'kash',
    atlas = 'kashimo',
    loc_txt = {
        name = 'Hajime Kashimo',
        text = {
            'Each scored {C:attention}4{} and{C:attention} Ace',
            'gives {C:white,X:chips}X#1#{} Chips'
        }},
    loc_vars = function (self,info_queue,center)
        return {vars = {
            center.ability.extra.xchips
        }}
    end,
    config = {extra = {xchips = 2.5}},
    rarity = 4,
    cost = 20,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == (4 or 14) then
                return {
                    xchips = card.ability.extra.xchips
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'kashimo',
    path = 'tac/KashMoney.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'yoro',
    cost = 20,
    atlas = 'yoro',
    rarity = 4,
    loc_txt = { name = 'Yorozu',
        text = {
            'Add another {C:attention}Card{} slot,',
            '{C:attention}Booster{} slot and',
            '{C:attention}Voucher{} to the shop'
        } },
    add_to_deck = function(self, card, from_debuff)
        SMODS.change_booster_limit(1)
        SMODS.change_voucher_limit(1)
        change_shop_size(1)
    end,
    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_booster_limit(-1)
        SMODS.change_voucher_limit(-1)
        change_shop_size(-1)
    end
}

SMODS.Atlas {
    key = 'yoro',
    path = 'fey/yorozu.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'takako',
    atlas = 'takako',
    loc_txt = { name = 'Takako',
        text = {
            '{C:planet}Blue{} Seals now {C:attention}create',
            '{C:dark_edition}3 Negative{} {C:planet}Planet{} cards' } },
    rarity = 4,
    cost = 8,
    discovered = true
}

SMODS.Atlas {
    key = 'takako',
    path = 'tac/takako.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'amaki',
    atlas = 'awakenedmaki',
    blueprint_compat = true,
    loc_txt = {
        name = 'Awakened Maki',
        text = {
            '{C:attention}Destroys{} the {C:chips}left most{} card in any',
            'played hand and gains {X:mult,C:white}X#2#{} Mult',
            '{C:inactive}(Currently: {X:mult,C:white}X#1#{C:inactive} Mult)',
            '{s:0.8}"A demonic fighter equal to Toji',
            '{s:0.8}Zenin was now fully realised!"'
        }
    },
    config = {heavenly = true, extra = {
        Xmult = 1,
        Xmult_gain = 0.25
    } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = { center.ability.extra.Xmult,
                center.ability.extra.Xmult_gain }
        }
    end,
    rarity = 4,
    cost = 20,
    calculate = function(self, card, context)
        if context.destroying_card and context.cardarea == G.play and context.destroying_card == context.full_hand[1] and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                remove = true,
                message = { 'X' .. card.ability.extra.Xmult .. ' Mult' }
            }
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Atlas {
    key = 'awakenedmaki',
    path = 'tac/amaki.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'nanami',
    loc_txt = { name = 'Nanami Kento',
        text = { 'Every scored {C:attention}7{} or {C:attention}3{}',
            'gives {X:mult,C:white}X#1#{} Mult',
            '{s:0.8}"You take it from here..."' } },
    rarity = 4,
    cost = 20,
    atlas = 'nanami',
    blueprint_compat = true,
    config = { extra = { Xmult = 2.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
    remove_from_deck = function(self, card, context)
        if #G.consumeables.cards < G.consumeables.config.card_limit then
            SMODS.add_card({ key = 'c_jjok_nanamitool' })
        end
    end,
    calculate = function(self, card, context)
        if SMODS.find_card('j_jjok_haruta')[1] then
            SMODS.find_card('j_jjok_haruta')[1]:start_dissolve()
        end
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 7 or context.other_card:get_id() == 3 then
                card:juice_up()
                return {
                    Xmult = card.ability.extra.Xmult,
                    card = context.other_card
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'nanami',
    path = 'tac/nanami.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'ygojo',
    atlas = 'ygojo',
    cost = 20,
    loc_vars = function(self, info_queue, center)
        return {
            vars = { center.ability.extra.Xmult,
                center.ability.extra.Xmult_gain }
        }
    end,
    loc_txt = {
        name = 'Young Gojo',
        text = {
            'Gains {C:white,X:mult}X#2#{} Mult everytime',
            'a playing card triggers',
            '{C:inactive}(Currently {C:white,X:mult}X#1#{C:inactive} Mult)',
            '{s:0.8}"I alone am the honoured one"{}'
        }
    },
    blueprint_compat = false,
    rarity = 4,
    config = { extra = { Xmult = 1, Xmult_gain = 0.05 },
        unlocked = true,
        discovered = true },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                message = 'Grasped!',
                colour = G.C.MULT,
                message_card = card
            }
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end,
    update = function(self, card, dt)
        if Jjok.config.thatoru then
            card.children.center.atlas = G.ASSET_ATLAS['jjok_thatoru']
        else
            card.children.center.atlas = G.ASSET_ATLAS['jjok_ygojo']
        end
    end
}

SMODS.Atlas {
    key = 'ygojo',
    path = 'tac/Student_Gojo.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'thatoru',
    path = 'fey/thatoru.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'luna',
    cost = 20,
    rarity = 4,
    loc_txt = {name = '{C:blue}Luna Snow',
                text = {
                    'Gain {C:blue}#1#{} hand',
                    'if {C:attention}final{} hand is played',
                    'during {C:attention}Boss{} blind'
                }},
    config = {extra = {hands = 1}},
    loc_vars = function(self,info_queue,center)
        return {vars = {center.ability.extra.hands}}
    end,
    calculate = function(self,card,context)
        if context.before and G.GAME.current_round.hands_left == 0 and G.GAME.blind.boss then
            ease_hands_played(card.ability.extra.hands)
            return {
                message = 'Frozen!', 
                colour = G.C.BLUE,
            }
        end
    end
}