local lore_template = {}

function lore_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'lore'

   return neu
end

return lore_template
