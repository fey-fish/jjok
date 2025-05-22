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
    for i,v in ipairs(G.jokers.cards) do
        if v.config.center.rarity == rar then
            table.insert(ret, v)
        end
    end
    return ret
end
