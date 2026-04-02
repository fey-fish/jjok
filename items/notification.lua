JJOK = JJOK or {}

function JJOK.create_notif(args)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            local jjok_notif = UIBox {
                definition = create_UIBox_notif(args),
                config = { align = "cm", offset = { x = 0, y = 0 }, instance_type = 'CARD', major = G.ROOM_ATTACH, bond = 'Weak' },
            }
            jjok_notif:align_to_major()
            jjok_notif.config.major = nil
            jjok_notif:set_role { role_type = 'Major' }
            jjok_notif.config.scale = 1

            jjok_notif.T.x = (args.x or 0)
            jjok_notif.T.y = (args.y or 0) + args.y

            if args.yoffset ~= false then jjok_notif.T.y = jjok_notif.T.y + 0.3 end
            G.jjok_notif = jjok_notif
            G.GAME.STOP_USE = G.GAME.STOP_USE + 1

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 4 * G.SETTINGS.GAMESPEED,
                func = function()
                    G.jjok_notif:start_dissolve(nil,nil, 1.5*G.SETTINGS.GAMESPEED)
                    G.GAME.STOP_USE = G.GAME.STOP_USE -1 
                    return true
                end
            }))
            return true
        end
    }))
end

function create_UIBox_notif(args)
    local t = {
        n = G.UIT.ROOT,
        config = { colour = args.bgcol or G.C.BLUE, align = 'cm', r = 0.2, minh = 0.9, minw = args.minw or 5, shadow = true },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = 'cm' },
                nodes = {
                    { n = G.UIT.T, config = { text = args.text or 'Ryoiki Tenkai!', colour = G.C.UI.TEXT_LIGHT, scale = 0.4, align = 'cm', padding = 0.03 } }
                }
            }
        }
    }
    return t
end

UIBox.start_dissolve = Card.start_dissolve

--eval JJOK.create_notif{minw = G.domain.T.w, x = G.domain.T.x, y = G.domain.T.y}