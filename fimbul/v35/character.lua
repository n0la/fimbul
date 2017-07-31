---@module fimbul.v35.character

local creature = require("fimbul.v35.creature")

local character = creature:new()

function character:new(t)
   local neu = creature:new()

   setmetatable(neu, self)
   self.__index = self

   neu.player = ""

   return neu
end

return character
