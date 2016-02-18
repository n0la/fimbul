---@module fimbul.eh.cartridge_template

local cartridge_template = {}

function cartridge_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = 'cartridge'

   return neu
end

return cartridge_template
