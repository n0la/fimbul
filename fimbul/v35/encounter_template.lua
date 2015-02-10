---@module fimbul.v35.encounter_template

local encounter_template = {}

function encounter_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.encounter then
      neu = neu.encounter
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "encounter"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return encounter_template
