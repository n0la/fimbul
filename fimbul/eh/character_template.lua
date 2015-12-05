---@module fimbul.eh.character_template

local character_template = {}

function character_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   neu.__index = self

   neu.templatetype = 'character'

   return neu
end

return character_template
