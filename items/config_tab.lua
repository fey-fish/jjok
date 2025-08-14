Jjok = SMODS.current_mod

Jjok.config_tab = function()
    return {
        n = G.UIT.ROOT,
        config = { align = "m", r = 0.1, padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 6 },
        nodes = {
            {
                n = G.UIT.C,
                config = { align = "cm", padding = 0.05 },
                nodes = {
                    {
                        n = G.UIT.R,
                        config = { align = "tm", padding = 0.2 },
                        nodes = { { n = G.UIT.T, config = { text = "Gameplay Settings", colour = G.C.UI.TEXT_LIGHT, scale = 0.5 } } }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "tm" },
                        nodes = {
                            create_toggle { col = true, label = 'Multi-Slot System', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "slotsystem" },
                            create_toggle { col = true, label = 'Majito', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "majito" },
                            
                        }
                    },
                    {
                        n = G.UIT.R,
                        config = { align = "tm" },
                        nodes = {
                            create_toggle { col = true, label = 'Jujutsu Jokers only', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "jjok_only"},
                            create_toggle { col = true, label = 'Thatoru', scale = 1, w = 0, shadow = true, ref_table = Jjok.config, ref_value = "thatoru" }
                        }
                    },
                }
            }
        }
    }
end
