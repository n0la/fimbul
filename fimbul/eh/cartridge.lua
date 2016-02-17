---@module fimbul.eh.cartridge

local cartridge = {}

local util = require('fimbul.util')

function cartridge:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu._damage = {}
   neu._cost = {}
   neu._weight = 0.0
   neu.stopped_by = 0
   neu._amount = 0

   return neu
end

function cartridge:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Cartridge should have a name')
   end

   neu.name = t.name
   neu.template = t

   neu.aliases = util.deepcopy(t.aliases) or {}
   neu._damage = util.deepcopy(t.damage) or {}

   neu._cost = t.cost or 0.1
   neu._weight = t.weight or 0.01

   neu.stopped_by = t.stopped_by or 1

   neu._amount = 1

   return neu
end

function cartridge:_parse_attributes(r, t)
   for i = 1, #t do
      local w = t[i]
      local s = string.lower(w)

      -- Parse amount as-in 5.56x45 (30) being thirty bullets.
      cap = string.match(s, '^%(([%d]+)%)$')
      if cap ~= nil then
         cap = tonumber(cap)
         self:amount(cap)
      end
   end
end

function cartridge:cost()
   return self._cost * self:amount()
end

function cartridge:weight()
   return self._weight * self:amount()
end

function cartridge:amount(value)
   if value == nil then
      return self._amount
   else
      if value < 1 then
         error('Amount may not be less than zero.')
      end
      self._amount = value
   end
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

   s = self.name .. ' [' .. table.concat(self:damage_dice(), ', ') .. ']'

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
