---@module fimbul.v35.character

local character = {}

local creature = require("fimbul.v35.creature")

function character:new()
   local neu = creature:new()

   setmetatable(neu, self)
   self.__index = self

   neu.player = ""

   return neu
end
