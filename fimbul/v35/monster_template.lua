---@module fimbul.v35.monster_template

local monster_template = {}

function monster_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.monster then
      neu = neu.monster
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "monster"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return monster_template
