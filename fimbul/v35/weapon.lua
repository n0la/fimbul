--- @module fimbul.v35.weapon

local base = _G
local util = require('fimbul.util')
local logger = require('fimbul.logger')
local item = require('fimbul.v35.item')

local rules = require('fimbul.v35.rules')

local weapon = item:new()

function weapon:new(y)
   local neu = item:new(y)

   setmetatable(neu, self)
   self.__index = self

   self.modifier = 0
   self.masterwork = false
   self.abilities = {}

   return neu
end

function weapon:is_artefact()
   return self.name ~= self.type
end

function weapon:is_ranged()
   return neu.ranged or false
end

function weapon:is_simple()
   return neu.category == 'simple'
end

function weapon:is_martial()
   return neu.category == 'martial'
end

function weapon:is_exotic()
   return neu.category == 'exotic'
end

function weapon:base_damage(size)
   local s = size or self:size()
   return self._damage[s]
end

function weapon:damage(size)
   local b = self:base_damage(size)
   if self.modifier > 0 then
      b = b .. '+' .. self.modifier
   end
   return b
end

function weapon:_parse_attributes(r, str)
   local tbl = util.split(str)

   for _, w in base.pairs(tbl) do
      local s = string.lower(w)

      -- Check for a modifier
      mod = string.match(s, "[+](%d+)")
      if mod then
         local m = base.tonumber(mod)
         if not m or m > 10 then
            logger.error("Modifiers above +10 are not valid in d20srd.")
            return false
         end
         self.modifier = m
      end

      -- Check for size descriptor
      if util.contains(item.SIZES, s) then
         self._size = s
      end

      -- Check for material descriptor
      -- TODO

      -- Check for special magical attributes
      -- TODO

   end

   return true
end

function weapon:spawn(r, t)
   local neu = weapon:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu.category = t.category
   neu.class = t.class

   -- Damage
   neu.damagetypes = util.deepcopy(t.damage.types)
   neu._damage = util.deepcopy(t.damage)
   neu.threat = util.deepcopy(t.threat) or {20}
   neu.multiplier = t.multiplier or 2

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu.weight = t.weight or 1

   -- Misc.
   neu.reach = t.reach or 5
   neu.double = t.double or false

   -- Ranged stuff
   neu.ranged = t.ranged or false
   neu.increment = t.increment or 10

   -- Amount or how many
   neu.amount = 0

   return neu
end

function weapon:price()
   local p = 0

   -- Add base price
   p = p + (self.cost or 0)

   -- Base price for modifier
   if self.modifier > 0 then
      p = p + rules.modifier_prices[self.modifier]
   end

   -- TODO add material

   return p
end

function weapon:string(extended)
   local e = extended or false
   local str = ''

   if self:is_artefact() then
      str = self.name .. ' ['
   end

   if self.modifier > 0 then
      str = str .. '+' .. self.modifier .. ' '
   end

   if self:size() ~= item.MEDIUM or e then
      str = str .. util.capitalise(self:size()) .. ' '
   end

   str = str .. self.type

   if e then
      str = str .. ' ' .. self:damage()
      str = str .. ' [' .. util.join(self.threat, ',') .. ']x' .. self.multiplier
      str = str .. ' (' .. self:price() .. ' GP)'
   end

   if self:is_artefact() then
      str = str .. ']'
   end

   return str
end

return weapon
