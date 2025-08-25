SMODS.Joker {
    key = 'tengen',
    rarity = 3,
    cost = 10,
    loc_txt = {
        name = 'Master Tengen',
        text = {
            'Create a {C:spectral}Spectral{} booster on',
            'entering the shop' } },
    calculate = function(self, card, context)
        if context.starting_shop then
            SMODS.add_booster_to_shop('p_spectral_normal_1')
        end
    end
}

SMODS.Joker {
    key = 'executor',
    atlas = 'exec',
    loc_txt = { name = 'The Executor',
        text = {
            'A crucible warrior from a',
            'shattered world, finish a blind',
            'within {C:red}1/10th{} requirement',
            'and gain {C:white,X:mult}X#1#{} Mult',
            '{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult)'
        } },
    rarity = 3,
    cost = 8,
    no_collection = true,
    blueprint_compat = true,
    config = { extra = { Xmult_gain = 1.5, Xmult = 1 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.Xmult_gain,
                center.ability.extra.Xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            if G.GAME.chips <= G.GAME.blind.chips * 1.1 then
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
                return {
                    message = 'Parried!', colour = G.C.MULT
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

SMODS.Atlas {
    key = 'exec',
    path = 'tac/Exec.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'toji',
    rarity = 3,
    atlas = 'retoji',
    heavenly = true,
    blueprint_compat = true,
    cost = 10,
    loc_txt = { name = 'Toji Fushiguro',
        text = { 
            {"When {C:attention}Blind{} is selected,",
            "{C:attention}destroy{} Joker to the {C:attention}right",
            "and permanently add {C:attention}1/10th",
            "its sell value to this {C:white,X:mult}XMult",
            "{C:inactive}(Currently {C:white,X:mult}X#1#{C:inactive} Mult)"},
            {
                'When {C:attention}Blind{} is selected,',
                'create {C:attention}1 {C:dark_edition}negative',
                'Fly-Head for every',
                '{C:attention}non-negative{} Fly-Head'
            }
         } },
    config = { extra = { Xmult = 1 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { Xmult = card.ability.extra.Xmult }
        end
        if context.setting_blind and not context.blueprint then
            for i,v in ipairs(G.jokers.cards) do
                if v == card and G.jokers.cards[i + 1] and not G.jokers.cards[i + 1].ability.eternal then
                    local next = G.jokers.cards[i + 1]
                    card.ability.extra.Xmult = card.ability.extra.Xmult + (next.sell_cost / 10)
                    card:juice_up(0.8, 0.8)
                    next:start_dissolve({HEX("57ecab")}, nil, 1.6)
                    play_sound('slice1', 0.96+math.random()*0.08)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'X'..card.ability.extra.Xmult..' Mult',
                        colour = G.C.FILTER, no_juice = true})
                end
            end
        end
        if context.setting_blind then
            local areas = SMODS.get_card_areas('jokers')
            for _,a in ipairs(areas) do
                for i,v in ipairs(a.cards) do
                    if v.config.center.key == 'j_jjok_flyhead' and (not v.edition or not v.edition.negative) then
                        SMODS.add_card({key = 'j_jjok_flyhead', edition = 'e_negative'})
                    end
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'retoji',
    path = 'fey/retoji.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'uruame',
    loc_txt = { name = 'Uruame',
        text = { 'Fulfill {C:attention}conditions{} for {C:attention}rewards',
            '{C:inactive,s:0.8}(Changes after each round)' } },
    rarity = 3,
    cost = 12,
    config = { extra = { cur = 1 } },
    loc_vars = function(self, info_queue, center)
        local main_end = {}
        if center.ability.extra.cur == 1 then
            main_end = {
                {
                    n = G.UIT.R,
                    config = { aling = 'cm', padding = 0.05 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'Sell a ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = 'Special Grade', scale = 0.32, colour = G.ARGS.LOC_COLOURS.jjok_special } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'to create ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = '5 ', scale = 0.32, colour = G.C.FILTER } },
                                { n = G.UIT.T, config = { text = 'Rare', scale = 0.32, colour = G.C.RARITY.Rare } },
                                { n = G.UIT.T, config = { text = ' Jokers', scale = 0.32, colour = G.C.UI.TEXT_DARK } }
                            }
                        }
                    }
                }
            }
        elseif center.ability.extra.cur == 2 then
            info_queue[#info_queue + 1] = G.P_CENTERS.c_jjok_awaken
            main_end = {
                {
                    n = G.UIT.R,
                    config = { aling = 'cm', padding = 0.05 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'One-shot', scale = 0.32, colour = G.C.FILTER } },
                                { n = G.UIT.T, config = { text = ' the ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = 'Boss', scale = 0.32, colour = G.C.FILTER } },
                                { n = G.UIT.T, config = { text = ' blind', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'to create an ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = 'Awaken', scale = 0.32, colour = G.C.SECONDARY_SET.Spectral } },
                                { n = G.UIT.T, config = { text = ' card', scale = 0.32, colour = G.C.UI.TEXT_DARK } }
                            }
                        }
                    }
                }
            }
        elseif center.ability.extra.cur == 3 then
            info_queue[#info_queue + 1] = G.P_CENTERS.c_ankh
            main_end = {
                {
                    n = G.UIT.R,
                    config = { aling = 'cm', padding = 0.05 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'Use an ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = 'Ankh', scale = 0.32, colour = G.C.SECONDARY_SET.Spectral } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'to add ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = '+1', scale = 0.32, colour = G.C.DARK_EDITION } },
                                { n = G.UIT.T, config = { text = ' Joker slot', scale = 0.32, colour = G.C.UI.TEXT_DARK } }
                            }
                        }
                    }
                }
            }
        elseif center.ability.extra.cur == 4 then
            info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_womb
            main_end = {
                {
                    n = G.UIT.R,
                    config = { aling = 'cm', padding = 0.05 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'Sell', scale = 0.32, colour = G.C.FILTER } },
                                { n = G.UIT.T, config = { text = ' this card', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'to create a ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = 'Cursed Womb', scale = 0.32, colour = G.C.RARITY.Uncommon } },
                            }
                        }
                    }
                }
            }
        elseif center.ability.extra.cur == 5 then
            main_end = {
                {
                    n = G.UIT.R,
                    config = { aling = 'cm', padding = 0.05 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'Skip', scale = 0.32, colour = G.C.FILTER } },
                                { n = G.UIT.T, config = { text = ' a blind', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'to gain ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = '$1/2', scale = 0.32, colour = G.C.MONEY } },
                                { n = G.UIT.T, config = { text = ' of current ', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = 'Dollars', scale = 0.32, colour = G.C.MONEY } }
                            }
                        }
                    }
                }
            }
        end
        return { main_end = main_end }
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.cur = pseudorandom('uruame', 1, 5)
        end
        if card.ability.extra.cur == 1 then
            if context.selling_card then
                if context.card.config.center.rarity == 'jjok_special' then
                    for i = 1, 5 do
                        SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 3 })
                    end
                end
            end
        elseif card.ability.extra.cur == 2 then
            if JJOK.one_shot_blind(context) == true and G.GAME.blind.boss == true then
                SMODS.add_card({ key = 'c_jjok_awaken' })
            end
        elseif card.ability.extra.cur == 3 then
            if context.using_consumeable then
                if context.consumeable.config.center.key == 'c_ankh' then
                    G.jokers.config.card_limit = G.jokers.config.card_limit + 1
                end
            end
        elseif card.ability.extra.cur == 4 then
            if context.selling_self then
                SMODS.add_card({ key = 'j_jjok_womb' })
            end
        elseif card.ability.extra.cur == 5 then
            if context.skip_blind then
                ease_dollars(math.floor((G.GAME.dollars / 2) + 0.5))
            end
        end
    end
}

SMODS.Joker {
    key = 'higu',
    atlas = 'higu',
    loc_txt = { name = 'Hiromi Higuruma',
        text = { 'Create a {C:attention}Death{} {C:tarot}tarot',
            'on {C:attention}selecting{} a Blind',
            '{s:0.8,C:inactive}(Must have room)' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_death
    end,
    rarity = 3,
    cost = 8,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.setting_blind then
            if #G.consumeables.cards < G.consumeables.config.card_limit then
                SMODS.add_card({ key = 'c_death' })
            end
        end
    end
}

SMODS.Atlas {
    key = 'higu',
    path = 'fey/thegoat.png',
    px = 71,
    py = 95
}


SMODS.Joker {
    key = 'yuji',
    rarity = 3,
    cost = 7,
    blueprint_compat = true,
    loc_txt = { name = 'Yuji Itadori',
        text = { 
            '{C:green}#2# in #3#{} chance for',
            '{C:mult}Mult{} cards to give',
            '{C:white,X:mult}X#1#{} Mult when scored,'
        } },
    config = { extra = { Xmult = 2.5, odds = 2 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
        return {
            vars = {
                center.ability.extra.Xmult,
                G.GAME.probabilities.normal,
                center.ability.extra.odds }
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and
        SMODS.pseudorandom_probability(card, 'yuji', G.GAME.probabilities.normal or 1, card.ability.extra.odds) and
        SMODS.has_enhancement(context.other_card, 'm_mult') then
            return {
                Xmult = card.ability.extra.Xmult,
                colour = G.C.MULT,
                card = context.other_card
            }
        end
    end
}

SMODS.Joker {
    key = 'juzo',
    rarity = 3,
    atlas = 'juzo',
    cost = 8,
    discovered = true,
    loc_txt = { name = 'Juzo Kumiya',
        text = {
            '{C:white,X:chips}X#1#{} Chips per {C:jjok_ctools}Cursed',
            '{C:jjok_ctools}Tool{} used this run',
            '{C:inactive}(Currently {C:white,X:chips}X#2#{C:inactive} Chips)'
        } },
    config = { extra = { Xchips_mod = 0.25 } },
    loc_vars = function(self, info_queue, center)
        local _xchips = 1
        if G.GAME.consumeable_usage_total then
            _xchips = 1 + ((G.GAME.consumeable_usage_total.ctools or 0) * center.ability.extra.Xchips_mod)
        end
        return {
            vars = {
                center.ability.extra.Xchips_mod,
                _xchips
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.ctools then
                return {
                    xchips = ((G.GAME.consumeable_usage_total.ctools or 0) * card.ability.extra.Xchips_mod) + 1
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'juzo',
    path = 'fey/jizz.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'hanami',
    cost = 8,
    rarity = 3,
    blueprint_compat = false,
    loc_txt = { name = 'Hanami',
        text = {
            'The nature disaster curse,',
            'add a {C:jjok_nature}Green Seal{} to leftmost',
            'played card'
        } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_SEALS.jjok_green
    end,
    calculate = function(self, card, context)
        if context.before then
            G.play.cards[1]:set_seal('jjok_green', nil, true)
        end
    end
}

SMODS.Joker {
    key = 'jogoat',
    rarity = 3,
    cost = 10,
    blueprint_compat = true,
    loc_txt = {
        name = 'Jogo',
        text = {
            '{C:attention}Immolate{} a consumable on leaving the',
            'shop in exchange for its {C:money}sell value{}',
            'and {C:money}1/5th{} its {C:money}sell value{} as {C:white,X:mult}XMult',
            '{C:inactive}(Currently: {C:white,X:mult}X#2#{C:inactive} Mult)'
        } },
    config = { extra = {
        Xmult = 1,
    } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.num,
                center.ability.extra.Xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.ending_shop and #G.consumeables.cards > 0 and not context.blueprint then
            local _card = pseudorandom('jogoat', 1, #G.consumeables.cards)
            local sv = (G.consumeables.cards[_card].sell_cost / 5)
            card.ability.extra.Xmult = card.ability.extra.Xmult + sv
            card.sell_cost = card.sell_cost + sv * 5
            G.consumeables.cards[_card]:valid_destroy()
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { sv } }
            }
        end
        if context.joker_main or (context.joker_main and context.blueprint) then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'mecha',
    rarity = 3,
    cost = 10,
    loc_txt = { name = 'Mechamaru',
        text = { 'Sell to create #1# {C:attention}Puppets',
            'Increase by #2# at the {C:attention}end{} of a round' } },
    config = { extra = { create = 0, increase = 1 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_jjok_puppet
        return {
            vars = {
                center.ability.extra.create,
                center.ability.extra.increase
            }
        }
    end,
    remove_from_deck = function(self, card)
        for i = 1, card.ability.extra.create do
            SMODS.add_card({ set = 'Spectral', area = G.consumeables, key = 'c_jjok_puppet' })
        end
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            card.ability.extra.create = card.ability.extra.create + card.ability.extra.increase
        end
    end
}

SMODS.Joker {
    key = 'ino',
    rarity = 3,
    cost = 10,
    loc_txt = { name = 'Takuma Ino',
        text = { '{C:attention}Cycles{} through {C:attention}3{} effects,',
            '{C:attention}scales{} after each effect',
            '{s:0.8,C:inactive}(Changes each round)', } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local main_end, c1, c2, c3, m1, m2 = {}, {}, {}, {}, nil, nil
        c1 = {
            {
                n = G.UIT.R,
                config = { align = 'cm' },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { colour = G.C.MULT, r = 0.05, res = 0.15, padding = 0.03, align = 'cm' },
                        nodes = {
                            { n = G.UIT.T, config = { text = 'X' .. (card.ability.extra.cycles * card.ability.extra.scaling.Xmult) + 1, scale = 0.32, colour = G.C.UI.TEXT_LIGHT } }
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = 'cm', padding = 0.03 },
                        nodes = {
                            { n = G.UIT.T, config = { text = ' Mult', scale = 0.32, colour = G.C.UI.TEXT_DARK } }
                        }
                    },
                }
            }
        }
        c2 = {
            {
                n = G.UIT.R,
                config = { align = 'cm' },
                nodes = {
                    { n = G.UIT.T, config = { text = '+' .. (card.ability.extra.cycles * card.ability.extra.scaling.chips), scale = 0.32, colour = G.C.CHIPS } },
                    { n = G.UIT.T, config = { text = ' Chips', scale = 0.32, colour = G.C.UI.TEXT_DARK } },
                }
            }
        }
        c3 = {
            {
                n = G.UIT.R,
                config = { padding = 0.05, align = 'cm' },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = 'cm' },
                        nodes = {
                            { n = G.UIT.T, config = { text = '$' .. (card.ability.extra.cycles * card.ability.extra.scaling.dollars), scale = 0.32, colour = G.C.MONEY } },
                            { n = G.UIT.T, config = { text = ' at the end', scale = 0.32, colour = G.C.UI.TEXT_DARK } }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = 'cm' },
                        nodes = {
                            { n = G.UIT.T, config = { text = 'of the round', scale = 0.32, colour = G.C.UI.TEXT_DARK } }
                        }
                    },
                }
            }
        }
        if card.ability.extra.st == 1 then
            m1 = c1
            m2 = c2
        elseif card.ability.extra.st == 2 then
            m1 = c2
            m2 = c3
        elseif card.ability.extra.st == 3 then
            m1 = c3
            m2 = c1
        end
        main_end = {
            {
                n = G.UIT.R,
                config = {},
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { padding = 0.03, align = 'cm' },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = 'cm', padding = 0.08 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = 'tm' },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = ' (Currently) ', scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } }
                                        }
                                    },

                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = 'cm', padding = 0.08 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = 'tm' },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = ' (Next) ', scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } }
                                        }
                                    },

                                }
                            }
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { padding = 0.03, align = 'cm' },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = 'cm', padding = 0.08 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = 'cm' },
                                        nodes = m1
                                    }

                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = 'cm', padding = 0.08 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = 'cm' },
                                        nodes = m2
                                    }

                                }
                            }
                        }
                    }
                }
            } }

        return { main_end = main_end }
    end,
    config = { extra = { cycles = 1, emp = false, st = 1, scaling = {
        Xmult = 0.5, chips = 50, dollars = 5
    } } },
    calculate = function(self, card, context)
        if context.setting_blind then
            card.ability.extra.cycles = card.ability.extra.cycles + 1
            if card.ability.extra.emp then
                card.ability.extra.cycles = card.ability.extra.cycles + 4
            end
            if card.ability.extra.st == 3 then
                card.ability.extra.st = 1
            else
                card.ability.extra.st = card.ability.extra.st + 1
            end
        end
        if context.joker_main then
            if card.ability.extra.st == 1 then
                return {
                    Xmult = (card.ability.extra.cycles * card.ability.extra.scaling.Xmult) + 1
                }
            elseif card.ability.extra.st == 2 then
                return {
                    chips = card.ability.extra.cycles * card.ability.extra.scaling.chips
                }
            end
        end
    end,
    calc_dollar_bonus = function(self, card)
        if card.ability.extra.st == 3 then
            local money = (card.ability.extra.cycles * card.ability.extra.scaling.dollars)
            return money
        end
    end
}