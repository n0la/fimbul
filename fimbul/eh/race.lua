---@module fimbul.eh.race

local race = {}

local hitzones = require('fimbul.eh.hitzones')
local dice = require('fimbul.dice')
local util = require('fimbul.util')

function race:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function race:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Race should at least have a name')
   end

   neu.name = t.name
   neu.template = t

   neu._hitzone = hitzones:new(t.hitzone or {})

   return neu
end

function race:hitzone()
   return self._hitzone
end

return race
