--- @module fimbul.v35.item

local stacked_value = require('fimbul.stacked_value')

local item = require('fimbul.v35.item')
local rules = require('fimbul.v35.rules')
local material = require('fimbul.v35.material')

local magical_item = item:new()

local base = _G

local util = require('fimbul.util')
local logger = require('fimbul.logger')

function magical_item:new(y)
   local neu = item:new(y)

   setmetatable(neu, self)
   self.__index = self

   self.name = ''
   self.type = ''

   self.cost = 0
   self.modifier = 0
   self.masterwork = false
   -- Any magical abilities
   self.abilities = {}
   -- Spawn a mysterious default material
   self.material = material:spawn(nil, {name = 'default'})

   return neu
end

-- It is considered an artifact if the name does not
-- match the type. Example:
--
-- name: Holy Avenger
-- type: Longsword
-- artefact: YES
--
-- name: Greataxe
-- type: Greataxe
-- artefact: NO
--
function magical_item:is_artefact()
   return self.name ~= self.type
end

function magical_item:spawn(r, t)
   local neu = self:new()

   if t == nil then
      logger.critical('No template specified')
   end

   neu.template = t

   return neu
end

function magical_item:is_masterwork()
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

function magical_item:category()
   return self._category
end

function magical_item:price()
   local p = 0
   local enhancement = false

   local pr = stacked_value:new({stack = true})

   local base = self.cost or 0
   pr:add(base, 'base')

   if self.material then
      p, new = self.material:additional_cost(self:category(), base)
      if new then
         p = p - base
      end
      if p ~= 0 then
         pr:add(p, 'material')
      end
   end

   local price_table = nil

   if self.slot == item.WEAPON then
      price_table = rules.weapons
   elseif self.slot == item.ARMOR then
      price_table = rules.armors
   elseif self.slot == item.SHIELD then
      price_table = rules.shields
   end

   if price_table then
      -- Additional cost for masterwork, twice if double weapon
      if self:is_masterwork() then
         if self.double then
            p = (price_table.masterwork_price * 2)
         else
            p = price_table.masterwork_price
         end
         pr:add(p, 'masterwork')
      end

      -- Base price for modifier
      if self.modifier > 0 then
         p = price_table.modifier_prices[self.modifier]
         pr:add(p, 'modifier')
         enhancement = true
      end
   end

   if enhancement and self.material then
      p = self.material:additional_cost('enhancement', 0)
      if p ~= 0 then
         pr:add(p, 'material_enhancement')
      end
   end

   return pr:value(), pr
end


function magical_item:_parse_attributes(r, str)
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

function magical_item:weight(size)
   local s = size or item.MEDIUM
   local w = self._weight

   if self.material.weight then
      w = w * self.material.weight
   end

   return w
end

-- This function will build a string for a name
-- and leave a %s inside this string were base classes
-- can add their own information.
--
function magical_item:_string(extended)
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

   if (self.material.name ~= "default" and self.material ~= "Iron") then
      str =  str .. self.material.name .. ' '
   end

   str = str .. self.type .. ' %s'

   if self:is_artefact() then
      str = str .. ']'
   end

   str = str .. ' (' .. self:price() .. ' GP)'
   if self:weight() > 0 and e then
      str = str .. ' (' .. self:weight() .. ' lbs)'
   end

   return str
end

return magical_item
