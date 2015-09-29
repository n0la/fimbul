---@module fimbul.v35.artifact_template

local artifact_template = {}

function artifact_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "artifact"

   return neu
end

return artifact_template
