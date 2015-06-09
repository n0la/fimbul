--- @module fimbul.v35.weapon

local base = _G
local util = require('fimbul.util')
local item = require('fimbul.v35.item')

local weapon = item:new()

function weapon:new(y)
   local neu = item:new(y)

   setmetatable(neu, self)
   self.__index = self

   return neu
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

function weapon:damage(size)
   local s = size or 'medium'
   return neu.damage[size]
end

function weapon:_parse_attributes(r, str)
end

function weapon:spawn(r, t)
   local neu = weapon:new()

   neu.name = t.name
   neu.category = t.category
   neu.type = t.type

   -- Damage
   neu.damagetypes = util.deepcopy(t.damage.types)
   neu.damage = util.deepcopy(t.damage)
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

return weapon
