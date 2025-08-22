local lapi = loadAPIs
function loadAPIs()
    lapi()
    -- Use to create JJOK Curses easily, rarity, pools and compatibility is already set (can be changed if needed)  
    ---@class Curse
    JJOK.Curse = SMODS.Center:extend {
        rarity = 'jjok_cs',
        blueprint_compat = false,
        perishable_compat = false,
        eternal_compat = false,
        cost = 0,
        config = {},
        pools = {['curses'] = true},
        set = 'Joker',
        atlas = 'Joker',
        class_prefix = 'j',
        in_pool = function(self,card)
            return false
        end,
        required_params = {
            'key',
        },
        inject = function(self)
            -- call the parent function to ensure all pools are set
            SMODS.Center.inject(self)
            if self.taken_ownership and self.rarity_original and self.rarity_original ~= self.rarity then
                SMODS.remove_pool(G.P_JOKER_RARITY_POOLS[self.rarity_original] or {}, self.key)
                SMODS.insert_pool(G.P_JOKER_RARITY_POOLS[self.rarity], self, false)
            else
                SMODS.insert_pool(G.P_JOKER_RARITY_POOLS[self.rarity], self)
            end
        end
    }
end

JJOK.Curse {
    key = 'swarm',
    loc_txt = {
        name = 'Swarm of Flyheads',
        text = { 'Duplicate in {C:attention}#1#{} rounds',
            '{s:0.8,C:inactive}(Must have space)',
            '{s:0.8,C:inactive}(Cannot be sold)' }
    },
    config = { extra = { rounds = 3 } },
    loc_vars = function(self, info_queue, center)
        return {
            vars = {
                center.ability.extra.rounds,
            }
        }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            card.ability.extra.rounds = card.ability.extra.rounds - 1
            if card.ability.extra.rounds == 0 then
                card.ability.extra.rounds = 3
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

JJOK.Curse {
    key = 'smallpox',
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

JJOK.Curse {
    key = 'kuro',
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
    calculate = function(self, card, context)
        if context.boss_defeat then
            pseudorandom_element(G.jokers.cards, pseudoseed('kuro'))
        end
    end
}

JJOK.Curse {
    key = 'onna',
    loc_txt = { name = 'Kuchisake Onna',
        text = {
            'Cards can no',
            'longer be bought',
            '{s:0.8,C:inactive}(Cannot be sold)'
        } }
}