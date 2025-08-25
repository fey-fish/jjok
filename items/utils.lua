JJOK = {}

JJOK.one_shot_blind = function(context)
    local ret = false
    if context.after and mult * hand_chips >= G.GAME.blind.chips then
        ret = true
    end
    return ret
end

JJOK.find_joker = function(_key)
    local ret = nil
    for i, v in ipairs(G.jokers.cards) do
        if v.config.center.key == _key then
            ret = i
        end
    end
    return ret
end

JJOK.pool_rarities = function(heavenly)
    local ret = { 0, 0, 0, 0, 0 }
    local areas = SMODS.get_card_areas('jokers')
    for _, a in ipairs(areas) do
        for i, v in ipairs(a.cards) do
            if v.ability.set == 'Joker' then
                if v.config.center.rarity == 1 then
                    ret[1] = ret[1] + 1
                elseif v.config.center.rarity == 2 then
                    ret[2] = ret[2] + 1
                elseif v.config.center.rarity == 3 then
                    ret[3] = ret[3] + 1
                elseif v.config.center.rarity == 4 then
                    ret[4] = ret[4] + 1
                elseif v.config.center.rarity == 'jjok_special' then
                    ret[5] = ret[5] + 1
                end
            end
        end
    end
    if heavenly then
        for _, a in ipairs(areas) do
        for i, v in ipairs(a.cards) do
            if v.ability.set == 'Joker' and v.ability.heavenly then
                if v.config.center.rarity == 1 then
                    ret[1] = ret[1] - 1
                elseif v.config.center.rarity == 2 then
                    ret[2] = ret[2] - 1
                elseif v.config.center.rarity == 3 then
                    ret[3] = ret[3] - 1
                elseif v.config.center.rarity == 4 then
                    ret[4] = ret[4] - 1
                elseif v.config.center.rarity == 'jjok_special' then
                    ret[5] = ret[5] - 1
                end
            end
        end
    end
    end
    return ret
end

JJOK.find_rar = function(rar)
    local ret = {}
    for i, v in ipairs(G.jokers.cards) do
        if v.config.center.rarity == rar then
            table.insert(ret, v)
        end
    end
    return ret
end

JJOK.find_enhance = function(enhancement)
    for i, v in ipairs(G.playing_cards) do
        if v.ability.name == enhancement then
            return true
        end
    end
end

JJOK.flip_enhance = function(card, _enhancement)
    --*borrowed* code from near :) @NH5674
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.4,
        func = function()
            play_sound('tarot1')
            card:juice_up(0.3, 0.5)
            return true
        end
    }))
    for i = 1, #G.hand.highlighted do
        local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip()
                play_sound('card1', percent)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    for i = 1, #G.hand.highlighted do
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                G.hand.highlighted[i]:set_ability(_enhancement)
                return true
            end
        }))
    end
    for i = 1, #G.hand.highlighted do
        local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            func = function()
                G.hand.highlighted[i]:flip()
                play_sound('tarot2', percent, 0.6)
                G.hand.highlighted[i]:juice_up(0.3, 0.3)
                return true
            end
        }))
    end
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.2,
        func = function()
            G.hand:unhighlight_all()
            return true
        end
    }))
    delay(0.5)
end

JJOK.poll_suits = function()
    local suits = {}
    for i, v in ipairs(G.playing_cards) do
        if v.ability and v.ability.effect ~= 'Stone Card' then
            table.insert(suits, v.base.suit)
        end
    end
    return suits
end

JJOK.credit = function(author)
    if author == 'tac' then
        return create_badge(localize('jjok_tac'), G.C.JJOK.LBLUE, G.C.WHITE, 0.8)
    elseif author == 'fey' then
        return create_badge(localize('jjok_fey'), G.C.JJOK.PINK, G.C.WHITE, 0.8)
    end
end

JJOK.create_cardarea = function(cardarea, name, counter)
    local id = name .. tostring(counter)
    G[id] = cardarea
end

function G.FUNCS.jjok_kenny_can(card)
    if card.config.ref_table.ability.extra.name then
        local other
        for i, v in ipairs(G.jokers.highlighted) do
            if v ~= card.config.ref_table then
                other = v
            end
        end
        if (#G.jokers.highlighted == 2 and ((G[card.config.ref_table.ability.extra.name].config.card_count + other.slots) < G[card.config.ref_table.ability.extra.name].config.card_limit)) or
            (#G[card.config.ref_table.ability.extra.name].highlighted == 1 and G.jokers.config.card_count < G.jokers.config.card_limit) then
            card.config.colour = G.C.PURPLE
            card.config.button = 'jjok_kenny_use'
        else
            card.config.colour = G.C.UI.BACKGROUND_INACTIVE
            card.config.button = nil
        end
    end
end

function G.FUNCS.jjok_kenny_use(card)
    local other
    if #G.jokers.highlighted == 2 then
        for i, v in ipairs(G.jokers.highlighted) do
            if v.config.center.key ~= 'j_jjok_kenjaku' then
                other = v
            end
        end
        G.jokers:remove_card(other)
        G[card.config.ref_table.ability.extra.name]:emplace(other)
    elseif #G[card.config.ref_table.ability.extra.name].highlighted == 1 then
        other = G[card.config.ref_table.ability.extra.name].highlighted[1]
        G[card.config.ref_table.ability.extra.name]:remove_card(other)
        G.jokers:emplace(other)
    end
    G.jokers:unhighlight_all()
end

function G.FUNCS.jjok_oro_can(card)
    if card.config.ref_table.ability.extra.name then
        local other
        for i, v in ipairs(G.jokers.highlighted) do
            if v ~= card.config.ref_table then
                other = v
            end
        end
        if (#G.jokers.highlighted == 2 and ((#G[card.config.ref_table.ability.extra.name].cards) <= G[card.config.ref_table.ability.extra.name].config.card_limit)) or
            (#G.jokers.highlighted == 1 and G.jokers.highlighted[1] == card.config.ref_table and G.jokers.config.card_count < G.jokers.config.card_limit and
                G[card.config.ref_table.ability.extra.name].config.card_count > 0) then
            card.config.colour = G.C.JJOK.NATURE
            card.config.button = 'jjok_oro_use'
        else
            card.config.colour = G.C.UI.BACKGROUND_INACTIVE
            card.config.button = nil
        end
    end
end

function G.FUNCS.jjok_oro_use(card)
    local other
    if #G.jokers.highlighted == 2 then
        for i, v in ipairs(G.jokers.highlighted) do
            if v ~= card then
                other = v
            end
        end
        G.jokers:remove_card(other)
        G[card.config.ref_table.ability.extra.name]:emplace(other)
    elseif #G.jokers.highlighted == 1 and G.jokers.highlighted[1] == card.config.ref_table then
        other = G[card.config.ref_table.ability.extra.name].cards[1]
        G[card.config.ref_table.ability.extra.name]:remove_card(other)
        G.jokers:emplace(other)
    end
    G.jokers:unhighlight_all()
end

function ease_ce(mod)
    G.GAME.cursed_energy = G.GAME.cursed_energy + mod
end

function G.FUNCS.ce_bar_update(self)
    local op = (G.GAME.cursed_energy / 100) + 0.1
    self.config.progress_bar.filled_col = adjust_alpha(G.C.JJOK.LBLUE, op)
    self.config.progress_bar.max = G.GAME.cursed_energy_limit
end

G.FUNCS.your_collection_rarities = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = create_UIBox_Rarities(),
    }
end

G.FUNCS.your_collection_jokers_of_rar = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = create_UIBox_your_collection_rars(e),
    }
end

function create_UIBox_your_collection_rars(e)
    local config = e.config.ref_table
    local jokersofrar = {}
    for i, v in ipairs(G.P_CENTER_POOLS.Joker) do
        if v.discovered then
            if config.key == 'Common' then
                if v.rarity == 1 then
                    table.insert(jokersofrar, v)
                end
            elseif config.key == 'Uncommon' then
                if v.rarity == 2 then
                    table.insert(jokersofrar, v)
                end
            elseif config.key == 'Rare' then
                if v.rarity == 3 then
                    table.insert(jokersofrar, v)
                end
            elseif config.key == 'Legendary' then
                if v.rarity == 4 then
                    table.insert(jokersofrar, v)
                end
            elseif v.rarity == config.key then
                table.insert(jokersofrar, v)
            end
        end
    end
    return SMODS.card_collection_UIBox(jokersofrar, { 5, 5, 5 }, {
        no_materialize = true,
        modify_card = function(card, center) card.sticker = get_joker_win_sticker(center) end,
        h_mod = 0.95,
        back_func = 'your_collection_rarities'
    })
end

function create_UIBox_Rarities()
    local rars = {}
    for i, v in pairs(SMODS.Rarities) do
        local add = false
        for k, m in pairs(G.P_CENTER_POOLS.Joker) do
            local center, val_rar = m, false
            if v.key == 'Common' then
                if center.rarity == 1 then
                    val_rar = true
                end
            elseif v.key == 'Uncommon' then
                if center.rarity == 2 then
                    val_rar = true
                end
            elseif v.key == 'Rare' then
                if center.rarity == 3 then
                    val_rar = true
                end
            elseif v.key == 'Legendary' then
                if center.rarity == 4 then
                    val_rar = true
                end
            elseif center.rarity == v.key then
                val_rar = true
            end
            if center.discovered and val_rar then
                add = true
            end
        end
        if add then
            local loc_key, col = 'k_' .. string.lower(v.key), G.C.RARITY[v.key]
            rars[#rars + 1] = UIBox_button({
                ref_table = v,
                button = 'your_collection_jokers_of_rar',
                label = { localize(loc_key) },
                minw = 5,
                colour =
                    col,
                count = G.DISCOVER_TALLIES.Rarities[v.key]
            })
        end
    end

    local t = create_UIBox_generic_options({
        back_func = 'your_collection_other_gameobjects',
        contents = {
            { n = G.UIT.C, config = { align = "cm", padding = 0.15 }, nodes = rars } }
    })
    return t
end

function Card:valid_destroy(bypass)
    if bypass or not SMODS.is_eternal(self) then
        return self:start_dissolve()
    end
end
