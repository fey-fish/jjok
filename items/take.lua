--yuki stuff
SMODS.Enhancement:take_ownership('glass', {
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and context.destroy_card == card and JJOK.find_joker('j_jjok_yuki') ~= nil then
            SMODS.calculate_context { glass_shattered = card }
            return { remove = true }
        elseif context.destroy_card and context.cardarea == G.play and context.destroy_card == card and pseudorandom('glass') < G.GAME.probabilities.normal / card.ability.extra then
            SMODS.calculate_context { glass_shattered = card }
            return { remove = true }
        end
    end,
}, true)

--hakari lucky desc
SMODS.Enhancement:take_ownership('lucky', {
    loc_vars = function(self, info_queue, center)
        if G.jokers then
            if JJOK.find_joker('j_jjok_hak') then
                return { key = 'm_jjok_lucky_hak' }
            else
                return {vars = {G.GAME.probabilities.normal, 20, 5, 20, 15}}
            end
        else
            return {vars = {G.GAME.probabilities.normal, 20, 5, 20, 15}}
        end
    end
}, true)

--4oak includes two pair, mainly for trousers
SMODS.PokerHand:take_ownership('Two Pair', {
        evaluate = function(parts, hand)
            if next(parts._4) then return parts._4 end
            if #parts._2 < 2 then return {} end
            return parts._all_pairs
        end
    },
    true)

--5oak contains full house
SMODS.PokerHand:take_ownership('Full House', {
        evaluate = function(parts, hand)
            if next(parts._5) then return parts._5 end
            if #parts._3 < 1 or #parts._2 < 2 then return {} end
            return parts._all_pairs
        end
    },
    true)

--ancient fix is in patches
