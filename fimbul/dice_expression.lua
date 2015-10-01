--- @module fimbul.dice_expression

local dice_expression = {}

local base = _G

local math = require("math")
local dice = require("fimbul.dice")

function dice_expression.d(str)
   local D = dice:parse(str)

   if not D then
      error("The dice " .. str .. " did not parse correctly.")
   end

   local ev, res = D:roll()
   return ev
end

function dice_expression.evaluate(str, ctx)
   local s = "return (" .. str .. ")"
   local context = ctx or {}

   -- Build sandbox
   context.d = dice_expression.d
   -- Commonly used aliases
   context.dice = context.d
   context.roll = context.d
   -- Math functions especially rounding functions like floor() and ceil()
   -- are always needed to compute values.
   context.math = math

   local chunk, e = base.load(s, "expression", "t", context)

   if not chunk then
      error(e)
   end

   local ret = chunk()

   return tonumber(ret)
end

function dice_expression.evaluate_save(str)
   local ok, e = pcall(dice_expression.evaluate, str)
   return ok, e
end

return dice_expression
