--- @module fimbul.v35.artefact

local base = _G

local table = require('table')
local magical_item = require('fimbul.v35.magical_item')
local stacked_value = require('fimbul.stacked_value')

local util = require('fimbul.util')

local artefact = magical_item:new()

function artefact:new(y)
   local neu = magical_item:new(y)

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function artefact:spawn(r, t)
   local neu = artefact:new()

   if t.type == nil then
      error('Artefact does not specify a base type.')
   end

   neu.template = t

   neu.name = t.name
   neu.type = t.type
   neu.aliases = util.shallowcopy(t.aliases)

   -- Magic related things
   neu.school = t.school
   neu.grade = t.grade
   neu.cl = t.cl
   neu.feats = util.shallowcopy(t.feats)
   neu.spells = util.shallowcopy(t.spells)
   neu.craft = util.shallowcopy(t.craft) or {}

   neu.cost = t.price
   neu.description = t.description

   return neu
end

-- Override magical_item:price()
function artefact:price()
   local pr = stacked_value:new({stack = true})

   pr:add(self.cost or 0, 'base')

   return pr:value(), pr
end

-- Override magical_item:craft_price()
function artefact:craft_price()
   if self.craft.price then
      local pr = stacked_value:new({stack = true})
      pr:add(self.craft.price, 'base')

      return pr:value(), pr
   else
      return self:price()
   end
end

-- Override crafting XP which is usually specified.
function artefact:craft_xp()
   if self.craft.xp then
      return self.craft.xp
   else
      return magical_item.craft_xp(self)
   end
end

-- Material cost is different. You usually don't pay that.
function artefact:craft_materials()
   if not self.craft.materials then
      return 0
   end

   return self.craft.materials
end

function artefact:string(extended)
   local e = extended or false
   local fmt = magical_item._string(self, e)
   local str = ''
   local res = ''

   res = string.format(fmt, str)

   if e then
      if self.description then
         res = res .. "\n" .. self.description
      end
   end

   return res
end

return artefact
