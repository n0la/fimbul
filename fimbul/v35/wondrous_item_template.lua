---@module fimbul.v35.wondrous_item_template

local wondrous_item_template = {}

function wondrous_item_template:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   neu.templatetype = "wondrous_item"

   return neu
end

return wondrous_item_template
