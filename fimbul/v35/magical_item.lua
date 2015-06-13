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

-- The modifier that determines the price and the power of
-- the item.
--
function magical_item:magic_modifier()
   local m = self.modifier

   for _, w in base.ipairs(self.abilities) do
      if w.modifier ~= 0 then
         m = m + w.modifier
      end
   end

   return m
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

   local b = self.cost or 0
   pr:add(b, 'base')

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
      if self:magic_modifier() > 0 then
         p = price_table.modifier_prices[self:magic_modifier()]
         pr:add(p, 'modifier')
      end

      if self.modifier > 0 or #self.abilities > 0 then
         enhancement = true
      end
   end

   if enhancement and self.material then
      p = self.material:additional_cost('enhancement', self)
      if p ~= 0 then
         pr:add(p, 'material_enhancement')
      end
   end

   -- Check if any abilities require flat amount of money to be added
   for _, a in base.ipairs(self.abilities) do
      if a.price and a.price ~= 0 then
         pr:add(a.price, a.name)
      end
   end

   return pr:value(), pr
end

function magical_item:_check_ability(a)
   -- Check if the slot fits.
   if #a.slots > 0 and not util.contains(a.slots, self.slot) then
      error('Ability "' .. a.name .. '" is only supported on the ' ..
               'following slots: [' .. table.concat(a.slots, ',') ..
               '] but this item is on slot: ' .. self.slot .. '.')
   end
end

function magical_item:_parse_attributes(r, str)
   local tbl = util.split(str)
   local i = 1

   while i <= #tbl do
      local w = tbl[i]
      local s = string.lower(w)
      local mat = nil
      local a, am, ability
      local mod, m

      if s == 'of' then
         goto end_of_loop
      end

      -- Check this or this + 1 for material
      if tbl[i+1] then
         mat = r:find("material", (s .. ' ' .. (tbl[i+1] or '')))

         if #mat > 0 then
            self.material = r:spawn(mat[1])
            i = i + 1
            goto end_of_loop
         end
      end

      mat = r:find("material", s)
      if #mat > 0 then
         self.material = r:spawn(mat[1])
      end

      -- Check for abilities
      --
      if tbl[i+1] and tbl[i+2] then
         am = s .. ' ' .. tbl[i+1] .. ' ' .. tbl[i+2]
         a = r:find("ability", am)

         if #a > 0 then
            for i = 1, #a do
               ability = r:spawn(a[i])
               -- Check ability
               ok, err = pcall(self._check_ability, self, ability)
               if not ok and i == #a then
                  error(err)
               elseif ok then
                  table.insert(self.abilities, ability)
                  break
               end
            end
            i = i + 2
            goto end_of_loop
         end
      end

      if tbl[i+1] then
         am = s .. ' ' .. tbl[i+1]
         a = r:find("ability", am)

         if #a > 0 then
            for i = 1, #a do
               ability = r:spawn(a[i])
               -- Check ability
               ok, err = pcall(self._check_ability, self, ability)
               if not ok and i == #a then
                  error(err)
               elseif ok then
                  table.insert(self.abilities, ability)
                  break
               end
            end
            i = i + 1
            goto end_of_loop
         end
      end

      a = r:find("ability", s)
      if #a > 0 then
         for i = 1, #a do
            ability = r:spawn(a[i])
            -- Check ability
            ok, err = pcall(self._check_ability, self, ability)
            if not ok and i == #a then
               error(err)
            elseif ok then
               table.insert(self.abilities, ability)
               break
            end
         end
      end

      -- Check for a modifier
      mod = string.match(s, "[+](%d+)")
      if mod then
         m = base.tonumber(mod)
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

      -- End of loop - for continue
      ::end_of_loop::
      i = i + 1
   end

   if self.modifier > rules.MAX_MODIFIER then
      error('Ability modifier of item cannot exceed the maximum of '
               .. rules.MAX_MODIFIER)
   end

   -- Sanity checks
   if self:magic_modifier() > rules.MAX_MODIFIER then
      error('Cummulative modifier of item cannot exceed the maximum of '
               .. rules.MAX_MODIFIER)
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

   for _, a in base.pairs(self.abilities) do
      str = str .. a.name .. ' '
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

   if self:magic_modifier() > 0 then
      str = str .. ' [MOD: +' .. self:magic_modifier() .. ']'
   end

   str = str .. ' (' .. self:price() .. ' GP)'
   if self:weight() > 0 and e then
      str = str .. ' (' .. self:weight() .. ' lbs)'
   end

   return str
end

return magical_item
