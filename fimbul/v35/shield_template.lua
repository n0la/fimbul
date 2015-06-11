---@module fimbul.v35.shield_template

local shield_template = {}

function shield_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.shield then
      neu = neu.shield
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "shield"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return shield_template
