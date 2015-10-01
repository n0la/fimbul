--- @module fimbul.v35.wondrous_item

local magical_item = require("fimbul.v35.magical_item")
local string = require("string")

local wondrous_item = magical_item:new()

function wondrous_item:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   -- Wondrous items are seldomly masterwork
   neu.allow_masterwork = false

   return neu
end

function wondrous_item:spawn(r, t)
   local neu = wondrous_item:new()

   neu.name = t.name
   neu.slot = t.slot
   neu.type = t.name

   neu.cost = t.cost or 0
   neu._weight = t.weight or 0

   neu.allow_masterwork = t.allowmasterwork or false

   return neu
end

function wondrous_item:string(extended)
   local e = extended or false
   local fmt = magical_item._string(self, e)
   local str = ''

   if e then
      str = str .. ' [' .. self.slot .. ']'
   end

   return string.format(fmt, str)
end

return wondrous_item
