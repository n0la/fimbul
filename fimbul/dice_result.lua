--- @module fimbul.dice_result

local dr = {}

local print = print
local string = require("string")

local dice_result = {}

function dice_result:drop()
   self.counts = false
end

function dice_result:use()
   self.counts = true
end

function dice_result:evaluate()
   if self.counts then
      return self.value
   else
      return 0
   end
end

function dice_result:__tostring()
   if self.counts then
      return string.format("%d", self.value)
   else
      return string.format("(%d)", self.value)
   end
end

function dice_result.__gt(a, b)
   return a.value > b.value
end

function dice_result.__lt(a, b)
   return a.value < b.value
end

function dice_result.__le(a, b)
   return a.value <= b.value
end

function dice_result.__eq(a, b)
   return a.value == b.value
end

function dr.new(v, c)
   local s = {}

   dice_result.__index = dice_result
   setmetatable(s, dice_result)

   s.value = v or 0
   s.counts = c or true

   return s
end

return dr
