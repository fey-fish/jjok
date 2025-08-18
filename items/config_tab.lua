Jjok = SMODS.current_mod

Jjok.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "tm", padding = 0.2 },
                        nodes = { { n = G.UIT.T, config = { text = "Gameplay Settings", colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } } }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "tm", padding = 0.2 },
                        nodes = {
                            {
                                n = G.UIT.C,
                                config = { align = "tm", padding = 0.03 },
                                nodes = {
                                    {
                                        n = G.UIT.C,
                                        config = {
                                            ref_table = card,
                                            align = "cr",
                                            padding = 0.1,
                                            r = 0.08,
                                            minw = 1.25,
                                            hover = true,
                                            shadow = true,
                                            colour = G.C.JJOK.LBLUE,
                                            button = 'jjok_textures',
                                            func = 'can_sell_card'
                                        },
                                        nodes = {
                                            { n = G.UIT.B, config = { w = 0.1, h = 0.6 } },
                                            {
                                                n = G.UIT.C,
                                                config = { align = "tm" },
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = { align = "cm", maxw = 1.25 },
                                                        nodes = {
                                                            { n = G.UIT.T, config = { text = 'Textures', colour = G.C.UI.TEXT_LIGHT, scale = 0.8, shadow = true } }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    },
                                }
                            },
                            {
                                n = G.UIT.C,
                                config = { align = "tm", padding = 0.03 },
                                nodes = {
                                    { n = G.UIT.R, config = { padding = 0.03 }, nodes = { create_toggle { col = true, label = 'Jujutsu Jokers only', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "jjok_only" } } },
                                    { n = G.UIT.R, config = { padding = 0.03 }, nodes = { create_toggle { col = true, label = 'Multi-Slot System', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "slotsystem" } } },
                                }
                            },
                        }
                    },
                }
            }
        }
    }
end

function G.FUNCS.jjok_textures()
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu {
        definition = textures(),
    }
end

function textures()
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", r = 0.1, padding = 0.1, colour = G.C.JJOK.LBLUE, minw = 8, maxh = 6 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = 'cm', r = 0.03, padding = 0.01, colour = G.C.BLUE, minw = 6, maxh = 5 },
                nodes = {
                    { n = G.UIT.R, config = { padding = 0.03 }, nodes = { create_toggle { col = true, label = 'Thatoru', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "thatoru" } } },
                    { n = G.UIT.R, config = { padding = 0.03 }, nodes = { create_toggle { col = true, label = 'Majito', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "majito" } } },

                }
            }
        }
    }
end
