--- @module fimbul.v35.item

local item = {}

local base = _G
local util = require('fimbul.util')

item.TINY = 'tiny'
item.SMALL = 'small'
item.MEDIUM = 'medium'
item.LARGE = 'large'
item.HUGE = 'huge'
item.GIGANTIC = 'gigantic'

item.SIZES = { item.TINY, item.SMALL, item.MEDIUM,
               item.LARGE, item.HUGE, item.GIGANTIC }

function item:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   self._size = item.MEDIUM

   return neu
end

function item:size()
   local s = self._size or item.MEDIUM
   return s
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
