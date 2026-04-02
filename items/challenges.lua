--for custom rules

local batr = Back.apply_to_run
function Back:apply_to_run()
    if self.effect.config.forced_2_slots then
        G.GAME.modifiers.forced_2_slots = true
    end
    return batr(self)
end

SMODS.Challenge {
    key = 'glutton',
    loc_txt = {name = 'Gluttonous'},
    rules = {
        custom = {
            { id = 'forced_2_slots' }
        },
        modifiers = {
            { id = 'joker_slots', value = 6 },
        }
    }
}

SMODS.Challenge {
    key = 'distortedkilling',
    loc_txt = {name = 'Distorted Killing'},
    jokers = {
        {id = 'j_jjok_mahito', eternal = true},
        {id = 'j_perkeo', eternal = true}
    },
    consumeables = {
        {id = 'c_ectoplasm'}
    }
}