--- @module fimbul.v35.saves

local engine = require("fimbul.v35.engine")
local saves = {}

function saves:new()
   local neu = {}

   setmetatable(neu, self)
   neu.__index = self

   neu.fortitude = engine.stacked_value()
   neu.reflex = engine.stacked_value()
   neu.will = engine.stacked_value()

   return neu
end

return saves
