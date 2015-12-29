---@module fimbul.eh.background_template

local background_template = {}

function background_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'background'

   return neu
end

return background_template
