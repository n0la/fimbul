--- @module fimbul.stacked_value

-- This class implements a value that is composed of other values.
-- These sub values have stacking rules applied to them which determine
-- whether these values stack together in the final rule.

-- Example (d20srd):
--  A character as 16 strength composed of:
--    12 base
--     2 enhancement bonus from item
--     4 enhancement bonus from Bull's Strength
-- The two enhancement boni do not stack together, only the highest applies
-- and thus the final strength score is 16.
-- It is important though to keep the +2 around. Because if you remove the +4
-- bonus (the spell runs out) the character should be back to 14.
--
-- This class does not support "sources". So if perhaps the race grants
-- +2 inherent bonus to strength, and so does a class those two do not stack
-- if they are both called "inherent". Use different types for that like "race"
-- and "class"
--

local sv = {}

local base = _G
local table = require("table")

local util = require("fimbul.util")

local pretty = require("pl.pretty")

local stacked_value = {}

sv.STACK = true
sv.DONT_STACK = false
sv.DIFFERENT_VALUES = "value"

function stacked_value:add(v, t)
   assert(v, "No value given")
   -- Assume "base" type
   local ty = t or "base"

   local value = { value = v, type = ty }

   -- Add value
   table.insert(self.values, value)
   return self:count()
end

function stacked_value:remove_if(f)
   for i = #self.values,1,-1 do
      local value = self.values[i]
      if f(value) then
         table.remove(self.values, i)
      end
   end
end

function stacked_value:remove_all(v, t)
   self:remove_if(function(value)
         return value.value == v and value.type == t
   end)
end

function stacked_value:count()
   return #self.values
end

function stacked_value:value(v)
   local values = {}

   for _, v in base.ipairs(self.values) do
      local rule = self:stacking_rule(v.type)

      if values[v.type] == nil then
         if rule == sv.DIFFERENT_VALUES then
            values[v.type] = { v.value }
         else
            values[v.type] = v.value
         end
      else
         if rule == sv.DONT_STACK then
            -- Only store highest
            if v.value > values[v.type] then
               values[v.type] = v.value
            end
         elseif rule == sv.STACK then
            -- Add it as they do stack
            values[v.type] = values[v.type] + v.value
         elseif rule == sv.DIFFERENT_VALUES then
            -- Different values stack, so check the list if it is there
            -- and otherwise add it
            if not util.contains(values[v.type], v.value) then
               table.insert(values[v.type], v.value)
            end
         end
      end
   end

   local count = 0

   for _, v in base.pairs(values) do
      if type(v) == "table" then
         for _, c in base.pairs(v) do
            count = count + c
         end
      else
         count = count + v
      end
   end

   return count
end

function stacked_value:stacking_rule(t)
   local ty = t or "stack"

   if self.rules[ty] ~= nil then
      return self.rules[ty]
   elseif self.rules.stack ~= nil then
      return self.rules.stack
   else
      return false
   end
end

function sv.new(rules)
   local neu = {}
   local r = rules or { stack = false }

   stacked_value.__index = stacked_value
   setmetatable(neu, stacked_value)

   neu.values = {}
   neu.rules = r

   return neu
end

return sv
