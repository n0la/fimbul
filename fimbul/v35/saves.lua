--- @module fimbul.v35.saves

local saves = {}

local engine = require("fimbul.v35.engine")

function saves:load(o)
end

function saves:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.fortitude = engine.stacked_value()
   neu.reflex = engine.stacked_value()
   neu.will = engine.stacked_value()

   return neu
end

return saves
