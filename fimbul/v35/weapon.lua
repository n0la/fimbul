--- @module fimbul.v35.weapon

local base = _G

local magical_item = require('fimbul.v35.magical_item')
local item = require('fimbul.v35.item')

local util = require('fimbul.util')
local logger = require('fimbul.logger')

local weapon = magical_item:new()

weapon.SIMPLE = 'simple'
weapon.MARTIAL = 'martial'
weapon.EXOTIC = 'exotic'

function weapon:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   self.slot = item.WEAPON

   return neu
end

function weapon:is_ranged()
   return neu.ranged or false
end

function weapon:is_simple()
   return self:category() == weapon.SIMPLE
end

function weapon:is_martial()
   return self:category() == weapon.MARTIAL
end

function weapon:is_exotic()
   return self:category() == weapon.EXOTIC
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
   local ret = false

   -- Call base class function to do basic resolving
   ret = magical_item._parse_attributes(self, r, str)

   return ret
end

function weapon:spawn(r, t)
   local neu = weapon:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu._category = t.category
   neu.class = t.class

   -- Damage
   neu.damagetypes = util.deepcopy(t.damage.types)
   neu._damage = util.deepcopy(t.damage)
   neu.threat = util.deepcopy(t.threat) or {20}
   neu.multiplier = t.multiplier or 2

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu._weight = t.weight or 0

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

function weapon:string(extended)
   local e = extended or false
   local fmt = magical_item._string(self, e)
   local str = ''

   if e then
      str = str .. self:damage()
      str = str .. ' [' .. util.join(self.threat, ',') .. ']x' ..
         self.multiplier
   end

   return string.format(fmt, str)
end

return weapon
