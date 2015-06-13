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
      -- Negative levels do stack
      [rules.types.NEGATIVE_LEVEL] = stacked_value.STACK,
}

rules.MAX_MODIFIER = 10

rules.armors = {}
-- PHB 126
rules.armors.masterwork_price = 250
-- DMG 216
rules.armors.modifier_prices = {
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

-- Per PHB armor == shields in this regard
rules.shields = rules.armors

rules.weapons = {}
-- PHB 122
rules.weapons.masterwork_price = 300
-- DMG 222
rules.weapons.modifier_prices = {
   [0] = 0,
   [1] = 2000,
   [2] = 8000,
   [3] = 18000,
   [4] = 32000,
   [5] = 50000,
   [6] = 72000,
   [7] = 98000,
   [8] = 128000,
   [9] = 162000,
   [10] = 200000,
}

rules.crafting = {}
-- How many GP per day
rules.crafting.GP_PER_DAY = 1000
-- XP cost: 1/25
rules.crafting.XP_COST = 0.04
-- Material cost: half
rules.crafting.MATERIAL_COST = 0.5

return rules
