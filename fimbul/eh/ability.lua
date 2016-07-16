---@module fimbul.eh.ability

local ability = {}

local base = _G

local rules = require('fimbul.eh.rules')

function ability:new(name, rank)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu:rank(rank or rules.abilities.AVERAGE)
   if name and rules.valid_ability(name) then
      neu._name = name
   end

   return neu
end

-- Name of this ability
--
function ability:name()
   return self._name
end

-- Short name: first three letters capitalised
--
function ability:short_name()
   if not self:name() then
      return nil
   end
   return rules.short_ability_name(self:name())
end

-- Rank
--
function ability:rank(value)
   if value == nil then
      return self._rank
   else
      if value < rules.abilities.LOWEST_RANK then
         error('Ability rank below ' .. rules.abilities.LOWEST_RANK ..
                  ' are not allowed: ' .. value)
      end
      if value > rules.abilities.HIGHEST_RANK then
         error('Ability rank above ' .. rules.abilities.HIGHEST_RANK ..
                  ' are not allowed: ' .. value)
      end
      -- TODO: Checks:
      self._rank = value
   end
end

-- Cost for this attribute
--
function ability:cost()
   local r = self:rank()
   if r >= rules.abilities.AVERAGE then
      return rules.calculate_rank_cost(5, r)
   else
      -- Below 4 is minus cost.
      return rules.calculate_rank_cost(r, 5) * -1
   end
end

-- Ability modifier
--
function ability:modifier()
   return rules.calculate_mod(self:rank())
end

return ability
