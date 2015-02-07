--- @module fimbul.v35.rules

local rules = {}

local stacked_value = require("fimbul.stacked_value")

rules.types = {
   BASE = "base",
   DODGE = "dodge",
   CIRCUMSTANCE = "circumstance",
   NEGATIVE_LEVEL = "negative_level",
}

rules.stacking_rules = {
      stack = stacked_value.DONT_STACK,
      -- http://www.d20srd.org/srd/theBasics.htm
      --  "Dodge bonuses and circumstance bonuses however, do stack
      --   with one another unless otherwise specified."
      [rules.types.DODGE] = stacked_value.STACK,
      [rules.types.CIRCUMSTANCE] = stacked_value.STACK,
      -- This is a handy hack to stack up negative levels
      [rules.types.NEGATIVE_LEVEL] = stacked_value.STACK,
}

return rules
