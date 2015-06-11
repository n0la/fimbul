---@module fimbul.v35.shield

local magical_item = require('fimbul.v35.magical_item')
local item = require('fimbul.v35.item')
local util = require('fimbul.util')

local base = _G

local shield = magical_item:new()

function shield:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   self.slot = item.SHIELD

   return neu
end

function shield:_parse_attributes(r, str)
   local tbl = util.split(str)
   local ret = false

   -- Call base class function to do basic resolving
   ret = magical_item._parse_attributes(self, r, str)

   return ret
end

function shield:spawn(r, t)
   local neu = shield:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu.category = t.category
   neu.basematerial = t.material

   neu.ac = t.ac or 0
   -- -1 == Disabled
   neu.dex = t.dex or -1
   neu.acp = t.acp or 0
   neu.acf = t.acf or 0

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu.weight = t.weight or 1

   return neu
end

return shield
