local cqr = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(x, y)
    if G.CONTROLLER and G.CONTROLLER.cursor_hover and G.CONTROLLER.cursor_hover.target
    and G.CONTROLLER.cursor_hover.target.config and G.CONTROLLER.cursor_hover.target.config.center 
    and G.CONTROLLER.cursor_hover.target.config.center.key == 'j_jjok_hak' then
        G.FUNCS.pachinko()
    else
        return cqr(self, x, y)
    end
end

G.FUNCS.pachinko = function()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = create_pachinko(),
    }
end

function G.FUNCS.pachinko_roll()
    G.GAME.pachinko_nums = {}
    G.GAME.pachinko_nums[1] = tostring(pseudorandom('pachinko', 1, 4))
    G.GAME.pachinko_nums[2] = tostring(pseudorandom('pachinko', 1, 4))
    G.GAME.pachinko_nums[3] = tostring(pseudorandom('pachinko', 1, 4))
    G.FUNCS.pachinko()
    if G.GAME.pachinko_nums[1] == G.GAME.pachinko_nums[2] and G.GAME.pachinko_nums[2] == G.GAME.pachinko_nums[3] then
        G.FUNCS.hakari_anim()
    end
end

function G.FUNCS.hakari_anim()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = hakari_anim(),
    }
end

function hakari_anim()
    local card = Card(0,0, G.CARD_W, G.CARD_H, nil, G.P_CENTERS['j_jjok_hak'])
    local cardarea = CardArea(
        G.ROOM.T.x + 2*G.ROOM.T.w/2,G.ROOM.T.h,
        G.CARD_W,
        G.CARD_H,
        {card_limit = 2, type = 'title', highlight_limit = 0})
    cardarea:emplace(card)

    return {
        n = G.UIT.ROOT,
        config = { align = "cm", r = 0.1, padding = 0.2, colour = G.C.UI.TEXT_INACTIVE },
        nodes = {
            {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                {n = G.UIT.O, config = {object = cardarea}}
            }},
            {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                {n = G.UIT.T, config = {text = 'In the 4 Minutes and 11 Seconds following a Jackpot, Hakari is effectively Immortal!', 
                    scale = 0.5, colour = G.C.DARK_EDITION}}
            }},
        }
    }
end

function create_pachinko()
    G.GAME.pachinko_nums = G.GAME.pachinko_nums or {'$', '$', '$'}
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", r = 0.1, padding = 0.1, colour = G.C.UI.TEXT_INACTIVE, minw = 8, maxh = 6 },
        nodes = {
            {n = G.UIT.R, config = { align = 'cm' }, nodes = {
                {n = G.UIT.C, config = {r = 0.05, padding = 0.05, colour = 	G.C.SECONDARY_SET.Tarot}, nodes = {
                {n = G.UIT.C, config = {r = 0.05, colour = SMODS.Gradients.jjok_specialgrad, padding = 0.1}, nodes = {
                {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n = G.UIT.T, config = {text = 'P R I V A T E', colour = G.C.MONEY, scale = 0.5}}}},
                {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n = G.UIT.T, config = {text = 'P U R E', colour = G.C.MONEY, scale = 0.5}}}},
                {n = G.UIT.R, config = {align = 'cm'}, nodes = {
                    {n = G.UIT.T, config = {text = 'L O V E T R A I N', colour = G.C.MONEY, scale = 0.5}}}},
            }}}}}},
            {n = G.UIT.R, config = { r = 0.3, colour = G.C.BLACK, minw = 7.5, maxh = 6, align = 'cm'}, nodes = {
                {n = G.UIT.R, config = { r = 0.3, padding = 0.05, align = 'cm'}, nodes = {
                    {n = G.UIT.C, config = {padding = 0.5}, nodes = {
                        {n = G.UIT.C, config = {colour = G.C.WHITE, padding = 0.5, r = 0.3, hover = true, shadow = true}, nodes = {
                            {n=G.UIT.O, config={object = DynaText({string = { G.GAME.pachinko_nums[1] }, colours = {G.C.MONEY},shadow = true, float = true})}}}
                        },
                    }},
                    {n = G.UIT.C, config = {padding = 0.5}, nodes = {
                        {n = G.UIT.C, config = {colour = G.C.WHITE, padding = 0.5, r = 0.3, hover = true, shadow = true}, nodes = {
                            {n=G.UIT.O, config={object = DynaText({string = { G.GAME.pachinko_nums[2] }, colours = {G.C.MONEY},shadow = true, float = true})}}}
                        },
                    }},
                    {n = G.UIT.C, config = {padding = 0.5}, nodes = {
                        {n = G.UIT.C, config = {colour = G.C.WHITE, padding = 0.5, r = 0.3, hover = true, shadow = true}, nodes = {
                            {n=G.UIT.O, config={object = DynaText({string = { G.GAME.pachinko_nums[3] }, colours = {G.C.MONEY},shadow = true, float = true})}}}
                        },
                    }},
                }},
                {n = G.UIT.R, config = {padding = 0.1, align = 'cm'}, nodes = {
                    UIBox_button({ button = 'pachinko_roll', label = { localize('b_roll') }, colour = G.C.GREEN})
                }}
                }
            }
        }
    }
end