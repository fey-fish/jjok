SMODS.Joker {
    key = 'kenny',
    atlas = 'kenjaku',
    loc_txt = { name = '{C:tarot}Kenjaku',
        text = {
            'In Getos dead body, Kenjaku',
            'can use his {C:attention}body hop technique',
            'to store {C:attention}#1#{} Jokers within his card area',
            '{C:inactive,s:0.8}(Increase by {C:dark_edition,s:0.8}#2#{C:inactive,s:0.8} on defeating the Ante)'
        } },
    loc_vars = function(self, info_queue, center)
        if G[center.ability.extra.name] then
            center.ability.extra.card_limit = G[center.ability.extra.name].config.card_limit
        end
        return {
            vars = {
                center.ability.extra.card_limit,
                center.ability.extra.increase
            }
        }
    end,
    rarity = 'jjok_special',
    cost = 40,
    add_to_deck = function(self, card)
        local ca = CardArea(0, 0, G.CARD_W * 1.2, G.CARD_H, {
            card_limit = card.ability.extra.card_limit,
            type = "joker",
            highlight_limit = 1,
            view_deck = true
        })
        local find = SMODS.find_card('j_jjok_kenny')
        local counter = #find
        JJOK.create_cardarea(ca, 'kenjaku', counter)
        card.ability.extra.name = 'kenjaku' .. tostring(counter)
        table.insert(G.GAME.loading_card_areas, card.ability.extra.name)
    end,
    config = { extra = { card_limit = 2, increase = 1, name = nil,
        button = {ftext = 'BODY', ttext = 'HOP', button = 'jjok_kenny_use', func = 'jjok_kenny_can'} } },
    remove_from_deck = function(self, card, from_debuff)
        for i,v in ipairs(G.GAME.loading_card_areas) do
            if v == card.ability.extra.name then
                table.remove(G.GAME.loading_card_areas, i)
                break
            end
        end
        G[card.ability.extra.name]:remove()
    end,
    calculate = function(self, card, context)
        if context.boss_defeat then
            G[card.ability.extra.name].config.card_limit = G[card.ability.extra.name].config.card_limit + card.ability.extra.increase
        end
    end,
    update = function(self, card, dt)
        if G.jokers and G.jokers.highlighted[1] then
            if G.jokers.highlighted[1].config.center.key == 'j_jjok_kenny' then
                G.jokers.config.highlighted_limit = 2
            else
                G.jokers.config.highlighted_limit = 1
            end
        end
        if G[card.ability.extra.name] then
            --change position to match parent
            G[card.ability.extra.name].T.x = card.T.x - 0.2
            G[card.ability.extra.name].T.y = card.T.y + card.T.h
        end
    end
}

SMODS.Atlas {
    key = 'kenjaku',
    path = 'tac/Kenjaku.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'mahito',
    rarity = 'jjok_special',
    atlas = 'mahito',
    cost = 40,
    loc_txt = { name = 'Mahito',
        text = { 'Hand size cannot change',
            '{s:0.8}"I truly am a curse!"' } },
    config = { extra = { hand_size = nil } },
    add_to_deck = function(self, card)
        card.ability.extra.hand_size = G.hand.config.card_limit
    end,
    calculate = function(self, card, context)
        if G.hand.config.card_limit ~= card.ability.extra.hand_size then
            G.hand.config.card_limit = card.ability.extra.hand_size
        end
    end,
    update = function(self, card, dt)
        if Jjok.config.majito then
            card.children.center.atlas = G.ASSET_ATLAS['jjok_majito']
        else
            card.children.center.atlas = G.ASSET_ATLAS['jjok_mahito']
        end
    end
}

SMODS.Atlas {
    key = 'mahito',
    path = 'tac/mahito.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'majito',
    path = 'tac/majito.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'yuki',
    atlas = 'yuki',
    loc_txt = { name = 'Yuki Tsukumo',
        text = {
            'On shattering a {C:attention}Glass{} card',
            'create a {C:dark_edition}negative{C:spectral} Black Hole,',
            '{C:white,X:chips}X#1#{} Chips for every held {C:spectral}Black Hole',
            '{C:inactive,s:0.8}({C:attention,s:0.8}Glass{C:inactive,s:0.8} cards are {C:green,s:0.8}guaranteed{C:inactive,s:0.8} to shatter)',
            '{s:0.8}"What kinda women do you go for?"'
        } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.c_black_hole
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
        return {
            vars = {
                center.ability.extra.xchips
            }
        }
    end,
    config = { extra = { xchips = 2.5 } },
    cost = 40,
    discovered = true,
    blueprint_compat = true,
    rarity = 'jjok_special',
    calculate = function(self, card, context)
        if context.glass_shattered then
            SMODS.add_card({ key = 'c_black_hole', edition = 'e_negative' })
        end
        if context.other_consumeable and context.other_consumeable.config.center.key == 'c_black_hole' then
            return {
                xchips = card.ability.extra.xchips,
                message_card = context.other_consumeable
            }
        end
    end
}

SMODS.Atlas {
    key = 'yuki',
    path = 'tac/yuki.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'hak',
    atlas = 'hakari',
    rarity = 'jjok_special',
    cost = 40,
    loc_txt = { name = '{C:dark_edition}Hakari Kinji',
        text = { '{C:attention}Lucky{} cards become {C:green}guaranteed{} to trigger',
            '{s:0.8}"The restless gambler"' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
    end
}

SMODS.Atlas {
    key = 'hakari',
    path = 'tac/hakari.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'cgeto',
    loc_txt = { name = '{C:spades}Suguru Geto',
        text = { 'On selecting a blind, fill all card',
            'slots with random cards',
            '{s:0.8}"The worst curse user in history"' } },
    rarity = 'jjok_special',
    cost = 40,
    calculate = function(self, card, context)
        if context.setting_blind then
            local areas = SMODS.get_card_areas('jokers')
            for i, v in ipairs(areas) do
                if v.config.card_limit and v.config.type == 'joker' then
                    local space = v.config.card_limit - v.config.card_count or #v.cards
                    if space > 0 then
                        repeat
                            local pool = {}
                            for _, m in pairs(G.P_CENTERS) do
                                if m.ability.consumeable or m.ability.set == 'Joker' then
                                    table.insert(pool, m)
                                end
                            end
                            local _card = pseudorandom_element(pool, pseudoseed('cgeto'))
                            SMODS.add_card({ key = _card.key })
                            space = v.config.card_limit - v.config.card_count or #v.cards
                        until space <= 0
                    end
                end
            end
        end
    end

}

SMODS.Joker {
    key = 'naoya',
    loc_txt = { name = "Naoya Zen'in",
        text = {
            '{C:white,X:mult}XMult{} = {C:white,X:dark_edition}Ante ^ 2{} - ',
            '{C:inactive,s:0.8}(Time in Small Blind + Big Blind x (Round/100))' } },
    loc_vars = function(self, info_queue, center)
        local main_end = {
            {
                n = G.UIT.R,
                config = { align = 'cm' },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = 'cm' },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = 'Time = ',
                                    colour = G.C.UI.TEXT_DARK,
                                    scale = 0.32,
                                }
                            },

                            {
                                n = G.UIT.T,
                                config = {
                                    ref_table = G.TIMERS,
                                    ref_value = "n_round",
                                    colour = G.C.FILTER,
                                    scale = 0.32,
                                }
                            } }
                    },

                    {
                        n = G.UIT.R,
                        config = { align = 'cm', padding = 0.03 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = 'cm' },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = '(Currently ',
                                            colour = G.C.UI.TEXT_INACTIVE,
                                            scale = 0.32,
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = 'X',
                                            colour = G.C.WHITE,
                                            scale = 0.32,
                                        }
                                    },
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            ref_table = G.GAME,
                                            ref_value = 'naoya_mult',
                                            colour = G.C.WHITE,
                                            scale = 0.32,
                                        }
                                    }
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = 'cm' },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = ' Mult)',
                                            colour = G.C.UI.TEXT_INACTIVE,
                                            scale = 0.32,
                                        }
                                    }
                                }
                            },
                        }
                    }
                }
            }

        }
        return {
            main_end = main_end
        }
    end,
    config = { extra = { Xmult = 1 } },
    rarity = 'jjok_special',
    cost = 40,
    atlas = 'naoya',
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = G.GAME.naoya_mult
            }
        end
    end
}

SMODS.Atlas {
    key = 'naoya',
    path = 'tac/nom_nom.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'tgojo',
    atlas = 'tgojo',
    loc_txt = {
        name = '{C:chips}Satoru {C:mult}Gojo',
        text = {
            'Using the six eyes and limitless',
            'techniques, {C:attention}doubles{} hand size',
            '{s:0.8}"Aside from Satoru Gojo, of course"{}'
        }

    },
    blueprint_compat = false,
    rarity = 'jjok_special',
    cost = 40,
    add_to_deck = function(self, card, context)
        G.hand:change_size(G.hand.config.card_limit)
    end,
    remove_from_deck = function(self, card, context)
        G.hand:change_size(-(G.hand.config.card_limit / 2))
    end
}

SMODS.Atlas {
    key = 'tgojo',
    path = 'tac/Teacher_Gojo.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'yuta',
    atlas = 'yuta',
    loc_txt = {
        name = '{C:purple}Yuta Okkotsu',
        text = {
            'Rika {C:attention}retriggers Jokers{} to',
            'the {C:blue}left{} and {C:red}right',
            '#1# times',
            '{s:0.8}"The cursed child..."{}'
        }
    },
    rarity = "jjok_special",
    cost = 40,
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.retriggers } }
    end,
    blueprint_compat = false,
    config = { extra = { retriggers = 2 } },
    discovered = true,
    calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker and not context.other_card == card then
            local ind = 1
            for i, v in ipairs(G.jokers.cards) do
                if v == card then
                    ind = i
                end
            end
            local right_joker = G.jokers.cards[ind + 1]
            local left_joker = G.jokers.cards[ind - 1]
            if (context.other_card == right_joker or context.other_card == left_joker) then
                return {
                    message = 'Copied!',
                    repetitions = card.ability.extra.retriggers,
                    card = card
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'yuta',
    path = 'tac/futa.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'sukuna',
    cost = 40,
    atlas = 'yujikuna',
    hidden = true,
    rarity = 'jjok_special',
    loc_txt = { name = '{V:1}#1#',
        text = {} },
    config = { extra = { phase = 1, fingers = 1, mult = 20, Xmult = 1, dollars = 10 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_sukfin
        local name, colours = nil, {}
        local main_end = {}
        if center.ability.extra.phase == 1 or not center.ability.extra.phase then
            name = 'Yuji-Kuna'
            colours = { G.C.WHITE }
            main_end = {
                {
                    n = G.UIT.C,
                    config = { padding = 0.03 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = {},
                            nodes = {
                                { n = G.UIT.T, config = { text = 'The first vessel of the King', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } } }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm', padding = 0.03 },
                            nodes = {
                                { n = G.UIT.T, config = { text = '+20', scale = 0.28, colour = G.C.MULT } },
                                { n = G.UIT.T, config = { text = (' Mult for every finger'), scale = 0.28, colour = G.C.UI.TEXT_DARK } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = '(Currently ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } },
                                { n = G.UIT.T, config = { text = ('+' .. center.ability.extra.fingers * 20), scale = 0.32, colour = G.C.MULT } },
                                { n = G.UIT.T, config = { text = ' Mult)', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } },
                            }
                        },
                    }
                }
            }
        elseif center.ability.extra.phase == 2 then
            name = 'Meg-una'
            colours = { G.C.RED }
            main_end = {
                {
                    n = G.UIT.C,
                    config = { padding = 0.03 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = {},
                            nodes = {
                                { n = G.UIT.T, config = { text = "This mug's more handsome", scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } } }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = 'X0.75', scale = 0.28, colour = G.C.WHITE } },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = (' Mult for every finger'), scale = 0.28, colour = G.C.UI.TEXT_DARK } }
                                    }
                                },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = '(Currently ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } }
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = ('X' .. ((center.ability.extra.fingers * 0.75) + 1)), scale = 0.32, colour = G.C.WHITE } },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = (' Mult)'), scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } }
                                    }
                                },
                            }
                        }
                    }
                }
            }
        elseif center.ability.extra.phase == 3 then
            name = 'True-Form Sukuna'
            colours = { G.C.BLACK }
            main_end = {
                {
                    n = G.UIT.C,
                    config = { padding = 0.03 },
                    nodes = {
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                { n = G.UIT.T, config = { text = "The King of Curses", scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } } }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = 'X2.5', scale = 0.28, colour = G.C.WHITE } },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = (' Mult for every finger'), scale = 0.28, colour = G.C.UI.TEXT_DARK } }
                                    }
                                },
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm', padding = 0.03 },
                            nodes = {
                                { n = G.UIT.T, config = { text = 'and ', scale = 0.28, colour = G.C.UI.TEXT_DARK } },
                                { n = G.UIT.T, config = { text = '$10', scale = 0.28, colour = G.C.MONEY } },
                                { n = G.UIT.T, config = { text = ' when scored', scale = 0.28, colour = G.C.UI.TEXT_DARK } }
                            }
                        },
                        {
                            n = G.UIT.R,
                            config = { align = 'cm' },
                            nodes = {
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = '(Currently ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } }
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = ('X' .. (center.ability.extra.fingers * 2.5)), scale = 0.32, colour = G.C.WHITE } },
                                    }
                                },
                                {
                                    n = G.UIT.C,
                                    config = { padding = 0.03 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = (' Mult)'), scale = 0.32, colour = G.C.UI.TEXT_INACTIVE } }
                                    }
                                },
                            }
                        }
                    }
                }
            }
        end
        return {
            vars = { name, colours = colours },
            main_end = main_end
        }
    end,
    update = function(self, card, context)
        if card.ability.extra.phase == 1 then
            card.children.center.atlas = G.ASSET_ATLAS['jjok_yujikuna']
        end
    end,
    calculate = function(self, card, context)
        if card.ability.extra.phase == 1 then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].config.center.key == 'j_jjok_meg' then
                    G.jokers.cards[i]:valid_destroy(true)
                    card.ability.extra.phase = 2
                end
            end
        end
        if card.ability.extra.fingers == 20 then
            card.ability.extra.phase = 3
        end
        if context.joker_main then
            card.ability.extra.mult = card.ability.extra.fingers * 20
            if card.ability.extra.phase == 2 then
                card.ability.extra.Xmult = (card.ability.extra.fingers * 0.75) + 1
            end
            if card.ability.extra.phase == 3 then
                card.ability.extra.Xmult = (card.ability.extra.fingers * 2.5)
            end
            if card.ability.extra.phase == 1 then
                return {
                    mult = card.ability.extra.mult,
                }
            end
            if card.ability.extra.phase == 2 then
                return { Xmult = card.ability.extra.Xmult }
            end
            if card.ability.extra.phase == 3 then
                return {
                    Xmult = card.ability.extra.Xmult,
                    dollars = card.ability.extra.dollars
                }
            end
        end
    end
}

SMODS.Atlas {
    key = 'yujikuna',
    path = 'tac/yujikuna.png',
    px = 71,
    py = 95
}
