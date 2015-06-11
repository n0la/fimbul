---@module fimbul.v35.armor_template

local armor_template = {}

function armor_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.armor then
      neu = neu.armor
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "armor"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return armor_template
