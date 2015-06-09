---@module fimbul.v35.weapon_template

local weapon_template = {}

function weapon_template:new(y)
   local neu = y or {}

   -- Do a deep resolve
   if neu.weapon then
      neu = neu.weapon
   end

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "weapon"

   -- TODO: Check if everything is here and in proper order
   -- neu:check()

   return neu
end

return weapon_template
