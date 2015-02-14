---@module fimbul.v35.character_template

local character_template = {}

function character_template:new(y)
   local neu = y or {}

   -- Deep resolve required :-(
   if neu.character then
      neu = neu.character
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "character"

   -- TODO: Error checking

   return neu
end

return character_template
