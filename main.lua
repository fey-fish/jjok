SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
        post_trigger = true
    }
end

local items = NFS.getDirectoryItems(SMODS.current_mod.path .. "items")
for _, file in ipairs(items) do
    sendInfoMessage("Loading " .. file, "Jujutsu Jokers")
    assert(SMODS.load_file("items/" .. file))()
end

--colours

G.C.JJOK = {
    NATURE = HEX("B6D7A8"),
    PURPLE = HEX("6A329F"),
    PINK = HEX("A64D79"),
    LBLUE = HEX('3D85C6'),
    NAVY = HEX('134f5c'),
    JJK = HEX('660000'),
    TECH = HEX('F52742')
}

SMODS.Gradient {
    key = 'specialgrad',
    colours = { G.C.JJOK.PURPLE, G.C.JJOK.PINK },
    cycle = 3,
}
SMODS.Gradient {
    key = 'ctools',
    colours = { G.C.JJOK.LBLUE, G.C.JJOK.NAVY },
    cycle = 6,
}

local loc_colour_ref = loc_colour
function loc_colour(_c, _default)
    if not G.ARGS.LOC_COLOURS then
        loc_colour_ref()
    end
    G.ARGS.LOC_COLOURS.jjok_nature = G.C.JJOK.NATURE
    G.ARGS.LOC_COLOURS.jjok_jjk = G.C.JJOK.JJK
    G.ARGS.LOC_COLOURS.jjok_lblue = G.C.JJOK.LBLUE
    G.ARGS.LOC_COLOURS.jjok_tech = G.C.JJOK.TECH
    G.ARGS.LOC_COLOURS.jjok_ctools = SMODS.Gradients.jjok_ctools
    G.ARGS.LOC_COLOURS.jjok_special = SMODS.Gradients.jjok_specialgrad

    return loc_colour_ref(_c, _default)
end

local old_main_menu = Game.main_menu
function Game:main_menu(change_context)
    if not G.C.SPLASH then
        G.C.SPLASH = { HEX('FFFFFF'), HEX('000000') }
    end
    G.C.SPLASH[1] = pseudorandom_element(G.C.JJOK)
    G.C.SPLASH[2] = pseudorandom_element(G.C.JJOK)
    old_main_menu(self)
end

SMODS.Blind {
    key = 'prison',
    loc_txt = { name = 'Prison Realm',
        text = { 'Disable all Special Grade',
            'jokers' } },
    boss = {
        min = 8,
        mult = 2
    },
    boss_colour = SMODS.Gradients.jjok_specialgrad,
    recalc_debuff = function(self, card, from_blind)
        if (card.area == G.jokers) and not G.GAME.blind.disabled and card.config.center.rarity == 'jjok_special' then
            return true
        end
        return false
    end,
}

--[[SMODS.Blind {
    key = 'restriction',
    loc_txt = { name = 'Heavenly Restriction' }
}]]

SMODS.Blind {
    key = 'hospital',
    loc_txt = {
        name = 'The Hospital',
        text = {
            'Disable all',
            'Grade 4 Jokers'
        }
    },
    boss = {
        min = 1,
        max = 8,
        mult = 2
    },
    recalc_debuff = function(self, card, from_blind)
        if (card.area == G.jokers) and not G.GAME.blind.disabled and card.config.center.rarity == 1 then
            return true
        end
        return false
    end,
    boss_colour = HEX('999999')
}

--domains

SMODS.Booster {
    key = 'debooster',
    config = { extra = 2, choose = 1 },
    loc_txt = { name = 'Domain Booster',
        text = { 'Choose {C:attention}#1# of {C:attention}#2#',
            'Domain Expansions' },
        group_name = { 'Domain Expansions can mostly',
            'only be used once per ante' } },
    draw_hand = false,
    cost = 20,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.choose,
                center.ability.extra
            }
        }
    end,
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
    primary_colour = HEX('6A329F'),
    secondary_colour = HEX('6A329F'),
    loc_txt = {
        name = 'Domain Expansion',
        collection = 'Domain Expansion'
    },
    collection_rows = { 3, 3 },
    shop_rate = 0.0,
    hidden = true
}

SMODS.Consumable {
    key = 'mutuallove',
    set = 'domain',
    loc_txt = { name = 'Authentic Mutual Love',
        text = {
            'The domain expansion of the',
            'prodigy, {C:jjok_specialgrad}Yuta Okkotsu',
            '{s:1.1}Create {s:1.1,C:attention}#1#{s:1.1} random',
            '{s:1.1,C:attention}temporary{} Domains',
            '{s:0.8,C:inactive}(Currently #2#)'
        } },
    cost = 10,
    config = { extra = { used_this_ante = false, create = 2 } },
    keep_on_use = function(self, card)
        return true
    end,
    loc_vars = function(self, info_queue, center)
        if center.ability.extra.used_this_ante == true then
            return { vars = { center.ability.extra.create, 'Inactive' } }
        else
            return { vars = { center.ability.extra.create, 'Active' } }
        end
    end,
    can_use = function(self, card)
        if card.ability.extra.used_this_ante == false then
            return true
        end
    end,
    use = function(self, card)
        for i = 1, card.ability.extra.create do
            SMODS.add_card({ set = 'domain', edition = 'e_negative', stickers = { 'perishable' } })
            local pos = #G.domain.cards
            G.domain.cards[pos].ability.perish_tally = 1
        end
        card.ability.extra.used_this_ante = true
    end
}

--[[SMODS.Consumable {
    key = 'wickerbasket',
    set = 'domain',
    loc_txt = { name = 'Hollow Wicker Basket',
        text = {
            'The anti domain technique',
            'of the Heian era',
            '{s:1.1}Prevent {C:spectral,s:1.1}Ankh{s:1.1} from destroying',
            '{s:1.1}Jokers when active',
            '{s:0.8,C:inactive}(Currently #2#)'
        }},
    cost = 10,
    config = { extra = { used_this_ante = false} },
    keep_on_use = function(self, card)
        return true
    end,
    loc_vars = function(self,info_queue,center)
        if center.ability.extra.used_this_ante == true then
            return { vars = { center.ability.extra.create, 'Inactive' } }
        else
            return { vars = { center.ability.extra.create, 'Active' } }
        end
    end,
    calculate = function(self, card, context)
        if context.using_consumeable then
            if context.consumeable.config.center.key == 'c_ankh' then
                if card.ability.extra.used_this_ante == false then

                end
            end
        end
        if context.boss_defeat then
            card.ability.extra.used_this_ante = false
        end
    end
}]] --

SMODS.Consumable {
    key = 'seop',
    set = 'domain',
    cost = 10,
    config = { extra = { editionless_jokers = {}, used_this_ante = false } },
    loc_txt = { name = '{C:purple}Self Embodiment of Perfection',
        text = { 'Mahitos domain, effectively allowing him to',
            'kill anything with a soul, without even',
            'touching them',
            '{s:1.1}Changes {C:attention,s:1.1}1{s:1.1} random Joker to {C:dark_edition,s:1.1}negative{},',
            '{s:1.1}lose all {s:1.1,C:money}money',
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
        card.ability.extra.editionless_jokers = {}
        for i, v in pairs(G.jokers.cards) do
            if v.ability.set == "Joker" and (v.edition == nil or v.edition.negative == false) then
                table.insert(card.ability.extra.editionless_jokers, v)
            end
        end
        if card.ability.extra.editionless_jokers[1] and card.ability.extra.used_this_ante == false then
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
        ease_dollars(-G.GAME.dollars)
        card.ability.extra.used_this_ante = true
    end
}

SMODS.Consumable {
    key = 'idg',
    set = 'domain',
    cost = 10,
    loc_txt = {
        name = '{C:dark_edition}Idle Death Gamble',
        text = {
            'Hakaris domain expansion which',
            'grants him infinite cursed energy,',
            '{C:green}#1#{} in {C:green}#2#{} chance to {C:money}double money',
            '{C:green}#1#{} in {C:green}#3#{} chance to {C:chips}win blind',
            '{s:0.8,C:inactive}(Currently #4#)'
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
                center.ability.extra.modds,
                center.ability.extra.wodds,
                word
            }
        }
    end,
    config = { extra = { modds = 3, wodds = 10, used_this_ante = false } },
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
        if pseudorandom('idgmoney') < G.GAME.probabilities.normal / card.ability.extra.modds then
            ease_dollars(G.GAME.dollars)
        end
        if pseudorandom('idgwin') < G.GAME.probabilities.normal / card.ability.extra.wodds then
            G.GAME.chips = G.GAME.blind.chips
        end
    end
}

SMODS.Consumable {
    key = 'simple',
    cost = 6,
    set = 'domain',
    keep_on_use = function(self, card)
        return true
    end,
    loc_txt = { name = 'Simple Domain',
        text = {
            'Use to refresh deck',
            '{C:inactive}Can be used once per round',
            '{s:0.8,C:inactive}(Currently #1#)'
        } },
    config = { extra = { used_this_round = false, cards = {} } },
    loc_vars = function(self, info_queue, center)
        local word = nil
        if center.ability.extra.used_this_round == true then
            word = 'Inactive'
        else
            word = 'Active'
        end
        return { vars = { word } }
    end,
    can_use = function(self, card)
        if card.ability.extra.used_this_round == false then
            return true
        end
    end,
    use = function(self, card)
        card.ability.extra.last_ante_round = G.GAME.round
        card.ability.extra.used_this_round = true
        G.FUNCS.draw_from_discard_to_deck()
    end
}

SMODS.Consumable {
    key = 'coffin',
    cost = 10,
    set = 'domain',
    loc_txt = { name = '{C:diamonds}Coffin of the Iron Mountain',
        text = { 'Jogo, the mount fuji disaster',
            'curses domain, {C:attention}destroy{} all cards',
            'held in hand in exchange for {C:money}$#1#{} per',
            'card destroyed',
            '{s:0.8,C:inactive}(Currently #2#)' } },
    config = { extra = { money = 5, used_this_ante = false } },
    loc_vars = function(self, info_queue, center)
        local ac = 'Inactive'
        if center.ability.extra.used_this_ante == false then
            ac = 'Active'
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
        for i, v in ipairs(G.hand.cards) do
            v:valid_destroy()
            ease_dollars(card.ability.extra.money)
        end
    end
}

SMODS.Consumable {
    key = 'iv',
    set = 'domain',
    cost = 10,
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
        local ac
        if center.ability.extra.used_this_ante == false then
            ac = 'Active'
        else
            ac = 'Inactive'
        end
        return { vars = { ac } }
    end,
    config = { extra = { used_this_ante = false } },
    keep_on_use = function(self, card)
        return true
    end,
    can_use = function(self, card)
        if card.ability.extra.used_this_ante == false then
            return true
        end
    end,
    use = function(self, card)
        G.FUNCS.draw_from_deck_to_hand(#G.deck.cards)
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
    cost = 10,
    loc_txt = { name = '{C:red}Malevolent Shrine',
        text = { 'Sukunas barrierless domain,',
            'truly a divine feat, relentlessly',
            'slashes at everything in its range',
            '{s:1.1}Gives {s:1.1,X:dark_edition,C:white}^#1#{s:1.1} Mult',
            'increase by {X:dark_edition,C:white}#2#{} when {C:attention}defeating{} a blind',
            '{s:0.8,C:inactive}(Currently #3#)' } },
    config = { extra = { emult = 1.2, scale = 0.05, used_this_ante = false } },
    loc_vars = function(self, info_queue, center)
        local ac
        if center.ability.extra.used_this_ante == true then
            ac = 'Inactive'
        else
            ac = 'Active'
        end
        return {
            vars = {
                center.ability.extra.emult,
                center.ability.extra.scale,
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

SMODS.Atlas {
    key = 'kenjaku',
    path = 'Kenjaku.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'bodyhop',
    path = 'bodyhop.png',
    px = 71,
    py = 95
}

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
    end,
    config = { extra = { card_limit = 2, increase = 1, name = nil } },
    remove_from_deck = function(self, card)
        G[card.ability.extra.name]:remove()
    end,
    calculate = function(self, card, context)
        if context.boss_defeat then
            G[card.ability.extra.name].config.card_limit = G[card.ability.extra.name].config.card_limit +
                card.ability.extra.increase
        end
    end,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
    update = function(self, card, dt)
        if G[card.ability.extra.name] then
            G[card.ability.extra.name].T.x = card.T.x - 0.2
            G[card.ability.extra.name].T.y = card.T.y + card.T.h
        end
        if G.jokers then
            if G.jokers.highlighted[1] == card then
                G.jokers.config.highlighted_limit = 2
            else
                G.jokers.config.highlighted_limit = 1
            end
        end
    end
}

SMODS.Back {
    key = 'gojodeck',
    discovered = true,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                if G.consumeables then
                    SMODS.add_card({ key = 'c_soul' })
                    SMODS.add_card({ key = 'c_jjok_awaken' })
                    G.jokers.config.card_limit = G.jokers.config.card_limit - 2
                    return true
                end
            end
        }))
    end
}

SMODS.Back {
    key = 'zenindeck',
    discovered = true,
    apply = function(self, back)
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                local pool = {}
                for i, v in ipairs(G.P_CENTER_POOLS.Joker) do
                    if v.mod then
                        if v.mod.id == 'jjok' then
                            table.insert(pool, v)
                        end
                    end
                end
                SMODS.add_card({ key = pseudorandom_element(pool, pseudoseed('zenindeck')).key })
                return true
            end
        }))
    end
}

local set_screen_positions_func = set_screen_positions
function set_screen_positions()
    set_screen_positions_func()

    if G.domain then
        G.domain.T.x = G.TILE_W - G.domain.T.w - 0.3
        G.domain.T.y = 3
        G.domain:hard_set_VT()
    end
end

local use_and_sell_buttonsref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local retval = use_and_sell_buttonsref(card)
    local sell = nil
    local use = nil
    if card.area and card.area.config.type == 'joker' and card.ability.set == 'domain' then
        sell = {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {

                {
                    n = G.UIT.C,
                    config = {
                        ref_table = card,
                        align = "cr",
                        padding = 0.1,
                        r = 0.08,
                        minw = 1.25,
                        hover = true,
                        shadow = true,
                        colour = G.C.UI.BACKGROUND_INACTIVE,
                        one_press = true,
                        button = 'sell_card',
                        func = 'can_sell_card'
                    },
                    nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                        {
                            n = G.UIT.C,
                            config = { align = "tm" },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", maxw = 1.25 },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('b_sell'), colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true } }
                                    }
                                },
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm" },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('$'), colour = G.C.WHITE, scale = 0.4, shadow = true } },
                                        { n = G.UIT.T, config = { ref_table = card, ref_value = 'sell_cost_label', colour = G.C.WHITE, scale = 0.55, shadow = true } }
                                    }
                                }
                            }
                        }
                    }
                },
            }
        }
        use =
        {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {

                {
                    n = G.UIT.C,
                    config = {
                        ref_table = card,
                        align = "cr",
                        maxw = 1.25,
                        padding = 0.1,
                        r = 0.08,
                        minw = 1.25,
                        minh = (card.area and card.area.config.type == 'joker') and 0 or 1,
                        hover = true,
                        shadow = true,
                        colour = G.C.UI.BACKGROUND_INACTIVE,
                        one_press = true,
                        button = 'use_card',
                        func = 'can_use_consumeable'
                    },
                    nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                        { n = G.UIT.T, config = { text = localize('b_use'), colour = G.C.UI.TEXT_LIGHT, scale = 0.55, shadow = true } }
                    }
                }
            }
        }
    end
    return retval
end

--card areas end

SMODS.Voucher {
    key = 'cursedv',
    order = 1,
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
    in_pool = function(self, card)
        if G.GAME.round_resets.ante <= 4 then
            return true
        end
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
    order = 2,
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

SMODS.Voucher {
    key = 'limitless',
    loc_txt = { name = 'Limitless Technique',
        text = {
            'Increase card highlight',
            'limit by {C:dark_edition}+#1#{}'
        } },
    config = { extra = { increase = 1 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.increase
            }
        }
    end,
    cost = 10,
    redeem = function(self, card)
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + card.ability.extra.increase
    end
}

--enhancements
SMODS.Enhancement {
    key = 'resonated',
    config = { x_chips = 1.75 },
    loc_txt = { name = 'Resonated',
        text = { '{C:white,X:chips}X#1#{} Chips when scored' } },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.x_chips } }
    end
}

SMODS.Consumable {
    key = 'sdt',
    loc_txt = { name = 'Straw Doll Technique',
        text = {
            'Turn {C:attention}#1#{} card into',
            'a {C:chips}Resonated{} card'
        } },
    cost = 3,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_jjok_resonated
        return { vars = { center.ability.extra.cards } }
    end,
    set = 'Tarot',
    config = { extra = { cards = 1 } },
    can_use = function(self, card)
        if #G.hand.highlighted <= card.ability.extra.cards and #G.hand.highlighted > 0 then
            return true
        end
    end,
    use = function(self, card)
        JJOK.flip_enhance(card, 'm_jjok_resonated')
    end
}


--seals
SMODS.Seal {
    key = 'green',
    loc_txt = { name = 'Nature Seal',
        text = { 'On {C:attention}playing{} this card, {C:attention}randomize{}',
            'its {C:dark_edition}edition{}' },
        label = 'Nature Seal' },
    atlas = 'seal',
    pos = { x = 1, y = 0 },
    badge_colour = HEX('B6D7A8'),
    calculate = function(self, card, context)
        if context.before and context.cardarea == G.play then
            local edition = poll_edition('greenseal', nil, true, true)
            card:set_edition(edition)
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
    default_weight = 0.15,
    get_weight = function(self, weight, object_type)
        return weight
    end,
    pools = { ["Joker"] = true }
}

SMODS.Rarity {
    key = 'special',
    loc_txt = {
        name = 'Special Grade'
    },
    badge_colour = SMODS.Gradients.jjok_specialgrad,
    hidden = true
}

SMODS.Consumable {
    key = 'awaken',
    loc_txt = { name = 'Awakening',
        text = { 'Use to {C:attention}Awaken{} any {C:legendary}Grade 1',
            'sorceror to {C:jjok_special}Special Grade' } },
    set = 'Spectral',
    hidden = true,
    soul_set = 'Spectral',
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
            return true
        else
            return false
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
            return true
        end
    end,
    use = function(card, self)
        local kill = pseudorandom('awaken', 1, Count)
        G.jokers.cards[Legendary[kill]]:start_dissolve()
        SMODS.add_card({ set = 'Joker', area = G.jokers, rarity = 'jjok_special' })
    end
}

SMODS.Joker {
    key = 'yuji',
    rarity = 3,
    cost = 7,
    blueprint_compat = true,
    loc_txt = { name = 'Yuji Itadori',
        text = { '{C:mult}Mult{} cards give',
            '{C:white,X:mult}X#1#{} Mult when scored,',
            '{C:green}#2#/#3#{} chance to',
            '{C:attention}remove{} Mult enhancement' } },
    config = { extra = { Xmult = 2.5, odds = 5 } },
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
        if context.individual and context.cardarea == G.play then
            if SMODS.has_enhancement(context.other_card, 'm_mult') then
                return {
                    Xmult = card.ability.extra.Xmult,
                    colour = G.C.MULT,
                    card = context.other_card
                }
            end
        end
        if context.after then
            for i, v in ipairs(context.scoring_hand) do
                if SMODS.has_enhancement(v, 'm_mult') and SMODS.pseudorandom_probability(card, 'yujiitadori', G.GAME.probabilities.normal, card.ability.extra.odds) then
                    v:set_ability(G.P_CENTERS.c_base, nil, true)
                    v:juice_up()
                end
            end
            delay(0.5)
        end
    end
}

SMODS.ConsumableType {
    key = 'ctools',
    primary_colour = SMODS.Gradients.jjok_ctools,
    secondary_colour = SMODS.Gradients.jjok_ctools,
    loc_txt = {
        name = 'Cursed Tools',
        collection = 'Cursed Tools'
    },
    collection_rows = { 6, 6 },
    shop_rate = 0.2,
}

SMODS.Booster {
    key = 'cbooster',
    config = { extra = 3, choose = 1 },
    loc_txt = { name = 'Cursed Booster',
        text = { 'Choose {C:attention}#1# of {C:attention}#2#',
            'Cursed cards' },
        group_name = { 'Select a cursed tool' } },
    draw_hand = true,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.choose,
                center.ability.extra
            }
        }
    end,
    cost = 6,
    in_pool = function(self, args)
        return true
    end,
    create_card = function(self, card, i)
        return
            SMODS.create_card({
                set = pseudorandom_element({ 'ct', 'ctools' }, pseudoseed('cbooster')),
                area = G.pack_cards,
                skip_materialize = true
            })
    end,
    weight = 0.45
}

SMODS.Consumable {
    key = 'possword',
    set = 'ctools',
    loc_txt = { name = 'Sword of Extermination',
        text = {
            'Wielded by Mahoraga and imbued',
            'with positive energy, {C:green}#1#/#2#{} chance',
            '{C:attention}destroy{} a random Joker,',
            'else duplicate it',
            '{C:inactive}(Must have room)' } },
    config = { extra = { odds = 2 } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_maho
        return {
            vars = {
                G.GAME.probabilities.normal,
                center.ability.extra.odds
            }
        }
    end,
    can_use = function(self, card, context)
        if #G.jokers.cards < G.jokers.config.card_limit then
            return true
        end
    end,
    use = function(self, card)
        local _card = pseudorandom_element(G.jokers.cards, pseudoseed('possword'))
        if pseudorandom('possword') < G.GAME.probabilities.normal / card.ability.extra.odds then
            _card:valid_destroy()
        else
            local copied_joker = copy_card(_card, nil, nil, nil, _card.edition and _card.edition.negative)
            copied_joker:start_materialize()
            copied_joker:add_to_deck()
            G.jokers:emplace(copied_joker)
        end
    end
}

SMODS.Consumable {
    key = 'invertedspear',
    set = 'ctools',
    loc_txt = { name = 'Inverted Spear of Heaven',
        text = {
            '{C:attention}Destroy{} up to #2# random',
            'Jokers and gain {C:dark_edition}#1# Joker slot',
            '{s:0.8,C:inactive}(Must hold atleast #2# Jokers)' } },
    cost = 6,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.slots,
                center.ability.extra.req
            }
        }
    end,
    config = { extra = { slots = 1, req = 3 } },
    can_use = function(self, card)
        if #G.jokers.cards >= card.ability.extra.req then
            return true
        end
    end,
    use = function(self, card, context)
        local pos, temp, valid, counter = {}, nil, true, 0
        for i = 1, card.ability.extra.req do
            pseudorandom_element(G.jokers.cards, pseudoseed('invspear')):valid_destroy()
        end
        G.jokers.config.card_limit = G.jokers.config.card_limit + card.ability.extra.slots
    end
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
            return true
        end
    end,
    use = function(card, self)
        for i = 1, #Destroyed_cards do
            Destroyed_cards[i]:valid_destroy()
        end
    end
}

SMODS.Consumable {
    key = 'nanamitool',
    set = 'ctools',
    cost = 4,
    hidden = true,
    loc_txt = { name = 'Nanamis Wrapped Blade',
        text = { 'A blade wrapped in',
            'a white speckled wrapping,',
            'use to {C:attention}empower Ino',
            '{s:0.8}"Imbued with the ratio technique"' } },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_ino
    end,
    can_use = function(card, self)
        if SMODS.find_card('j_jjok_ino')[1] then
            return true
        end
    end,
    use = function(card, self)
        local inos = SMODS.find_card('j_jjok_ino')
        local chosen = pseudorandom_element(inos, pseudoseed('wrappedblade'))
        chosen.ability.extra.emp = true
        return {
            message = 'Empowered!',
            message_card = chosen
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
        if M then
            return { true }
        end
    end,
    use = function(card, self)
        G.jokers.cards[M]:start_dissolve()
        SMODS.add_card({ set = 'Joker', area = G.jokers, key = 'j_jjok_amaki' })
    end
}

SMODS.Joker {
    key = 'juzo',
    rarity = 3,
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
            _xchips = 1 + (G.GAME.consumeable_usage_total.ctools or 0 * center.ability.extra.Xchips_mod)
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
                    xchips = (G.GAME.consumeable_usage_total.ctools or 0 * card.ability.extra.Xchips_mod) + 1
                }
            end
        end
    end
}

SMODS.Consumable {
    key = 'pride',
    set = 'Tarot',
    cost = 5,
    config = { extra = { dollars_gain = 2 } },
    loc_txt = { name = 'Pride',
        text = {
            'Gain {C:money}$#1#{} on use',
            '{s:0.8,C:inactive}(Increase by {C:money,s:0.8}$#2#{s:0.8,C:inactive} after use)' } },
    loc_vars = function(self, info_queue, center)
        local dollars = nil
        if G.GAME.consumeable_usage == nil or G.GAME.consumeable_usage.c_jjok_pride == nil then
            dollars = 0
        elseif G.GAME.consumeable_usage.c_jjok_pride ~= nil then
            dollars = G.GAME.consumeable_usage.c_jjok_pride.count * center.ability.extra.dollars_gain
        end
        return {
            vars = {
                dollars, center.ability.extra.dollars_gain }
        }
    end,
    can_use = function(self, card)
        return true
    end,
    use = function(self, card)
        if G.GAME.consumeable_usage ~= nil and G.GAME.consumeable_usage.c_jjok_pride ~= nil then
            ease_dollars((G.GAME.consumeable_usage.c_jjok_pride.count - 1) * card.ability.extra.dollars_gain)
        end
    end
}

SMODS.Consumable {
    key = 'bodyhop',
    set = 'Tarot',
    atlas = 'bodyhop',
    cost = 3,
    loc_txt = {
        name = 'Body Hop',
        text = {
            'Select {C:attention}two{} cards, cards will',
            '{C:attention}transfer{} {C:edition}edition{} and {C:edition}seal' } },
    can_use = function(self, card)
        if #G.hand.highlighted == 2 then
            return true
        end
    end,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
    use = function(self, card)
        local card1 = copy_card(G.hand.highlighted[1])
        local card2 = copy_card(G.hand.highlighted[2])
        G.hand.highlighted[1]:set_edition((card2.edition and card2.edition.key))
        G.hand.highlighted[1]:set_seal(card2.seal)
        G.hand.highlighted[2]:set_edition((card1.edition and card1.edition.key))
        G.hand.highlighted[2]:set_seal(card1.seal)
        card1:remove()
        card2:remove()
    end
}

SMODS.Consumable {
    key = 'sloth',
    set = 'Tarot',
    loc_txt = { name = 'Sloth',
        text = { '{C:attention}Create{} a flyhead' } },
    can_use = function(self, card)
        return { true }
    end,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_flyhead
    end,
    use = function(self, card)
        SMODS.add_card({ set = 'Joker', key = 'j_jjok_flyhead' })
        if pseudorandom('sloth', 1, (100 / G.GAME.probabilities.normal)) == 100 then
            SMODS.add_card({ set = 'Joker', rarity = 'jjok_special' })
        end
    end
}

SMODS.Consumable {
    key = 'lust',
    set = 'Tarot',
    loc_txt = { name = 'Lust',
        text = { 'Turn a random Joker',
            '{C:edition}Polychrome{} and eternal' } },
    can_use = function(self, card)
        if #G.jokers.cards ~= 0 then
            return true
        end
    end,
    use = function(self, card, area, copier)
        local lustcard = pseudorandom_element(G.jokers.cards, pseudoseed('lust'))
        lustcard:set_edition('e_polychrome')
        lustcard.ability.eternal = true
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
    config = { extra = { editionless = {} } },
    can_use = function(self, card)
        card.ability.extra.editionless = {}
        for i, v in ipairs(G.consumeables.cards) do
            if v.edition == nil then
                table.insert(card.ability.extra.editionless, v)
            end
        end
        if #card.ability.extra.editionless > 0 and #G.consumeables.cards > 1 or (#G.consumeables.cards == 1 and G.consumeables.cards[1] ~= card) then
            return true
        end
    end,
    use = function(self, card)
        local _card = pseudorandom_element(card.ability.extra.editionless, pseudoseed('veil'))
        _card:set_edition('e_negative')
    end
}

SMODS.Consumable {
    key = 'imbue',
    set = 'Tarot',
    pos = { x = 0, y = 0 },
    loc_txt = { name = 'Cursed Imbue',
        text = { 'Use to imbue cursed energy',
            'into a card, creating a random',
            '{C:jjok_ctools}Cursed Tool' } },
    can_use = function(card, self)
        if #G.consumeables.cards < G.consumeables.config.card_limit or card.area == G.consumeables then
            return true
        end
    end,
    use = function(card, self)
        SMODS.add_card({ set = 'ctools' })
    end
}

-- sukuna start
SMODS.Consumable {
    key = 'sukfin',
    set = 'ctools',
    cost = 6,
    config = { extra = { yuji_pre = false, suku_pre = false } },
    loc_txt = { name = 'Sukunas Finger',
        text = { 'A finger of the king of curses, use',
            'to {C:attention}transform Yuji or {C:attention}empower {C:mult}Sukuna',
            '{s:0.8,C:inactive}(Prioritises transforming Yuji)',
            '{s:0.8}"Each containing the soul of Ryomen Sukuna"' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_yuji
    end,
    can_use = function(self, card)
        card.ability.extra.yuji_pre = JJOK.find_joker('j_jjok_yuji')
        card.ability.extra.suku_pre = JJOK.find_joker('j_jjok_sukuna')
        if card.ability.extra.yuji_pre then
            return true
        elseif card.ability.extra.suku_pre and G.jokers.cards[card.ability.extra.suku_pre].ability.extra.fingers < 20 then
            return true
        end
    end,
    use = function(self, card)
        if card.ability.extra.yuji_pre then
            G.jokers.cards[card.ability.extra.yuji_pre]:valid_destroy(true)
            SMODS.add_card({ set = 'Joker', are = G.jokers, key = 'j_jjok_sukuna' })
        else
            G.jokers.cards[card.ability.extra.suku_pre].ability.extra.fingers = G.jokers.cards
                [card.ability.extra.suku_pre].ability.extra.fingers + 1
            G.jokers.cards[card.ability.extra.suku_pre]:juice_up()
        end
    end,
    in_pool = function(self, args)
        if JJOK.find_joker('j_jjok_sukuna') or JJOK.find_joker('j_jjok_yuji') then
            return true
        end
    end
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_sukfin
        local name, colours = nil, {}
        local main_end = {}
        if center.ability.extra.phase == 1 or not center.ability.extra.phase then
            name = 'Yuji-Kuna'
            colours = { G.C.WHITE }
            main_end = {
                {
                    n = G.UIT.C, config = {padding = 0.03}, nodes = {
                        {n = G.UIT.R, config = {}, nodes = {
                            {n = G.UIT.T, config = {text = 'The first vessel of the King', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}}
                        },
                        {n = G.UIT.R, config = {align = 'cm', padding = 0.03}, nodes = {
                            {n = G.UIT.T, config = {text = '+20', scale = 0.28, colour = G.C.MULT}},
                            {n = G.UIT.T, config = {text = (' Mult for every finger'), scale = 0.28, colour = G.C.UI.TEXT_DARK}}
                        }},
                        {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.T, config = {text = '(Currently ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}},
                            {n = G.UIT.T, config = {text = ('+'..center.ability.extra.fingers*20), scale = 0.32, colour = G.C.MULT}},
                            {n = G.UIT.T, config = {text = ' Mult)', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}},
                        }},
                    }
                }
            }
        elseif center.ability.extra.phase == 2 then
            name = 'Meg-una'
            colours = { G.C.RED }
            main_end = {
                {
                    n = G.UIT.C, config = {padding = 0.03}, nodes = {
                        {n = G.UIT.R, config = {}, nodes = {
                            {n = G.UIT.T, config = {text = "This mug's more handsome", scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}}
                        },
                        {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.C, config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' }, nodes = {
                                {n = G.UIT.T, config = {text = 'X0.75', scale = 0.28, colour = G.C.WHITE}},
                            }},
                            {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                                {n = G.UIT.T, config = {text = (' Mult for every finger'), scale = 0.28, colour = G.C.UI.TEXT_DARK}}
                            }},
                        }},
                        {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                                {n = G.UIT.T, config = {text = '(Currently ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.C, config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' }, nodes = {
                                {n = G.UIT.T, config = {text = ('X'..((center.ability.extra.fingers*0.75)+1)), scale = 0.32, colour = G.C.WHITE}},
                            }},
                            {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                                {n = G.UIT.T, config = {text = (' Mult)'), scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                        }}
                    }
                }
            }
        elseif center.ability.extra.phase == 3 then
            name = 'True-Form Sukuna'
            colours = { G.C.BLACK }
            main_end = {
                {
                    n = G.UIT.C, config = {padding = 0.03}, nodes = {
                        {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.T, config = {text = "The King of Curses", scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}}
                        },
                        {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.C, config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' }, nodes = {
                                {n = G.UIT.T, config = {text = 'X2.5', scale = 0.28, colour = G.C.WHITE}},
                            }},
                            {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                                {n = G.UIT.T, config = {text = (' Mult for every finger'), scale = 0.28, colour = G.C.UI.TEXT_DARK}}
                            }},
                        }},
                        {n = G.UIT.R, config = {align = 'cm', padding = 0.03}, nodes = {
                            {n = G.UIT.T, config = {text = 'and ', scale = 0.28, colour = G.C.UI.TEXT_DARK}},
                            {n = G.UIT.T, config = {text = '$10', scale = 0.28, colour = G.C.MONEY}},
                            {n = G.UIT.T, config = {text = ' when scored', scale = 0.28, colour = G.C.UI.TEXT_DARK}}
                        }},
                        {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                            {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                                {n = G.UIT.T, config = {text = '(Currently ', scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                            {n = G.UIT.C, config = { colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15, align = 'cm' }, nodes = {
                                {n = G.UIT.T, config = {text = ('X'..(center.ability.extra.fingers*2.5)), scale = 0.32, colour = G.C.WHITE}},
                            }},
                            {n = G.UIT.C, config = {padding = 0.03}, nodes = {
                                {n = G.UIT.T, config = {text = (' Mult)'), scale = 0.32, colour = G.C.UI.TEXT_INACTIVE}}
                            }},
                        }}
                    }
                }
            }
        end
        return {
            vars = {name, colours = colours},
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
    path = 'yujikuna.png',
    px = 71,
    py = 95
}

-- sukuna end

-- disaster curses
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
        ease_ce(10)
        card.ability.extra.hand_size = G.hand.config.card_limit
    end,
    calculate = function(self, card, context)
        if G.hand.config.card_limit ~= card.ability.extra.hand_size then
            G.hand.config.card_limit = card.ability.extra.hand_size
        end
    end,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
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
    path = 'mahito.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'majito',
    path = 'majito.png',
    px = 71,
    py = 95
}

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
    path = 'Cthulu.png',
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

--end disaster curses



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

SMODS.Consumable {
    key = 'puppet',
    set = 'Spectral',
    cost = 5,
    loc_txt = { name = 'Puppet',
        text = {
            'Use to {C:attention}create{} a random {C:attention}tag' } },
    can_use = function(self, card)
        return true
    end,
    use = function(self, card)
        G.orbital_hand = G.GAME.current_round.most_played_poker_hand
        local tag = pseudorandom_element(G.P_CENTER_POOLS.Tag, pseudoseed('puppet'))
        add_tag(Tag(tag.key, false, 'Small'))
    end
}

--[[SMODS.Joker {
    key = 'kash',
    loc_txt = { name = 'Hajime Kashimo',
        text = { 'The strongest of the edo period,',
            'if any {C:attention}played card{} has seal, give every',
            'played card an {C:jjok_lblue}Conductive{} seal' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_SEALS.jjok_electric
    end,
    rarity = 3,
    cost = 6,
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
                return { message = 'Electrified!', message_card = card, colour = G.C.BLUE }
            end
        end
    end
}]]

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
    key = 'yoro',
    cost = 20,
    rarity = 4,
    loc_txt = { name = 'Yorozu',
        text = {
            'Add another {C:attention}Card{} slot, {C:attention}Booster',
            'pack and {C:attention}Voucher{} to the shop'
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
    config = { extra = { xchips = 1.5 } },
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
    end,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
}

SMODS.Atlas {
    key = 'yuki',
    path = 'yuki.png',
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
    end,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end
}

SMODS.Atlas {
    key = 'hakari',
    path = 'hakari.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'meg',
    cost = 12,
    rarity = 2,
    blueprint_compat = true,
    loc_txt = { name = 'Megumi Fushiguro',
        text = { 'Upon selecting a {C:attention}boss blind,',
            '{C:attention}create{} 1 a Ten Shadows',
            'shikigami' } },
    calculate = function(self, card, context)
        if context.setting_blind and G.GAME.blind.boss == true then
            local _card = pseudorandom_element(G.P_CENTER_POOLS.meg_shi, pseudoseed('megumi'))
            SMODS.add_card({ key = _card.key })
        end
    end
}

SMODS.ObjectType {
    key = 'meg_shi'
}

SMODS.ObjectType {
    key = 'curses'
}

--fuck it, all the shikigami
SMODS.Joker {
    key = 'maho',
    rarity = 'jjok_shiki',
    pools = { meg_shi = true },
    cost = 10,
    loc_txt = { name = '{C:money}Mahoraga',
        text = { 'Eight handled sword, divergent sila,',
            'divine general, {C:money}Mahoraga!',
            'Upon playing a hand, {C:attention}reduce blind size by 20%{}',
            'up to a maximum of {X:chips,C:white}1x{} ante base blind size',
            '{s:0.8,C:inactive}(Current base blind size = {C:chips,s:0.8}#1#{s:0.8,C:inactive})',
            '{s:0.8,C:hearts}"MAHORAGA HELP ME!"' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { get_blind_amount(G.GAME.round_resets.ante) } }
    end,
    calculate = function(self, card, context)
        if G.GAME.blind.chips > get_blind_amount(G.GAME.round_resets.ante) then
            if context.before then
                G.GAME.blind.chips = G.GAME.blind.chips * 0.8
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
    pools = { meg_shi = true },
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
    key = 'cgeto',
    loc_txt = { name = '{C:spades}Suguru Geto',
        text = { 'On selecting a blind, fill all card',
            'slots with random cards',
            '{s:0.8}"The worst curse user in history"' } },
    rarity = 'jjok_special',
    cost = 40,
    calculate = function(self, card, context)
        if context.setting_blind then
            local space = G.jokers.config.card_limit - G.jokers.config.card_count
            for i = 1, space do
                SMODS.add_card({ set = 'Joker' })
            end
            if G.consumeables.config.card_limit - #G.consumeables.cards < 0 then
            for i = 1, G.consumeables.config.card_limit - #G.consumeables.cards do
                local _ctype = pseudorandom_element(SMODS.ConsumableTypes, pseudoseed('sugurugeto'))
                SMODS.add_card({ set = _ctype.key })
            end
        end
            if G.domain.config.card_limit - #G.domain.cards < 0 then
                for i = 1, G.domain.config.card_limit - #G.domain.cards do
                    SMODS.add_card({ set = 'domain' })
                end
            end
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
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
    path = 'Exec.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'toji',
    rarity = 3,
    blueprint_compat = true,
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
        if context.joker_main then
            return { Xmult = card.ability.extra.Xmult }
        end
        if context.setting_blind and not context.blueprint then
            Create = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    if #G.jokers.cards >= i + 1 then
                        if not SMODS.is_eternal(G.jokers.cards[i + 1]) then
                            card.ability.extra.Xmult = card.ability.extra.Xmult + (G.jokers.cards[i + 1].sell_cost / 5)
                            G.jokers.cards[i + 1]:valid_destroy()
                            play_sound('slice1', 0.96 + math.random() * 0.08)
                        end
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
    key = 'takako',
    atlas = 'takako',
    loc_txt = { name = 'Takako',
        text = {
            '{C:planet}Blue{} Seals now {C:attention}create',
            '{C:dark_edition}3 Negative{} {C:planet}Planet{} cards' } },
    rarity = 4,
    cost = 8,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
    discovered = true
}

SMODS.Atlas {
    key = 'takako',
    path = 'takako.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'panda',
    loc_txt = { name = 'Panda',
        text = {
            'Gain {C:money}$#1#{} dollars when scoring',
            'an enhancment, {C:attention}destroy{} the enhancement',
            'and increase payout by {C:money}$#2#',
            "{C:inactive}(Reset if a scored card isn't enhanced)" } },
    config = { extra = { cur = 0, inc = 1 } },
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
    key = 'flyhead',
    rarity = 'jjok_cs',
    cost = 1,
    atlas = 'flyhead',
    blueprint_compat = true,
    loc_txt = { name = 'Fly Heads',
        text = { 'A useless {C:common}Grade 4',
            'cursed spirit',
            'gives {C:mult}+#1#{} Mult and {C:chips}+#2#{} chips' } },
    config = { extra = { mult = 1, chips = 1 } },
    loc_vars = function(card, info_queue, center)
        return {
            vars = { center.ability.extra.mult,
                center.ability.extra.chips }
        }
    end,
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('fey')
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                chips = card.ability.extra.chips
            }
        end
    end
}

SMODS.Atlas {
    key = 'flyhead',
    path = 'flyheads.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'swarm',
    rarity = 'jjok_cs',
    in_pool = function(self, card)
        return false
    end,
    cost = 0,
    pools = { ['curses'] = true },
    loc_txt = {
        name = 'Swarm of Flyheads',
        text = { 'Duplicate in {C:attention}#1#{} rounds',
            '{s:0.8,C:inactive}(Must have space)',
            '{s:0.8,C:inactive}(Cannot be sold)' }
    },
    config = { extra = { rounds = 2 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.rounds,
            }
        }
    end,
    blueprint_compat = false,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds == 0 then
                card.ability.extra.rounds = 2
                if #G.jokers.cards < G.jokers.config.card_limit then
                    local copied_joker = copy_card(card, nil, nil, nil, card.edition and card.edition.negative)
                    copied_joker:start_materialize()
                    copied_joker:add_to_deck()
                    G.jokers:emplace(copied_joker)
                end
            else
                return {
                    message = tostring(card.ability.extra.rounds),
                    message_card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'smallpox',
    rarity = 'jjok_cs',
    in_pool = function(self, card)
        return false
    end,
    cost = 0,
    pools = { ['curses'] = true },
    loc_txt = {
        name = 'Smallpox Deity',
        text = { 'Destroy within {C:attention}#1#',
            'rounds, else {C:mult}lose',
            'this run',
            '{s:0.8,C:inactive}(Cannot be sold)' }
    },
    config = { extra = { rounds = 6 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.rounds
            }
        }
    end,
    blueprint_compat = false,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds == 0 then
                G.STATE = G.STATES.GAME_OVER
                G.STATE_COMPLETE = false
            else
                return {
                    message = tostring(card.ability.extra.rounds),
                    message_card = card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'kuro',
    rarity = 'jjok_cs',
    in_pool = function(self, card)
        return false
    end,
    cost = 0,
    pools = { ['curses'] = true },
    loc_txt = {
        name = 'Kurourushi',
        text = { 'Destroys {C:attention}#1#{} Joker',
            'at the end of',
            'each {C:attention}ante',
            '{s:0.8,C:inactive}(Cannot be sold)' }
    },
    config = { extra = { cards = 1 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.cards
            }
        }
    end,
    blueprint_compat = false,
    eternal_compat = false,
    calculate = function(self, card, context)
        if context.boss_defeat then
            pseudorandom_element(G.jokers.cards, pseudoseed('kuro'))
        end
    end
}

SMODS.Joker {
    key = 'onna',
    cost = 1,
    pools = { ['curses'] = true },
    in_pool = function(self, card)
        return false
    end,
    rarity = 'jjok_cs',
    loc_txt = { name = 'Kuchisake Onna',
        text = {
            'Cards can no',
            'longer be bought',
            '{s:0.8,C:inactive}(Cannot be sold)'
        } }
}

SMODS.Joker {
    key = 'fb',
    rarity = 'jjok_cs',
    cost = 2,
    eternal_compat = false,
    loc_txt = { name = 'Finger Bearer',
        text = { 'Gain one of {C:red}Sukunas Fingers{} upon',
            '{C:attention}defeating{} the boss blind',
            '{s:0.8,C:inactive}({s:0.8,C:white,X:mult}X#1#{s:0.8,C:inactive} boss blind size)' } },
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
            SMODS.add_card({ key = 'c_jjok_sukfin' })
            card:start_dissolve()
        end
    end
}

SMODS.Joker {
    key = 'roppo',
    loc_txt = { name = 'Roppongi Curse',
        text = { '{C:white,X:mult}X#1#{} Mult if played',
            'hand contains a {C:attention}Flush{},',
            'otherwise hand {C:inactive}will not score' } },
    config = { extra = { Xmult = 3 } },
    rarity = 'jjok_cs',
    cost = 4,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.Xmult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.debuff_hand and not context.blueprint then
            if not context.poker_hands['Flush'][1] then
                return { debuff = true }
            end
        end
        if context.joker_main and context.poker_hands['Flush'][1] then
            return {
                Xmult = card.ability.extra.Xmult
            }
        end
    end
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
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
    path = 'amaki.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'naoya',
    loc_txt = { name = "Naoya Zen'in",
        text = {
            '{C:white,X:mult}XMult{} = {C:white,X:dark_edition}Ante ^ 2{} - ',
            '{C:inactive}(Time in Ante Blinds x (Round/100))' } },
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
            vars = {
                G.GAME.naoya_mult
            },
            main_end = main_end
        }
    end,
    config = { extra = { Xmult = 1 } },
    rarity = 'jjok_special',
    cost = 40,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult = G.GAME.naoya_mult
            }
        end
    end
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
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
    path = 'Teacher_Gojo.png',
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
    calculate = function(self, card, context)
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
    path = 'nanami.png',
    px = 71,
    py = 95
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
                            { n = G.UIT.T, config = { text = 'X' .. (card.ability.extra.cycles * card.ability.extra.scaling.Xmult), scale = 0.32, colour = G.C.UI.TEXT_LIGHT } }
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

SMODS.Joker {
    key = 'higu',
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
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
                message = 'Concept Grasped',
                colour = G.C.MULT,
                message_card = card
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
    key = 'ygojo',
    path = 'Student_Gojo.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'seal',
    path = 'seal.png',
    px = 68,
    py = 92
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
    set_badges = function(self, card, badges)
        badges[#badges + 1] = JJOK.credit('tac')
    end,
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
    path = 'futa.png',
    px = 71,
    py = 95
}
