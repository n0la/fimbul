---@module fimbul.encounter_template

local encounter_template = {}

function encounter_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "encounter"

   return neu
end

return encounter_template
