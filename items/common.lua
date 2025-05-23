
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
        if context.setting_blind or (context.setting_blind and context.blueprint) then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    local clubs = 0
                    local hearts = 0
                    local diamonds = 0
                    local spades = 0
                    local max = {}
                    for i, v in ipairs(G.playing_cards) do
                        local cardsuit = v.base.suit

                        if cardsuit == 'Clubs' then
                            clubs = clubs + 1
                        end
                        if cardsuit == 'Spades' then
                            spades = spades + 1
                        end
                        if cardsuit == 'Hearts' then
                            hearts = hearts + 1
                        end
                        if cardsuit == 'Diamonds' then
                            diamonds = diamonds + 1
                        end
                    end
                    if diamonds >= hearts then
                        max[1] = diamonds
                        max[2] = 'c_star'
                    else
                        max[1] = hearts
                        max[2] = 'c_sun'
                    end
                    if spades >= clubs then
                        max[3] = spades
                        max[4] = 'c_world'
                    else
                        max[3] = clubs
                        max[4] = 'c_moon'
                    end
                    if max[1] >= max[3] then
                        max[5] = max[2]
                    else
                        max[5] = max[4]
                    end

                    SMODS.add_card({ set = 'Tarot', area = G.consumeables, key = max[5] })
                    return true
                end
            }))
        end
    end
}

--junpei
SMODS.Joker {
    key = 'junpei',
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    loc_txt = { name = 'Junpei Yoshino',
        text = { 'Gain {C:money}$#1#{} on purchasing an item',
            'from the shop' } },
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

--miwa
SMODS.Joker {
    key = 'miwa',
    rarity = 1,
    cost = 4,
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
    config = { extra = { Xmult = 1, Xmult_gain = 0.25 } },
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
                    message = { '+' .. card.ability.extra.Xmult_gain .. ' XMult' }
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
    loc_txt = { name = 'Haruta',
        text = {'On {C:attention}final hand{} of the',
            'round, retrigger all played cards',
            '{C:inactive}(self destructs)'
        } },
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and G.GAME.current_round.hands_left == 0 then
            return {
                repetitions = 1
            }
        end
        if context.end_of_round and G.GAME.current_round.hands_left == 0 then
            card:start_dissolve()
        end
    end
}

--toge
SMODS.Joker {
    key = 'toge',
    rarity = 1,
    blueprint_compat = true,
    loc_txt = { name = 'Toge Inumaki',
        text = { 'If hand contains {C:attention}2{} or more cards',
            '{C:mult}+Mult{} equal to value of leftmost card',
            'and {C:chips}+Chips{} equal to {C:white,X:chips}X5{} of rightmost card',
            '{s:0.8}"Stop breathing!"' } },
    config = { extra = { mult = 0, chips = 0 } },
    calculate = function(self, card, context)
        if context.joker_main then
            if #G.play.cards > 1 then
                return {
                    mult = G.play.cards[1].base.nominal,
                    chips = (G.play.cards[#G.play.cards].base.nominal * 5)
                }
            end
        end
    end
}

--finger bearer
SMODS.Joker {
    key = 'fb',
    rarity = 1,
    cost = 5,
    loc_txt = { name = 'Finger Bearer',
        text = { 'Gain one of {C:red}Sukunas Fingers{} upon',
            '{C:attention}defeating{} the boss blind',
            '{s:0.8}(X#1# boss blind size)' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_jjok_sukfin
        return { vars = { center.ability.extra.Xblind } }
    end,
    config = { extra = { Xblind = 3, trig = false } },
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss == true then
            G.GAME.blind.chips = G.GAME.blind.chips * card.ability.extra.Xblind
            G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            SMODS.juice_up_blind()
            card.ability.extra.trig = true
        end
        if context.end_of_round and context.cardarea == G.jokers and card.ability.extra.trig == true then
            SMODS.add_card({ set = 'Tarot', area = G.consumeables, key = 'c_jjok_sukfin' })
            card:start_dissolve()
        end
    end
}