SMODS.PokerHand {
    key = '6oak',
    loc_txt = { name = 'Six of a Kind',
        description = {
            '6 cards with the same rank'
        } },
    visible = false,
    example = {
        { 'S_K', true },
        { 'S_K', true },
        { 'D_K', true },
        { 'H_K', true },
        { 'D_K', true },
        { 'C_K', true } },
    mult = 20, chips = 200,
    l_mult = 5, l_chips = 50,
    evaluate = function(parts, hand)
        return parts.jjok_6
    end
}

SMODS.Consumable {
    key = "sun",
    set = "Planet",
    cost = 3,
    config = { hand_type = 'jjok_6oak' },
    loc_txt = {name = 'The Sun',
                text = {
                    "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
                    "{C:attention}Six of a Kind",
                    "{C:mult}+#2#{} Mult and",
                    "{C:chips}+#3#{} chips",
                }},
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.hands[card.ability.hand_type].level,
                G.GAME.hands[card.ability.hand_type].l_mult,
                G.GAME.hands[card.ability.hand_type].l_chips,
                colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
            }
        }
    end
}

SMODS.PokerHand {
    key = 'f6',
    loc_txt = { name = 'Flush Six',
        description = {
            '6 cards with the same rank and suit'
        } },
    visible = false,
    example = {
        { 'H_K', true },
        { 'H_K', true },
        { 'H_K', true },
        { 'H_K', true },
        { 'H_K', true },
        { 'H_K', true } },
    mult = 30, chips = 300,
    l_mult = 6, l_chips = 60,
    evaluate = function(parts, hand)
        return next(parts.jjok_6) and next(parts.jjok_flush)
            and { SMODS.merge_lists(parts.jjok_6, parts.jjok_flush) } or {}
    end
}

SMODS.Consumable {
    key = "milky",
    set = "Planet",
    cost = 3,
    config = { hand_type = 'jjok_f6' },
    loc_txt = {name = 'The Milky Way',
                text = {
                    "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
                    "{C:attention}Flush Six",
                    "{C:mult}+#2#{} Mult and",
                    "{C:chips}+#3#{} chips",
                }},
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                G.GAME.hands[card.ability.hand_type].level,
                G.GAME.hands[card.ability.hand_type].l_mult,
                G.GAME.hands[card.ability.hand_type].l_chips,
                colours = { (G.GAME.hands[card.ability.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, G.GAME.hands[card.ability.hand_type].level)]) }
            }
        }
    end
}

SMODS.PokerHandPart {
    key = '6',
    func = function(hand)
        return get_X_same(6, hand)
    end
}
SMODS.PokerHandPart {
    key = 'flush',
    func = function(hand)
        local ret = {}
        local four_fingers = next(find_joker('Four Fingers'))
        local suits = SMODS.Suit.obj_buffer
        if #hand < (6 - (four_fingers and 1 or 0)) then
            return ret
        else
            for j = 1, #suits do
                local t = {}
                local suit = suits[j]
                local flush_count = 0
                for i = 1, #hand do
                    if hand[i]:is_suit(suit, nil, true) then
                        flush_count = flush_count + 1; t[#t + 1] = hand[i]
                    end
                end
                if flush_count >= (6 - (four_fingers and 1 or 0)) then
                    table.insert(ret, t)
                    return ret
                end
            end
            return {}
        end
    end
}