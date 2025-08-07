SMODS.ConsumableType {
    key = 'ct',
    primary_colour = HEX('F52742'),
    secondary_colour = HEX('F52742'),
    loc_txt = {name = 'Cursed Technique', collection = 'Techniques'},
    collection_rows = {4, 5},
    shop_rate = 0
}

SMODS.Voucher {
    key = 'techniquevoucher',
    cost = 10,
    loc_txt = {name = 'Cursed Inheritance',
                text = {'Allows {C:jjok_tech}Cursed Techniques',
                        'to appear in the {C:attention}shop'}},
    redeem = function(self,card)
        G.GAME.ct_rate = 2
    end
}

SMODS.Consumable {
    key = 'transgender',
    cost = 5,
    loc_txt = {name = 'Idle Transfiguration',
                text = {'Convert a {C:attention}selected{} Joker',
                        'to another of the same {C:attention}Rarity'}},
    set = 'ct',
    can_use = function(self,card)
        if #G.jokers.highlighted == 1 and G.GAME.cursed_energy >= card.ce_cost then
            return true
        end
    end,
    use = function(self,card)
        local _card = G.jokers.highlighted[1]
        local edition = _card.edition.key or nil

        SMODS.add_card({rarity = _card.config.center.rarity, edition = edition})
        _card:start_dissolve()
        ease_ce(card.ce_cost)
    end,
    in_pool = function(self,args)
        if #G.jokers.cards > 0 then
            return true
        else
            return false
        end
    end
}

SMODS.Consumable {
    key = 'piercingblood',
    cost = 5,
    loc_txt = {name = 'Piercing Blood',
                text = {'{C:attention}Destroy{} a',
                        'selected {C:attention}Joker'}},
    set = 'ct',
    can_use = function(self,card)
        if #G.jokers.highlighted == 1 and G.GAME.cursed_energy >= card.ce_cost and
         not G.jokers.highlighted[1].ability.eternal then
            return true
        end
    end,
    use = function(self,card)
        G.jokers.highlighted[1]:start_dissolve()
        ease_ce(card.ce_cost)
    end,
    in_pool = function(self,args)
        if #G.jokers.cards > 0 then
            return true
        else
            return false
        end
    end
}

SMODS.Consumable {
    key = 'uzuma',
    cost = 5,
    loc_txt = { name = 'Uzumaki',
        text = { '{C:attention}Fuse Jokers{}',
            '{C:attention,s:0.8}4 {C:common,s:0.8}Common {C:attention,s:0.8}Jokers{,s:0.8} = {C:uncommon,s:0.8}Uncommon',
            '{C:attention,s:0.8}3 {C:uncommon,s:0.8}Uncommon {C:attention,s:0.8}Jokers{,s:0.8} = {C:rare,s:0.8}Rare',
            '{C:attention,s:0.8}2 {C:rare,s:0.8}Rare {C:attention,s:0.8}Jokers{,s:0.8} = {C:legendary,s:0.8}Legendary', } },
    set = 'ct',
    config = { extra = { common = false, uncommon = false, rare = false } },
    can_use = function(self, card)
        card.ability.extra.common = false
        card.ability.extra.uncommon = false
        card.ability.extra.rare = false
        local rars = JJOK.pool_rarities()
        if rars[1] >= 4 then
            card.ability.extra.common = true
        end
        if rars[2] >= 3 then
            card.ability.extra.uncommon = true
        end
        if rars[3] >= 2 then
            card.ability.extra.rare = true
        end
        if rars[1] >= 4 or rars[2] >= 3 or rars[3] >= 2 then
            return true
        end
    end,
    use = function(self, card)
        if card.ability.extra.common == true then
            for i, v in ipairs(JJOK.find_rar(1)) do
                v:start_dissolve()
            end
            SMODS.add_card({ set = 'Joker', rarity = 'Uncommon' })
        end
        if card.ability.extra.uncommon == true then
            for i, v in ipairs(JJOK.find_rar(2)) do
                v:start_dissolve()
            end
            SMODS.add_card({ set = 'Joker', rarity = 'Rare' })
        end
        if card.ability.extra.rare == true then
            for i, v in ipairs(JJOK.find_rar(3)) do
                v:start_dissolve()
            end
            SMODS.add_card({ set = 'Joker', rarity = 'Legendary' })
        end
        ease_ce(card.ce_cost)
    end
}