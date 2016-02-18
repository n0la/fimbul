---@module fimbul.eh.race

local race_template = {}

function race_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'race'

   return neu
end

return race_template
