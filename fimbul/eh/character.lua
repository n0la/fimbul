---@module fimbul.eh.character

local character = {}

local base = _G

local ability = require('fimbul.eh.ability')
local rules = require('fimbul.eh.rules')

function character:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   -- Initialise abilities
   neu.abilities = {}
   for _, a in base.pairs(rules.abilities.names) do
      local lower = string.lower(a)
      neu[lower] = ability:new(a)
      table.insert(neu.abilities, neu[lower])
   end

   neu.skills = {}
   neu.equipment = {}
   neu._credits = 0
   neu._weight = 0
   neu.name = ''

   return neu
end

function character:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Character must have a name!')
   end

   neu.name = t.name
   neu.template = t

   neu._weight = t.weight or 0
   neu._height = t.height or 0
   neu._credits = t.credits or 0

   for _, a in base.pairs(rules.abilities.names) do
      local at
      local name = string.lower(a)
      local ans = rules.short_ability_name(a)

      -- TODO: Perfect candidate for a function in util
      if t[a] then
         -- Normal name?
         at = t[a]
      elseif t[name] then
         -- Lower case name?
         at = t[name]
      elseif t[ans] then
         -- Short ability name?
         at = t[ans]
      elseif t[string.lower(ans)] then
         -- Lowercase short ability name?
         at = t[string.lower(ans)]
      end

      if at then
         neu[name] = ability:new(name, at)
      end
   end

   if t.skills then
      for skill, rank in base.pairs(t.skills) do
         local s = r:find(r.eh.skills, skill)
         if #s == 0 then
            error('No such skill: ' .. skill)
         end

         local sk = r:spawn(s[1])
         sk:rank(rank)
         -- Insert skill to list
         table.insert(neu.skills, sk)
      end
   end

   if t.equipment then
      for _, item in base.pairs(t.equipment) do
         local it = r:parse_item(item)

         if it == nil then
            error('No such item: ' .. item)
         end

         table.insert(neu.equipment, it)
      end
   end

   return neu
end

function character:weight()
   return self._weight
end

function character:height()
   return self._height
end

function character:max_hp()
   return rules.character.BASE_HP
      + self.strength:rank()
      + self.constitution:rank()
end

function character:max_carry_weight()
   return rules.character.BASE_CARRY_WEIGHT
      + self.constitution:rank()
      + self.constitution:rank()
end

function character:equipment_weight()
   local w = 0

   for _, i in base.pairs(self.equipment) do
      w = w + i:weight()
   end

   return w
end

function character:equipment_cost()
   local c = 0

   for _, i in base.pairs(self.equipment) do
      c = c + i:cost()
   end

   return c
end

function character:total_weight()
   return self:weight() + self:equipment_weight()
end

function character:cost()
   local c = 0

   -- TODO: Performance
   for _, a in base.pairs(self.abilities) do
      c = c + a:cost()
   end

   for _, s in base.pairs(self.skills) do
      c =  c + s:cost()
   end

   return c
end

return character
