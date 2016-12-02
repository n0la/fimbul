--- @module fimbul.v35.weapon

local base = _G

local table = require('table')
local magical_item = require('fimbul.v35.magical_item')
local item = require('fimbul.v35.item')

local util = require('fimbul.util')
local logger = require('fimbul.logger')

local weapon = magical_item:new()

weapon.SIMPLE = 'simple'
weapon.MARTIAL = 'martial'
weapon.EXOTIC = 'exotic'

function weapon:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   neu.slot = item.WEAPON

   return neu
end

function weapon:is_ranged()
   return self.ranged or false
end

function weapon:is_double()
   return self.double or false
end

function weapon:is_simple()
   return self:category() == weapon.SIMPLE
end

function weapon:is_martial()
   return self:category() == weapon.MARTIAL
end

function weapon:is_exotic()
   return self:category() == weapon.EXOTIC
end

function weapon:base_damage(size)
   local s = size or self:size()
   return self._damage[s]
end

function weapon:price()
   local p, pr = magical_item.price(self)
   local base = self.cost or 0

   if self.material then
      if self:is_double() then
         p, new = self.material:additional_cost('double', self)
      else
         p, new = self.material:additional_cost(self.class, self)
      end
      if new then
         p = p - base
      end
      if p ~= 0 then
         pr:add(p, 'material')
      end
   end

   return pr:value(), pr
end

function weapon:damage(size)
   local b = self:base_damage(size)
   if self.modifier > 0 then
      b = b .. '+' .. self.modifier
   end
   return b
end

function weapon:_check_ability(r, a)
   local found = false

   -- Call super method
   magical_item._check_ability(self, r, a)

   -- Nothing to check
   if a.weapon == nil then
      return
   end

   -- Check if we have 'ranged' only ability
   if a.weapon.ranged ~= nil then
      if a.weapon.ranged == false and self:is_ranged() then
         error('The ability "' .. a.name .. '" does not apply to ' ..
                  'ranged weapons.')
      elseif a.weapon.ranged == true and not self:is_ranged() then
         error('The ability "' .. a.name .. '" only applies to ' ..
                  'ranged weapons.')
      end
   end

   -- Types
   if a.weapon.categories then
      if not util.contains(a.weapon.categories, self._category) then
         error('The ability "' .. a.name .. '" only works on the ' ..
                  'following weapon categories: [' ..
                  table.concat(a.weapon.categories, ', ') .. '].')
      end
   end

   -- Types
   if a.weapon.types then
      if not util.contains(a.weapon.types, self.type) then
         error('The ability "' .. a.name .. '" only works on the ' ..
                  'following weapons: [' ..
                  table.concat(a.weapon.types, ', ') .. '].')
      end
   end

   -- Classes
   if a.weapon.classes then
      if not util.contains(a.weapon.classes, self.class) then
         error('The ability "' .. a.name .. '" only works on the ' ..
                  'following weapon classes : [' ..
                  table.concat(a.weapon.classes, ', ') .. '].')
      end
   end

   -- Damage types
   if a.weapon.damagetypes then
      found = false
      for _, dt in base.ipairs(self.damagetypes) do
         if util.contains(a.weapon.damagetypes, dt) then
            found = true
            break
         end
      end

      if not found then
         error('The ability "' .. a.name .. '" only applies to ' ..
                  'weapons dealing the following damage types: [' ..
                  table.concat(a.weapon.damagetypes, ',') ..
                  '] but this weapon only deals the following damage ' ..
                  'types: [' .. table.concat(self.damagetypes, ',') ..
                  '].')
      end
   end

end

function weapon:_parse_attributes(r, str)
   local tbl = util.split(str)
   local ret = false

   -- Call base class function to do basic resolving
   ret = magical_item._parse_attributes(self, r, str)

   return ret
end

function weapon:spawn(r, t)
   local neu = weapon:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu._category = t.category
   neu.class = t.class

   -- Damage
   neu.damagetypes = util.deepcopy(t.damage.types)
   neu._damage = util.deepcopy(t.damage)
   neu.threat = util.deepcopy(t.threat) or {20}
   neu.multiplier = t.multiplier or 2

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu._weight = t.weight or 0

   -- Misc.
   neu.reach = t.reach or 5
   neu.double = t.double or false

   -- Ranged stuff
   neu.ranged = t.ranged or false
   neu.increment = t.increment or 10

   -- Amount or how many
   neu.amount = 0

   return neu
end

function weapon:string(extended)
   local e = extended or false
   local fmt = magical_item._string(self, e)
   local str = ''

   if e then
      str = str .. ' ' .. self:damage()
      str = str .. ' [' .. table.concat(self.threat, ',') .. ']x' ..
         self.multiplier
   end

   return string.format(fmt, str)
end

return weapon
