local magical_item = require('fimbul.v35.magical_item')
local item = require('fimbul.v35.item')
local rules = require('fimbul.v35.rules')

local stacked_value = require('fimbul.stacked_value')

local util = require('fimbul.util')

local base = _G

local wand = magical_item:new()

function wand:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   neu.slot = item.WEAPON

   neu.itemprice = 0
   neu.craftprice = 0

   return neu
end

function wand:spawn(r, t)
   local neu = wand:new()

   neu.template = t

   neu.name = t.name or 'Wand'
   neu.charges = t.charges or 50
   neu.spell = util.deepcopy(t.spell) or nil
   neu.spelllevel = t.spelllevel or nil
   neu.casterlevel = t.casterlevel or nil

   return neu
end

function wand:_check_ability(r, a)
   error('Wands may not have special abilities')
end

function wand:_parse_casterlevel(str)
   local cl = 0

   -- Parses d20srd standard: (1st)
   cl = string.match(str, "%((%d+)%w+%)")
   if cl ~= nil then
      return true, tonumber(cl)
   end

   -- Parses also commonly used: [CL:1]
   cl = string.match(str, "%[CL:(%d+)%]")
   if cl ~= nil then
      return true, tonumber(cl)
   end

   return false
end

function wand:_parse_charges(str)
   local ch = 0

   ch = string.match(str, "%[(%d+)%]")
   if ch ~= nil then
      return true, tonumber(ch)
   end

   return false
end

function wand:_parse_spelllevel()
   local sl = 0

   sl = string.match(str, "%((%d+) level%)")
   if sl ~= nil then
      return true, tonumber(sl)
   end

   sl = string.match(str, "%[SL:(%d+)%]")
   if sl ~= nil then
      return true, tonumber(sl)
   end

   return false
end

function wand:_update_spelllevel()
   local lowest = 9999

   -- no spell or already a spell level?
   if not self.spell then
      return
   end

   if not self.spelllevel then
      for class, level in base.pairs(self.spell:levels()) do
         if lowest > level then
            lowest = level
         end
      end

      self.spelllevel = lowest
   end

   if not self.spelllevel then
      self.spelllevel = 0
   end

   if not self.casterlevel then
      if self.spelllevel == 0 then
         self.casterlevel = 0
      else
         -- TODO: Wrong, this assumes caster is wizard, druid or cleric
         self.casterlevel = self.spelllevel + (self.spelllevel - 1)
      end
   end

   if self.spelllevel > rules.wand.MAX_SPELL_LEVEL then
      error('You cannot make wands of spells of level 4 or higher')
   end
end

function wand:_parse_attributes(r, str)
   local tbl = util.split(str)
   local ret = false
   local i = 1

   while i <= #tbl do
      local w = tbl[i]
      local s = string.lower(w)

      -- Wand of Magic Missile, skip the 'of'
      if s == 'of' then
         goto end_of_loop
      end

      spellfinder = function(str, tbl, pos, i)
         ok, s = pcall(r.find_spawn_first, r, r.v35.spell, str)
         if ok and s ~= nil then
            self.spell = s
            return true
         end

         return false
      end

      -- Attempt to find and parse the spell
      ok, count = util.lookahead(tbl, i, spellfinder)
      if ok then
         i = i + (count - 1)
         goto end_of_loop
      end

      -- Attempt to parse caster level
      ok, cl = self:_parse_casterlevel(w)
      if ok then
         self.casterlevel = base.tonumber(cl)
         goto end_of_loop
      end

      ok, ch = self:_parse_charges(w)
      if ok then
         self.charges = base.tonumber(ch)
         goto end_of_loop
      end

      ok, sl = self:_parse_spelllevel(w)
      if ok then
         self.spelllevel = base.tonumber(sl)
         goto end_of_loop
      end

::end_of_loop::
      i = i + 1
   end

   self:_update_spelllevel()
   self:_update_price()

   return ret
end

function wand:_update_price()
   local price = 0
   local craftprice = 0

   local sl = 1
   local cl = 1

   -- A non-charged wand costs nothing
   if not self.spell or not self.spelllevel or not self.casterlevel then
      return 0
   end

   -- Usually 0 as very little spells have component cost
   price = price + self.spell.components.gold * 50
   -- usually 0 as very little spells have XP cost
   -- Here the same rule applies: 1 XP = 5 gp
   price = price + self.spell.components.xp * 50 * 5

   if self.spelllevel <= 0 then
      sl = 1
   else
      sl = self.spelllevel
   end

   if self.casterlevel <= 0 then
      cl = 1
   else
      cl = self.casterlevel
   end

   self.craftprice = price + (rules.wand.BASE_CRAFT_PRICE * sl * cl)
   self.itemprice = price + (rules.wand.BASE_ITEM_PRICE * sl * cl)

   -- "A 0-level spell is half the value of a 1st-level spell for determining
   --  price." src: http://www.d20srd.org/srd/magicItems/creatingMagicItems.htm
   -- So as long as spell level is 0 the cost is halved.
   if self.spelllevel == 0 then
      self.craftprice = self.craftprice / 2
      self.itemprice = self.itemprice / 2
   end
end

function wand:price()
   local sv = stacked_value:new()

   sv:add(self.itemprice or 0, 'spell')

   return sv:value(), sv
end

function wand:string(extended)
   local e = extended or false
   local s = 'Wand'

   if self.spell then
      s = s .. ' of ' .. self.spell.name
   end

   if self.casterlevel then
      s = s .. ' [CL:' .. self.casterlevel .. ']'
   end

   if self.spelllevel then
      s = s .. ' [SL:' .. self.spelllevel .. ']'
   end

   if self.charges then
      s = s .. ' [' .. self.charges .. ']'
   end

   s = s .. ' (' .. self:price() .. ' GP)'

   s = s .. magical_item._add_craftcost(self, e)

   return s
end

return wand
