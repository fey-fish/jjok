--maki
SMODS.Joker {
    key = 'maki',
    atlas = 'maki',
    heavenly = true,
    loc_txt = {
        name = 'Maki Zenin',
        text = {
            '{X:mult,C:white}X#1#{} mult',
            '{s:0.8}"A demonic fighter...',
            '{s:0.8}was not yet realized"' } },
    blueprint_compat = true,
    cost = 3,
    rarity = 1,
    config = { extra = { Xmult = 1.5, } },
    loc_vars = function(self, info_queue, center)
        local main_end = {}
        if pseudorandom('maki_me', 1, 10) > 9 then
            main_end = {
                {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                {
                    n = G.UIT.R, config = {}, nodes = {
                        {n = G.UIT.T, config = {text = 'Fun fact!: Maki was the',
                        scale = 0.32 * 0.8, colour = G.C.UI.TEXT_INACTIVE}}
                    }
                },
                {
                    n = G.UIT.R, config = {}, nodes = {
                        {n = G.UIT.T, config = {text = 'first Joker I made!',
                        scale = 0.32 * 0.8, colour = G.C.UI.TEXT_INACTIVE}}
                    }
                }
                }
                }}
        end
        return { vars = { center.ability.extra.Xmult }, main_end = main_end }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
            }
        end
    end
}

SMODS.Atlas {
    key = 'maki',
    path = 'fey/maki.png',
    px = 71,
    py = 95
}

--momo
SMODS.Joker {
    key = 'momo',
    blueprint_compat = true,
    loc_txt = { name = 'Momo Nishimiya',
        text = { 'On selecting a {C:attention}Blind{} create',
            ' a suit {C:tarot}Tarot{} for the most',
            'populated suit in deck' } },
    rarity = 1,
    cost = 6,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_sun
        info_queue[#info_queue + 1] = G.P_CENTERS.c_world
        info_queue[#info_queue + 1] = G.P_CENTERS.c_star
        info_queue[#info_queue + 1] = G.P_CENTERS.c_moon
    end,
    calculate = function(self, card, context)
        if context.setting_blind and #G.consumeables.cards < G.consumeables.config.card_limit then
            local suits = {}
            for i, v in ipairs(G.playing_cards) do
                if not SMODS.has_enhancement(v, 'm_stone') then
                    suits[v.base.suit] = (suits[v.base.suit] or 0) + 1
                end
            end
            if next(suits) then
                local m, suit = 0, nil
                for i, v in pairs(suits) do
                    if v > m then
                        m = v
                        if i == 'Hearts' then
                            suit = 'c_sun'
                        elseif i == 'Clubs' then
                            suit = 'c_moon'
                        elseif i == 'Spades' then
                            suit = 'c_world'
                        elseif i == 'Diamonds' then
                            suit = 'c_star'
                        end
                    end
                end
                SMODS.add_card({ key = suit })
            end
        end
    end
}

--junpei
SMODS.Joker {
    key = 'junpei',
    rarity = 1,
    cost = 4,
    atlas = 'junpei',
    blueprint_compat = true,
    loc_txt = { name = 'Junpei Yoshino',
        text = { 'Gain {C:money}$#1#{} on purchasing an',
            'item from the shop' } },
    config = { extra = {
        dollars = 1
    } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.dollars
            }
        }
    end,
    calculate = function(self, card, context)
        if context.buying_card or context.open_booster then
            ease_dollars(card.ability.extra.dollars)
        end
    end
}

SMODS.Atlas {
    key = 'junpei',
    path = 'fey/junpie.png',
    px = 71,
    py = 95
}

--miwa
SMODS.Joker {
    key = 'miwa',
    rarity = 1,
    cost = 4,
    atlas = 'miwa',
    blueprint_compat = false,
    loc_txt = { name = 'Kasumi Miwa',
        text = { '{C:blue}+#1#{} hand each round',
            '{s:0.8}"He blocked it with his bare hands!"' } },
    config = { extra = { hands = 1 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.hands } }
    end,
    add_to_deck = function(self, card)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands
    end,
    remove_from_deck = function(self, card)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands
    end
}

SMODS.Atlas {
    key = 'miwa',
    path = 'fey/miwa.png',
    px = 71,
    py = 95
}

--ogami
SMODS.Joker {
    key = 'ogami',
    rarity = 1,
    cost = 5,
    blueprint_compat = true,
    loc_txt = { name = 'Granny Ogami',
        text = { 'Summon the bodies of the dead',
            'and use their techniques, gains',
            '{C:white,X:mult}X#2#{} Mult for every {C:attention}flyhead sold{}',
            '{s:0.8,C:inactive}(Currently{} {s:0.8,C:white,X:mult}X#1#{} {s:0.8,C:inactive}Mult)',
            '{s:0.8}"Kill sorcerors huh? Youre a sorceror."' } },
    config = { extra = { Xmult = 1, Xmult_gain = 0.5 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
        return {
            vars = {
                center.ability.extra.Xmult,
                center.ability.extra.Xmult_gain }
        }
    end,
    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint then
            if context.card.config.center.key == 'j_jjok_flyhead' then
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
                return {
                    message = 'X' .. card.ability.extra.Xmult, colour = G.C.MULT
                }
            end
        end
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

--haruta
SMODS.Joker {
    key = 'haruta',
    cost = 2,
    rarity = 1,
    atlas = 'haruta',
    blueprint_compat = true,
    eternal_compat = false,
    loc_txt = { name = 'Haruta',
        text = { '{C:white,X:mult}X#1#{} Mult,',
            'earn {C:money}$#2#{}',
            '{C:inactive}(self destructs)'
        } },
    config = { extra = { dollars = 3, Xmult = 3 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.Xmult,
                center.ability.extra.dollars }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = card.ability.extra.Xmult,
            }
        end
        if context.end_of_round and context.main_eval then
            card:start_dissolve()
            ease_dollars(card.ability.extra.dollars)
        end
    end,
}

SMODS.Atlas {
    key = 'haruta',
    path = 'fey/fraud.png',
    px = 71,
    py = 95
}

--toge
SMODS.Joker {
    key = 'toge',
    rarity = 1,
    blueprint_compat = true,
    loc_txt = { name = 'Toge Inumaki',
        text = { 'If hand contains {C:attention}2{} or more cards',
            '{C:mult}+Mult{} equal to value of leftmost card',
            'and {C:chips}+Chips{} equal to X#1# of rightmost card',
            '{s:0.8}"Stop breathing!"' } },
    config = { extra = { chips = 5 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.chips } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if #G.play.cards > 1 then
                return {
                    mult = G.play.cards[1].base.nominal,
                    chips = (G.play.cards[#G.play.cards].base.nominal * card.ability.extra.chips)
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'ijichi',
    atlas = 'iji',
    loc_txt = { name = 'Ijichi',
        text = {
            'Retrigger all',
            '{C:planet}Blue{} seals' } },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.hand and context.repetition then
            if context.other_card.seal == 'Blue' then
                return {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'iji',
    path = 'fey/ijichi.png',
    px = 71,
    py = 95
}

--charles
SMODS.Joker {
    key = 'charles',
    rarity = 1,
    cost = 8,
    loc_txt = { name = 'Charles',
        text = {
            'See the top {C:attention}#1#{}',
            'cards of your deck',
            '{s:0.8,C:inactive}(Increase by {s:0.8,C:attention}#2#{s:0.8,C:inactive} when',
            '{s:0.8,C:inactive}defeating a boss, max)',
            '{s:0.8,C:inactive}of {s:0.8,C:attention}#3#{s:0.8,C:inactive})'
        } },
    config = { extra = { cards = 2, increase = 1, max = 5 } },
    blueprint_compat = false,
    loc_vars = function(self, info_queue, center)
        local main_end
        if G.deck then
            local cardarea = CardArea(0, 0, G.CARD_W  * (center.ability.extra.cards * 0.7), G.CARD_H * 0.9, {
                card_limit = center.ability.extra.max,
                type = "title",
                highlight_limit = 0
            })
            local temp = #G.deck.cards
            for i = 1, center.ability.extra.cards do
                local copy = copy_card(G.deck.cards[temp], nil, 0.75)
                cardarea:emplace(copy)
                temp = temp - 1
            end
            main_end = {
                { n = G.UIT.O, config = { object = cardarea } }
            }
        end
        return {
            vars = {
                center.ability.extra.cards,
                center.ability.extra.increase,
                center.ability.extra.max
            },
            main_end = main_end
        }
    end,
    calculate = function(self, card, context)
        if context.boss_defeat and not context.blueprint then
            if not card.ability.extra.cards == card.ability.extra.max then
                card.ability.extra.cards = card.ability.extra.cards + card.ability.extra.increase
                return { message = '+' .. card.ability.extra.increase, colour = G.C.FILTER }
            end
        end
    end
}
