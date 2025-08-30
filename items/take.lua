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
        if G.jokers and SMODS.find_card('j_jjok_hak')[1] then
            return { key = 'm_jjok_lucky_hak' }
        else
            return { key = 'm_lucky', vars = { G.GAME.probabilities.normal, center.ability.mult, 5, center.ability.p_dollars, 15, G.GAME.probabilities.normal } }
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

--wicker basket stuff
SMODS.Consumable:take_ownership('ankh', {
        use = function(self, card)
            local wicker = SMODS.find_card('c_jjok_wickerbasket')
            local protect
            for i, v in ipairs(wicker) do
                if v.ability.extra.used_this_ante == false then
                    protect = v
                    break
                end
            end

            if protect then
                --wicker basket prot
                local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('ankh_choice'))

                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        local card = copy_card(chosen_joker, nil, nil, nil,
                            chosen_joker.edition and chosen_joker.edition.negative)
                        card:start_materialize()
                        card:add_to_deck()
                        if card.edition and card.edition.negative then
                            card:set_edition(nil, true)
                        end
                        G.jokers:emplace(card)
                        return true
                    end
                }))
                protect.ability.extra.used_this_ante = true
                return { message = 'Protected!', colour = G.C.SECONDARY_SET.Spectral, message_card = protect }
            else
                --vanilla
                local deletable_jokers = {}
                for k, v in pairs(G.jokers.cards) do
                    if not SMODS.is_eternal(v, self) then deletable_jokers[#deletable_jokers + 1] = v end
                end
                local chosen_joker = pseudorandom_element(G.jokers.cards, pseudoseed('ankh_choice'))
                local _first_dissolve = nil
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.75,
                    func = function()
                        for k, v in pairs(deletable_jokers) do
                            if v ~= chosen_joker then
                                v:start_dissolve(nil, _first_dissolve)
                                _first_dissolve = true
                            end
                        end
                        return true
                    end
                }))
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.4,
                    func = function()
                        local card = copy_card(chosen_joker, nil, nil, nil,
                            chosen_joker.edition and chosen_joker.edition.negative)
                        card:start_materialize()
                        card:add_to_deck()
                        if card.edition and card.edition.negative then
                            card:set_edition(nil, true)
                        end
                        G.jokers:emplace(card)
                        return true
                    end
                }))
            end
        end
    },
    true)

SMODS.Joker:take_ownership('riff_raff', {
    calculate = function(self, card, context)
        if context.setting_blind then
            local jokers_to_create = G.jokers.config.card_limit - (G.jokers.config.card_count + G.GAME.joker_buffer)
            if jokers_to_create > 0 then
                G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create
                G.E_MANAGER:add_event(Event({
                    func = function()
                        for i = 1, jokers_to_create do
                            SMODS.add_card({ set = 'Joker', key_append = 'rif' })
                            G.GAME.joker_buffer = 0
                        end
                        return true
                    end
                }))
                card_eval_status_text(context_blueprint_card or card, 'extra', nil, nil, nil,
                { message = localize('k_plus_joker'), colour = G.C.BLUE })
            end
        end
    end
}, true)
