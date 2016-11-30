---@module fimbul.v35.spell_template

local spell_template = {}

function spell_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "spell"

   return neu
end

return spell_template
