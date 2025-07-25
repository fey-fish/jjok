--generate an awaken on end of finisher and boss kill context
local hookTo = end_round
function end_round()
    local ret = hookTo()
    if G.GAME.blind.boss == true then
        SMODS.calculate_context { boss_defeat = true }
        if G.domain.cards[1] then
            for i, v in ipairs(G.domain.cards) do
                if v.config.center.set == 'Domain' then
                    v.ability.extra.used_this_ante = false
                end
            end
        end
    end
    if G.GAME.blind.config.blind.boss ~= nil then
        if G.GAME.blind.config.blind.boss.showdown == true then
            SMODS.add_card({ key = 'c_jjok_awaken' })
        end
    end
    return ret
end

G.TIMERS.naoya = 0
local ante = nil
local hookTo = love.update
function love.update(dt)
    local ret = hookTo(dt)
    if G.GAME.blind and G.GAME.blind.in_blind and not G.GAME.blind.boss then
        G.TIMERS.naoya = G.TIMERS.naoya + 0.01666666666
        G.TIMERS.n_round = math.floor(G.TIMERS.naoya + 0.5)
    end
    if ante ~= G.GAME.round_resets.ante then
        G.TIMERS.naoya = 0
        G.TIMERS.n_round = 0
    end
    ante = G.GAME.round_resets.ante
    if G.TIMERS.naoya then
        G.GAME.naoya_mult = (G.GAME.round_resets.ante ^ 2) - (G.GAME.round / 100 * G.TIMERS.n_round)
    end
    return ret
end

--big ty to N' again
local ccr = SMODS.calculate_context
function SMODS.calculate_context(context, return_table)
    if G.in_delete_run then return end
    return ccr(context, return_table)
end

local csd = Card.set_debuff
function Card:set_debuff(should_debuff)
    if self.area == G.domain and self.ability.perishable and self.ability.perish_tally <= 0. then
        self:start_dissolve()
    else
        return csd(self, should_debuff)
    end
end

--jjok only
local gsr = Game.start_run
function Game:start_run(args)
    local ret = gsr(self, args)
    if Jjok.config.jjok_only == true then
        self.GAME.jjok_only = true
    else
        self.GAME.jjok_only = false
    end
    return ret
end

local gcp = get_current_pool
function get_current_pool(_type, _rarity, _legendary, _append)
    local _pool, _pool_key = gcp(_type, _rarity, _legendary, _append)
    if G.GAME.jjok_only == true and _type == 'Joker' then
        for i, v in ipairs(_pool) do
            if not (string.sub(v, 1, 6) == 'j_jjok') then
                _pool[i] = 'UNAVAILABLE'
            end
        end
    end
    return _pool, _pool_key
end

--placeholder sprites
local csa = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    if self.config.center.atlas and self.config.center.atlas == 'Joker' then
        if self.config.center.mod and self.config.center.mod.id == 'jjok' then
            self.config.center.pos = {x = 9, y = 9}
        end
    end
    if self.config.center.atlas and self.config.center.atlas == 'Tarot' then
        if self.config.center.mod and self.config.center.mod.id == 'jjok' then
            if self.config.center.set == 'Tarot' then
                self.config.center.pos = {x = 6, y = 2}
            elseif self.config.center.set == 'Spectral' then
                self.config.center.pos = {x = 5, y = 2}
            elseif self.config.center.set == ('ctools' or 'domain') then
                self.config.center.pos = {x = 7, y = 2}
            end
        end
    end
    return csa(self, center, initial, delay_sprites)
end