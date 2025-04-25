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

--domains area

local cae = CardArea.emplace
function CardArea:Emplace(card, location, stay_flipped)
    G.jjok_domains:emplace(card, location, stay_flipped)
    return
        cae(self, card, location, stay_flipped)
end

--

SMODS.Rarity {
    key = 'shiki',
    loc_txt = {
        name = 'Shikigami'
    },
    badge_colour = HEX('16537E'),
    hidden = true
}

SMODS.Rarity {
    key = 'cs',
    loc_txt = { name = 'Cursed Spirit' },
    badge_colour = HEX('674EA7'),
    default_weight = 0.6
}

SMODS.Rarity {
    key = 'special',
    loc_txt = {
        name = 'Special Grade'
    },
    badge_colour = HEX('A64D79'),
    hidden = true
}

SMODS.Consumable {
    key = 'awaken',
    loc_txt = { name = 'Awakening',
        text = { 'Use to {C:attention}awaken{} any {C:Legendary}Grade 1',
            'sorceror to special grade' } },
    set = 'Spectral',
    hidden = true,
    soul_set = 'Spectral',
    atlas = 'atlastwo',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    soul_rate = 0.1,
    cost = 4,
    pools = { ['Spectral'] = true },
    can_use = function(card, self, center)
        Count = 0
        Legendary = { 0 }
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.rarity == 4 then
                Count = Count + 1
                Legendary[Count] = i
            end
        end
        if Count ~= 0 then
            return { true }
        end
    end,
    use = function(card, self)
        local kill = pseudorandom('Seed', 1, Count)
        G.jokers.cards[Legendary[kill]]:start_dissolve()
        SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 'jjok_special' })
    end
}

SMODS.ConsumableType {
    key = 'ctools',
    primary_colour = HEX('40E0D0'),
    secondary_colour = HEX('000000'),
    loc_txt = {
        name = 'Cursed Tools',
        collection = 'Cursed Tools'
    },
    collection_rows = { 6, 6 },
    shop_rate = 0.2
}

SMODS.Consumable {
    key = 'playcloud',
    set = 'ctools',
    cost = 6,
    loc_txt = { name = 'Playful Cloud',
        text = { 'Wielded by the two ghosts of the',
            'Zenin clan and Suguru Geto, use to',
            'create a {C:attention}Double Tag' } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_TAGS.tag_double
    end,
    can_use = function(card, self)
        return { true }
    end,
    use = function(card, self)
        add_tag(Tag('tag_double'))
        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
    end
}

SMODS.Consumable {
    key = 'kamutoke',
    set = 'ctools',
    cost = 6,
    atlas = 'atlastwo',
    soul_pos = { x = 2, y = 0 },
    pos = { x = 0, y = 1 },
    loc_txt = { name = 'Kamutoke',
        text = { 'Wielded by Sukuna in Shinjuku after',
            'his battle with Gojo, use to {C:attention}destroy',
            'any number of selected playing cards',
            '{s:0.8}"Holds the ability to summon torrents of electricity"' } },
    can_use = function(card, self)
        if #G.hand.highlighted > 0 then
            Destroyed_cards = {}
            for i = 1, #G.hand.highlighted do
                Destroyed_cards[#Destroyed_cards + 1] = G.hand.highlighted[i]
            end
            return { true }
        end
    end,
    use = function(card, self)
        for i = 1, #Destroyed_cards do
            Destroyed_cards[i]:start_dissolve()
        end
    end
}

SMODS.Consumable {
    key = 'nanamitool',
    set = 'ctools',
    cost = 4,
    atlas = 'atlastwo',
    pos = { x = 0, y = 1 },
    hidden = true,
    soul_pos = { x = 2, y = 1 },
    loc_txt = { name = 'Nanamis Wrapped Blade',
        text = { 'A blade wrapped in',
            'a white speckled wrapping,',
            'use to {C:attention}empower Ino',
            '{s:0.8}"Imbued with the ratio technique!"' } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_ino
    end,
    can_use = function(card, self)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_jjok_ino' then
                Ind = i
                return { true }
            end
        end
    end,
    use = function(card, self)
        G.jokers.cards[Ind].ability.extra.emp = true
        return {
            message = 'Empowered!',
            card = G.jokers.cards[Ind]
        }
    end
}

SMODS.Consumable {
    key = 'makitool',
    set = 'ctools',
    loc_txt = {
        name = 'Split Soul Katana',
        text = { 'Formerly wielded by Toji Zenin,',
            'use to {C:attention}awaken Maki',
            '{s:0.8}"Cuts directly at the soul"{}'
        }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_maki
    end,
    atlas = 'atlastwo',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    cost = 4,
    hidden = true,
    can_use = function(card, self)
        local i = nil
        M = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_jjok_maki' then
                M = i
            end
        end
        if M ~= nil then
            return { true }
        end
    end,
    use = function(card, self)
        local destroy_joker = G.jokers.cards[M]:start_dissolve()
        local create_amaki = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_jjok_amaki')
        create_amaki:add_to_deck()
        G.jokers:emplace(create_amaki)
    end
}

SMODS.Consumable {
    key = 'sloth',
    set = 'Tarot',
    loc_txt = { name = 'Sloth',
        text = { 'Create a flyhead...' } },
    can_use = function(self, card)
        return { true }
    end,
    use = function(self, card)
        SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_jjok_flyhead' })
        if pseudorandom('sloth', 1, 100) == 100 then
            SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_jjok_maho' })
        end
    end
}

SMODS.Consumable {
    key = 'lust',
    set = 'Tarot',
    loc_txt = { name = 'Lust',
        text = { '{C:attention}Destroy{} a random Joker and {C:attention}create',
            'the same one with an {C:purple}eternal{} sticker and {C:dark_edition}polychrome{} edition' } },
    can_use = function(self, card)
        if #G.jokers.cards ~= 0 then
            return { true }
        end
    end,
    use = function(self, card, area, copier)
        local lustcard = G.jokers.cards[pseudorandom('lust', 1, #G.jokers.cards)]
        lustcard:start_dissolve()
        SMODS.add_card({ set = 'Joker', area = G.jokers, key = lustcard.config.center.key, edition = 'e_polychrome', stickers = { 'eternal' } })
    end
}

SMODS.Consumable {
    key = 'greed',
    set = 'Tarot',
    cost = 3,
    loc_txt = { name = 'Greed',
        text = { 'Create a {C:dark_edition}negative tag{} but',
            '{C:attention}add{} a {C:money}rental{} sticker to a {C:attention}random joker{} held' } },
    can_use = function(self, card)
        if #G.jokers.cards > 0 then
            return { true }
        end
    end,
    use = function(self, card, area, copier)
        G.jokers.cards[pseudorandom('greed', 1, #G.jokers.cards)].ability.rental = true
        add_tag(Tag('tag_negative'))
        play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
    end
}

SMODS.Consumable {
    key = 'veil',
    set = 'Tarot',
    cost = 3,
    loc_txt = { name = 'Veil',
        text = { 'Draw a veil to {C:attention}add{} {C:dark_edition}negative',
            'to a random held consumable' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
    end,
    can_use = function(self, card)
        if #G.consumeables.cards > 1 then
            return { true }
        end
    end,
    use = function(self, card)
        G.consumeables.cards[pseudorandom('veil', 1, #G.consumeables.cards)]:set_edition('e_negative')
    end
}

SMODS.Consumable {
    key = 'imbue',
    set = 'Tarot',
    atlas = 'atlasfour',
    pos = { x = 0, y = 0 },
    loc_txt = { name = 'Cursed Imbue',
        text = { 'Use to imbue cursed energy',
            'into a card, creating a random',
            '{C:attention}cursed tool{} consumable' } },
    can_use = function(card, self)
        if G.consumeables.config.card_limit >= #G.consumeables.cards then
            return { true }
        end
    end,
    use = function(card, self)
        local create_ctool = SMODS.add_card({ set = 'ctools', area = G.consumeable })
    end
}

-- sukuna start
SMODS.Consumable {
    key = 'sukfin',
    set = 'ctools',
    cost = 6,
    loc_txt = { name = 'Sukunas Finger',
        text = { 'A finger of the king of curses, use',
            'to {C:attention}transform Yuji or {C:attention}empower {C:mult}Sukuna',
            '{s:0.8,C:inactive}(Prioritises transforming Yuji)',
            '{s:0.8}"Each containing the soul of Ryomen Sukuna"' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_yuji
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_sukuna
    end,
    can_use = function(self, card)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_jjok_yuji' then
                Yuji = i
                return { true }
            end
            if G.jokers.cards[i].config.center.key == 'j_jjok_sukuna' then
                Suku = i
                return { true }
            end
        end
    end,
    use = function(self, card)
        if Yuji ~= nil then
            G.jokers.cards[Yuji]:start_dissolve()
            SMODS.add_card({ set = 'Joker', are = G.jokers, key = 'j_jjok_sukuna' })
        end
        if Yuji == nil and Suku ~= nil and G.jokers.cards[Suku].ability.extra.fingers < 20 then
            G.jokers.cards[Suku].ability.extra.fingers = G.jokers.cards[Suku].ability.extra.fingers + 1
        end
    end
}

SMODS.Joker {
    key = 'yuji',
    rarity = 3,
    cost = 10,
    loc_txt = { name = 'Yuji Itadori',
        text = { 'Every "Mult" enhanaced card becomes a',
            '{X:inactive,C:white}Black{} {X:mult,C:white}Flash{} card and gives an additional {C:white,X:mult}X#1#{} Mult' } },
    config = { extra = { Xmult = 1.5 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, 'm_mult') then
                return {
                    Xmult = card.ability.extra.Xmult,
                    colour = G.C.MULT,
                    card = context.other_card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'sukuna',
    cost = 40,
    hidden = true,
    rarity = 'jjok_special',
    loc_txt = { name = '{V:1,B:2}#1#',
        text = { '#2#',
            '#3# {V:3,B:4}#4#{} #5#{V:6}#8#{}#9#',
            '{s:0.8,C:inactive}(Current fingers: {s:0.8,V:5}#6#{s:0.8,C:inactive})',
            '{s:0.8}"#7#"' } },
    config = { extra = { phase = 1, fingers = 1, mult = 5, Xmult = 1, dollars = 10 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_sukfin
        if center.ability.extra.phase == 1 or center.ability.extra.phase == nil then
            return {
                vars = {
                    'Yuji-kuna',
                    'The first vessel of the legendary myth.',
                    'Currently gives',
                    '+' .. center.ability.extra.mult,
                    '(+5 for each finger)',
                    center.ability.extra.fingers,
                    'Without a doubt, he is the king of curses',
                    '',
                    '',
                    colours = { G.C.WHITE, G.C.INACTIVE, G.C.MULT, G.C.WHITE, G.C.MULT, G.C.WHITE }
                }
            }
        end
        if center.ability.extra.phase == 2 then
            return {
                vars = {
                    'Meg-una',
                    'The vessel to defeat the chosen one.',
                    'Currently gives',
                    'X' .. center.ability.extra.Xmult,
                    '(+0.75 for each finger)',
                    center.ability.extra.fingers,
                    'The strongest sorceror in history',
                    '',
                    '',
                    colours = { G.C.WHITE, G.C.RED, G.C.WHITE, G.C.MULT, G.C.MULT, G.C.WHITE }
                }
            }
        end
        if center.ability.extra.phase == 3 then
            return {
                vars = {
                    'True Form Sukuna',
                    'The Heian and final form of the king of the curses.',
                    'Currently gives',
                    'X' .. center.ability.extra.Xmult,
                    ' (+X2 for each finger) and ',
                    center.ability.extra.fingers,
                    'The demon king',
                    center.ability.extra.dollars,
                    ' dollars',
                    colours = { G.C.RED, HEX('000000'), G.C.WHITE, G.C.MULT, G.C.MULT, G.C.MONEY }
                }
            }
        end
    end,
    calculate = function(self, card, context)
        if card.ability.extra.phase == 1 then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].config.center.key == 'j_jjok_meg' then
                    G.jokers.cards[i]:start_dissolve()
                    card.ability.extra.phase = 2
                end
            end
        end
        if card.ability.extra.fingers == 19 then
            card.ability.extra.phase = 3
        end

        card.ability.extra.mult = card.ability.extra.fingers * 5
        if card.ability.extra.phase == 2 then
            card.ability.extra.Xmult = (card.ability.extra.fingers * 0.75) + 1
        end
        if card.ability.extra.phase == 3 then
            card.ability.extra.Xmult = (card.ability.extra.fingers * 2)
        end

        if context.joker_main then
            if card.ability.extra.phase == 1 then
                return {
                    mult_mod = card.ability.extra.mult,
                    message = { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
                }
            end
            if card.ability.extra.phase == 2 then
                return { Xmult = card.ability.extra.Xmult }
            end
            if card.ability.extra.phase == 3 then
                return {
                        Xmult = card.ability.extra.Xmult,
                        message = { '$' .. card.ability.extra.dollars, colour = G.C.MONEY }
                    },
                    ease_dollars(card.ability.extra.dollars)
            end
        end
    end
}

SMODS.Joker {
    key = 'fb',
    rarity = 3,
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
            card.ability.extra.trig = true
        end
        if context.end_of_round and context.cardarea == G.jokers and card.ability.extra.trig == true then
            SMODS.add_card({ set = 'Tarot', area = G.consumeables, key = 'c_jjok_sukfin' })
            card:start_dissolve()
        end
    end
}
-- sukuna end

SMODS.Joker {
    key = 'hak',
    rarity = 'jjok_special',
    cost = 40,
    loc_txt = { name = '{C:dark_edition}Hakari Kinji',
        text = { '{C:green}#1#{} in {C:green}#2#{} chance to give {V:1,B:2}#3#{}',
            '{s:0.8}"The restless gambler"' } },
    config = { extra = { odds = 7, consc_unc = 0, consc = 0 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                G.GAME.probabilities.normal + center.ability.extra.consc,
                center.ability.extra.odds,
                'Everything',
                colours = { G.C.WHITE, G.C.DARK_EDITION }
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local rand = pseudorandom('hak', 1, card.ability.extra.odds)
            if rand <= 1 + card.ability.extra.consc then
                if card.ability.extra.consc < 5 then
                    card.ability.extra.consc = card.ability.extra.consc + 1
                end
                card.ability.extra.consc_unc = card.ability.extra.consc_unc + 1
                ease_dollars(card.ability.extra.consc_unc)
                return {
                    Xmult = 2 * card.ability.extra.consc_unc,
                    xchips = 1.5 * card.ability.extra.consc_unc,
                    message = {'+1 Odds!', colour = G.C.GREEN}
                }
            else
                card.ability.extra.consc = 0
                card.ability.extra.consc_unc = 0
                if pseudorandom('hakbad', 1, 5) == 4 then
                    return {
                        chip_mod = -G.GAME.blind.chips,
                        message = {'-'..G.GAME.blind.chips, 
                                    colour = G.C.CHIPS}
                    }
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'muffin',
    cost = 1,
    no_collection = true,
    atlas = 'atlasmuffin',
    rarity = 3,
    blueprint_compat = true,
    config = { extra = { mult = 10 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.mult } }
    end,
    loc_txt = { name = 'Muffin',
        text = { '{C:mult}MURRRRFINNNN',
            'Gives {C:mult}+#1#{} mult' } },
    add_to_deck = function(card, self)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_jjok_cookie' then
                local create_mac = SMODS.add_card { key = 'j_jjok_cookieandmuffin' }
                G.jokers.cards[i]:start_dissolve()
                self:start_dissolve()
            end
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return { mult_mod = card.ability.extra.mult }
        end
    end
}

SMODS.Atlas { key = 'atlasmuffin', path = 'muffin.png', px = 1134, py = 1674 }
SMODS.Atlas { key = 'atlascookie', path = 'cookie.png', px = 630, py = 930 }
SMODS.Atlas { key = 'atlascm', path = 'cookieandmuffin.png', px = 630, py = 930 }

SMODS.Joker {
    key = 'cookieandmuffin',
    loc_txt = { name = 'Murfin and Cookieee',
        text = { '{C:legendary,s:1.1}MUFFIN AND COOKIEEE <3333333333',
            'Gives {C:money}$#1#{} at the end of the round,',
            '{C:white,X:mult}X#2#{} Mult and {C:white,X:chips}X#3#{} Chips' } },
    no_collection = true,
    cost = 36,
    atlas = 'atlascm',
    hidden = true,
    blueprint_compat = true,
    rarity = 'jjok_special',
    config = { extra = { money = 15,
        Xmult = 4,
        xchips = 2 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_cookie
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_muffin
        return { vars = { center.ability.extra.money, center.ability.extra.Xmult, center.ability.extra.xchips } }
    end,
    add_to_deck = function(card, self)
        self:set_edition('e_negative', true, true)
    end,
    calculate = function(self, card, context)
        if context.joker_main or context.blueprint then
            return {
                Xmult = card.ability.extra.Xmult,
                xchips = card.ability.extra.xchips
            }
        end
    end,
    calc_dollar_bonus = function(self, card)
        local mon = card.ability.extra.money
        return mon
    end
}

SMODS.Joker {
    key = 'cookie',
    cost = 1,
    atlas = 'atlascookie',
    rarity = 3,
    no_collection = true,
    blueprint_compat = true,
    config = { extra = { chips = 30 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.chips } }
    end,
    add_to_deck = function(card, self)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_jjok_muffin' then
                local create_mac = SMODS.add_card { key = 'j_jjok_cookieandmuffin' }
                G.jokers.cards[i]:start_dissolve()
                self:start_dissolve()
            end
        end
    end,
    loc_txt = { name = 'Cookie',
        text = { '{C:chips}OWWWEEEOOO',
            'Gives {C:chips}+#1#{} chips' } },
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
    end
}

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

SMODS.Joker {
    key = 'meg',
    cost = 12,
    rarity = 3,
    loc_txt = { name = 'Megumi Fushiguro',
        text = { 'Upon selecting a {C:attention}boss blind,',
            '{C:attention}create{} 1 of the ten shadows shikigami' } },
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss == true then
            SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 'jjok_shiki' })
        end
    end
}

--fuck it, all the shikigami
SMODS.Joker {
    key = 'maho',
    rarity = 'jjok_shiki',
    cost = 10,
    loc_txt = { name = '{C:money}Mahoraga',
        text = { 'Eight handled sword, divergent sila,',
            'divine general, {C:money}Mahoraga!',
            'Upon playing a hand, {C:attention}reduce blind size by 5%{}',
            'up to a maximum of {X:chips,C:white}1x{} ante base blind size',
            '{s:0.8,C:inactive}(Current base blind size = {C:chips,s:0.8}#1#{s:0.8,C:inactive})',
            '{s:0.8,C:hearts}"MAHORAGA HELP ME!"' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { get_blind_amount(G.GAME.round_resets.ante) } }
    end,
    calculate = function(self, card, context)
        if G.GAME.blind.chips > get_blind_amount(G.GAME.round_resets.ante) then
            if context.before then
                G.GAME.blind.chips = G.GAME.blind.chips * 0.95
                if G.GAME.blind.chips < get_blind_amount(G.GAME.round_resets.ante) then
                    G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante)
                end
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                SMODS.juice_up_blind()
            end
        end
    end
}

SMODS.Joker {
    key = 'demdogs',
    rarity = 'jjok_shiki',
    cost = 10,
    loc_txt = { name = 'Demon Dogs',
        text = { '{C:green}#1#/#2#{} chance to {C:money}refund',
            'any opened booster pack',
            '{s:0.8}"Demon dogs!"' } },
    config = { extra = { odds = 2 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { (G.GAME.probabilities.normal or 0), center.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.open_booster then
            local bcost = context.card.cost
            if pseudorandom('demdogs') < G.GAME.probabilities.normal / card.ability.extra.odds then
                ease_dollars(bcost)
            end
        end
    end
}
--fuck it, end of the shikigamis
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
    key = 'toji',
    rarity = 3,
    atlas = 'atlasfive',
    pos = { x = 1, y = 0 },
    blueprint_compat = true,
    soul_pos = { x = 0, y = 0 },
    cost = 10,
    loc_txt = { name = 'Toji Fushiguro',
        text = { 'Creates {C:attention}1 negative flyhead{} on selecting a blind',
            'for every non-negative flyhead, {C:attention}destroy{} the joker',
            'to the {C:attention}right{} on {C:attention}selection of a blind{} in exchange for',
            '{C:money}1/5th sell value{} as {C:white,X:mult}XMult',
            '{C:inactive,s:0.8}(Currently {C:white,X:mult,s:0.8}X#1#{C:inactive,s:0.8} Mult)',
            '{s:0.8}"The ghost of the Zenin clan"' } },
    config = { extra = { Xmult = 1 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.Joker_main or context.blueprint then
            return { Xmult = card.ability.extra.Xmult }
        end
        if context.setting_blind and not context.blueprint then
            Create = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    if #G.jokers.cards >= i + 1 then
                        card.ability.extra.Xmult = card.ability.extra.Xmult + (G.jokers.cards[i + 1].sell_cost / 5)
                        G.jokers.cards[i + 1]:start_dissolve()
                        play_sound('slice1', 0.96 + math.random() * 0.08)
                    end
                end
                if G.jokers.cards[i].config.center.key == 'j_jjok_flyhead' and G.jokers.cards[i].config.center.edition ~= 'e_negative' then
                    Create = Create + 1
                end
            end
            if Create ~= 0 then
                for i = 1, Create do
                    local createfh = SMODS.add_card({ set = 'Joker', key = 'j_jjok_flyhead', edition = 'e_negative' })
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'ogami',
    rarity = 1,
    cost = 5,
    blueprint_compat = true,
    loc_txt = { name = 'Granny Ogami',
        text = { 'Summon the bodies of the dead',
            'and use their techniques, gains',
            '{C:white,X:mult}X#2#{} Mult for every {C:attention}Flyhead removed from deck{}',
            '{s:0.8,C:inactive}(Currently{} {s:0.8,C:white,X:mult}X#1#{} {s:0.8,C:inactive}Mult)',
            '{s:0.8}"Kill sorcerors huh? Youre a sorceror."' } },
    config = { extra = { Xmult = 1, Xmult_gain = 0.25 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
        if Flyhead_sold ~= nil then
            return { vars = { (1 + (center.ability.extra.Xmult_gain * Flyhead_sold)), center.ability.extra.Xmult_gain } }
        end
        if Flyhead_sold == nil then
            return { vars = { 1, center.ability.extra.Xmult_gain } }
        end
    end,
    add_to_deck = function(card, self)
        Flyhead_sold = 0
    end,
    calculate = function(self, card, context)
        card.ability.extra.Xmult = (1 + (card.ability.extra.Xmult_gain * Flyhead_sold))
        if context.joker_main or context.blueprint then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'haruta',
    cost = 5,
    rarity = 1,
    atlas = 'atlasthree',
    blueprint_compat = false,
    pos = { x = 3, y = 2 },
    soul_pos = { x = 2, y = 2 },
    loc_txt = { name = 'Haruta',
        text = { 'A curse user in Shibuya,',
            'if it is the {C:attention}final hand{} and',
            'you hold atleast {C:attention}1 charge{} then add {C:white,X:mult}x Mult{} equal to (current ante / 2)',
            'in exchange for 1 charge {C:tarot}(Currently #1# charges)',
            '{C:attention}gain 1 charge if you win a blind in one hand',
            '{s:0.8}"A coward"'
        } },
    config = { extra = { charges = 3 } },
    loc_vars = function(card, info_queue, center)
        return { vars = { center.ability.extra.charges } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            if G.GAME.current_round.hands_left == 0 and card.ability.extra.charges > 0 then
                card.ability.extra.charges = card.ability.extra.charges - 1
                return {
                    Xmult = G.GAME.round_resets.ante / 2
                }
            end
        end
        if context.end_of_round and G.GAME.current_round.hands_left == G.GAME.current_round.hands_left - 1 then
            if card.ability.extra.charges ~= 3 then
                card.ability.extra.charges = card.ability.extra.charges + 1
            end
        end
    end
}

SMODS.Joker {
    key = 'flyhead',
    rarity = 'jjok_cs',
    cost = 1,
    shop_rate = 0.70,
    atlas = 'atlasthree',
    blueprint_compat = true,
    pos = { x = 3, y = 0 },
    soul_pos = { x = 3, y = 1 },
    loc_txt = { name = 'Fly Heads',
        text = { 'A useless less-than {C:common}Grade 4',
            'cursed spirit',
            'gives {C:mult}+#1#{} Mult and {C:chips}+#2#{} chips' } },
    config = { extra = { mult = 1, chips = 1 } },
    loc_vars = function(card, info_queue, center)
        return {
            vars = { center.ability.extra.mult,
                center.ability.extra.chips }
        }
    end,
    remove_from_deck = function(card, self)
        if Flyhead_sold == nil then
            Flyhead_sold = 0
        end
        Flyhead_sold = Flyhead_sold + 1
    end,
    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips
            }
        end
        if context.blueprint then
            return { message = 'Pittiful creature, too weak!' }
        end
    end
}

SMODS.Joker {
    key = 'rainbowdragon',
    loc_txt = { name = 'Rainbow Dragon',
        text = { 'One of the most powerful cursed',
            'spirits in young Getos collection,',
            'exorcised by Toji Zenin, gives',
            '{C:mult}+#1#{} mult ({C:mult}round{} * {C:mult}ante{})',
            '{s:0.8,C:inactive}(Destroyed upon use)' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { G.GAME.round * G.GAME.round_resets.ante } }
    end,
    atlas = 'atlasthree',
    pos = { x = 3, y = 0 },
    soul_pos = { x = 2, y = 0 },
    shop_rate = 0.75,
    pools = { ['ygeto_col'] = true },
    no_collection = true,
    blueprint_compat = false,
    rarity = 'jjok_cs',
    add_to_deck = function(card, self, context)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end,
    remove_from_deck = function(card, self, context)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 1
    end,
    calculate = function(self, card, context)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                D = i
            end
        end
        if context.joker_main then
            return {
                card = card,
                mult = (G.GAME.round * G.GAME.round_resets.ante),
            }
        end
        if context.after then
            G.E_MANAGER:add_event(Event({
                trigger = 'immediate',
                func = function()
                    card:start_dissolve()
                    return { true }
                end
            }))
        end
    end
}

SMODS.Joker {
    key = 'flyingspirit',
    atlas = 'atlasthree',
    no_collection = true,
    rarity = 'jjok_cs',
    pos = { x = 3, y = 0 },
    blueprint_compat = false,
    soul_pos = { x = 2, y = 1 },
    loc_txt = { name = 'Flying Cursed Spirit',
        text = { 'A minor cursed spirit in',
            'young Getos collection that',
            'can fly with people, adds',
            '{C:attention}1 extra joker slot{} temporarily',
            '{s:0.8,C:inactive}(Destroyed at end of round)' } },
    add_to_deck = function(self, card, context)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 2
    end,
    remove_from_deck = function(self, card, context)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 2
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.cardarea == G.jokers then
            card:start_dissolve()
        end
    end
}

SMODS.Joker {
    key = 'ygeto',
    atlas = 'atlasthree',
    pos = { x = 1, y = 0 },
    cost = 8,
    soul_pos = { x = 0, y = 0 },
    loc_txt = { name = 'Young Geto',
        text = { 'Upon {C:attention}entering a blind{},',
            'create 1 of 2 cursed spirits from',
            'young Getos collection',
            '{s:0.8}"Are you the strongest because',
            '{s:0.8}youre Satoru Gojo...' } },
    rarity = 3,
    blueprint_compat = true,
    calculate = function(card, self, context)
        if context.setting_blind or context.blueprint then
            local which = pseudorandom("seed", 1, 2)
            if which == 1 then
                local create_cs = SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_jjok_rainbowdragon' })
            else
                if which == 2 then
                    local create_cs = SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_jjok_flyingspirit' })
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'amaki',
    atlas = 'atlasone',
    pos = { x = 3, y = 1 },
    soul_pos = { x = 2, y = 1 },
    blueprint_compat = false,
    loc_txt = {
        name = 'Awakened Maki',
        text = {
            '{C:attention}Destroys{} the {X:chips,C:white}left most{} card in any',
            'played hand if it is scoring and gains {X:mult,C:white}#2#x{} Mult',
            '{s:0.8}(Currently: {s:0.8,X:mult,C:white}#1#x{s:0.8} Mult){}',
            '{s:0.8}"A demonic fighter equal to Toji',
            '{s:0.8}Zenin was now fully realised!"'
        }
    },
    config = { extra = {
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
    hidden = true,
    calculate = function(self, card, context)
        if context.destroying_card and context.cardarea == G.play and context.destroying_card == context.full_hand[1] then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return {
                remove = true,
                message = { '+' .. 0.25 }
            }
        end
        if context.joker_main then
            return {
                card = card,
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'tgojo',
    loc_txt = {
        name = '{C:chips}Satoru {C:mult}Gojo',
        text = {
            'Using the six eyes and limitless',
            'techniques, {C:attention}doubles{} hand size',
            '{s:0.8}"Aside from Satoru Gojo, of course"{}'
        }

    },
    atlas = 'atlasthree',
    pos = { x = 1, y = 1 },
    blueprint_compat = false,
    soul_pos = { x = 0, y = 1 },
    rarity = 'jjok_special',
    cost = 40,
    add_to_deck = function(self, card, context)
        G.hand:change_size(G.hand.config.card_limit)
    end,
    remove_from_deck = function(self, card, context)
        G.hand:change_size(-(G.hand.config.card_limit / 2))
    end
}

SMODS.Joker {
    key = 'nanami',
    loc_txt = { name = 'Nanami Kento',
        text = { 'Every scored {C:attention}7{} or {C:attention}3{}',
            'gives {X:mult,C:white}#1#x{} Mult',
            '{s:0.8}"You take it from here..."' } },
    rarity = 4,
    cost = 20,
    atlas = 'atlasone',
    blueprint_compat = true,
    pos = { x = 3, y = 2 },
    soul_pos = { x = 2, y = 2 },
    config = { extra = { Xmult = 2.5 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,
    remove_from_deck = function(self, card, context)
        if #G.consumeables.cards < G.consumeables.config.card_limit then
            local create_ntool = SMODS.add_card({ key = 'c_jjok_nanamitool', area = G.consumeable })
        end
    end,
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play or context.blueprint and context.cardarea == G.play and context.individual then
            if context.other_card:get_id() == 7 or context.other_card:get_id() == 3 then
                return {
                    Xmult = card.ability.extra.Xmult,
                    card = context.other_card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'ino',
    rarity = 3,
    cost = 10,
    loc_txt = { name = 'Takuma Ino',
        text = { '{C:attention,s:1.1}-Cycles through 3 effects on selecting blind-',
            'Currently gives {V:1,B:2}#1##3#{} #2#',
            '{s:0.8}"The shiesty sorceror, the GOAT"' } },
    atlas = 'atlasthree',
    pos = { x = 1, y = 2 },
    soul_pos = { x = 0, y = 2 },
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        if Stage == 1 or Stage == 0 or Stage == nil then
            return { vars = { 'x', 'mult', card.ability.extra.Xmult, colours = { G.C.WHITE, G.C.MULT } } }
        end
        if Stage == 2 then
            return { vars = { '+', 'chips', card.ability.extra.chips, colours = { G.C.CHIPS, G.C.WHITE } } }
        end
        if Stage == 3 then
            return { vars = { '$', 'at the end of the round', card.ability.extra.money, colours = { G.C.MONEY, G.C.WHITE } } }
        end
    end,
    config = { extra = { cycles = 1,
        Xmult = 1,
        chips = 20,
        money = 1,
        emp = false } },
    add_to_deck = function(self, card, context)
        Stage = 0
    end,
    calculate = function(self, card, context)
        if context.setting_blind then
            if Stage == 3 then
                Stage = 0
            end
            Stage = Stage + 1
            card.ability.extra.cycles = card.ability.extra.cycles + 1
            if card.ability.extra.emp == true then
                card.ability.extra.cycles = card.ability.extra.cycles + 1
            end
            card.ability.extra.Xmult = card.ability.extra.cycles / 2
            card.ability.extra.chips = card.ability.extra.cycles * 20
            card.ability.extra.money = card.ability.extra.cycles
        end
        if context.joker_main then
            if Stage == 1 then
                return {
                    Xmult = card.ability.extra.Xmult }
            end
            if Stage == 2 then
                return {
                    message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                    chip_mod = card.ability.extra.chips,
                    colour = G.C.CHIPS
                }
            end
        end
    end,
    calc_dollar_bonus = function(self, card)
        if Stage == 3 then
            local mon = card.ability.extra.money
            return mon
        end
    end
}

SMODS.Joker {
    key = 'ygojo',
    atlas = 'atlasone',
    soul_pos = { x = 0, y = 2 },
    pos = { x = 1, y = 2 },
    cost = 20,
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
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
    blueprint_compat = true,
    rarity = 4,
    config = { extra = { mult = 0, mult_gain = 1 },
        unlocked = true,
        discovered = true },
    calculate = function(self, card, context)
        if context.joker_main or context.blueprint then
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { self.ability.extra.mult } },
                mult_mod = card.ability.extra.mult
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

SMODS.Atlas {
    key = 'atlasthree',
    path = 'three.png',
    px = 1030,
    py = 1378
}

SMODS.Atlas {
    key = 'atlasfour',
    path = 'four.png',
    px = 63,
    py = 93
}

SMODS.Atlas {
    key = 'atlasfive',
    path = 'five.png',
    px = 630,
    py = 844
}

SMODS.Joker {
    key = 'mai',
    loc_txt = {
        name = 'Mai Zenin',
        text = { '{C:attention}Create{} a random {C:spectral}Spectral{}',
            'or {C:tarot}Tarot{} card upon ',
            '{C:attention}skipping or entering a blind{}',
            '{s:0.8}"Why wouldnt you stay at the bottom with me..."{}'
        } },
    atlas = 'atlasone',
    pos = { x = 3, y = 0 },
    soul_pos = { x = 2, y = 0 },
    blueprint_compat = true,
    cost = 6,
    rarity = 2,
    calculate = function(self, card, context)
        if context.skip_blind or context.setting_blind and #G.consumeables.cards < G.consumeables.config.card_limit then
            local create_consum = nil
            local sort = pseudorandom("seed", 1, 10)
            if sort <= 5 then
                create_consum = SMODS.add_card({ set = 'Tarot', area = G.consumeable })
            end
            if sort >= 6 and sort ~= 10 then
                create_consum = SMODS.add_card({ set = 'Spectral', area = G.consumeable })
            end
            if sort == 10 then
                if context ~= context.blueprint then
                    create_consum = SMODS.add_card({ key = 'c_jjok_makitool', area = G.consumeable })
                    card:start_dissolve()
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'yuta',
    loc_txt = {
        name = '{C:purple}Yuta Okkotsu',
        text = {
            'Rika {C:attention}copies{} the abilities of the jokers',
            'to the {X:chips,C:white}left{} and {X:mult,C:white}right{} of Yuta if both',
            'abilities can be copied',
            '{s:0.8}"The cursed child..."{}'
        }
    },
    rarity = "jjok_special",
    atlas = 'atlasone',
    pos = { x = 1, y = 1 },
    soul_pos = { x = 0, y = 1 },
    cost = 40,
    blueprint_compat = false,
    config = { extra = { retriggers = 1 },
        unlocked = true,
        discovered = true },
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
            '{s:0.8}"A demonic fighter...',
            '{s:0.8}was not yet realized"'
        }
    },
    atlas = 'atlasone',
    blueprint_compat = true,
    cost = 3,
    soul_pos = { x = 0, y = 0 },
    pos = { x = 1, y = 0 },
    config = { extra = {
        Xmult = 1.5,
    }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main or context.blueprint then
            return {
                card = card,
                Xmult = card.ability.extra.Xmult,
            }
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
