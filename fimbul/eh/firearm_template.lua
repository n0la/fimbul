---@module fimbul.eh.firearm_template

local firearm_template = {}

function firearm_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'firearm'

   return neu
end

return firearm_template
