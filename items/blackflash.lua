JJOK = JJOK or {}

--[[local hook = Card.calculate_joker
function Card:calculate_joker(...)
    if SMODS.pseudorandom_probability(self, 'black flash lol', G.GAME.probabilities.blackflash, 100) then 
        JJOK.black_flash(self)
    end
    return hook(self, ...)
end]]

SMODS.Sound {
    key = 'blackflash',
    path = 'black-flash.ogg'
}

function JJOK.black_flash(card)
    play_sound('jjok_blackflash', 0.7, 0.55)
    --card_eval_status_text(card, )
end