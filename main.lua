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

--domains

SMODS.Booster {
    key = 'debooster',
    config = { extra = 2, choose = 1 },
    loc_txt = { name = 'Domain Booster',
        text = { 'Choose {C:attention}1 of {C:attention}2',
            'Domain Expansions' },
        group_name = {'Domain Expansions cannot be sold',
                    'and can only be used once per ante'}},
    draw_hand = false,
    cost = 20,
    in_pool = function(self, args)
        if G.GAME.round_resets.ante >= 4 then
            return true
        end
    end,
    select_card = 'domain',
    create_card = function(self, card, i)
        return
            SMODS.create_card({
                set = 'domain',
                area = G.pack_cards,
                skip_materialize = true
            })
    end,
    weight = 1
}

SMODS.ConsumableType {
    key = 'domain',
    primary_colour = HEX('6a329f'),
    secondary_colour = HEX('000000'),
    loc_txt = {
        name = 'Domain Expansion',
        collection = 'Domain Expansion'
    },
    collection_rows = { 2, 3 },
    shop_rate = 0.0,
    hidden = true
}

SMODS.Consumable {
    key = 'seop',
    set = 'domain',
    cost = 5,
    hidden = true,
    config = { extra = { editionless_jokers = {}, used_this_ante = false } },
    loc_txt = { name = '{C:purple}Self Embodiment of Perfection',
        text = { 'Mahitos domain, effectively allowing him to',
            'kill anything with a soul, without even',
            'touching them',
            '{s:1.1}Changes {C:attention,s:1.1}1{s:1.1} random Joker to {C:dark_edition,s:1.1}negative',
            '{s:0.8,C:inactive}(Currently #1#)' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_mahito
        if center.ability.extra.used_this_ante == true then
            return { vars = { 'Inactive' } }
        else
            return { vars = { 'Active' } }
        end
    end,
    can_use = function(self, card)
        if card.ability.extra.last_ante_used ~= G.GAME.round_resets.ante then
            card.ability.extra.used_this_ante = false
        end

        card.ability.extra.editionless_jokers = {}
        for i, v in pairs(G.jokers.cards) do
            if v.ability.set == "Joker" and (v.edition == nil or v.edition.negative == false) then
                table.insert(card.ability.extra.editionless_jokers, v)
            end
        end
        if card.ability.extra.editionless_jokers ~= nil and card.ability.extra.used_this_ante == false then
            return true
        end
    end,
    keep_on_use = function(self, card)
        return true
    end,
    use = function(self, card)
        local seopcard = card.ability.extra.editionless_jokers
            [pseudorandom('seop', 1, #card.ability.extra.editionless_jokers)]
        seopcard:set_edition('e_negative')
        card.ability.extra.used_this_ante = true
        card.ability.extra.last_ante_used = G.GAME.round_resets.ante
    end
}

SMODS.Consumable {
    key = 'idg',
    set = 'domain',
    cost = 5,
    loc_txt = {
        name = '{C:dark_edition}Idle Death Gamble',
        text = {
            'Hakaris domain expansion which',
            'grants him infinite cursed energy,',
            '{C:green}#1#{} in {C:green}#2#{} chance to give {C:dark_edition}+1 Domain Slots',
            '{C:green}#1#{} in {C:green}#3#{} chance to {C:money}double money',
            '{C:green}#1#{} in {C:green}#4#{} chance to {C:chips}win blind',
            '{s:0.8,C:inactive}(Currently #5#)'
        }
    },
    loc_vars = function(self, info_queue, center)
        local word = ''
        if center.ability.extra.used_this_ante == false then
            word = 'Active'
        else
            word = 'Inactive'
        end
        return {
            vars = {
                G.GAME.probabilities.normal,
                center.ability.extra.slodds,
                center.ability.extra.modds,
                center.ability.extra.wodds,
                word
            }
        }
    end,
    config = { extra = { slodds = 7, modds = 3, wodds = 10, used_this_ante = false } },
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        if card.ability.extra.last_ante_used ~= G.GAME.round_resets.ante then
            card.ability.extra.used_this_ante = false
        end
        if card.ability.extra.used_this_ante == false then
            return true
        end
    end,
    use = function(self, card)
        card.ability.extra.last_ante_used = G.GAME.round_resets.ante
        card.ability.extra.used_this_ante = true
        if pseudorandom('idgdomainlim') < G.GAME.probabilities.normal / card.ability.extra.slodds then
            G.domain.config.card_limit = G.domain.config.card_limit + 1
        end
        if pseudorandom('idgmoney') < G.GAME.probabilities.normal / card.ability.extra.modds then
            ease_dollars(G.GAME.dollars)
        end
        if pseudorandom('idgwin') < G.GAME.probabilities.normal / card.ability.extra.wodds then
            G.GAME.chips = G.GAME.blind.chips
        end
    end
}

SMODS.Consumable {
    key = 'coffin',
    cost = 5,
    set = 'domain',
    loc_txt = { name = '{C:diamonds}Coffin of the Iron Mountain',
        text = { 'Jogo, the mount fuji disaster',
            'curses domain, {C:attention}destroy{} all cards',
            'held in hand in exchange for {C:money}$#1#{} per',
            'card destroyed',
            '{s:0.8,C:inactive}(Currently #2#)' } },
    config = { extra = { money = 5, used_this_ante = false } },
    loc_vars = function(self, info_queue, center)
        local ac = ''
        if center.ability.extra.last_ante_used ~= G.GAME.round_resets.ante then
            ac = 'Active'
            center.ability.extra.used_this_ante = false
        else
            ac = 'Inactive'
        end
        return {
            vars = {
                center.ability.extra.money,
                ac
            }
        }
    end,
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        if card.ability.extra.used_this_ante == false then
            return true
        end
    end,
    use = function(self, card)
        card.ability.extra.used_this_ante = true
        card.ability.extra.last_ante_used = G.GAME.round_resets.ante
        for i, v in ipairs(G.hand.cards) do
            v:start_dissolve()
            ease_dollars(card.ability.extra.money)
        end
    end
}

SMODS.Consumable {
    key = 'iv',
    set = 'domain',
    cost = 5,
    loc_txt = { name = '{C:blue}Infinite Void',
        text = { 'Satoru Gojos domain:',
            'launch a stream of infinite',
            'information into the blinds mind',
            'effectively turning them brain dead,',
            '{s:1.1,C:chips}draw full {s:1.1,C:tarot}deck {s:1.1,C:mult}to hand',
            '{s:1.1,C:chips}and disable {s:1.1,C:tarot}any {s:1.1,C:mult}active blinds',
            '{s:0.8,C:inactive}(Currently #1#)' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_tgojo
        if center.ability.extra.used_this_ante == false then
            return {
                vars = {
                    'Active'
                }
            }
        end
        if center.ability.extra.used_this_ante == true then
            return {
                vars = {
                    'Inactive'
                }
            }
        end
    end,
    config = { extra = { used_this_ante = false } },
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        if G.GAME.round_resets.ante ~= card.ability.extra.last_ante_used then
            card.ability.extra.used_this_ante = false
        end
        if card.ability.extra.used_this_ante == false then
            return { true }
        end
    end,
    use = function(self, card)
        G.FUNCS.draw_from_deck_to_hand(#G.deck.cards)
        card.ability.extra.last_ante_used = G.GAME.round_resets.ante
        card.ability.extra.used_this_ante = true
        if G.GAME.blind.boss == true then
            G.GAME.blind:disable()
            play_sound('timpani')
        end
    end,
}

SMODS.Consumable {
    key = 'ms',
    set = 'domain',
    loc_txt = { name = '{C:red}Malevolent Shrine',
        text = { 'Sukunas barrierless domain,',
            'truly a divine feat, relentlessly',
            'slashes at everything in its range',
            '{s:1.1}Gives {s:1.1,X:dark_edition,C:white}^#1#{s:1.1} Mult',
            'increase by {X:dark_edition,C:white}#2#{} when {C:attention}defeating{} a blind',
            '{s:0.8,C:inactive}(Currently #3#)' } },
    config = { extra = { emult = 1.2, scale = 0.05, used_this_ante = false } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_sukuna
        if center.ability.extra.used_this_ante == true then
            center.ability.extra.ret = 'Inactive'
        else
            center.ability.extra.ret = 'Active'
        end
        return {
            vars = {
                center.ability.extra.emult,
                center.ability.extra.scale,
                center.ability.extra.ret
            }
        }
    end,
    keep_on_use = function(self, card)
        return { true }
    end,
    can_use = function(self, card)
        if card.ability.extra.last_ante_used ~= G.GAME.round_resets.ante then
            card.ability.extra.used_this_ante = false
        end
        if card.ability.extra.used_this_ante == false then
            return { true }
        end
    end,
    use = function(self, card)
        card.ability.extra.used_this_ante = true
        card.ability.extra.last_ante_used = G.GAME.round_resets.ante
        card.ability.extra.activated = true
    end,
    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.activated == true then
            card.ability.extra.activated = false
            mult = mult ^ card.ability.extra.emult
            return {
                message = '^' .. card.ability.extra.emult .. ' Mult', colour = G.C.DARK_EDITION
            }
        end
        if context.end_of_round and context.cardarea == G.domain and card == card then
            card.ability.extra.emult = card.ability.extra.emult + card.ability.extra.scale
            return {
                message = {
                    'Binding Vow!', colour = G.C.RED
                }
            }
        end
    end
}

--domain end

--domains area

local start_run_ref = Game.start_run
function Game:start_run(args)
    self.GAME.starting_params.domain_slots = 1
    self.domain = CardArea(0, 0, G.CARD_W * 1.2, G.CARD_H, {
        card_limit = self.GAME.starting_params.domain_slots,
        type = "joker",
        highlight_limit = 1,
        view_deck = true
    })
    start_run_ref(self, args)
    set_screen_positions()
end

local set_screen_positions_func = set_screen_positions
function set_screen_positions()
    set_screen_positions_func()

    if G.domain then
        G.domain.T.x = G.TILE_W - G.domain.T.w - 0.3
        G.domain.T.y = 3
        G.domain:hard_set_VT()
    end
end

local emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    if self == G.consumeables and card.ability.set == 'domain' then
        G.domain:emplace(card, location, stay_flipped)
        return
    end
    emplace_ref(self, card, location, stay_flipped)
end

--

SMODS.Voucher {
    key = 'cursedv',
    loc_txt = { name = 'Cursed Voucher',
        text = { 'A voucher imbued with cursed energy,',
            'receive {C:money}$#1#{}',
            '{C:red}-#2#{} Joker Slots' } },
    cost = 1,
    config = { extra = { slots = 1, money = 50 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.money,
                center.ability.extra.slots
            }
        }
    end,
    redeem = function(self, card)
        G.jokers.config.card_limit = G.jokers.config.card_limit - card.ability.extra.slots
        return {
            ease_dollars(card.ability.extra.money),
        }
    end
}

SMODS.Voucher {
    key = 'rcursedv',
    loc_txt = { name = 'Reversed-Cursed Voucher',
        text = { 'A voucher imbued with positive energy,',
            'lose {C:money}$#1#{}',
            '{C:dark_edition}+#2#{} Joker Slots' } },
    cost = 1,
    config = { extra = { slots = 1, money = 75 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.money,
                center.ability.extra.slots
            }
        }
    end,
    redeem = function(self, card)
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
        return {
            ease_dollars(-card.ability.extra.money),
        }
    end,
    requires = { 'v_jjok_cursedv' }
}

SMODS.Seal {
    key = 'electric',
    atlas = 'seal',
    pos = { x = 0, y = 0 },
    loc_txt = { name = 'Conductive Seal',
        text = { 'Multiply total blind size by',
            '{C:white,X:chips}#1#%{} up to a total of',
            'X1 base blind chips: Currently {C:chips}#2#{} chips' },
        label = 'Conductive Seal' },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                0.99,
                get_blind_amount(G.GAME.round_resets.ante)
            }
        }
    end,
    badge_colour = HEX('3d85c6'),
    calculate = function(self, card, context)
        if context.main_scoring and context.cardarea == G.play then
            if G.GAME.blind.chips > get_blind_amount(G.GAME.round_resets.ante) then
                G.GAME.blind.chips = G.GAME.blind.chips * 0.99
                if G.GAME.blind.chips < get_blind_amount(G.GAME.round_resets.ante) then
                    G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante)
                end
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                card:juice_up(0.3, 0.4)
                SMODS.juice_up_blind()
                return {
                    message = { '{C:chips}X0.99{} Blind Size', colour = G.C.CHIPS }
                }
            end
        end
    end
}

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
    in_pool = function(self, card)
        local found = false
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.rarity == 4 then
                found = true
            end
        end
        if found == true then
            return { true }
        else
            return { false }
        end
    end,
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
            'Zenin clan, Suguru Geto and Aoi Todo, use to',
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
        text = { 'Wielded by Sukuna, use to {C:attention}destroy',
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
        text = { '{C:attention}Create{} a flyhead...' } },
    can_use = function(self, card)
        return { true }
    end,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
    end,
    use = function(self, card)
        SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_jjok_flyhead' })
        if pseudorandom('sloth', 1, 100) == 100 then
            SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 'jjok_special' })
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
    key = 'wallet',
    set = 'Tarot',
    cost = 1,
    loc_txt = { name = 'Tojis Wallet',
        text = {
            'Multiply current {C:money}balance{} by {C:red}#1#'
        } },
    config = { extra = { dollars = -1 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.dollars
            }
        }
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card)
        ease_dollars(-G.GAME.dollars * 2)
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
        if #G.consumeables.cards > 1 or (#G.consumeables.cards == 1 and not G.consumeables.cards[1] == card) then
            return true
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
                    mult = card.ability.extra.mult,
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
-- sukuna end

-- disaster curses
SMODS.Joker {
    key = 'mahito',
    rarity = 'jjok_special',
    cost = 40,
    loc_txt = { name = 'Mahito',
        text = { 'On choosing a blind, set hand size to {C:white,X:dark_edition}1{}',
            '{s:0.8}"I truly am a curse!"' } },
    calculate = function(self, card, context)
        if context.setting_blind then
            G.hand.config.card_limit = 1
        end
    end
}

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
        if context.setting_blind or (context.setting_blind and context.blueprint) then
            SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_splash', edition = 'e_negative' })
        end
        if context.selling_self and not context.blueprint then
            local tally = 0
            for i,v in ipairs(G.jokers.cards) do
                if v.config.center.key == 'j_splash' and v.edition.negative == true then
                    tally = tally + 1
                end
            end
            if tally >= 5 then
                SMODS.add_card({set = 'Joker', area = G.jokers, key = 'j_jjok_dagon'})
            end
        end
    end
}

SMODS.Joker {
    key = 'dagon',
    loc_txt = { name = 'Dagon',
        text = { 'The disaster curse rooted in',
            'the fear of water, the deep and',
            'ultimately the unknown, {C:attention}fill{} all card',
            'slots with {C:attention}Splash{} plus {C:dark_edition}+1 negative {C:attention}Splash',
            'for every joker slot on {C:attention}selecting{} a blind' } },
    cost = 20,
    rarity = 4,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
        info_queue[#info_queue + 1] = G.P_CENTERS.j_splash
    end,
    add_to_deck = function(self,card)
        card.ability.extra.jokerslots = G.jokers.config.card_limit
    end,
    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local emptyJ = G.jokers.config.card_limit - #G.jokers.cards
            local emptyC = G.consumeables.config.card_limit - #G.consumeables.cards
            local emptyD = G.domain.config.card_limit - #G.domain.cards
            for i = 1, emptyJ do
                SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_splash' })
            end
            for i = 1, emptyC do
                SMODS.add_card({ set = 'Joker', area = G.consumeables, key = 'j_splash' })
            end
            for i = 1, emptyD do
                SMODS.add_card({ set = 'Joker', area = G.domain, key = 'j_splash' })
            end
        end
        if context.setting_blind or (context.setting_blind and context.blueprint) then
            for i = 1, card.ability.extra.jokerslots do
                SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_splash', edition = 'e_negative' })
            end
        end
    end
}

--end disaster curses

SMODS.Joker {
    key = 'shoko',
    loc_txt = { name = 'Shoko Ieiri',
        text = { 'Increase domain slots by {C:dark_edition}+1{}',
            '{s:0.8}"I was worried about you!"' } },
    rarity = 2,
    cost = 5,
    in_pool = function(self, args)
        if G.GAME.round_resets.ante >= 4 then
            return true
        end
    end,
    add_to_deck = function(self, card)
        G.domain.config.card_limit = G.domain.config.card_limit + 1
    end,
    remove_from_deck = function(self, card)
        G.domain.config.card_limit = G.domain.config.card_limit - 1
    end
}

SMODS.Joker {
    key = 'junpei',
    rarity = 1,
    cost = 4,
    blueprint_compat = true,
    loc_txt = {name = 'Junpei Yoshino',
                text = {'Gain {C:money}$#1#{} on purchasing an item',
                'from the shop'}},
    config = {extra = {
        dollars = 1
    }},
    loc_vars = function(self,info_queue,center)
        return {vars = {
            center.ability.extra.dollars
        }}
    end,
    calculate = function(self,card)
        if context.buying_card or context.open_booster or (context.buying_card and context.blueprint) or (context.open_booster and context.blueprint) then
            ease_dollars(card.ability.extra.dollars)
        end
    end
}

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
                    message = { '+1 Odds!', colour = G.C.GREEN }
                }
            else
                card.ability.extra.consc = 0
                card.ability.extra.consc_unc = 0
                if pseudorandom('hakbad', 1, 5) == 4 then
                    return {
                        chip_mod = -G.GAME.blind.chips,
                        message = {
                            '-' .. G.GAME.blind.chips,
                            colour = G.C.CHIPS
                        }
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
            return { mult_mod = card.ability.extra.mult,
                    message = localize{type='variable',key='a_mult',vars={self.ability.mult}} }
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
    blueprint_compat = true,
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
                card:juice_up(0.3, 0.5)
                return {
                    message = 'Adapted!', colour = G.C.CHIPS
                }
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
        if context.joker_main or context.blueprint then
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
                if G.jokers.cards[i].config.center.key == 'j_jjok_flyhead' and (G.jokers.cards[i].edition == nil or G.jokers.cards[i].edition.negative == false) then
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
            '{C:white,X:mult}X#2#{} Mult for every {C:attention}flyhead sold{}',
            '{s:0.8,C:inactive}(Currently{} {s:0.8,C:white,X:mult}X#1#{} {s:0.8,C:inactive}Mult)',
            '{s:0.8}"Kill sorcerors huh? Youre a sorceror."' } },
    config = { extra = { Xmult = 1, Xmult_gain = 0.25 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
        return { vars = {
             center.ability.extra.Xmult,
             center.ability.extra.Xmult_gain } }
    end,
    calculate = function(self, card, context)
        if context.selling_card then
            if context.card.config.center.key == 'j_jjok_flyhead' then
                card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
                return {
                    message = {'+'..card.ability.extra.Xmult_gain.. ' XMult'}
                }
            end
        end
        if context.joker_main or (context.blueprint and context.joker_main) then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
}

SMODS.Joker {
    key = 'kash',
    loc_txt = { name = 'Hajime Kashimo',
        text = { 'The strongest of the edo period,',
            'if any {C:attention}played card{} has seal, give every',
            'played card an {C:blue}Electric{} seal' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_SEALS.jjok_electric
    end,
    rarity = 2,
    cost = 4,
    calculate = function(self, card, context)
        local seal = false
        if context.before then
            for i, v in ipairs(G.play.cards) do
                if v.seal ~= nil then
                    seal = true
                end
            end
            if seal == true then
                for i, v in ipairs(G.play.cards) do
                    v:set_seal('jjok_electric', nil, true)
                end
            end
        end
    end
}

SMODS.Joker {
    key = 'toge',
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

SMODS.Joker {
    key = 'haruta',
    cost = 5,
    rarity = 1,
    atlas = 'atlasthree',
    blueprint_compat = true,
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
        if context.joker_main or (context.joker_main and context.blueprint) then
            if G.GAME.current_round.hands_left == 0 and card.ability.extra.charges > 0 then
                card.ability.extra.charges = card.ability.extra.charges - 1
                if G.GAME.round_resets.ante >= 2 then
                    return { Xmult = G.GAME.round_resets.ante / 2 }
                else
                    card.ability.extra.charges = card.ability.extra.charges + 1
                    return { Xmult = 1 }
                end
            end
        end
        if context.final_scoring_step and (hand_chips * mult) >= G.GAME.blind.chips and not context.blueprint then
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
    calculate = function(self, card, context)
        if context.joker_main and not context.blueprint then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips
            }
        end
        if context.joker_main and context.blueprint then
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
            'a playing card triggers',
            '{s:0.8, C:inactive}(Currently: {C:mult,s:0.8}+#1#{s:0.8, C:inactive} mult){}',
            '{s:0.8}"I alone am the honoured one"{}'
        }
    },
    blueprint_compat = false,
    rarity = 4,
    config = { extra = { mult = 0, mult_gain = 1 },
        unlocked = true,
        discovered = true },
    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = 'Concept Grasped',
                colour = G.C.MULT
            }
        end
        if context.joker_main then
            return {
                message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                mult_mod = card.ability.extra.mult
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

SMODS.Atlas {
    key = 'seal',
    path = 'seal.png',
    px = 68,
    py = 92
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
