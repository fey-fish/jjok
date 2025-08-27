---Table of arguments for SMODS.Tutorial
---@class args table
---@field w number Scale for width of card
---@field h number Scale for height of card
---@field x number x position of card
---@field y number y position of card
---@field center string Center of card character
---@field particle_colours table? Particle colors to apply, should be 3 indexes

---Secondary table for SMODS.Tutorial
---@class other table
---@field spot table UI Element for Card Character to replace
---@field quip string Loc key in [tutorial] or [quips]
---@field loc_vars table Variables for your loc_key (loc_vars.quip = true if loc_key is in [quips])
---@field times number? How many times character should speak

---For adding a button to your tutorial
---@class button table
---@field func string Function in G.FUNCS that triggers on button click
---@field button string Text on your button
---@field update_func string Function in G.FUNCS that updates your button every frame
---@field colour table? Colour values for background colour of button

---Creates a tutorial character like the vanilla one.
---@class SMODS.Tutorial function
---@field args table Table of arguments for card character
---@field other table Table of secondary arguments for text and position

function SMODS.Tutorial(args, other, button)
    G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
            args.w = args.w or G.CARD_W * 1.25
            args.h = args.h or G.CARD_H * 1.25
            Character = Card_Character(args)
            other.spot:remove()
            other.spot = Character

            if button then
                Character:add_button(button.button, button.func, button.colour or G.C.RED, button.update_func)
            end

            Character:add_speech_bubble(other.quip, args.align or nil, other.loc_vars)
            Character:say_stuff((other and other.times) or 5, false, other.quip)
            return true
        end
    }))
end

---Example Joker
SMODS.Joker {
    key = 'tutorialjoker',
    loc_txt = { name = 'Tutorial Joker',
        text = {
            'Add to deck to',
            'preview {C:attention}SMODS.Tutorial'
        } },
    rarity = 1,
    cost = 2,
    add_to_deck = function(self, card)
        local args = {
            w = G.CARD_H,
            h = G.CARD_W,
            x = card.T.x,
            y = card.T.y,
            align = 'cr',
            center = 'j_blueprint',
            particle_colours = { G.C.BLUE, G.C.PURPLE, G.C.MONEY }
        }
        local other = { spot = card, times = 10, quip = 'wq_4', loc_vars = { quip = true } }
        local button = {
            update_func = 'tutorial_joker_function',
            button = 'Cannot progress',
            colour = G.C.BLUE
        }
        SMODS.Tutorial(args, other, button)
    end
}

function G.FUNCS.tutorial_joker_function(card)
    local button = Character.children.button.definition.nodes[1].nodes[1].nodes[1].config
    if G.STATE == G.STATES.SELECTING_HAND then
        button.button = 'Open mod Directory!'
        button.func = 'openModsDirectory'
        button.colour = G.C.UI.TEXT_LIGHT
    else
        button.text = 'Cannot Progress'
        button.func = nil
        button.colour = G.C.UI.BACKGROUND_INACTIVE
    end
end
