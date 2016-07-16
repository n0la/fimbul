---@module fimbul.eh.magazine_template

local magazine_template = {}

function magazine_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'magazine'

   return neu
end

return magazine_template
