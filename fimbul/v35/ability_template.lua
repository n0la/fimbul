---@module fimbul.v35.ability_template

local ability_template = {}

function ability_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.ability then
      neu = neu.ability
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "ability"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return ability_template
