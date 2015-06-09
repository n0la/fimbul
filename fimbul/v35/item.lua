--- @module fimbul.v35.item

local item = {}

local base = _G
local util = require('fimbul.util')

function item:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function item:spawn(r, t)
   local neu = self:new()

   if t == nil then
      error("No template specified to spawn from.")
   end

   neu.template = t

   return neu
end

function item:_parse_attributes(r, str)
   error('Base class of item did not override _parse_attributes')
end

return item
