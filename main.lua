--- STEAMODDED HEADER
--- MOD_NAME: Jujutsu Jokers
--- MOD_ID: JJOKERS
--- MOD_AUTHOR: [fey]
--- MOD_DESCRIPTION: Add jokers based on the popular shonen JJK
--- BADGE_COLOR: 660000
--- PREFIX: jjok
----------------------------------------------
------------MOD CODE -------------------------

SMODS.current_mod.optional_features = function()
    return {
        retrigger_joker = true,
        post_trigger = true
    }
end

SMODS.Rarity {
    key = 'shiki',
    loc_txt = {
        name = 'Shikigami'
    },
    badge_colour = HEX('EEEEEE')
}

SMODS.Rarity {
    key = 'special',
    loc_txt = {
        name = 'Special Grade'
    },
    badge_colour = HEX('A64D79'),
}

SMODS.Consumable {
    key = 'awaken',
    loc_txt = {name = 'Awakening',
                text = {'Use to {C:attention}awaken{} any {C:Legendary}Grade 1',
                        'sorceror to special grade'}},
    set = 'Spectral',
    hidden = true,
    soul_set = 'Spectral',
    atlas = 'atlastwo',
    pos = {x = 0, y = 0},
    soul_pos = {x = 1, y = 0},
    soul_rate = 0.06,
    cost = 4,
    pools = {['Spectral'] = true},
    can_use = function(card,self,center)
        Count = 0
        Legendary = {}
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.rarity == 4 then
                Count = Count + 1
                Legendary[Count] = i
            end
        end
        if Count ~= nil then
            return {true}
        end
    end,
    use = function(card,self)
        local kill = pseudorandom('Seed', 1, Count)
        G.jokers.cards[Legendary[kill]]:start_dissolve()
        SMODS.add_card({set = 'Joker', area = G.jokers, rarity = 'jjok_special'})
    end
}

SMODS.ConsumableType {
    key = 'ctools',
    primary_colour = HEX('40E0D0'),
    secondary_colour = HEX('000000'),
    loc_txt = {
        name = 'Cursed Tools',
        collection = 'Cursed Tools'
    },
    collection_rows = {6, 6},
    shop_rate = 0.0
}

SMODS.Consumable {
    key = 'nanamitool',
    set = 'ctools',
    atlas = 'atlastwo',
    pos = {x = 3, y = 1},
    soul_pos = {x = 2,y = 1},
    loc_txt = {name = 'Nanamis Wrapped Blade',
                text = {'A blade wrapped in',
                        'a white speckled wrapping,',
                        'use to {C:attention}empower Ino',
                        '{s:0.8}"Imbued with the ratio technique!"'}}
}

SMODS.Consumable {
    key = 'makitool',
    set = 'ctools',
    loc_txt = {
        name = 'Split Soul Katana',
        text = {'Formerly wielded by Toji Zenin,',
                'use to {C:attention}awaken Maki',
                '{s:0.8}"Cuts directly at the soul"{}'
    }
    },
    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.j_jjok_maki
    end,
    atlas = 'atlastwo',
    pos = {x = 0, y = 1},
    soul_pos = {x = 1, y = 1},
    cost = 4,
    can_use = function(card,self)
        local i = nil
        M = nil
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].config.center.key == 'j_jjok_maki' then
                M = i
            end
        end
        if M ~= nil then
            return {true}
        end
    end,
    use = function(card,self)
        local destroy_joker = G.jokers.cards[M]:start_dissolve()
        local create_amaki = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_jjok_amaki')
        create_amaki:add_to_deck()
        G.jokers:emplace(create_amaki)
    end
}

SMODS.Consumable:take_ownership('c_soul', {
        soul_set = 'Tarot',
        soul_rate = 0.08
})

SMODS.Joker {
    key = 'rainbowdragon',
    loc_txt = {name = 'Rainbow Dragon',
                text = {'One of the most powerful cursed',
                        'spirits in young Getos collection,',
                        'exorcised by Toji Zenin, gives',
                        '{C:mult}+#1#{} mult ({C:mult}round{} * {C:mult}ante{})',
                        '{s:0.8,C:inactive}(Destroyed upon use)'}},
    loc_vars = function(self,info_queue,card)
        return {vars = {G.GAME.round * G.GAME.round_resets.ante}}
    end,
    atlas = 'atlasthree',
    pos = {x = 3, y = 0},
    soul_pos = {x = 2, y = 0},
    pools = {['ygeto_col'] = true},
    no_collection = true,
    rarity = 'jjok_shiki',
    add_to_deck = function(card,self,context)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end,
    remove_from_deck = function(card,self,context)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 1
    end,
    calculate = function(self,card,context)
        for i = 1, #G.jokers.cards do
          if G.jokers.cards[i] == card then
            D = i 
          end  
        end
        if context.joker_main then
            return {
                card = card,
                mult = (G.GAME.round * G.GAME.round_resets.ante),
            }
            
        end
        if context.after then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        card:start_dissolve()
                        return {true}
                    end
                }))
            end
    end
}

SMODS.Joker {
    key = 'flyingspirit',
    atlas = 'atlasthree',
    no_collection = true,
    rarity = 'jjok_shiki',
    pos = {x = 3, y = 0},
    soul_pos = {x = 2, y = 1},
    loc_txt = {name = 'Flying Cursed Spirit',
                text = {'A minor cursed spirit in',
                        'young Getos collection that',
                        'can fly with people, adds',
                        '{C:attention}1 extra joker slot{} temporarily',
                        '{s:0.8,C:inactive}(Destroyed at end of round)'}},
    add_to_deck = function(self,card,context)
        G.jokers.config.card_limit = G.jokers.config.card_limit + 2
    end,
    remove_from_deck = function(self,card,context)
        G.jokers.config.card_limit = G.jokers.config.card_limit - 2
    end,
    calculate = function(self,card,context)
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i] == card then
                S = i
            end
        end
        if context.end_of_round and context.cardarea == G.jokers then
            G.jokers.cards[S]:start_dissolve()
        end
    end
}

SMODS.Joker {
    key = 'ygeto',
    atlas = 'atlasthree',
    pos = {x = 1, y = 0},
    soul_pos = {x = 0, y = 0},
    loc_txt = {name = 'Young Geto',
                text = {'Upon {C:attention}entering a blind{},',
                            'create 1 of 2 cursed spirits from',
                            'young Getos collection',
                            '{s:0.8}"Are you the strongest because',
                            '{s:0.8}youre Satoru Gojo...'}},
    rarity = 3,
    calculate = function(card,self,context)
        if context.setting_blind then
            local which = pseudorandom("seed", 1, 2)
            if which == 1 then
                local create_cs = SMODS.add_card({set = 'Joker', area = G.jokers, key = 'j_jjok_rainbowdragon'})
            else if which == 2 then
                local create_cs = SMODS.add_card({set = 'Joker', area = G.jokers, key = 'j_jjok_flyingspirit'})
        end
    end
end
end
}

SMODS.Joker {
    key = 'amaki',
    atlas = 'atlasone',
    pos = {x = 3, y = 1},
    soul_pos = {x = 2, y = 1},
    loc_txt = {
        name = 'Awakened Maki',
        text = {
            '{C:attention}Destroys{} the {X:chips,C:white}left most{} card in any',
            'played hand if it is scoring and gains {X:mult,C:white}#2#x{} Mult',
            '{s:0.8}(Currently: {s:0.8,X:mult,C:white}#1#x{s:0.8} Mult){}',
            '{s:0.8}"A demonic fighter equal to Toji',
            '{s:0.8}Zenin was now fully realised!"'
    }
    },
    config ={extra = {
        Xmult = 1,
        Xmult_gain = 0.25
    }},
    loc_vars = function(self,info_queue,center)
        return { vars = { center.ability.extra.Xmult,
                            center.ability.extra.Xmult_gain } }
    end,
    rarity = 4,
    cost = 20,
    hidden = true,
    calculate = function(self,card,context)
        if context.destroying_card and context.cardarea == G.play and context.destroying_card == context.full_hand[1] then
            card.ability.extra.Xmult = card.ability.extra.Xmult + card.ability.extra.Xmult_gain
            return { remove = true, 
                    message = {'+' .. 0.25}}
          end
        if context.joker_main then
            return{
            card = card,
            Xmult = card.ability.extra.Xmult}
        end
end
}

SMODS.Joker {
    key = 'tgojo',
    loc_txt = {
        name = 'Satoru Gojo',
        text = {
            'Using the six eyes and limitless',
            'techniques, {C:attention}doubles{} hand size',
            '{s:0.8}"Aside from Satoru Gojo, of course"{}'
        }
    
    },
    atlas = 'atlasthree',
    pos = {x = 1, y = 1},
    soul_pos = {x = 0, y = 1},
    rarity = 'jjok_special',
    cost = 40,
    add_to_deck = function(self,card,context)
        G.hand:change_size(G.hand.config.card_limit)
    end,
    remove_from_deck = function(self,card,context)
        G.hand:change_size(-(G.hand.config.card_limit/2))
    end
}

SMODS.Joker {
    key = 'nanami',
    loc_txt = {name = 'Nanami Kento',
                text = {'Every scored {C:attention}7{} or {C:attention}3{}',
                        'gives {X:mult,C:white}#1#x{} Mult',
                        '{s:0.8}"You take it from here..."'}},
    rarity = 4,
    cost = 20,
    atlas = 'atlasone',
    pos = {x = 3, y = 2},
    soul_pos = {x = 2, y = 2},
    config = {extra = {Xmult = 1.5}},
    loc_vars = function(self,info_queue,card)
        return {vars = {card.ability.extra.Xmult}}
    end,
    remove_from_deck = function(self,card,context)
        if #G.consumeables.cards < G.consumeables.config.card_limit then
            local create_ntool = SMODS.add_card({key = 'c_jjok_nanamitool', area = G.consumeable})
        end
    end,
    calculate = function(self,card,context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 7 or context.other_card:get_id() == 3 then
                return {
                    Xmult = card.ability.extra.Xmult,
                    card = context.other_card
                }
            end
        end
    end
}

SMODS.Joker {
    key = 'ygojo',
    atlas = 'atlasone',
    soul_pos = {x = 0, y = 2},
    pos = {x = 1, y = 2},
    cost = 20,
    loc_vars = function(self,info_queue,card)
        return  {vars = {card.ability.extra.mult}}
    end,
    loc_txt = {
        name = 'Young Gojo',
        text = {
            'Gains {C:mult}+1{} mult everytime',
            'a joker triggers',
            '{s:0.8, C:inactive}(Currently: {C:mult,s:0.8}+#1#{s:0.8, C:inactive} mult){}',
            '{s:0.8}"I alone am the honoured one"{}'
        }
    },
    blueprint_compat = true,
    rarity = 4,
    config = {extra = { mult = 0, mult_gain = 1},
                        unlocked = true,
                        discovered = true  },
    calculate = function(self,card,context)
        if context.joker_main then
            return {
            mult_mod = card.ability.extra.mult
            }
        end
        if context.post_trigger and context.other_card ~= card and not context.blueprint then
            card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
            return {
                message = 'Concept Grasped',
                colour = G.C.MULT
            }
        end
    end
}


SMODS.Atlas {
    key = 'atlasone',
    path = 'one.png',
    px = 1030,
    py = 1378
}

SMODS.Atlas {
    key = 'atlastwo',
    path = 'two.png',
    px = 126,
    py = 185
}

SMODS.Atlas {
    key = 'atlasthree',
    path = 'three.png',
    px = 1030,
    py = 1378
}

SMODS.Joker {
    key = 'mai',
    loc_txt = {
        name = 'Mai Zenin',
        text = {'{C:attention}Create{} a random {C:spectral}Spectral{}',
                'or {C:tarot}Tarot{} card upon ',
                '{C:attention}skipping or entering a blind{}',
                '{s:0.8}"Why wouldnt you stay at the bottom with me..."{}'
    }},
    atlas = 'atlasone',
    pos = {x = 3, y = 0},
    soul_pos = {x = 2, y = 0},
    blueprint_compat = true,
    cost = 6,
    rarity = 2,
    calculate = function(self,card,context)
        if context.skip_blind or context.setting_blind and #G.consumeables.cards < G.consumeables.config.card_limit then
            local create_consum = nil
            local sort = pseudorandom("seed", 1, 10)
            if sort <= 5 then 
                create_consum = SMODS.add_card({set = 'Tarot', area = G.consumeable})
            end
            if sort >= 6 and sort ~= 10 then 
                create_consum = SMODS.add_card({set = 'Spectral', area = G.consumeable})
            end
            if sort == 10 then
                create_consum = SMODS.add_card({key = 'c_jjok_makitool', area = G.consumeable})
                card:start_dissolve()
            end
        end 
end
}

SMODS.Joker {
    key = 'yuta',
    loc_txt = {
        name = 'Yuta Okkotsu',
        text = {
            'Rika {C:attention}copies{} the abilities of the jokers',
            'to the {X:chips,C:white}left{} and {X:mult,C:white}right{} of Yuta if both',
            'abilities can be copied',
            '{s:0.8}"The cursed child..."{}'
        }
    }, 
    rarity = "jjok_special",
    atlas = 'atlasone',
    pos = {x = 1, y = 1},
    soul_pos = {x = 0, y = 1},
    cost = 40,
    blueprint_compat = false,
    config = { extra = { retriggers = 1 },
            unlocked = true,
            discovered = true },
    update = function(self, card, context)
        local index = -1
        Right_joker = nil
        Left_joker = nil
        RightCompat = nil
        LeftCompat = nil
        if G.STAGE == G.STAGES.RUN then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then
                    index = i
                end
            end
            if index > 1 and index < #G.jokers.cards then
                Left_joker = G.jokers.cards[index - 1]
                Right_joker = G.jokers.cards[index + 1]

                if Right_joker and Right_joker ~= self and Right_joker.config.center.blueprint_compat then
                    RightCompat = true
                else
                    RightCompat = false
                end
                if Left_joker and Left_joker ~= self and Left_joker.config.center.blueprint_compat then
                    LeftCompat = true
                else
                    LeftCompat = false
                end
                if LeftCompat == true and RightCompat == true then
                    card.ability.blueprint_compat = 'compatible'
                else
                    card.ability.blueprint_compat = 'incompatible'
                end
            end
        end
    end,
    calculate = function(self, card, context)
        if RightCompat == true and LeftCompat == true then
            if context.retrigger_joker_check and not context.retrigger_joker and (context.other_card == Right_joker or context.other_card == Left_joker) then
                return {
                    message = 'Copied!',
                    repetitions = card.ability.extra.retriggers,
                    card = card
                }
            end
        end
    end
}   

SMODS.Joker {
    key = 'maki',
    loc_txt = {
        name = 'Maki Zenin',
        text = {
            'Gives {X:mult,C:white}X#1#{} mult',
            '{s:0.8}"A demonic fighter...',
            '{s:0.8}was not yet realized"'
        }
    },
    atlas = 'atlasone',
    blueprint_compat = true,
    cost = 3,
    soul_pos = { x = 0, y = 0 },
    pos = { x = 1, y = 0 },
    config = { extra = {
        Xmult = 1.5,
    }
    },
    loc_vars = function(self, info_queue, center)
        return { vars = { center.ability.extra.Xmult } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            return {
                card = card,
                Xmult = card.ability.extra.Xmult,
            }
        else
            if context.blueprint then
                return {
                    card = card,
                    Xmult = card.ability.extra.Xmult,
                }
            end
        end
    end
}

----------------------------------------------
------------MOD CODE END----------------------
