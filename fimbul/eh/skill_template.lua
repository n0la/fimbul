---@module fimbul.eh.skill_template

local skill_template = {}

function skill_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'skill'

   return neu
end

return skill_template
