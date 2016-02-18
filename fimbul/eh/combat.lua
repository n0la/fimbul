---@module fimbul.eh.combat

local combat = {}

local base = _G

local task = require('fimbul.eh.task')
local rules = require('fimbul.eh.rules')
local util = require('fimbul.util')

function combat:new(r)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._r = r
   neu._participants = {}
   neu._order = {}
   neu._round = 0
   neu._cur = 0

   neu.on_damage = {}
   neu.on_attack = {}
   neu.on_death = {}

   return neu
end

function combat:raise(event, ...)
   if self[event] == nil or type(self[event]) ~= 'table' then
      return nil
   end

   for _, f in base.pairs(self[event]) do
      if type(f) == 'function' then
         f(...)
      end
   end
end

function combat:register(event, f)
   if self[event] == nil then
      error('No such event!')
   end

   table.insert(self[event], f)
end

function combat:participants()
   return self._participants
end

function combat:round()
   return self._round
end

function combat:_determine_initiative()
   -- Roll initiative for each participant and see where they stand
   --

   self._order = {}
   for _, p in base.pairs(self:participants()) do
      local ini = p:roll_initiative()

      table.insert(self._order, {initiative = ini, target = p})
   end

   -- Sort based on initiative
   table.sort(self._order,
              function (a1, a2)
                 return a1.initiative < a2.initiative
              end
   )
end

function combat:start()
   self:_determine_initiative()
   self._round = 1
   self._cur = 1
end

function combat:current()
   if #self._order == 0 or self._cur == 0 then
      return nil
   end

   return self._order[self._cur].target
end

function combat:next_round()
   self._cur = 1
   self._round = self._round + 1
   -- Redetermine initiative again
   self:_determine_initiative()
end

function combat:next()
   self._cur = self._cur + 1

   if self._cur > #self._order then
      self:next_round()
   end
end

function combat:_find(tbl, target)
   t = nil
   if type(target) == 'string' then
      t = util.find_name(tbl, target)
      if t == nil then
         error('Could not find: ' .. target)
      end
   elseif type(target) == 'number' then
      if target > #tbl then
         error('Index out of bounds')
      end
      t = tbl[target]
   elseif type(target) == 'table' then
      if not util.contains(tbl, target) then
         error('Target is not part of this battle')
      end
      t = target
   end

   return t
end

function combat:attacks(target, gun, range)
   local c = self:current()
   local t = self:_find(self._participants, target)
   local g = self:_find(c:equipment(), gun)

   local tk = task:ranged_attack(c, t, g, range)
   local ok, mod = c:perform(self._r, tk)

   self:raise('on_attack', c, t, g, ok, tk, mod)

   if ok then
      local dmg = g:roll_damage(self._r)
      local dead = t:is_dead()

      dmg, zone = t:damage(dmg, g)
      self:raise('on_damage', c, t, g, dmg, zone)

      -- is_dead and not dead: UNDEAD
      if t:is_dead() and not dead then
         self:raise('on_death', t)
      end
   end
end

return combat
