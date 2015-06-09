--- @module fimbul.v35.material

local base = _G

local string = require('string')
local util = require('fimbul.util')

local material = {}

function material:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function material:spawn(r, t)
   local neu = material:new()

   neu.name = t.name

   neu.hardness = t.hardness or 10
   neu.hp = t.hp or 10

   -- Must be masterwork?
   neu.masterwork = t.masterwork or false

   -- DR
   neu.dr = util.shallowcopy(t.dr or {})

   -- Additional cost
   neu.cost = util.shallowcopy(t.cost or {})
   -- Additional weight
   neu.weight = t.weight or 1

   neu.dex_bonus = t.dex_bonus or 0
   neu.acf_bonus = t.acf_bonus or 0
   neu.acp_bonus = t.acp_bonus or 0
   neu.category_bonus = t.category_bonus or 0

   -- Additional damage and/or damage loss
   neu.damage = t.damage or 0

   return neu
end

function material:additional_cost(t, price)
   local tp = string.lower(t)

   -- No additional cost associated
   if not self.cost then
      return price
   end

   if self.cost[t] then
      -- Additional cost depending on type
      return price + self.cost[tp]
   elseif self.cost['multiplier'] then
      -- New price is a multiple of base price
      return price * tonumber(self.cost['multiplier'])
   elseif t == 'enhancement' and self.cost['enhancement'] then
      -- Additional price for enhancements
      return price + tonumber(self.cost['enhancement'])
   end

   -- No additional cost associated
   return price
end

return material
