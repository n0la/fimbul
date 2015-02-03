--- @module fimbul.v35.attribute

local base = _G
local math = require("math")

local stacked_value = require("fimbul.stacked_value")
local engine = require("fimbul.v35.engine")

local attribute = stacked_value:new()

function attribute:modifier()
   local v = self:value()
   return math.floor((v - 10) / 2)
end

function attribute:new()
   -- Override and provide with default stacking rules
   local neu = engine.stacked_value(attribute)
   return neu
end

return attribute
