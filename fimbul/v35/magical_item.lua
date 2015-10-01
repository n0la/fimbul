--- @module fimbul.v35.item

local item = require('fimbul.v35.item')

local rules = require('fimbul.v35.rules')
local material = require('fimbul.v35.material')

local stacked_value = require('fimbul.stacked_value')
local util = require('fimbul.util')
local logger = require('fimbul.logger')

local magical_item = item:new()

local base = _G
local math = require('math')

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
-- artifact: YES
--
-- name: Greataxe
-- type: Greataxe
-- artifact: NO
--
function magical_item:is_artifact()
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
   -- Some items don't have masterwork.
   if self.allow_masterwork ~= nil and self.allow_masterwork == false then
      return false
   end

   if self.modifier > 0 then
      -- If it has a modifier it is automatically considered
      -- masterwork.
      return true
   elseif #self.abilities > 0 then
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
   end

   local addcost = self.material:additional_cost('enhancement', self)

   if self.modifier > 0 and addcost ~= 0 then
      pr:add(addcost, 'material_enhancement')
   end

   for _, ab in base.ipairs(self.abilities) do
      if ab.material ~= nil and ab.material.enhancement ~= nil then
         if ab.material.enhancement ~= 0 then
            pr:add(ab.material.enhancement, 'material_enhancement')
         end
      elseif addcost ~= nil and addcost ~= 0 then
         pr:add(addcost, 'material_enhancement')
      end

      -- Check if any abilities require flat amount of money to be added
      if ab:price() ~= 0 then
         pr:add(ab:price(), ab.name)
      end
   end

   return pr:value(), pr
end

function magical_item:_check_ability(r, a)
   -- Check if the slot fits.
   if #a.slots > 0 and not util.contains(a.slots, self.slot) then
      error('Ability "' .. a.name .. '" is only supported on the ' ..
               'following slots: [' .. table.concat(a.slots, ', ') ..
               '] but this item is on slot: ' .. self.slot .. '.')
   end

   -- Check requirements
   if a.requires then
      -- All of these must be present, so add them to the
      -- ability list. But mark them for later, so we don't have
      -- to print them in the :string() method.
      --
      if a.requires.allof then
         for _, ab in base.ipairs(a.requires.allof) do
            local temp = r:find("ability", ab)

            if not temp or #temp == 0 then
               error('Ability "' .. a.name .. '" depends on an ' ..
                        'ability named "' .. ab '" but no such ' ..
                        'ability could be found.')
            end

            local abil = r:spawn(temp[1])
            -- Check if we can even have it
            --
            self:_check_ability(r, abil)
            -- Mark for later
            --
            abil.wasdependency = true
            table.insert(self.abilities, abil)
         end
      end

      -- One of these must be present
      --
      if a.requires.oneof then
         local found = false
         for _, rm in base.ipairs(a.requires.oneof) do
            if util.containsbyname(self.abilities, rm) then
               found = true
            end
         end

         if not found then
            error('Ability "' .. a.name .. '" requires one of the ' ..
                     'following abilities to be present: [' ..
                     table.concat(a.requires.oneof, ', ') .. ']')
         end
      end
   end
end

function magical_item:lookup_ability(r, am, tbl, pos, i)
   local extra = 0

   if self:_has_function(r, 'ability') then
      return self:_call_function(r, 'ability', am)
   end

   a = r:find("ability", am)
   if #a > 0 then
      for i = 1, #a do
         ability = r:spawn(a[i])
         -- Make some checks if we can even apply this item.
         ok, err = pcall(self._check_ability, self, r, ability)
         if not ok and i == #a then
            return false
         else
            ok, cons = ability:parse(util.splice(tbl, pos+1))
            if ok then
               extra = extra + cons
            end

            table.insert(self.abilities, ability)
            return true, extra
         end
      end
   end

   return false
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

      if s == 'masterwork' then
         self.masterwork = true
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
         goto end_of_loop
      end

      bind = function(str, tbl, i, pos)
         return magical_item.lookup_ability(self, r, str, tbl, i, pos)
      end

      ok, count = util.lookahead(tbl, i, bind)
      if ok then
         -- We add +1 after going to 'end_of_loop'
         i = i + (count - 1)
         goto end_of_loop
      end

      -- Check for a modifier
      ok, mod = pcall(util.parse_modifier, s)
      if ok then
         m = base.tonumber(mod)
         if not m or m > 10 then
            logger.error("Modifiers above +10 are not valid in d20srd.")
            return false
         end
         self.modifier = m
         goto end_of_loop
      end

      -- Check for size descriptor
      if util.contains(item.SIZES, s) then
         self._size = s
         goto end_of_loop
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

function magical_item:_has_function(r, f)
   if self.lua == nil or self.lua[f] == nil then
      return false
   end

   if not r:has_function(self.lua[f]) then
      error('Data repository has no such function: ' .. f)
   end

   return true
end

function magical_item:_call_function(r, f, ...)
   if self.lua[f] ~= nil then
      return r:call_function(self.lua[f], self, ...)
   end
end

function magical_item:weight(size)
   local s = size or item.MEDIUM
   local w = self._weight or 0

   if self.material.weight then
      w = w * self.material.weight
   end

   return w
end

function magical_item:craft_price()
   local p, pr = self:price()

   pr:remove_all_type("base")
   pr:remove_all_type("masterwork")
   pr:remove_all_type("material")

   return pr:value(), pr
end

function magical_item:craft_xp()
   local p, pr = self:craft_price()

   p = pr:value() * rules.crafting.XP_COST

   return p, pr
end

function magical_item:craft_days()
   local p, pr = self:craft_price()
   return math.ceil(p / rules.crafting.GP_PER_DAY)
end

function magical_item:craft_materials()
   local p, pr = self:craft_price()
   return (p * rules.crafting.MATERIAL_COST)
end

-- This function will build a string for a name
-- and leave a %s inside this string were base classes
-- can add their own information.
--
function magical_item:_string(extended)
   local e = extended or false
   local str = ''

   if self:is_artifact() then
      str = self.name .. ' ['
   end

   if self.modifier > 0 then
      str = str .. '+' .. self.modifier .. ' '
   elseif self:magic_modifier() == 0 and self:is_masterwork() then
      str = str .. 'Masterwork '
   end

   for _, a in base.pairs(self.abilities) do
      if not a.wasdependency or e then
         str = str .. a:string() .. ' '
      end
   end

   if self:size() ~= item.MEDIUM or e then
      str = str .. util.capitalise(self:size()) .. ' '
   end

   if (self.material.name ~= "default" and self.material ~= "Iron") then
      str =  str .. self.material.name .. ' '
   end

   str = str .. self.type .. '%s'

   if self:is_artifact() then
      str = str .. ']'
   end

   if self:magic_modifier() > 0 then
      str = str .. ' [MOD: +' .. self:magic_modifier() .. ']'
   end

   str = str .. ' (' .. self:price() .. ' GP)'
   if self:weight() > 0 and e then
      str = str .. ' (' .. self:weight() .. ' lbs)'
   end

   if e and self:craft_price() ~= 0 then
      str = str .. "\n"
      str = str .. 'Crafting: [Price: ' .. self:craft_price() .. ', '
      str = str .. 'XP: ' .. self:craft_xp() .. ', '
      str = str .. 'Materials: ' .. self:craft_materials() .. ', '
      str = str .. 'Days: ' .. self:craft_days() .. ']'
   end

   return str
end

return magical_item
