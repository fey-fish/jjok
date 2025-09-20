SMODS.Joker {
    key = 'cwdagon',
    rarity = 2,
    cost = 7,
    loc_txt = { name = 'Curse Womb Dagon',
        text = { 'The disaster curse in his',
            'curse womb form before his pseduo-',
            'evolution, {C:attention}create{} a {C:dark_edition}negative',
            '{C:attention}Splash{} on {C:attention}selecting{} a blind',
            '{s:0.8,C:inactive}(If holding {C:attention,s:0.8}5{C:inactive,s:0.8} or more {C:dark_edition,s:0.8}negative {C:attention,s:0.8}Splashes',
            '{s:0.8,C:inactive}whilst selling, create {C:attention,s:0.8}Dagon{s:0.8,C:inactive})' } },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_dagon
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            SMODS.add_card({ key = 'j_splash', edition = 'e_negative' })
        end
        if context.selling_self and not context.blueprint then
            local tally = 0
            for i, v in ipairs(G.jokers.cards) do
                if v.config.center.key == 'j_splash' and v.edition and v.edition.negative then
                    tally = tally + 1
                end
            end
            if tally >= 5 then
                SMODS.add_card({ key = 'j_jjok_dagon' })
            end
        end
    end
}

SMODS.Joker {
    key = 'utahime',
    rarity = 2,
    cost = 9,
    loc_txt = { name = 'Utahime Iori',
        text = { 'On selecting a {C:attention}boss blind,',
            'remove all {C:attention}stickers',
            'from Joker to the right', } },
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss == true then
            local ind, area
            local areas = SMODS.get_card_areas('jokers')
            for _, m in ipairs(areas) do
                for i, v in ipairs(m.cards) do
                    if v == card then
                        ind = i + 1
                        area = m
                    end
                end
            end
            if #m.cards >= ind then
                for i, k in pairs(SMODS.Stickers) do
                    m[ind].ability[i] = false
                end
                card:juice_up()
            end
        end
    end
}

SMODS.Joker {
    key = 'shoko',
    atlas = 'shoko',
    loc_txt = { name = 'Shoko Ieiri',
        text = { 'Increase domain slots by {C:dark_edition}#1#{}',
            '{s:0.8}"I was worried about you!"' } },
    rarity = 2,
    cost = 5,
    config = { extra = { slots = 1 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.slots } }
    end,
    in_pool = function(self, args)
        if G.GAME.round_resets.ante >= 4 then
            return true
        end
    end,
    add_to_deck = function(self, card)
        G.domain.config.card_limit = G.domain.config.card_limit + card.ability.extra.slots
    end,
    remove_from_deck = function(self, card)
        G.domain.config.card_limit = G.domain.config.card_limit - card.ability.extra.slots
    end
}

SMODS.Atlas {
    key = 'shoko',
    path = 'fey/depression.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'womb',
    rarity = 2,
    cost = 10,
    loc_txt = { name = 'Cursed Womb',
        text = { '{C:attention}Sell{} to create a new {C;attention}joker',
            'for every {C:attention}#1# rounds held{} increase new',
            'jokers rarity (up to {C:legendary}Legendary{})',
            '{s:0.8,C:inactive}(Currently #2#, held for #3# rounds)' } },
    config = { extra = { scale = 2, sellrar = 0.69, heldfor = 0, rartxt = 'Common', leg = false } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.scale, center.ability.extra.rartxt, center.ability.extra.heldfor } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.heldfor = card.ability.extra.heldfor + 1
            if card.ability.extra.heldfor <= 1 then
                card.ability.extra.sellrar = 0.69
                card.ability.extra.rartxt = 'Common'
            end
            if card.ability.extra.heldfor == 2 or card.ability.extra.heldfor == 3 then
                card.ability.extra.sellrar = 0.71
                card.ability.extra.rartxt = 'Uncommon'
            end
            if card.ability.extra.heldfor == 4 or card.ability.extra.heldfor == 5 then
                card.ability.extra.sellrar = 1
                card.ability.extra.rartxt = 'Rare'
            end
            if card.ability.extra.heldfor > 5 then
                card.ability.extra.sellrar = 0
                card.ability.extra.leg = true
                card.ability.extra.rartxt = 'Legendary'
            end
            local eval = function(card)
                return (card.ability.extra.rartxt == 'Legendary')
            end
            juice_card_until(card, eval, true)
            return {
                message = (card.ability.extra.rartxt .. '! ' .. card.ability.extra.heldfor),
                colour = G.C.FILTER
            }
        end
        if context.selling_self then
            SMODS.add_card({ set = 'Joker', rarity = card.ability.extra.sellrar, legendary = card.ability.extra.leg })
        end
    end
}

SMODS.Joker {
    key = 'ygeto',
    atlas = 'ygeto',
    cost = 6,
    loc_txt = { name = 'Young Geto',
        text = { '{C:white,X:mult}X#1#{} Mult for each',
            'unique {C:attention}Joker rarity{} held',
            '{C:inactive}(Currently {C:white,X:mult}X#2#{C:inactive} Mult)' } },
    rarity = 2,
    blueprint_compat = true,
    config = { extra = { Xmult = 0.5 } },
    loc_vars = function(self, info_queue, center)
        local rars, count = {}, 0
        local areas = SMODS.get_card_areas('jokers')
        for l, n in ipairs(areas) do
            for i, v in ipairs(n.cards) do
                if v.config.center.set == 'Joker' then
                    local unique = true
                    for k, m in ipairs(rars) do
                        if v.config.center.rarity == m then
                            unique = false
                        end
                    end
                    if unique == true then
                        table.insert(rars, v.config.center.rarity)
                        count = count + center.ability.extra.Xmult
                    end
                end
            end
        end
        return {
            vars = {
                center.ability.extra.Xmult,
                count + 1
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local rars, count = {}, 0
            local areas = SMODS.get_card_areas('jokers')
            for l, n in ipairs(areas) do
                for i, v in ipairs(n.cards) do
                    if v.config.center.set == 'Joker' then
                        local unique = true
                        for k, m in ipairs(rars) do
                            if v.config.center.rarity == m then
                                unique = false
                            end
                        end
                        if unique == true then
                            table.insert(rars, v.config.center.rarity)
                            count = count + card.ability.extra.Xmult
                        end
                    end
                end
            end
            return { Xmult = count + 1 }
        end
    end
}

SMODS.Atlas {
    key = 'ygeto',
    path = 'fey/smallgaytoe.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'mai',
    atlas = 'bum',
    loc_txt = {
        name = 'Mai Zenin',
        text = { '{C:attention}Create{} a random {C:spectral}Spectral{}',
            'or {C:tarot}Tarot{} card upon ',
            '{C:attention}skipping or entering a blind{}',
            '{s:0.8}"Why wouldnt you stay at the bottom with me..."{}'
        } },
    blueprint_compat = true,
    eternal_compat = false,
    cost = 6,
    rarity = 2,
    calculate = function(self, card, context)
        if (context.skip_blind or context.setting_blind) and #G.consumeables.cards < G.consumeables.config.card_limit then
            local sort = pseudorandom("seed", 1, 10)
            if sort <= 5 then
                SMODS.add_card({ set = 'Tarot', area = G.consumeable })
            end
            if sort >= 6 and sort ~= 10 then
                SMODS.add_card({ set = 'Spectral', area = G.consumeable })
            end
            if not context.blueprint then
                if sort == 10 then
                    SMODS.add_card({ key = 'c_jjok_makitool', area = G.consumeable })
                    card:start_dissolve()
                end
            end
        end
    end
}

SMODS.Atlas {
    key = 'bum',
    path = 'fey/mai.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'kusa',
    rarity = 2,
    cost = 7,
    blueprint_compat = false,
    loc_txt = {
        name = 'Atsuya Kusakabe',
        text = {
            '{C:attention}Lose{} all but {C:blue}1{} hand,',
            '{C:attention}+#1#{} Hand Size',
            '{s:0.8}"Strongest sorceror in the immediate area"' } },
    config = { extra = { hand_size = 5, hands = 0 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.hand_size
            }
        }
    end,
    add_to_deck = function(self, card)
        card.ability.extra.hands = G.GAME.round_resets.hands
        G.GAME.round_resets.hands = 1
        G.hand:change_size(card.ability.extra.hand_size)
    end,
    remove_from_deck = function(self, card)
        G.GAME.round_resets.hands = card.ability.extra.hands
        G.hand:change_size(-card.ability.extra.hand_size)
    end
}

SMODS.Joker {
    key = 'nobara',
    cost = 6,
    blueprint_compat = true,
    rarity = 2,
    atlas = 'nobara',
    loc_txt = { name = 'Nobara Kugisaki',
        text = { '{C:chips}Resonated{} cards give',
            'an additonal {C:white,X:chips}X#1#{} Chips',
            'when scored' } },
    config = { extra = { Xchips = 1.5 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_jjok_resonated
        return {
            vars = {
                center.ability.extra.Xchips
            }
        }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, 'm_jjok_resonated') then
                return {
                    x_chips = card.ability.extra.Xchips
                }
            end
        end
    end,
    in_pool = function(self, args)
        if JJOK.find_enhance('m_jjok_resonated') == true then
            return true
        end
    end
}

SMODS.Atlas {
    key = 'nobara',
    path = 'tac/labubudubaichocomatcha.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'haibara',
    loc_txt = { name = 'Yu Haibara',
        text = {
            'Scoring {C:diamonds}Diamond{} and {C:spades}Spade',
            '{C:attention}face{} cards become {C:attention}Glass'
        } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
    end,
    cost = 7,
    rarity = 2,
    calculate = function(self, card, context)
        if context.before then
            for i, v in ipairs(context.scoring_hand) do
                if v:is_face() and (v:is_suit('Diamonds') or v:is_suit('Spades')) then
                    v:set_ability(G.P_CENTERS.m_glass)
                    v:juice_up()
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'panda',
    atlas = 'panda',
    loc_txt = { name = 'Panda',
        text = {
            'Gain {C:money}$#1#{} dollars when scoring',
            'an enhancment, {C:attention}destroy{} the enhancement',
            'and increase payout by {C:money}$#2#',
            "{C:inactive}(Reset if a scored card isn't enhanced)" } },
    config = { extra = { cur = 0, inc = 2 } },
    rarity = 2,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.cur,
                center.ability.extra.inc
            }
        }
    end,
    cost = 6,
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.play then
            for i, v in ipairs(context.scoring_hand) do
                if not v.debuff and not v.config.center == 'c_base' then
                    card.ability.extra.cur = card.ability.extra.cur + card.ability.extra.inc
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            v:set_ability()
                            return true
                        end
                    }))
                    return {
                        dollars = card.ability.extra.cur,
                    }
                else
                    card.ability.extra.cur = 0
                    return {
                        message = 'Core Destroyed!',
                        message_card = card,
                        colour = G.C.FILTER
                    }
                end
            end
        end
    end

}

SMODS.Atlas {
    key = 'panda',
    path = 'fey/panda.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'meg',
    cost = 12,
    rarity = 2,
    atlas = 'meg',
    blueprint_compat = true,
    loc_txt = { name = 'Megumi Fushiguro',
        text = { 'Upon selecting a {C:attention}boss blind,',
            '{C:attention}create 1{} a Ten Shadows',
            'shikigami' } },
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss == true then
            local _card = pseudorandom_element(G.P_CENTER_POOLS.s10, pseudoseed('megumi'))
            SMODS.add_card({ key = _card.key })
        end
    end
}

SMODS.Atlas {
    key = 'meg',
    path = 'fey/potentialman.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'ryu',
    loc_txt = { name = 'Ryu',
        text = {
            '{C:white,X:mult}X#1#{} Mult for',
            'every {C:attention}#2#{C:jjok_ctools} Cursed Energy',
            'possesed',
            '{C:inactive}(Currently {C:white,X:mult}X#3#{C:inactive} Mult)'
        } },
    config = { extra = { scale = 1, ce = 15 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = { center.ability.extra.scale, center.ability.extra.ce,
                G.GAME.cursed_energy and
                ((math.floor(G.GAME.cursed_energy / center.ability.extra.ce) + 1) * center.ability.extra.scale) > 1 and
                ((math.floor(G.GAME.cursed_energy / center.ability.extra.ce) + 1) * center.ability.extra.scale) or 1 }
        }
    end,
    rarity = 2,
    cost = 5,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            local Xmult = 1
            if ((math.floor(G.GAME.cursed_energy / card.ability.extra.ce) + 1) * card.ability.extra.scale) > 1 then
                Xmult = ((math.floor(G.GAME.cursed_energy / card.ability.extra.ce) + 1) * card.ability.extra.scale)
            end
            return {
                Xmult = Xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'kira',
    atlas = 'kirara',
    loc_txt = { name = 'Kirara',
        text = {
            'If a {C:attention}random{} Joker',
            'is to be selected,',
            'select only the {C:attention}first',
            'Joker instead'
        } },
    rarity = 2,
    cost = 10
}

local pse = pseudorandom_element
function pseudorandom_element(_t, seed, args)
    if SMODS.find_card('j_jjok_kira')[1] and G.jokers and _t == G.jokers.cards then
        return _t[1]
    end
    return pse(_t, seed, args)
end

SMODS.Atlas {
    key = 'kirara',
    path = 'fey/KIRA!!.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'mechamaru',
    rarity = 2,
    atlas = 'mecha',
    cost = 6,
    loc_txt = { name = 'Mechamaru',
        text = { 'Sell to create #1# {C:attention}Puppets,',
            'increase by #2# at the',
            '{C:attention}end{} of a round' } },
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

SMODS.Atlas {
    key = 'mecha',
    path = 'fey/kokichi.png',
    px = 71,
    py = 95
}
