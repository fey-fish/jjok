SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
        post_trigger = true
    }
end

-- loading files, dont copy this unless you understand allat (i barely do lmao)
local function load_dir(fs_path, mod_path)
    for _, name in ipairs(NFS.getDirectoryItems(fs_path)) do
        local full = fs_path .. name
        if NFS.getInfo(full).type == "directory" then
            load_dir(full .. "/", mod_path .. name .. "/")
        elseif full:match('.lua$') then
            sendInfoMessage("Loading " .. name .. " Jujutsu Jokers")
            assert(SMODS.load_file(mod_path .. name))()
        end
    end
end

load_dir(SMODS.current_mod.path .. "items/", "items/")

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

SMODS.Consumable {
    key = 'wickerbasket',
    set = 'domain',
    loc_txt = { name = 'Hollow Wicker Basket',
        text = {
            'The anti domain technique',
            'of the Heian era',
            '{s:1.1}Prevent {C:spectral,s:1.1}Ankh{s:1.1} from destroying',
            '{s:1.1}Jokers when active',
            '{s:0.8,C:inactive}(Currently #2#)'
        } },
    cost = 10,
    config = { extra = { used_this_ante = false } },
    keep_on_use = function(self, card)
        return true
    end,
    loc_vars = function(self, info_queue, center)
        if center.ability.extra.used_this_ante == true then
            return { vars = { center.ability.extra.create, 'Inactive' } }
        else
            return { vars = { center.ability.extra.create, 'Active' } }
        end
    end
}

SMODS.Consumable {
    key = '9tails',
    set = 'domain',
    cost = 10,
    config = { extra = {} },
    loc_txt = {
        name = 'The 9 Tails Chakra',
        text = {
            'Generate {C:attention}#1#',
            '{C:attention}Cursed Energy{} at the',
            'end of each round'
        }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.ce or 10 } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            ease_ce(card.ability.extra.ce or 10)
        end
    end
}

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
            '{s:1.1}Gives {s:1.1,X:mult,C:white}X#1#{s:1.1} Mult',
            'increase by {X:mult,C:white}#2#{} when {C:attention}defeating{} a blind',
            '{s:0.8,C:inactive}(Currently #3#)' } },
    config = { extra = { xmult = 2, scale = 0.4, used_this_ante = false } },
    loc_vars = function(self, info_queue, center)
        local ac
        if center.ability.extra.used_this_ante == true then
            ac = 'Inactive'
        else
            ac = 'Active'
        end
        return {
            vars = {
                center.ability.extra.xmult,
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
            return {
                xmult = card.ability.extra.xmult
            }
        end
        if context.end_of_round and context.cardarea == G.domain and card == card then
            card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.scale
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
    key = 'bodyhop',
    path = 'tac/bodyhop.png',
    px = 71,
    py = 95
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
        SMODS.add_card({ rarity = 'jjok_special' })
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
        SMODS.add_card({ key = 'j_jjok_flyhead' })
        if pseudorandom('sloth', 1, (100 / G.GAME.probabilities.normal)) == 100 then
            SMODS.add_card({ rarity = 'jjok_special' })
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
    atlas = 'veil',
    loc_txt = { name = 'Veil',
        text = {
            'Draw a veil to {C:attention}add',
            '{C:dark_edition}negative to a',
            'random held consumable' } },
    loc_vars = function(self, info_queue, center)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
    end,
    can_use = function(self, card)
        local editionless = {}
        for i, v in ipairs(G.consumeables.cards) do
            if v ~= card and not v.edition then
                table.insert(editionless, v)
            end
        end
        if editionless[1] then
            return true
        end
    end,
    use = function(self, card)
        local editionless = {}
        for i, v in ipairs(G.consumeables.cards) do
            if v ~= card and not v.edition then
                table.insert(editionless, v)
            end
        end
        local _card = pseudorandom_element(editionless, pseudoseed('veil'))
        _card:set_edition('e_negative')
    end
}

SMODS.Atlas {
    key = 'veil',
    path = 'fey/veil.png',
    px = 71,
    py = 95
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
        if (#G.consumeables.cards < G.consumeables.config.card_limit) or card.added_to_deck then
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
        local yuji, sukuna = SMODS.find_card('j_jjok_yuji'), SMODS.find_card('j_jjok_sukuna')
        local fingies = false
        for i, v in ipairs(sukuna) do
            if v.ability.extra.fingers < 20 then
                fingies = true
            end
        end
        if yuji[1] or fingies then
            return true
        end
    end,
    use = function(self, card)
        local yuji, sukuna = SMODS.find_card('j_jjok_yuji'), SMODS.find_card('j_jjok_sukuna')
        local fingietable = {}
        for i, v in ipairs(sukuna) do
            if v.ability.extra.fingers < 20 then
                table.insert(fingietable, v)
            end
        end
        if yuji[1] then
            local edition = yuji[1].edition and yuji[1].edition.key
            local area = yuji[1].area
            yuji[1]:start_dissolve()
            SMODS.add_card({ key = 'j_jjok_sukuna', area = area, edition = edition })
        elseif sukuna[1] then
            local unckuna = pseudorandom_element(fingietable, pseudoseed('fingies'))
            unckuna.ability.extra.fingers = unckuna.ability.extra.fingers + 1
            unckuna:juice_up()
        end
    end,
    in_pool = function(self, args)
        if JJOK.find_joker('j_jjok_sukuna') or JJOK.find_joker('j_jjok_yuji') then
            return true
        end
    end
}

SMODS.Consumable {
    key = 'puppet',
    set = 'Spectral',
    cost = 5,
    loc_txt = { name = 'Puppet',
        text = {
            'Use to {C:attention}create',
            'a random {C:attention}Tag' } },
    can_use = function(self, card)
        return true
    end,
    use = function(self, card)
        G.orbital_hand = G.GAME.current_round.most_played_poker_hand
        local tag = pseudorandom_element(G.P_CENTER_POOLS.Tag, pseudoseed('puppet'))
        add_tag(Tag(tag.key, false, 'Small'))
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
            'up to a maximum of {C:attention}X0.75{} ante base blind size',
            '{s:0.8,C:inactive}(Current base blind size = {C:chips,s:0.8}#1#{s:0.8,C:inactive})' } },
    loc_vars = function(self, info_queue, card)
        return { vars = { (get_blind_amount(G.GAME.round_resets.ante) * 0.75) } }
    end,
    calculate = function(self, card, context)
        if G.GAME.blind.chips > (get_blind_amount(G.GAME.round_resets.ante) * 0.75) then
            if context.before then
                G.GAME.blind.chips = G.GAME.blind.chips * 0.8
                if G.GAME.blind.chips < get_blind_amount(G.GAME.round_resets.ante) then
                    G.GAME.blind.chips = get_blind_amount(G.GAME.round_resets.ante)
                end
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                SMODS.juice_up_blind()
                card:juice_up(0.3, 0.5)
                return {
                    message = 'Adapted!', colour = G.C.FILTER
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

SMODS.Joker {
    key = 'toad',
    rarity = 'jjok_shiki',
    cost = 10,
    pools = { meg_shi = true },
    loc_txt = { name = 'Gama',
        text = { '{C:green}#1#/#2#{} chance to {C:attention}duplicate',
            'any used consumable',
            '{s:0.8,C:inactive}(Must have space)' } },
    config = { extra = { odds = 3 } },
    loc_vars = function(self, info_queue, center)
        return { vars = { (G.GAME.probabilities.normal or 0), center.ability.extra.odds } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable then
            local con = context.consumeable
            if ((G.consumeables.config.card_count < G.consumeables.config.card_limit) or
                    (G.consumeables.config.card_count <= G.consumeables.config.card_limit and con.added_to_deck)) then
                if pseudorandom('gama_toad') < G.GAME.probabilities.normal / card.ability.extra.odds then
                    local card = copy_card(con)
                    card:start_materialize()
                    card:add_to_deck()
                    G.consumeables:emplace(card)
                end
            end
        end
    end
}
--fuck it, end of the shikigamis

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
    path = 'fey/flyheads.png',
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
                    local copied_joker = copy_card(card)
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
    atlas = 'fingerbearer',
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

SMODS.Atlas {
    key = 'fingerbearer',
    path = 'fey/fb.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'roppo',
    atlas = 'roppo',
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

SMODS.Atlas {
    key = 'roppo',
    path = 'fey/roppongi.png',
    px = 71,
    py = 95
}

SMODS.Atlas {
    key = 'seal',
    path = 'fey/seal.png',
    px = 68,
    py = 92
}
