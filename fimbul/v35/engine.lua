--- @module fimbul.v35.engine

local stacked_value = require("fimbul.stacked_value")
local engine = {}

engine.types = {
   BASE = "base",
   DODGE = "dodge",
   CIRCUMSTANCE = "circumstance",
   NEGATIVE_LEVEL = "negative_level",
}

engine.stacking_rules = {
      stack = stacked_value.DONT_STACK,
      -- http://www.d20srd.org/srd/theBasics.htm
      --  "Dodge bonuses and circumstance bonuses however, do stack
      --   with one another unless otherwise specified."
      [engine.types.DODGE] = stacked_value.STACK,
      [engine.types.CIRCUMSTANCE] = stacked_value.STACK,
      -- This is a handy hack to stack up negative levels
      [engine.types.NEGATIVE_LEVEL] = stacked_value.STACK,
}

function engine.stacked_value(c)
   -- Compose a new stacked value with proper v35 rules
   -- in place. Mostly regarding dodge and circumstance
   return stacked_value.new(c or stacked_value, engine.stacking_rules)
end

function engine:new()
   local neu = {}

   setmetatable(neu, self)
   neu.__index = self

   return neu
end

return engine
