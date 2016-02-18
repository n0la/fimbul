---@module fimbul.eh.hitzones

local hitzones = {}

local base = _G

local util = require('fimbul.util')
local dice = require('fimbul.dice')

local hitzone = require('fimbul.eh.hitzone')

function hitzones:new(y)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._dice = dice:new({amount = 2, sides = 6})
   neu._zones = {}

   if y ~= nil then
      neu._dice = dice:parse(y.dice or '2d6')

      for _, z in base.pairs(y.zones) do
         local hz = hitzone:new(z)
         table.insert(neu._zones, hz)
      end
   end

   return neu
end

function hitzones:zones()
   return self._zones
end

function hitzones:dice()
   return self._dice
end

function hitzones:roll_zone()
   local res = self:dice():roll()

   for _, z in base.pairs(self:zones()) do
      if util.contains(z:results(), res) then
         return z
      end
   end

   return nil
end


return hitzones
