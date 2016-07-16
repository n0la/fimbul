---@module fimbul.eh.item

local item = {}

local util = require('fimbul.util')

function item:new(y)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu:set_attributes(y)

   return neu
end

function item:set_attributes(y)
   if y == nil then
      return
   end

   self._amount = 1
   self._weight = y.weight or 0
   self._cost = y.cost or 0
   self._maxamount = y.max_amount or 0
   self._aliases = util.deepcopy(y.aliases or {})
end

function item:aliases()
   return self._aliases
end

function item:amount(value)
   if value == nil then
      return self._amount
   else
      if value < 1 then
         error('Amount may not be less than zero.')
      end
      self._amount = value
   end
end

function item:weight()
   return self._weight * self:amount()
end

function item:unit_weight()
   return self._weight
end

function item:cost()
   return self._cost * self:amount()
end

function item:unit_cost()
   return self._cost
end

function item:max_amount()
   return self._maxamount
end

function item:_parse_attributes(r, t)
   for i = 1, #t do
      local w = t[i]
      local s = string.lower(w)

      -- Parse amount as-in 5.56x45 (30) being thirty bullets.
      cap = string.match(s, '^%(([%d]+)%)$')
      if cap ~= nil then
         cap = tonumber(cap)
         self:amount(cap)
      end
   end
end

return item
