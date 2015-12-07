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

   neu.name = t.name or ''
   -- Is it special?
   neu.special = t.special or false
   -- Abilities it uses
   neu.uses = t.uses or {}

   -- Is it a speciality?
   neu.specialityof = t.specialiaty_of or nil
   -- TODO: Check speciality parent skill for existence

   return neu
end

-- Is the skill special?
--
function skill:is_special()
   return self.special or false
end

-- Is it a special variant of another skill?
--
function skill:is_speciality()
   return self.specialityof ~= nil
end

function skill:speciality_of(neu)
   if neu ~= nil then
      self.specialityof = neu
   else
      return self.specialityof
   end
end

-- Name of the parent skill
--
function skill:parent_skill()
   return self.specialityof
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
      cost = cost + rules.calculate_rank_cost(0, self:rank())
   end

   return cost
end

return skill
