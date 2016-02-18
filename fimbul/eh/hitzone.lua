---@module fimbul.eh.hitzone

local hitzone = {}

local base = _G
local util = require('fimbul.util')

function hitzone:new(y)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   if y ~= nil then
      neu._name = y.name or error('No name specified')
      neu._damagemultiplier = y.damage_multiplier or 1
      neu._abilitydamages = util.shallowcopy(y.ability_damages or {})
      neu._results = util.shallowcopy(y.results or {})
   end

   return neu
end

function hitzone:name()
   return self._name
end

function hitzone:damage_multiplier()
   return self._damagemultiplier
end

function hitzone:ability_damages()
   return self._abilitydamages
end

function hitzone:results()
   return self._results
end

function hitzone:modify_damage(sv)
   if self:damage_multiplier() == 1 then
      return
   end

   local d = sv:value()
   local m

   m = d * self:damage_multiplier()

   -- Add as another one that stacks
   sv:add((m - d), 'zone')
end

return hitzone
