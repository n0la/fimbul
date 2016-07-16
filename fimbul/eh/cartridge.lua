---@module fimbul.eh.cartridge

local item = require('fimbul.eh.item')
local util = require('fimbul.util')

local cartridge = item:new()

function cartridge:new(y)
   local neu = item:new(y)

   setmetatable(neu, self)
   self.__index = self

   neu._damage = {}
   neu.stopped_by = 0

   return neu
end

function cartridge:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Cartridge should have a name')
   end

   neu._name = t.name
   neu.template = t

   item.set_attributes(neu, t)

   neu._damage = util.deepcopy(t.damage) or {}
   neu.stopped_by = t.stopped_by or 1

   return neu
end

function cartridge:name()
   return self._name
end

function cartridge:damage()
   return self._damage
end

function cartridge:damage_dice()
   dt = {}

   for i = 1, #self._damage do
      table.insert(dt, self._damage[i].dice)
   end

   return dt
end

function cartridge:string(extended)
   local e = extended or false
   local s

   s = self:aliases()[1]

   if e then
      s = s .. ' [' .. table.concat(self:damage_dice(), ', ') .. ']'
   end

   if self:amount() > 1 then
      s = s .. " (" .. self:amount() .. ")"
   end

   if e then
      s = s .. "\n"
      s = s .. "Cost: " .. self:cost() .. "\n"
      s = s .. "Weight: " .. self:weight() .. "\n"
      s = s .. "Stopped by: " .. self.stopped_by
   end

   return s
end

return cartridge
