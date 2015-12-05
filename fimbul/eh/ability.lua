---@module fimbul.eh.ability

local ability = {}

local base = _G
local string = require('string')

local rules = require('fimbul.eh.rules')

function ability:new(name)
   local neu = {}

   neu.name = name
   neu._rank = rules.ability.AVERAGE

   setmetatable(neu, self)
   self.__index = self

   return neu
end

-- Name of this ability
--
function ability:name()
   return self.name
end

-- Short name: first three letters capitalised
--
function ability:short_name()
   return string.upper(self.name:sub(0, 3))
end

-- Rank
--
function ability:rank(value)
   if value == nil then
      return self._rank
   else
      -- TODO: Checks:
      self._rank = value
   end
end

-- Cost for this attribute
--
function ability:cost()
   local r = self:rank()
   if r >= rules.ability.AVERAGE then
      return rules.calculate_rank_cost(5, r)
   else
      -- Below 4 is minus cost.
      return rules.calculate_rank_cost(r, 5) * -1
   end
end

-- Ability modifier
--
function ability:modifier()
   return self:rank() - rules.ability.AVERAGE
end

return ability
