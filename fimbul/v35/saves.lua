--- @module fimbul.v35.saves

local saves = {}

local stacked_value = require("fimbul.stacked_value")
local rules = require("fimbul.v35.rules")

function saves:load(o)
end

function saves:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.fortitude = stacked_value:new(rules.stacking_rules)
   neu.reflex = stacked_value:new(rules.stacking_rules)
   neu.will = stacked_value:new(rules.stacking_rules)

   return neu
end

return saves
