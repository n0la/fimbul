--- @module fimbul.dice_expression

local dice_expression = {}

local base = _G
local math = math

local dice = require("fimbul.dice")

function dice_expression.d(str)
   local D = dice:parse(str)

   if not D then
      return
   end

   local ev, res = D:roll()
   return ev
end

function dice_expression.evaluate(str)
   local s = "return (" .. str .. ")"
   local context = {}

   -- Build sandbox
   context.d = dice_expression.d
   -- Commonly used aliases
   context.dice = context.d
   context.roll = context.d
   -- Math functions especially rounding functions like floor() and ceil()
   -- are always needed to compute values.
   context.math = math

   local chunk, e = base.load(s, nil, "t", context)

   if not chunk then
      error(e)
   end

   local ret = chunk()

   return tonumber(ret)
end

return dice_expression
