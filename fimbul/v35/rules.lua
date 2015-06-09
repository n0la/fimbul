--- @module fimbul.v35.rules

local rules = {}

local stacked_value = require("fimbul.stacked_value")

rules.types = {
   BASE = "base",
   DODGE = "dodge",
   CIRCUMSTANCE = "circumstance",
   NEGATIVE_LEVEL = "negative_level",
}

rules.damage_types = {
   POSITIVE = "positive",
   NEGATIVE = "negative",
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

rules.modifier_prices = {
   [0] = 0,
   [1] = 1000,
   [2] = 4000,
   [3] = 9000,
   [4] = 16000,
   [5] = 25000,
   [6] = 36000,
   [7] = 49000,
   [8] = 64000,
   [9] = 81000,
   [10] = 100000,
}

return rules
