# manifest
[manifest]
version = "0.1.0"
dump_lua = true
priority = 0

#for calculating cardareas
[[patches]]
[patches.pattern]
target = '=[SMODS _ "src/utils.lua"]'
pattern = "-- TARGET: add your own CardAreas for joker evaluation"
position = 'before'
match_indent = true
payload = '''
table.insert(t, G.domain)
'''

#hands bigger than 5
[[patches]]
[patches.pattern]
target = 'functions/button_callbacks.lua'
pattern = 'if #G.hand.highlighted <= 0 or G.GAME.blind.block_play or #G.hand.highlighted > math.max(G.GAME.starting_params.play_limit, 1) then'
position = 'at'
payload = 'if #G.hand.highlighted <= 0 or G.GAME.blind.block_play or #G.hand.highlighted > G.hand.config.highlighted_limit then'
match_indent = true
[[patches]]
[patches.pattern]
target = 'functions/button_callbacks.lua'
pattern = 'if G.GAME.current_round.discards_left <= 0 or #G.hand.highlighted <= 0 or #G.hand.highlighted > math.max(G.GAME.starting_params.discard_limit, 0) then'
position = 'at'
payload = 'if G.GAME.current_round.discards_left <= 0 or #G.hand.highlighted <= 0 or #G.hand.highlighted > G.hand.config.highlighted_limit then'
match_indent = true

#load anim
[[patches]]
[patches.pattern]
target = "game.lua"
pattern = "SC = Card(G.ROOM.T.w/2 - SC_scale*G.CARD_W/2, 10. + G.ROOM.T.h/2 - SC_scale*G.CARD_H/2, SC_scale*G.CARD_W, SC_scale*G.CARD_H, G.P_CARDS.empty, G.P_CENTERS['j_joker'])"
position = "after"
payload = '''
	SC = Card(G.ROOM.T.w/2 - SC_scale*G.CARD_W/2, 10. + G.ROOM.T.h/2 - SC_scale*G.CARD_H/2, SC_scale*G.CARD_W, SC_scale*G.CARD_H, G.P_CARDS.empty, G.P_CENTERS['j_jjok_tgojo'],{bypass_discovery_center = true, bypass_discovery_ui = true})
'''
match_indent = true

#splash card
[[patches]]
[patches.pattern]
target = 'game.lua'
pattern = "local replace_card = Card(self.title_top.T.x, self.title_top.T.y, 1.2*G.CARD_W*SC_scale, 1.2*G.CARD_H*SC_scale, G.P_CARDS.S_A, G.P_CENTERS.c_base)"
position = 'at'
match_indent = true
payload = '''
local replace_card = Card(self.title_top.T.x, self.title_top.T.y, 1.2*G.CARD_W*SC_scale, 1.2*G.CARD_H*SC_scale, G.P_CENTERS.j_jjok_tgojo, G.P_CENTERS.c_base)
'''

#takako
[[patches]]
[patches.pattern]
target = 'card.lua'
pattern = "if self.seal == 'Blue' and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit and not self.ability.extra_enhancement then"
position = 'before'
match_indent = true
payload = '''
local _found = {}
for i,v in ipairs(G.jokers.cards) do
	if v.config.center.key == 'j_jjok_takako' then
		table.insert(_found, v)
	end
end
if #_found > 0 and self.seal == 'Blue' then
				local _planet = nil
					for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                        if v.config.hand_type == G.GAME.last_hand_played then
                            _planet = v.key
                        end
                    end
    for i = 1, (#_found * 3) do
		    SMODS.add_card({set = 'Planet', area = G.consumeables, key = _planet, edition = 'e_negative'})
	    end
	    self:juice_up()
            return {
                message = '+'.. #_found*3 ..' Planets!', colour = G.C.SECONDARY_SET.Planet
            }
else
'''

[[patches]]
[patches.pattern]
target = 'card.lua'
pattern = '''
ret.effect = true
end
'''
position = 'after'
match_indent = false
payload = '''
end
'''

#ctools tracking
[[patches]]
[patches.pattern]
target = 'functions/misc_functions.lua'
pattern = "elseif card.config.center.set == 'Spectral' then  G.GAME.consumeable_usage_total.spectral = G.GAME.consumeable_usage_total.spectral + 1"
position = 'after'
match_indent = true
payload = '''
elseif card.config.center.set == 'ctools' then  G.GAME.consumeable_usage_total.ctools = G.GAME.consumeable_usage_total.ctools + 1
'''

[[patches]]
[patches.pattern]
target = 'functions/misc_functions.lua'
pattern = "G.GAME.consumeable_usage_total = G.GAME.consumeable_usage_total or {tarot = 0, planet = 0, spectral = 0, tarot_planet = 0, all = 0}"
position = 'at'
match_indent = true
payload = '''
G.GAME.consumeable_usage_total = G.GAME.consumeable_usage_total or {tarot = 0, planet = 0, spectral = 0, ctools = 0, tarot_planet = 0, all = 0}
'''

#outer swirl main menu
[[patches]]
[patches.pattern]
target = "game.lua"
pattern = "{name = 'colour_1', ref_table = G.C, ref_value = 'RED'},"
position = "at"
payload = "{name = 'colour_1', ref_table = G.C.SPLASH, ref_value = 1},"
match_indent = true

#inner swirl main menu
[[patches]]
[patches.pattern]
target = "game.lua"
pattern = "{name = 'colour_2', ref_table = G.C, ref_value = 'BLUE'},"
position = "at"
payload = "{name = 'colour_2', ref_table = G.C.SPLASH, ref_value = 2},"
match_indent = true

#ancient fix
[[patches]]
[patches.pattern]
target = 'functions/common_events.lua'
pattern = '''
local ancient_suits = {}
    for k, v in ipairs({'Spades','Hearts','Clubs','Diamonds'}) do
        if v ~= G.GAME.current_round.ancient_card.suit then ancient_suits[#ancient_suits + 1] = v end
    end
    local ancient_card = pseudorandom_element(ancient_suits, pseudoseed('anc'..G.GAME.round_resets.ante))
    G.GAME.current_round.ancient_card.suit = ancient_card
'''
position = 'at'
payload = '''
G.GAME.current_round.ancient_card.suit = 'Spades'
    local valid_ancient_cards = {}
    for k, v in ipairs(G.playing_cards) do
        if v.ability.effect ~= 'Stone Card' then
            if not SMODS.has_no_suit(v) then
                table.insert(valid_ancient_cards, v)
            end
        end
    end
    if valid_ancient_cards[1] then 
        local ancient_card = pseudorandom_element(valid_ancient_cards, pseudoseed('anc'..G.GAME.round_resets.ante))
        G.GAME.current_round.ancient_card.suit = ancient_card.base.suit
    end
'''
match_indent = true

# Hook into Card:highlight for card alignment
[[patches]]
[patches.pattern]
target = "card.lua"
pattern = '''
config = {align=
        ((self.area == G.jokers) or (self.area == G.consumeables)) and "cr" or
        "bmi"
    , offset = 
        ((self.area == G.jokers) or (self.area == G.consumeables)) and {x=x_off - 0.4,y=0} or
        {x=0,y=0.65},
    parent =self}
'''
position = "at"
payload = '''
config = {align=
        ((self.area == G.jokers) or (self.area == G.consumeables) or (self.area == G.domain)) and "cr" or
        "bmi"
    , offset = 
        ((self.area == G.jokers) or (self.area == G.consumeables) or (self.area == G.domain)) and {x=x_off - 0.4,y=0} or
        {x=0,y=0.65},
    parent =self}
'''
match_indent = true

#hakari
[[patches]]
[patches.pattern]
target = "card.lua"
pattern = '''
if pseudorandom('lucky_mult') < G.GAME.probabilities.normal/5 then
'''
position = "at"
match_indent = true
payload = '''
if (pseudorandom('lucky_mult') < G.GAME.probabilities.normal/5) or JJOK.find_joker('j_jjok_hak') ~= nil then
'''

[[patches]]
[patches.pattern]
target = "card.lua"
pattern = '''
if pseudorandom('lucky_money') < G.GAME.probabilities.normal/15 then
'''
position = "at"
match_indent = true
payload = '''
if (pseudorandom('lucky_money') < G.GAME.probabilities.normal/15) or JJOK.find_joker('j_jjok_hak') ~= nil then
'''

[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
if card.ability.consumeable and card.area == G.pack_cards and booster_obj and booster_obj.select_card and card:selectable_from_pack(booster_obj) then
'''
position = 'before'
match_indent = true
payload = '''
if card.config.center.key == 'j_jjok_kenny' then
use = {n=G.UIT.C, config={align = "cr"}, nodes={
      {n=G.UIT.C, config={ref_table = card, align = "cr",padding = 0.1, r=0.08, minw = 1.25, hover = true, shadow = true, colour = G.C.UI.BACKGROUND_INACTIVE, one_press = true, button = 'jjok_kenny_use', func = 'jjok_kenny_can'}, nodes={
        {n=G.UIT.B, config = {w=0.1,h=0.6}},
        {n=G.UIT.C, config={align = "tm"}, nodes={
          {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={ {n=G.UIT.T, config={text = 'BODY',colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}}},
          {n=G.UIT.R, config={align = "cm", maxw = 1.25}, nodes={ {n=G.UIT.T, config={text = 'HOP',colour = G.C.UI.TEXT_LIGHT, scale = 0.4, shadow = true}}}}
          }
        }
      }}
    }}
end
'''

[[patches]]
[patches.pattern]
target = 'game.lua'
pattern = '''
self.HUD = UIBox{
        definition = create_UIBox_HUD(),
        config = {align=('cli'), offset = {x=-0.7,y=0},major = G.ROOM_ATTACH}
    }
    self.HUD_blind = UIBox{
        definition = create_UIBox_HUD_blind(),
        config = {major = G.HUD:get_UIE_by_ID('row_blind_bottom'), align = 'bmi', offset = {x=0,y=-10}, bond = 'Weak'}
    }
    self.HUD_tags = {}
'''
position = 'after'
match_indent = true
payload = '''
--self.CE = UIBox{
  --  definition = create_UIBox_HUD(),
    --    config = {align=('cli'), offset = {x=0,y=0}, major = G.HUD}
--}
'''
[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
{n=G.UIT.R, config={align = "cm", minh = 0.3}, nodes={}},
'''
position = 'after'
match_indent = true
payload = '''
contents.cursed,
'''
[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
contents.hand =
'''
position = 'before'
match_indent = true
payload = '''
contents.cursed = 
   {n=G.UIT.R, config={align = "cm",r=0.1, padding = 0,colour = G.C.DYN_UI.BOSS_MAIN, emboss = 0.05 }, nodes={
      {n=G.UIT.C, config={align = "cm", padding = 0.1}, nodes={
        {n=G.UIT.C, config={align = "cm", minw = 1}, nodes={
          {n=G.UIT.R, config={align = "cm", padding = 0, maxw = 1.3}, nodes={
            {n=G.UIT.T, config={text = 'Cursed', scale = 0.32, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
          }},
          {n=G.UIT.R, config={align = "cm", padding = 0, maxw = 1.3}, nodes={
            {n=G.UIT.T, config={text ='energy', scale = 0.32, colour = G.C.UI.TEXT_LIGHT, shadow = true}}
          }}
        }},
        {n=G.UIT.C, config={align = "cm", minw = 3.3, minh = 0.4, r = 0.1, colour = G.C.DYN_UI.BOSS_DARK, emboss = 0.05}, nodes={
            {n=G.UIT.C, config = {align = 'cm', minw = 3.2, minh = 0.4, r = 0.1, colour = G.C.UI.TEXT_INACTIVE, id = 'CE_UI_count',
            progress_bar = {
                max = G.GAME.cursed_energy_limit or 100, ref_table = G.GAME, ref_value = 'cursed_energy', empty_col = G.C.UI.TEXT_INACTIVE, filled_col = adjust_alpha(G.C.JJOK.LBLUE, 0.1)
            }, func = 'ce_bar_update' }, nodes = {}}
        }}
      }}
    }}
'''

#massive thanks to bepisfever for the styling patches <3
# Fixing description error when info_queue has multi-box descriptions.
[[patches]]
[patches.pattern]
target = 'functions/misc_functions.lua'
pattern = '''
args.AUT.multi_box = {}
'''
position = "at"
payload = '''
if not args.is_info_queue then
    args.AUT.multi_box = {} 
end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/common_events.lua'
pattern = '''
if _c.specific_vars then specific_vars = _c.specific_vars end
'''
position = "before"
payload = '''
local is_info_queue = false
if specific_vars and specific_vars.is_info_queue then is_info_queue = true; specific_vars = nil end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/common_events.lua'
pattern = '''
for _, v in ipairs(info_queue) do
  generate_card_ui(v, full_UI_table)
end
'''
position = "at"
payload = '''
for _, v in ipairs(info_queue) do
  generate_card_ui(v, full_UI_table, {is_info_queue = true})
end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = '=[SMODS _ "src/game_object.lua"]'
pattern = '''
local target = {
  type = 'descriptions',
  key = self.key,
  set = self.set,
  nodes = desc_nodes,
  AUT = full_UI_table,
  vars = 
      specific_vars or {}
}
'''
position = "after"
payload = '''
if target.vars.is_info_queue then target.is_info_queue = true; target.vars.is_info_queue = nil end
'''
match_indent = true

# info_queue supporting stylized names.
[[patches]]
[patches.pattern]
target = 'functions/misc_functions.lua'
pattern = '''
scale =  (0.55 - 0.004*#(final_name_assembled_string or assembled_string))*(part.control.s and tonumber(part.control.s) or args.scale  or 1)
'''
position = "at"
payload = '''
scale =  (0.55 - 0.004*#(final_name_assembled_string or assembled_string))*(part.control.s and tonumber(part.control.s) or args.scale  or 1)*(args.fixed_scale or 1)
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/misc_functions.lua'
pattern = '''
bump = true,
silent = true,
pop_in = 0,
pop_in_rate = 4,
maxw = 5,
shadow = true,
y_offset = -0.6,
spacing = math.max(0, 0.32*(17 - #(final_name_assembled_string or assembled_string))),
'''
position = "at"
payload = '''
bump = not args.no_bump,
silent = not args.no_silent,
pop_in = (not args.no_pop_in and (args.pop_in or 0)) or nil,
pop_in_rate = (not args.no_pop_in and (args.pop_in_rate or 4)) or nil,
maxw = args.maxw or 5,
shadow = not args.no_shadow,
y_offset = args.y_offset or -0.6,
spacing = (not args.no_spacing and math.max(0, 0.32*(17 - #(final_name_assembled_string or assembled_string)))) or nil,
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/common_events.lua'
pattern = '''
desc_nodes.name = localize{type = 'name_text', key = name_override or _c.key, set = name_override and 'Other' or _c.set} 
'''
position = "after"
payload = '''
local set = name_override and "Other" or _c.set
local key = name_override or _c.key
if set == "Seal" then
  if G.localization.descriptions["Other"][_c.key.."_seal"] then set = "Other"; key = key.."_seal" end
else
  if not G.localization.descriptions[set][_c.key] then set = "Other" end
end
desc_nodes.loc_name = {}
localize{type = 'name', key = key, set = set, nodes = desc_nodes.loc_name, fixed_scale = 0.63, no_pop_in = true, no_shadow = true, y_offset = 0, no_spacing = true, no_bump = true, vars = (_c.create_fake_card and _c.loc_vars and (_c:loc_vars(info_queue, _c:create_fake_card()) or {}).vars) or {colours = {}}} 
desc_nodes.loc_name = info_queue_desc_from_rows(desc_nodes.loc_name, true)
desc_nodes.loc_name.config.align = "cm"
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/common_events.lua'
pattern = '''
_c:generate_ui(info_queue, card, desc_nodes, specific_vars, full_UI_table)
'''
position = "before"
payload = '''
local specific_vars = specific_vars or {}
if is_info_queue then specific_vars.is_info_queue = true end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/common_events.lua'
pattern = '''
_c:generate_ui(info_queue, card, desc_nodes, specific_vars, full_UI_table)
'''
position = "after"
payload = '''
if is_info_queue then
  desc_nodes.loc_name = {}
  local set = name_override and "Other" or _c.set
  local key = name_override or _c.key
  if set == "Seal" then
    if G.localization.descriptions["Other"][_c.key.."_seal"] then set = "Other"; key = key.."_seal" end
  else
    if not G.localization.descriptions[set][_c.key] then set = "Other" end
  end

  localize{type = 'name', key = key, set = set, nodes = desc_nodes.loc_name, fixed_scale = 0.63, no_pop_in = true, no_shadow = true, y_offset = 0, no_spacing = true, no_bump = true, vars = (_c.create_fake_card and _c.loc_vars and (_c:loc_vars(info_queue, _c:create_fake_card()) or {}).vars) or {colours = {}}} 
  desc_nodes.loc_name = info_queue_desc_from_rows(desc_nodes.loc_name, true)
  desc_nodes.loc_name.config.align = "cm"
end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
function info_tip_from_rows(desc_nodes, name)
'''
position = "after"
payload = '''
  local name_nodes = {}
  if not desc_nodes.loc_name then
    name_nodes = {{n=G.UIT.T, config={text = name, scale = 0.32, colour = G.C.UI.TEXT_LIGHT}}}
  else
    name_nodes = {desc_nodes.loc_name}
  end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
function desc_from_rows(desc_nodes, empty, maxw)
'''
position = "before"
payload = '''
function info_queue_desc_from_rows(desc_nodes, empty, maxw)
  local t = {}
  for k, v in ipairs(desc_nodes) do
    t[#t+1] = {n=G.UIT.R, config={align = "cm", maxw = maxw}, nodes=v}
  end
  return {n=G.UIT.R, config={align = "cm", colour = desc_nodes.background_colour or empty and G.C.CLEAR or G.C.UI.BACKGROUND_WHITE, r = 0.1, emboss = not empty and 0.05 or nil, filler = true, main_box_flag = desc_nodes.main_box_flag and true or nil}, nodes={
    {n=G.UIT.R, config={align = "cm"}, nodes=t}
  }}
end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
{n=G.UIT.R, config={align = "tm", minh = 0.36, padding = 0.03}, nodes={{n=G.UIT.T, config={text = name, scale = 0.32, colour = G.C.UI.TEXT_LIGHT}}}},
'''
position = "at"
payload = '''
{n=G.UIT.R, config={align = "tm", minh = 0.36, padding = 0.03}, nodes=name_nodes},
'''
match_indent = true


#multi joker slot system
[[patches]]
[patches.pattern]
target = 'card.lua'
pattern = '''
self.edition = nil
'''
position = "after"
payload = '''
self.slots = center.slots or 1
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'functions/UI_definitions.lua'
pattern = '''
if obj and obj.set_badges and type(obj.set_badges) == 'function' then
'''
position = "after"
payload = '''
if card.slots ~= 1 then
    badges[#badges + 1] = create_badge(card.slots .. ' Slots', G.C.DARK_EDITION, G.C.WHITE, 1)
end
'''
match_indent = true

[[patches]]
[patches.pattern]
target = 'cardarea.lua'
pattern = '''
self.config.temp_limit = math.max(#self.cards, self.config.card_limit)
    self.config.card_count = #self.cards
'''
position = "at"
payload = '''
local count = 0
for i,v in ipairs(self.cards) do
    count = count + v.slots
end
self.config.temp_limit = math.max(#self.cards, self.config.card_limit)
self.config.card_count = count
'''
match_indent = true
