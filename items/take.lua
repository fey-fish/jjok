SMODS.Enhancement:take_ownership('glass', {
    calculate = function(self, card, context)
        if context.destroy_card and context.cardarea == G.play and context.destroy_card == card and pseudorandom('glass') < G.GAME.probabilities.normal / card.ability.extra then
            SMODS.calculate_context { glass_shattered = card }
            return { remove = true }
        end
    end,
}, true)

SMODS.Joker:take_ownership('trousers', {
    config = { extra = { mult = 0, mult_gain = 2 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.mult_gain,
                localize('Two Pair', 'poker_hands'),
                center.ability.extra.mult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.before and (next(context.poker_hands['Two Pair']) or next(context.poker_hands['Full House'])
                or next(context.poker_hands['Four of a Kind']) or next(context.poker_hands['Five of a Kind']) or next(context.poker_hands['Six of a Kind'])) then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.RED
            }
        end
        if context.joker_main then
            return {
                mult = card.ability.extra.mult
            }
        end
    end
})
