---@module fimbul.eh.background

local base = _G

local background = {}

local rules = require('fimbul.eh.rules')
local ability = require('fimbul.eh.ability')
local util = require('fimbul.util')

function background:new(y)
   local neu = {}

   neu._name = ''
   neu._cost = 0
   neu._abilities = {}
   neu._skills = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function background:spawn(r, t)
   local neu = background:new()

   if not t.name then
      error('Background must have a name')
   end

   neu._name = t.name or ''
   neu._cost = t.cost or 0

   for ab, ra in base.pairs(t.abilities or {}) do
      -- Let ability do the name checking for us.
      a = ability:new(ab)
      neu._abilities[util.capitalise(a:name())] = ra
   end

   for sk, ra in base.pairs(t.skills or {}) do
      local skt = r:find(r.eh.skills, sk)

      if #skt == 0 then
         error('No such skill, but it is defined in the background: ' ..
                  neu._name .. ': ' .. sk)
      end

      skill = r:spawn(skt[1])
      -- Set rank
      skill:rank(ra)

      table.insert(neu._skills, skill)
   end

   neu._template = t

   return neu
end

function background:name()
   return self._name
end

function background:cost()
   return self._cost
end

function background:skills()
   return self._skills
end

function background:abilities()
   return self._abilities
end

function background:actual_cost(r, t)
   local cost = 0

   for _, s in base.ipairs(self._skills) do
      cost = cost + s:cost()
   end

   for _, a in base.pairs(self._abilities) do
      cost = cost + (a * rules.abilities.BACKGROUND_FLAT_COST)
   end

   return cost
end

return background
