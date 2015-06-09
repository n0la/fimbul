--- @module fimbul.v35.weapon

local base = _G
local util = require('fimbul.util')
local logger = require('fimbul.logger')
local item = require('fimbul.v35.item')
local material = require('fimbul.v35.material')

local rules = require('fimbul.v35.rules')

local weapon = item:new()

function weapon:new(y)
   local neu = item:new(y)

   setmetatable(neu, self)
   self.__index = self

   self.modifier = 0
   self.masterwork = false
   self.abilities = {}
   -- Spawn a mysterious default material
   self.material = material:spawn(nil, {name = 'default'})

   return neu
end

function weapon:is_artefact()
   return self.name ~= self.type
end

function weapon:is_ranged()
   return neu.ranged or false
end

function weapon:is_simple()
   return neu.category == 'simple'
end

function weapon:is_martial()
   return neu.category == 'martial'
end

function weapon:is_exotic()
   return neu.category == 'exotic'
end

function weapon:base_damage(size)
   local s = size or self:size()
   return self._damage[s]
end

function weapon:damage(size)
   local b = self:base_damage(size)
   if self.modifier > 0 then
      b = b .. '+' .. self.modifier
   end
   return b
end

function weapon:is_masterwork()
   if self.modifier > 0 then
      -- If it has a modifier it is automatically considered
      -- masterwork.
      return true
   elseif self.material.masterwork then
      -- If the material requires masterwork, then so be it.
      return true
   else
      -- Was it specified to be masterwork?
      return self.masterwork
   end
end

function weapon:_parse_attributes(r, str)
   local tbl = util.split(str)
   local hadmaterial = false

   for i = 1, #tbl do
      local w = tbl[i]
      local s = string.lower(w)

      -- Check this or this + 1 for material
      if tbl[i+1] and not hadmaterial then
         local mat = r:find("material", (w .. ' ' .. (tbl[i+1] or '')))

         if #mat > 0 then
            self.material = r:spawn(mat[1])
            hadmaterial = true
         end
      end

      if not hadmaterial then
         local mat = r:find("material", w)
         if #mat > 0 then
            self.material = r:spawn(mat[1])
            hadmaterial = true
         end
      end

      -- Check for a modifier
      local mod = string.match(s, "[+](%d+)")
      if mod then
         local m = base.tonumber(mod)
         if not m or m > 10 then
            logger.error("Modifiers above +10 are not valid in d20srd.")
            return false
         end
         self.modifier = m
      end

      -- Check for size descriptor
      if util.contains(item.SIZES, s) then
         self._size = s
      end

      -- Check for material descriptor
      -- TODO

      -- Check for special magical attributes
      -- TODO

   end

   return true
end

function weapon:spawn(r, t)
   local neu = weapon:new()

   neu.name = t.name
   if t.type == nil then
      neu.type = t.name
   else
      neu.type = t.type
   end
   neu.category = t.category
   neu.class = t.class

   -- Damage
   neu.damagetypes = util.deepcopy(t.damage.types)
   neu._damage = util.deepcopy(t.damage)
   neu.threat = util.deepcopy(t.threat) or {20}
   neu.multiplier = t.multiplier or 2

   -- Cost & Weight
   neu.cost = t.cost or 0
   neu.weight = t.weight or 1

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

function weapon:price()
   local p = 0
   local enhancement = false

   -- Add base price
   p = p + (self.cost or 0)

   if self.material then
      -- Ask for base price from the material
      p = self.material:additional_cost(self.category, p)
   end

   -- Additional cost for masterwork, twice if double weapon
   if self:is_masterwork() then
      if self.double then
         p = p + (rules.weapons.mastework_price * 2)
      else
         p = p + rules.weapons.mastework_price
      end
   end

   -- Base price for modifier
   if self.modifier > 0 then
      p = p + rules.weapons.modifier_prices[self.modifier]
      enhancement = true
   end

   if enhancement then
      if self.material then
         p = self.material:additional_cost('enhancement', p)
      end
   end

   return p
end

function weapon:string(extended)
   local e = extended or false
   local str = ''

   if self:is_artefact() then
      str = self.name .. ' ['
   end

   if self.modifier > 0 then
      str = str .. '+' .. self.modifier .. ' '
   end

   if self:size() ~= item.MEDIUM or e then
      str = str .. util.capitalise(self:size()) .. ' '
   end

   if (self.material.name ~= "default" and self.material ~= "Iron") or e then
      str =  str .. self.material.name .. ' '
   end

   str = str .. self.type

   if e then
      str = str .. ' ' .. self:damage()
      str = str .. ' [' .. util.join(self.threat, ',') .. ']x' .. self.multiplier
      str = str .. ' (' .. self:price() .. ' GP)'
   end

   if self:is_artefact() then
      str = str .. ']'
   end

   return str
end

return weapon
