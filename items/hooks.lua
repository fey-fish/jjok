--generate an awaken on end of finisher and boss kill context
local hookTo = end_round
function end_round()
    local ret = hookTo()
    if G.GAME.blind.boss == true then
        SMODS.calculate_context { boss_defeat = true }
    end
    if G.GAME.blind.config.blind.boss ~= nil then
        if G.GAME.blind.config.blind.boss.showdown == true then
            SMODS.add_card({ key = 'c_jjok_awaken' })
        end
    end
    return ret
end
