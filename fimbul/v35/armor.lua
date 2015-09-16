---@module fimbul.v35.armor

local magical_item = require('fimbul.v35.magical_item')
local item = require('fimbul.v35.item')
local util = require('fimbul.util')

local base = _G

local armor = magical_item:new()

armor.NONE = 'none'
armor.LIGHT = 'light'
armor.MEDIUM = 'medium'
armor.HEAVY = 'heavy'

function armor:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   self.slot = item.ARMOR

   return neu
end

function armor:_parse_attributes(r, str)
   local tbl = util.split(str)
   local ret = false

   -- Call base class function to do basic resolving
   ret = magical_item._parse_attributes(self, r, str)

   return ret
end

function armor:_check_ability(r, a)
   -- Call super method
   magical_item._check_ability(self, r, a)

   -- Nothing to do
   if not a.armor then
      return
   end

   if a.armor.categories then
      -- For all intents and purposes use self:category() as we allow
      -- mithral to make the weapon count as one lower.
      --
      if not util.contains(a.armor.categories, self:category()) then
         error('The ability "' .. a.name .. '" requires an armor of ' ..
                  'the categories: [' ..
                  table.concat(a.armor.categories, ', ') .. '] ' ..
                  'instead of: ' .. self:category() .. '.')
      end
   end
end

function armor:spawn(r, t)
   local neu = armor:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu._category = t.category or armor.NONE

   neu._ac = t.ac or 0
   neu.dex = t.dex or 0
   neu._acp = t.acp or 0
   neu._asf = t.asf or 0

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu._weight = t.weight or 1

   -- Speed
   neu.speed = t.speed or {}

   return neu
end

function armor:acp()
   local a = 0
   -- PHB 126
   if self._acp < 0 and self:is_masterwork() then
      a = self._acp + 1
   else
      a = self._acp
   end
   -- TODO: Find out if these stack.
   if self.material.acp_bonus then
      a = a + self.material.acp_bonus
   end

   return a
end

function armor:ac()
   local a = self._ac

   if self.modifier > 0 then
      a = a + self.modifier
   end

   return a
end

function armor:price()
   local p, pr = magical_item.price(self)
   local base = self.cost or 0

   if self.material then
      -- Use real category not the one lessened by material.
      p, new = self.material:additional_cost(self._category, self)
      if new then
         p = p - new
      end
      if p ~= 0 then
         pr:add(p, 'material')
      end
   end

   return pr:value(), pr
end

function armor:category()
   local c = self._category

   if self.material.category_bonus > 0 then
      if c == armor.HEAVY then
         c = armor.MEDIUM
      elseif c == armor.MEDIUM then
         c = armor.LIGHT
      end
   end

   return c
end

function armor:max_dex()
   local d = self.dex

   if d ~= -1 and self.material.dex_bonus then
      d = d + self.material.dex_bonus
   end

   return d
end

function armor:asf()
   local a = self._asf

   if self.material.asf_bonus then
      a = a + self.material.asf_bonus
   end

   if a < 0 then
      a = 0
   end

   return a
end

function armor:string(expanded)
   local e = expanded or false
   local fmt = magical_item._string(self, e)
   local str = ''

   if e then
      str = str .. ' [' .. util.capitalise(self:category()) .. ' Armor] '
      str = str .. '[AC: ' .. self:ac() .. ', '
      str = str .. 'DEX: ' .. self:max_dex() .. ', '
      str = str .. 'ACP: ' .. self:acp() .. ', '
      str = str .. 'ASF: ' .. self:asf() .. '%]'
   end

   return string.format(fmt, str)
end

return armor
