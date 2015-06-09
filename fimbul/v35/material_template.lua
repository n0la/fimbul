---@module fimbul.v35.material_template

local material_template = {}

function material_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.material then
      neu = neu.material
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "material"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return material_template
