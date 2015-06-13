---@module fimbul.v35.shield

local magical_item = require('fimbul.v35.magical_item')
local item = require('fimbul.v35.item')
local util = require('fimbul.util')

local base = _G

local shield = magical_item:new()

shield.LIGHT = 'light'
shield.HEAVY = 'heavy'
shield.TOWER = 'tower'
shield.NONE  = 'none'

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

function shield:_check_ability(a)
   -- Call super method
   magical_item._check_ability(self, a)

   if a.shield == nil then
      return
   end

   if a.shield.category then
      if not util.contains(a.shield.category, self.category) then
         error('The Ability "' .. a.name .. '" does not apply to ' ..
                  'shields of the category "' .. self.category .. '".');
      end
   end
end

function shield:price()
   local p, pr = magical_item.price(self)
   local base = self.cost or 0

   if self.material then
      -- Use real category not the one lessened by material.
      p, new = self.material:additional_cost('shield', self)
      if new then
         p = p - new
      end
      if p ~= 0 then
         pr:add(p, 'material')
      end
   end

   return pr:value(), pr
end

function shield:spawn(r, t)
   local neu = shield:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu.category = t.category or shield.NONE
   neu.basematerial = t.basematerial

   neu.ac = t.ac or 0
   -- -1 == Disabled
   neu.dex = t.dex or -1
   neu.acp = t.acp or 0
   neu.acf = t.acf or 0

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu._weight = t.weight or 1

   return neu
end

function shield:string(extended)
   local e = extended or false
   local fmt = magical_item._string(self, e)
   local str = ''

   return string.format(fmt, str)
end

return shield
