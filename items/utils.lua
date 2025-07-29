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

JJOK.pool_rarities = function()
    local ret = { 0, 0, 0, 0, 0 }
    for i, v in ipairs(G.jokers.cards) do
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
        table.insert(suits, v.base.suit)
    end
    return suits
end

JJOK.credit = function()
    return create_badge(localize('jjok_tac'), G.C.JJOK.LBLUE, G.C.WHITE, 0.8)
end

JJOK.create_cardarea = function(cardarea, name, counter)
    local id = name .. tostring(counter)
    G[id] = cardarea
end

function G.FUNCS.jjok_kenny_can(card)
    if card.config.ref_table.ability.extra.name then
        if (#G.jokers.highlighted == 2 and (#G[card.config.ref_table.ability.extra.name].cards < G[card.config.ref_table.ability.extra.name].config.card_limit) and
                not (G.jokers.highlighted[1].config.center.key == 'j_jjok_kenjaku' and G.jokers.highlighted[2].config.center.key == 'j_jjok_kenjaku')) or
            (#G[card.config.ref_table.ability.extra.name].highlighted == 1 and #G.jokers.cards < G.jokers.config.card_limit) then
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

function ease_ce(mod)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            local ce_UI = G.HUD:get_UIE_by_ID('CE_UI_count')

            mod = (mod or 0) + G.GAME.cursed_energy

            G.E_MANAGER:add_event(Event({
                trigger = 'ease',
                blockable = false,
                ref_table = G.GAME,
                ref_value = 'cursed_energy',
                ease_to = mod,
                delay =  0,
                func = (function(t) return math.floor(t) end)
            }))
            play_sound('timpani')
            return true
        end
      }))
end

function G.FUNCS.ce_bar_update(self)
    local op = (G.GAME.cursed_energy / 100) + 0.1
    self.config.progress_bar.filled_col = adjust_alpha(G.C.JJOK.LBLUE, op)
    self.config.progress_bar.max = G.GAME.cursed_energy_limit
end