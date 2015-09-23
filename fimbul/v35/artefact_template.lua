---@module fimbul.v35.artefact_template

local artefact_template = {}

function artefact_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "artefact"

   return neu
end

return artefact_template
