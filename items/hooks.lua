--generate an awaken on end of finisher and boss kill context
local hookTo = end_round
function end_round()
    local ret = hookTo()
    if G.GAME.blind.boss == true then
        SMODS.calculate_context { boss_defeat = true }
        if G.domain.cards[1] then
            local count = 0
            for i, v in ipairs(G.domain.cards) do
                if v.config.center.set == 'domain' then
                    count = count + 1
                    v.ability.extra.used_this_ante = false
                end
            end
            ease_ce(-count)
        end
    end
    if G.GAME.blind.config.blind.boss then
        if G.GAME.blind.config.blind.boss.showdown == true then
            SMODS.add_card({ key = 'c_jjok_awaken' })
        end
    end
    if SMODS.find_card('j_jjok_sukuna')[1] and G.consumeables.config.card_count < G.consumeables.config.card_limit then
        SMODS.add_card({ key = 'c_jjok_sukfin' })
    end
    local rars = JJOK.pool_rarities(true)
    local ce = rars[1] + (rars[2] * 2) + (rars[3] * 3) + (rars[4] * 4) + (rars[5] * 5)
    ease_ce(ce)
    if G.GAME.cursed_energy and G.GAME.cursed_energy_limit then
        if G.GAME.cursed_energy >= G.GAME.cursed_energy_limit and G.jokers.config.card_count < G.jokers.config.card_limit then
            ease_ce(-G.GAME.cursed_energy)
            local joker = G.P_CENTER_POOLS.curses[pseudorandom('cursedenergy', 1, #G.P_CENTER_POOLS.curses)]
            SMODS.add_card({ key = joker.key, no_edition = true })
        end
    end
    return ret
end

G.TIMERS.naoya = G.TIMERS.naoya or 0
local ante = nil
local hookTo = love.update
function love.update(dt)
    local ret = hookTo(dt)
    if G.GAME.blind and G.GAME.blind.in_blind and not G.GAME.blind.boss then
        G.TIMERS.naoya = G.TIMERS.naoya + (dt or 0)
        G.TIMERS.n_round = math.floor(G.TIMERS.naoya + 0.5)
    end
    if ante ~= G.GAME.round_resets.ante then
        G.TIMERS.naoya = 0
        G.TIMERS.n_round = 0
    end
    ante = G.GAME.round_resets.ante
    if G.TIMERS.naoya then
        G.GAME.naoya_mult = (G.GAME.round_resets.ante ^ 2) - (G.GAME.round / 100 * G.TIMERS.n_round)
    end
    return ret
end

--big ty to N' again
local ccr = SMODS.calculate_context
function SMODS.calculate_context(context, return_table)
    if G.in_delete_run then return end
    return ccr(context, return_table)
end

local csd = Card.set_debuff
function Card:set_debuff(should_debuff)
    if self.area == G.domain and self.ability.perishable and self.ability.perish_tally <= 0. then
        self:start_dissolve() return
    end
    return csd(self, should_debuff)
end

--jjok only
local gsr = Game.start_run
function Game:start_run(args)
    local saveTable = args.savetext or nil
    local ret = gsr(self, args)
    if Jjok.config.jjok_only and self.GAME.jjok_only == nil then
        self.GAME.jjok_only = true
    else
        self.GAME.jjok_only = false
    end
    if not saveTable then
        self.GAME.cursed_energy = 0
        self.GAME.cursed_energy_limit = 100
        self.GAME.loading_card_areas = {}
    end
    return ret
end

local gcp = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    local _pool, _pool_key = gcp(_type, _rarity, _legendary, _append)
    if G.GAME.jjok_only == true and _type == 'Joker' then
        for i, v in ipairs(_pool) do
            if not (string.sub(v, 1, 6) == 'j_jjok') then
                _pool[i] = 'UNAVAILABLE'
            end
        end
    end
    return _pool, _pool_key
end

--placeholder sprites
local csa = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    if self.config.center.atlas and self.config.center.atlas == 'Joker' then
        if self.config.center.mod and self.config.center.mod.id == 'jjok' then
            self.config.center.pos = { x = 9, y = 9 }
        end
    end
    if self.config.center.atlas and self.config.center.atlas == 'Tarot' then
        if self.config.center.mod and self.config.center.mod.id == 'jjok' then
            if self.config.center.set == 'Tarot' then
                self.config.center.pos = { x = 6, y = 2 }
            elseif self.config.center.set == 'Spectral' then
                self.config.center.pos = { x = 5, y = 2 }
            elseif self.config.center.set == 'ctools' or self.config.center.set == 'ct' or self.config.center.set == 'domain' or self.config.center.set == 'Planet' then
                self.config.center.pos = { x = 7, y = 2 }
            end
        end
    end
    if self.config.center.set == 'Booster' and self.config.center.mod and self.config.center.mod.id == 'jjok' and self.config.center.atlas == 'Booster' then
        self.config.center.atlas = 'jjok_wip_booster'
    end
    return csa(self, center, initial, delay_sprites)
end

local ccsc = Card.can_sell_card
function Card:can_sell_card(context)
    for i, v in ipairs(G.P_CENTER_POOLS.curses) do
        if v.key == self.config.center.key then
            return false
        end
    end
    return ccsc(self, context)
end

local ccuc = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
    if self.config.center.key == 'c_wraith' or self.config.center.key == 'c_judgement' or self.config.center.key == 'c_soul' then
        local space = G.jokers.config.card_limit - G.jokers.config.card_count
        if space >= 1 then
            return true
        else
            return false
        end
    elseif self.config.center.key == 'c_ankh' then
        local max = 1
        for i, v in ipairs(G.jokers.cards) do
            if v.ability.slots > max then
                max = v.ability.slots
            end
        end
        local space = G.jokers.config.card_limit - G.jokers.config.card_count
        if space >= max then
            return true
        else
            return false
        end
    end
    return ccuc(self, any_state, skip_check)
end

local cb = G.FUNCS.can_buy
G.FUNCS.can_buy = function(e)
    if SMODS.find_card('j_jjok_onna')[1] then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
        return false
    end
    return cb(e)
end

local cbau = G.FUNCS.can_buy_and_use
G.FUNCS.can_buy_and_use = function(e)
    if SMODS.find_card('j_jjok_onna')[1] then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
        return false
    end
    return cbau(e)
end

--crash fixes
local gphi = G.FUNCS.get_poker_hand_info
function G.FUNCS.get_poker_hand_info(_cards)
    if G.in_delete_run then
        return false
    end
    return gphi(_cards)
end

local bdh = Blind.debuff_hand
function Blind:debuff_hand(cards, hand, handname, check)
    if G.in_delete_run then
        return false
    end
    return bdh(self, cards, hand, handname, check)
end

local caph = CardArea.parse_highlighted
function CardArea:parse_highlighted()
    if not G.in_delete_run then caph(self) end
end

--multi slot system
local cfbs = G.FUNCS.check_for_buy_space
function G.FUNCS.check_for_buy_space(card)
    if card.config.center.set == 'Joker' then
        local negative = false
        if card.edition and card.edition.card_limit then negative = true end
        local space = G.jokers.config.card_limit - G.jokers.config.card_count
        if (space >= card.ability.slots) or negative then
            return true
        else
            alert_no_space(card, card.ability.consumeable and G.consumeables or G.jokers)
            return false
        end
    else
        return cfbs(card)
    end
end

local csc = G.FUNCS.can_select_card
G.FUNCS.can_select_card = function(e)
    local card = e.config.ref_table
    if card.ability.set == 'Joker' then
        local negative = false
        if card.edition then
            if card.edition.negative then negative = true end
        end
        local space = G.jokers.config.card_limit - G.jokers.config.card_count
        if (space >= card.ability.slots) or negative then
            e.config.colour = G.C.GREEN
            e.config.button = 'use_card'
        else
            e.config.colour = G.C.UI.BACKGROUND_INACTIVE
            e.config.button = nil
        end
    else
        return csc(e)
    end
end

local sdt = set_discover_tallies
function set_discover_tallies()
    sdt()
    G.DISCOVER_TALLIES = G.DISCOVER_TALLIES or {}
    G.DISCOVER_TALLIES.Rarities = {}
    for i, v in pairs(SMODS.Rarities) do
        G.DISCOVER_TALLIES.Rarities[v.key] = { tally = 0, of = 0, key = v.key }
    end
    for i, v in ipairs(G.P_CENTER_POOLS.Joker) do
        local disc, rar
        if v.discovered then
            disc = true
        end

        if v.rarity == 1 then rar = 'Common' end
        if v.rarity == 2 then rar = 'Uncommon' end
        if v.rarity == 3 then rar = 'Rare' end
        if v.rarity == 4 then rar = 'Legendary' end

        if not rar then
            rar = v.rarity
        end
        G.DISCOVER_TALLIES.Rarities[rar].of = G.DISCOVER_TALLIES.Rarities[rar].of + 1
        if disc then
            G.DISCOVER_TALLIES.Rarities[rar].tally = G.DISCOVER_TALLIES.Rarities[rar].tally + 1
        end
    end
end

local catd = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    local t = catd(self, from_debuff)
    if self.config.center.set == 'ct' and not self.ability.ce_cost then
        if self.config.center.key == 'c_jjok_piercingblood' then
            self.ability.ce_cost = pseudorandom('c_cost', 0, 10)
        else
            self.ability.ce_cost = pseudorandom('ce_cost', 0, 75)
        end
    end
    if self.config.center.key == 'c_jjok_9tails' and not self.ability.extra.ce then
        self.ability.extra.ce = pseudorandom('9tails', 0, 75)
    end
    if self.ability.inc_select ~= 0 and self.ability.inc_select then
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit + self.ability.inc_select
    end
    return t
end

local crfd = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
    if self.added_to_deck and self.ability.inc_select ~= 0 and self.ability.inc_select then
        G.hand.config.highlighted_limit = G.hand.config.highlighted_limit - self.ability.inc_select
    end
    return crfd(self, from_debuff)
end

local emplace_ref = CardArea.emplace
function CardArea:emplace(card, location, stay_flipped)
    if self == G.consumeables and card.ability.set == 'domain' then
        G.domain:emplace(card, location, stay_flipped)
        return
    end
    return emplace_ref(self, card, location, stay_flipped)
end

--auto discover
local su = SMODS.SAVE_UNLOCKS
function SMODS.SAVE_UNLOCKS()
    su()
    for i, v in pairs(G.P_CENTERS) do
        if v.mod and v.mod.id == 'jjok' then
            v.discovered = true
        end
    end
end

local cc = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, bypass)
    local _card = cc(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append, bypass)
    if _card.config.center.create and type(_card.config.center.create) == 'function' then
        _card.config.center.create(_card)
    end
    return _card
end

local gca = SMODS.get_card_areas
function SMODS.get_card_areas(_type, _context)
    local t = gca(_type, _context)
    if _type == 'jokers' then
        for i, v in ipairs(G.GAME.loading_card_areas or {}) do
            t[#t + 1] = G[v]
        end
    end
    return t
end

function CardArea:count_extra_slots_used(cards)
    local slots = 0
    if (self.config.type == 'joker' or self.config.type == 'hand') and not self.config.fixed_limit then
        for _, card in ipairs(cards) do
            slots = slots + card.ability.extra_slots_used + card.ability.slots
        end
    end
    if self == G.deck then
        slots = #G.deck.cards
    end
    return slots
end

local ac = SMODS.create_card
function SMODS.create_card(t)
    local m = ac(t)
    if t.slots then m.ability.slots = t.slots end
    return m
end