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

function shield:_check_ability(r, a)
   -- Call super method
   magical_item._check_ability(self, r, a)

   if a.shield == nil then
      return
   end

   if a.shield.categories then
      if not util.contains(a.shield.categories, self.category) then
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

   neu._ac = t.ac or 0
   -- -1 == Disabled
   neu.dex = t.dex or -1
   neu._acp = t.acp or 0
   neu._asf = t.acf or 0

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu._weight = t.weight or 1

   return neu
end

function shield:acp()
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

function shield:ac()
   local a = self._ac

   if self.modifier > 0 then
      a = a + self.modifier
   end

   return a
end

function shield:max_dex()
   local d = self.dex

   if d ~= -1 and self.material.dex_bonus then
      d = d + self.material.dex_bonus
   end

   return d
end

function shield:asf()
   local a = self._asf

   if self.material.asf_bonus then
      a = a + self.material.asf_bonus
   end

   if a < 0 then
      a = 0
   end

   return a
end

function shield:string(extended)
   local e = extended or false
   local fmt = magical_item._string(self, e)
   local str = ''

   if e then
      str = str .. ' [AC: ' .. self:ac() .. ', '
      if self:max_dex() > -1 then
         str = str .. 'DEX: ' .. self:max_dex() .. ', '
      end
      str = str .. 'ACP: ' .. self:acp() .. ', '
      str = str .. 'ASF: ' .. self:asf() .. '%]'
   end

   return string.format(fmt, str)
end

return shield
