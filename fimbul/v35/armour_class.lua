--- @module fimbul.v35.armour_class

local armour_class = {}
package.loaded["fimbul.v35.armour_class"] = armour_class

local stacked_value = require("fimbul.stacked_value")
local rules = require("fimbul.v35.rules")

armour_class = stacked_value:new(rules.stacking_rules)

function armour_class:load(o)
end

function armour_class:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return armour_class
