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
    apply = function(self,card)
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
    end,
    in_pool = function(self,args)
        if #G.jokers.cards > 0 then
            return true
        else
            return false
        end
    end
}