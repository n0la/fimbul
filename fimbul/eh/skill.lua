---@module fimbul.eh.skill

local base = _G

local skill = {}

local rules = require('fimbul.eh.rules')

function skill:new(y)
   local neu = {}

   neu._rank = 0

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function skill:spawn(r, t)
   local neu = skill:new()

   if not t.name then
      error('Skill must have a name')
   end

   if not t.uses or #t.uses == 0 then
      error('Skill must specify abilities')
   end

   neu._name = t.name or ''
   -- Is it special?
   neu._special = t.special or false
   -- Abilities it uses
   neu._uses = t.uses or {}

   return neu
end

function skill:uses()
   return self._uses
end

function skill:name()
   return self._name
end

-- Is the skill special?
--
function skill:is_special()
   return self.special or false
end

-- Return the current rank
--
function skill:rank(neu)
   if neu == nil then
      return self._rank or 0
   else
      if neu < rules.skills.LOWEST_RANK then
         error('Skill ranks below ' .. rules.skills.LOWEST_RANK ..
                  ' are not allowed: ' .. neu)
      end

      if neu > rules.skills.HIGHEST_RANK then
         error('Skill ranks above ' .. rules.skills.HIGHEST_RANK ..
                  ' are not allowed: ' .. neu)
      end

      self._rank = neu
      self._activated = (neu > 0)
   end
end

-- The abilities involved
--
function skill:abilities()
   return self.uses or {}
end

-- Is the skill activated?
--
function skill:activated()
   return self._activated or false
end

-- Calculate the cost of the skill including activation and ranks.
--
function skill:cost()
   local cost = 0

   if self:activated() then
      if self:is_special() then
         cost = cost + rules.skills.SPECIAL_ACTIVATION_COST
      else
         cost = cost + rules.skills.ACTIVATION_COST
      end

      -- Add any rank
      cost = cost + rules.calculate_skill_cost(0, self:rank())
   end

   return cost
end

return skill
