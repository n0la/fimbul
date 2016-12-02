---@module fimbul.v35.wand_template

local wand_template = {}

function wand_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "wand"

   return neu
end

return wand_template
