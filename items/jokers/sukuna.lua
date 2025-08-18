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