---@module fimbul.v35.monster

local creature = require("fimbul.v35.creature")

local monster = creature:new()

function monster:new()
   local neu = creature:new()

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return monster
