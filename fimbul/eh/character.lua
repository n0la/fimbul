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
         neu[name] = ability:new(at)
      end
   end

   pretty = require('pl.pretty')
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

   return neu
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
